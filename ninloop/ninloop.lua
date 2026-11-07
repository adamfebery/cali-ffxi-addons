_addon.name     = 'ninloop'
_addon.author   = 'Adam'
_addon.version  = '1.0.0'
_addon.commands = {'ninloop', 'nl'}

require('logger')
res = require('resources')

local NINJUTSU = 39

-- spell name -> tier-specific tool item id (lifted from GearSwap statics.lua)
local tool_map = {
    ['Aisha: Ichi'] = 2555,
    ['Dokumori: Ichi'] = 1191,
    ['Dokumori: Ni'] = 1191,
    ['Dokumori: San'] = 1191,
    ['Doton: Ichi'] = 1170,
    ['Doton: Ni'] = 1170,
    ['Doton: San'] = 1170,
    ['Gekka: Ichi'] = 8803,
    ['Hojo: Ichi'] = 1185,
    ['Hojo: Ni'] = 1185,
    ['Hojo: San'] = 1185,
    ['Huton: Ichi'] = 1167,
    ['Huton: Ni'] = 1167,
    ['Huton: San'] = 1167,
    ['Hyoton: Ichi'] = 1164,
    ['Hyoton: Ni'] = 1164,
    ['Hyoton: San'] = 1164,
    ['Jubaku: Ichi'] = 1182,
    ['Jubaku: Ni'] = 1182,
    ['Jubaku: San'] = 1182,
    ['Kakka: Ichi'] = 2644,
    ['Katon: Ichi'] = 1161,
    ['Katon: Ni'] = 1161,
    ['Katon: San'] = 1161,
    ['Kurayami: Ichi'] = 1188,
    ['Kurayami: Ni'] = 1188,
    ['Kurayami: San'] = 1188,
    ['Migawari: Ichi'] = 2970,
    ['Monomi: Ichi'] = 2553,
    ['Monomi: Ni'] = 2553,
    ['Myoshu: Ichi'] = 2642,
    ['Raiton: Ichi'] = 1173,
    ['Raiton: Ni'] = 1173,
    ['Raiton: San'] = 1173,
    ['Suiton: Ichi'] = 1176,
    ['Suiton: Ni'] = 1176,
    ['Suiton: San'] = 1176,
    ['Tonko: Ichi'] = 1194,
    ['Tonko: Ni'] = 1194,
    ['Tonko: San'] = 1194,
    ['Utsusemi: Ichi'] = 1179,
    ['Utsusemi: Ni'] = 1179,
    ['Utsusemi: San'] = 1179,
    ['Yain: Ichi'] = 8804,
    ['Yurin: Ichi'] = 2643,
}

-- spell name -> universal fuda item id
local universal_tool_map = {
    ['Aisha: Ichi'] = 2973,
    ['Dokumori: Ichi'] = 2973,
    ['Dokumori: Ni'] = 2973,
    ['Dokumori: San'] = 2973,
    ['Doton: Ichi'] = 2971,
    ['Doton: Ni'] = 2971,
    ['Doton: San'] = 2971,
    ['Gekka: Ichi'] = 2972,
    ['Hojo: Ichi'] = 2973,
    ['Hojo: Ni'] = 2973,
    ['Hojo: San'] = 2973,
    ['Huton: Ichi'] = 2971,
    ['Huton: Ni'] = 2971,
    ['Huton: San'] = 2971,
    ['Hyoton: Ichi'] = 2971,
    ['Hyoton: Ni'] = 2971,
    ['Hyoton: San'] = 2971,
    ['Jubaku: Ichi'] = 2973,
    ['Jubaku: Ni'] = 2973,
    ['Jubaku: San'] = 2973,
    ['Kakka: Ichi'] = 2972,
    ['Katon: Ichi'] = 2971,
    ['Katon: Ni'] = 2971,
    ['Katon: San'] = 2971,
    ['Kurayami: Ichi'] = 2973,
    ['Kurayami: Ni'] = 2973,
    ['Kurayami: San'] = 2973,
    ['Migawari: Ichi'] = 2972,
    ['Monomi: Ichi'] = 2972,
    ['Myoshu: Ichi'] = 2972,
    ['Raiton: Ichi'] = 2971,
    ['Raiton: Ni'] = 2971,
    ['Raiton: San'] = 2971,
    ['Suiton: Ichi'] = 2971,
    ['Suiton: Ni'] = 2971,
    ['Suiton: San'] = 2971,
    ['Tonko: Ichi'] = 2972,
    ['Tonko: Ni'] = 2972,
    ['Tonko: San'] = 2972,
    ['Utsusemi: Ichi'] = 2972,
    ['Utsusemi: Ni'] = 2972,
    ['Utsusemi: San'] = 2972,
    ['Yain: Ichi'] = 2972,
    ['Yurin: Ichi'] = 2973,
}

