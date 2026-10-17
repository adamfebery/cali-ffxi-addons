--[[
    Zone map lookup + automatic calibration.

    Map images come from sortienav (tools/extract_maps.py), which already
    extracted every zone map from the DATs to sortienav/maps/<zone>_<map>.png
    and listed them in sortienav/data/zone_maps.lua.

    Calibration needs no clicking: windower.ffxi.get_position(x, y, z) asks
    the client which grid square ("(H-8)") any game position falls in. FFXI
    maps are 512 px with a 15x15 grid of 32 px cells starting at pixel 16, so
    finding where the grid letter (or number) changes along an axis pins down
    two grid lines, and two grid lines give that axis's scale and offset.
]]

local map = {}

local ROOT = windower.windower_path .. 'addons/sortienav/'
local MAP_DIR = ROOT .. 'maps/'

local GRID_U0 = 16     -- pixel of the A / 1 grid edge on a 512 px map
local GRID_CELL = 32   -- pixels per grid cell

local STEP = 2         -- yalms per step while walking for a grid line
local LIMIT = 2500     -- give up after walking this far
local BISECT = 24      -- bisection rounds (2 / 2^24 yalm, plenty)

local zone_maps = nil
local cal_cache = {}   -- ['zone:map'] = {su, ou, sv, ov} or false

local function load_zone_maps()
    if zone_maps ~= nil then return zone_maps end
    local chunk = loadfile(ROOT .. 'data/zone_maps.lua')
    local ok, result = false, nil
    if chunk then ok, result = pcall(chunk) end
    zone_maps = (ok and type(result) == 'table') and result or false
    return zone_maps
end

-- Map number the client uses for this spot (floor / sub-map), or nil
function map.map_id(x, y, z)
    if not windower.ffxi.get_map_data then return nil end
    local ok, id = pcall(windower.ffxi.get_map_data, x, y, z)
    if ok and type(id) == 'number' then return id end
    return nil
end

-- Grid square text for a game position, e.g. "(H-8)", or nil
function map.grid(x, y, z)
    local ok, p = pcall(windower.ffxi.get_position, x, y, z)
    if ok and type(p) == 'string' and p:match('%a%-%d') then return p end
    return nil
end

-- 0-based column (A = 0) and row (1 = 0) of a game position
local function cell(x, y, z)
    local p = map.grid(x, y, z)
    if not p then return nil end
    local letter, number = p:match('(%a)%-(%d+)')
    return letter:upper():byte() - 65, tonumber(number) - 1
end

-- Walk from (x0, y0) along one axis (1 = x/columns, 2 = y/rows) in `dir`
-- and return up to `need` grid lines as {t = game coord, px = pixel}.
local function walk(axis, x0, y0, z, want_map, dir, need)
    local function idx(t)
        local x, y = x0, y0
        if axis == 1 then x = t else y = t end
        if want_map and map.map_id(x, y, z) ~= want_map then return nil end
        local c, r = cell(x, y, z)
        if axis == 1 then return c end
        return r
    end

    local found = {}
    local cur_t = (axis == 1) and x0 or y0
    local cur_i = idx(cur_t)
    if cur_i == nil then return found end

    local travelled = 0
    while #found < need and travelled < LIMIT do
        local next_t = cur_t + dir * STEP
        travelled = travelled + STEP
        local next_i = idx(next_t)
        if next_i == nil then break end   -- left the map

        if next_i ~= cur_i then
            local lo, hi = cur_t, next_t
            local clean = true
            for _ = 1, BISECT do
                local mid = (lo + hi) / 2
                local mid_i = idx(mid)
                if mid_i == cur_i then
                    lo = mid
                elseif mid_i == next_i then
                    hi = mid
                else
                    clean = false
                    break
                end
            end
            if clean and math.abs(next_i - cur_i) == 1 then
                found[#found + 1] = {
                    t = (lo + hi) / 2,
                    px = GRID_U0 + GRID_CELL * math.max(next_i, cur_i),
                }
            end
            cur_i = next_i
        end
        cur_t = next_t
    end
    return found
end

-- Scale and offset for one axis: pixel = s * game + o
local function solve_axis(axis, x, y, z, want_map)
    local fwd = walk(axis, x, y, z, want_map, 1, 2)
    local back = walk(axis, x, y, z, want_map, -1, 2)
    local candidates = {fwd[1], back[1], fwd[2], back[2]}

    local p1, p2
    for _, p in ipairs(candidates) do
        if p then
            if not p1 then
                p1 = p
            elseif p.px ~= p1.px and math.abs(p.t - p1.t) > 0.5 then
                p2 = p
                break
            end
        end
    end
    if not p2 then return nil end

    local s = (p2.px - p1.px) / (p2.t - p1.t)
    return s, p1.px - s * p1.t
end

local RETRY = 10   -- seconds before retrying a failed calibration

local function calibrate(key, x, y, z, want_map)
    local cached = cal_cache[key]
    if cached then
        if not cached.failed then return cached end
        if os.clock() - cached.failed < RETRY then return nil end
    end
    local su, ou = solve_axis(1, x, y, z, want_map)
    local sv, ov = solve_axis(2, x, y, z, want_map)
    if su and sv then
        cal_cache[key] = {su = su, ou = ou, sv = sv, ov = ov}
    else
        cal_cache[key] = {failed = os.clock()}
        return nil
    end
    return cal_cache[key]
end

function map.reset()
    cal_cache = {}
end

-- Image + pixel position for a game position in a zone.
-- Returns {image, width, height, map, u, v} or nil, reason
function map.locate(zone_id, x, y, z)
    local maps = load_zone_maps()
    if not maps then return nil, 'Map images not found (needs addons/sortienav)' end

    local zm = maps[zone_id]
    if not zm or not zm.floors or #zm.floors == 0 then
        return nil, 'No map image for this zone'
    end

    local map_id = map.map_id(x, y, z)
    local floor
    for _, f in ipairs(zm.floors) do
        if map_id and f.id == tostring(map_id) then floor = f break end
    end
    -- One image, or the client wouldn't say which map: use the first
    if not floor and (#zm.floors == 1 or map_id == nil) then floor = zm.floors[1] end
    if not floor then
        return nil, string.format('No image for map %s of this zone', tostring(map_id))
    end

    local key = tostring(zone_id) .. ':' .. floor.id
    local cal = calibrate(key, x, y, z, map_id)
    if not cal then return nil, 'Could not line up the map grid here' end

    local w = floor.map.width or 512
    local h = floor.map.height or 512
    return {
        image = MAP_DIR .. floor.map.image,
        width = w,
        height = h,
        map = map_id,
        label = floor.label,
        u = (cal.su * x + cal.ou) * w / 512,
        v = (cal.sv * y + cal.ov) * h / 512,
    }
end

-- Pixel position on an already-located map, or nil if it's on another map
function map.project(loc, zone_id, x, y, z)
    if loc.map and map.map_id(x, y, z) ~= loc.map then return nil end
    local other = map.locate(zone_id, x, y, z)
    if not other or other.image ~= loc.image then return nil end
    return other.u, other.v
end

return map