-- tool item id -> toolbag item id
local toolbag = {
    [1161] = 5308,   -- Uchitake -> Toolbag (Uchi)
    [1164] = 5309,   -- Tsurara -> Toolbag (Tsura)
    [1167] = 5310,   -- Kawahori-Ogi -> Toolbag (Kawa)
    [1170] = 5311,   -- Makibishi -> Toolbag (Maki)
    [1173] = 5312,   -- Hiraishin -> Toolbag (Hira)
    [1176] = 5313,   -- Mizu-Deppo -> Toolbag (Mizu)
    [1179] = 5314,   -- Shihei -> Toolbag (Shihe)
    [1182] = 5315,   -- Jusatsu -> Toolbag (Jusa)
    [1185] = 5316,   -- Kaginawa -> Toolbag (Kagi)
    [1188] = 5317,   -- Sairui-Ran -> Toolbag (Sai)
    [1191] = 5318,   -- Kodoku -> Toolbag (Kodo)
    [1194] = 5319,   -- Shinobi-Tabi -> Toolbag (Shino)
    [2553] = 5417,   -- Sanjaku-Tenugui -> Toolbag (Sanja)
    [2555] = 5734,   -- Soshi -> Toolbag (Soshi)
    [2642] = 5863,   -- Kabenro -> Toolbag (Kaben)
    [2643] = 5864,   -- Jinko -> Toolbag (Jinko)
    [2644] = 5865,   -- Ryuno -> Toolbag (Ryuno)
    [2970] = 5866,   -- Mokujin -> Toolbag (Moku)
    [2971] = 5867,   -- Inoshishinofuda -> Toolbag (Ino)
    [2972] = 5868,   -- Shikanofuda -> Toolbag (Shika)
    [2973] = 5869,   -- Chonofuda -> Toolbag (Cho)
    [8803] = 6265,   -- Ranka -> Toolbag (Ranka)
    [8804] = 6266,   -- Furusumi -> Toolbag (Furu)
}

local settings = {
    delay   = 0.4,    -- pause after a cast lands before starting the next
    tier    = 'all',  -- all | ichi | ni | san
    range   = 20,     -- max yalms to target
    restock = true,   -- auto-use toolbags when a tool runs out
}

local running   = false
local spells    = {}
local idx       = 0
local state     = 'idle'      -- idle | casting
local next_try  = 0
local deadline  = 0
local started   = false
local start_by  = 0
local blocked   = {}          -- spell id -> os.clock() to retry after

local function me() return windower.ffxi.get_player() end

local function inv_count(id)
    local bag = windower.ffxi.get_items('inventory')
    if not bag then return 0 end
    local n = 0
    for i = 0, (bag.max or 80) do
        local it = bag[i]
        if type(it) == 'table' and it.id == id then n = n + (it.count or 0) end
    end
    return n
end

-- returns ready, primary tool id, universal tool id
local function tools_for(sp)
    local t, u = tool_map[sp.en], universal_tool_map[sp.en]
    if t and inv_count(t) > 0 then return true, t, u end
    if u and inv_count(u) > 0 then return true, t, u end
    return false, t, u
end

local function try_restock(t, u)
    for _, id in ipairs({t, u}) do
        local bag = id and toolbag[id]
        if bag and inv_count(bag) > 0 then
            windower.send_command('input /item "' .. res.items[bag].en .. '" <me>')
            return true
        end
    end
    return false
end

local function build()
    spells, idx = {}, 0
    local p = me()
    if not p then return end
    local known = windower.ffxi.get_spells()
    for id, sp in pairs(res.spells) do
        if known[id] and sp.skill == NINJUTSU and sp.targets:contains('Enemy') then
            local mlv, slv = sp.levels[p.main_job_id], sp.levels[p.sub_job_id]
            local ok = (mlv and mlv <= p.main_job_level) or (slv and slv <= p.sub_job_level)
            if ok and (settings.tier == 'all'
                       or sp.en:lower():match(':%s*' .. settings.tier .. '$')) then
                table.insert(spells, sp)
            end
        end
    end
    table.sort(spells, function(a, b) return a.id < b.id end)
end

local function target_ok()
    local t = windower.ffxi.get_mob_by_target('t')
    return t and t.valid_target and t.hpp > 0 and t.spawn_type == 16
       and math.sqrt(t.distance) <= settings.range
end

local function cast(sp)
    state    = 'casting'
    started  = false
    start_by = os.clock() + 1.5
    deadline = os.clock() + (sp.cast_time or 2) + 3
    windower.send_command('input /ma "' .. sp.en .. '" <t>')
end

windower.register_event('prerender', function()
    if not running then return end
    local now = os.clock()

    if state == 'casting' then
        -- cast never started (no tools, silenced, moving) or ran long: bail fast
        if (not started and now > start_by) or now > deadline then
            state, next_try = 'idle', now + 0.2
        end
        return
    end

    if now < next_try then return end
    local p = me()
    if not p or p.status == 2 or p.status == 3 then next_try = now + 1 return end
    if #spells == 0 then next_try = now + 2 return end
    if not target_ok() then next_try = now + 0.5 return end

    local recasts = windower.ffxi.get_spell_recasts()
    for _ = 1, #spells do
        idx = (idx % #spells) + 1
        local sp = spells[idx]
        if (recasts[sp.recast_id] or 1) == 0 and (blocked[sp.id] or 0) < now then
            local ready, t, u = tools_for(sp)
            if ready then
                cast(sp)
                return
            elseif settings.restock and try_restock(t, u) then
                next_try = now + 1.5
                return
            else
                blocked[sp.id] = now + 30
            end
        end
    end
    next_try = now + 0.3   -- everything on cooldown, poll again shortly
end)

windower.register_event('action', function(act)
    if not running or state ~= 'casting' then return end
    local p = me()
    if not p or act.actor_id ~= p.id then return end
    if act.category == 8 then          -- begin casting
        started = true
    elseif act.category == 4 then      -- finished casting magic
        state, next_try = 'idle', os.clock() + settings.delay
    end
end)

windower.register_event('job change', function() build() end)
windower.register_event('login', function() build() end)

windower.register_event('addon command', function(cmd, ...)
    cmd = (cmd or 'help'):lower()
    local args = {...}

    if cmd == 'start' or cmd == 'on' then
        build()
        if #spells == 0 then
            error('no enemy-target ninjutsu known for this job/tier')
            return
        end
        running, state, next_try, blocked = true, 'idle', 0, {}
        local out = {}
        for _, sp in ipairs(spells) do table.insert(out, sp.en) end
        log('looping ' .. #spells .. ' spells: ' .. table.concat(out, ', '))

    elseif cmd == 'stop' or cmd == 'off' then
        running, state = false, 'idle'
        log('stopped')

    elseif cmd == 'tier' then
        settings.tier = (args[1] or 'all'):lower()
        build()
        log('tier = ' .. settings.tier .. ' (' .. #spells .. ' spells)')

    elseif cmd == 'delay' then
        settings.delay = tonumber(args[1]) or settings.delay
        log('delay = ' .. settings.delay)

    elseif cmd == 'restock' then
        settings.restock = not settings.restock
        log('toolbag restock ' .. (settings.restock and 'on' or 'off'))

    elseif cmd == 'list' then
        build()
        for _, sp in ipairs(spells) do
            local ready, t = tools_for(sp)
            log(('%-16s %s'):format(sp.en, ready and 'ok'
                or ('NO TOOL (' .. (t and res.items[t].en or '?') .. ')')))
        end

    else
        log('//nl start | stop | tier <all|ichi|ni|san> | delay <sec> | restock | list')
    end
end)
