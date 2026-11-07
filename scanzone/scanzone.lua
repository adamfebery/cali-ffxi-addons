_addon.name = 'ScanZone'
_addon.version = '2.0'
_addon.author = 'Project Tako (GUI: Chronicle widgets by Jintawk)'
_addon.commands = {'scanzone', 'sz'}

require('pack')
local bit = require('bit')
local config = require('config')
local packets = require('packets')
local res = require('resources')
local dats = require('datmap')
local widgets = require('ui/widgets')
local theme = require('ui/theme')
local zonemap = require('zonemap')

---------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------
local defaults = {
    pos = {x = 200, y = 150},
    visible_on_load = false,
    scan_timeout = 3,       -- seconds to wait for a 0x00E reply before giving up
    scan_all_delay = 0.3,   -- seconds between requests when scanning a whole list
    scan_all_max = 50,      -- cap on how many entities "Scan all" will request
    show_map = true,        -- map pane on the right of the window
    map_size = 330,         -- map pane size in pixels (before UI scale)
}

local settings = config.load(defaults)

-- Row indicator states (reuse Chronicle's status icons/colors)
local STATE_IDLE = 'not_started'      -- grey: never scanned
local STATE_PENDING = 'active'        -- amber: waiting for reply
local STATE_FOUND = 'repeat'          -- cyan: server answered, entity is up
local STATE_GONE = 'uncompletable'    -- orange: despawned / no reply

---------------------------------------------------------------------------
-- Zone data (read from the zone's entity DAT)
---------------------------------------------------------------------------
local zone = {
    id = nil,
    entries = {},     -- every named entity in the DAT
    by_index = {},    -- target index -> entry
}

local function dat_root()
    local path = windower.ffxi_path
    if path:sub(-1) ~= '\\' and path:sub(-1) ~= '/' then
        path = path .. '\\'
    end
    return path
end

-- Each DAT record is 32 bytes: 28-byte null-padded name, then a 4-byte
-- little-endian server id. Target index is id & 0xFFF.
local function read_dat(path, out)
    local file = io.open(path, 'rb')
    if not file then return false end
    while true do
        local data = file:read(32)
        if not data or #data < 32 then break end
        local name = data:sub(1, 28):match('^[^%z]*')
        local b1, b2, b3, b4 = data:byte(29, 32)
        local id = b1 + b2 * 0x100 + b3 * 0x10000 + b4 * 0x1000000
        if id ~= 0 and name ~= '' then
            out[#out + 1] = {
                name = name,
                id = id,
                index = id % 0x1000,
                status = STATE_IDLE,
            }
        end
    end
    file:close()
    return true
end

local function load_zone(zone_id)
    zone.id = zone_id
    zone.entries = {}
    zone.by_index = {}

    local list = zone_id and dats[zone_id]
    if type(list) ~= 'table' then return end

    local root = dat_root()
    for _, rel in ipairs(list) do
        if not read_dat(root .. rel, zone.entries) then
            windower.add_to_chat(167, '[ScanZone] Could not open ' .. root .. rel)
        end
    end
    for _, entry in ipairs(zone.entries) do
        zone.by_index[entry.index] = entry
    end
end

local function zone_name(zone_id)
    local z = zone_id and res.zones[zone_id]
    return z and z.en or ('Zone ' .. tostring(zone_id))
end

local function find(name_to_find)
    local needle = name_to_find:lower()
    local results = {}
    for _, entry in ipairs(zone.entries) do
        if entry.name:lower():find(needle, 1, true) then
            results[#results + 1] = entry
        end
    end
    return results
end

---------------------------------------------------------------------------
-- Formatting helpers
---------------------------------------------------------------------------
local function distance_to(live)
    if not live or not live.x then return nil end
    local me = windower.ffxi.get_mob_by_target('me')
    if not me then return nil end
    local dx, dy = live.x - me.x, live.y - me.y
    return math.sqrt(dx * dx + dy * dy)
end

local function status_name(status)
    local s = status and res.statuses[status]
    return s and s.en or tostring(status)
end

local function row_sub(entry)
    local parts = {string.format('0x%03X   ID %d', entry.index, entry.id)}
    local live = entry.live
    if entry.status == STATE_PENDING then
        parts[#parts + 1] = 'scanning...'
    elseif entry.status == STATE_GONE then
        parts[#parts + 1] = live and live.note or 'not up'
    elseif live then
        if live.hpp then parts[#parts + 1] = string.format('HP %d%%', live.hpp) end
        local d = distance_to(live)
        if d then parts[#parts + 1] = string.format('%.1fy', d) end
    end
    return table.concat(parts, '   ')
end

---------------------------------------------------------------------------
-- UI
---------------------------------------------------------------------------
local ui = {
    panel = nil,
    visible = false,
    dirty = false,
    last_refresh = 0,
}

local filtered = {}
local selected = nil
local scan_all_token = 0

local function update_details()
    if not ui.details then return end
    local e = selected
    if not e then
        ui.details:text('Click an entity in the list to scan it.')
        return
    end

    local lines = {string.format('%s   (index 0x%03X  /  ID %d)', e.name, e.index, e.id)}
    local live = e.live

    if e.status == STATE_PENDING then
        lines[#lines + 1] = 'Waiting for server reply...'
    elseif e.status == STATE_GONE then
        lines[#lines + 1] = live and live.note or 'Not spawned.'
    elseif not live then
        lines[#lines + 1] = 'Not scanned yet.'
    end

    if live and e.status ~= STATE_PENDING then
        if live.hpp or live.status then
            lines[#lines + 1] = string.format('HP: %s     Status: %s',
                live.hpp and (live.hpp .. '%') or '?', status_name(live.status))
        end
        if live.x then
            local d = distance_to(live)
            lines[#lines + 1] = string.format('Pos: (%.2f, %.2f, %.2f)', live.x, live.y, live.z)
            lines[#lines + 1] = string.format('Grid: %s     Dist: %s',
                zonemap.grid(live.x, live.y, live.z) or '?', d and string.format('%.1fy', d) or '?')
        end
        if live.seen then
            lines[#lines + 1] = string.format('Last update: %ds ago (%s)',
                os.time() - live.seen, live.source or 'packet')
        end
    end

    ui.details:text(table.concat(lines, '\n'))
end

local function refresh_rows()
    for _, entry in ipairs(filtered) do
        entry.npc_info = row_sub(entry)
    end
    if ui.list then ui.list:_refresh() end
    update_details()
    ui.dirty = false
    ui.last_refresh = os.clock()
end

local function apply_filter(text)
    text = text or (ui.input and ui.input:text()) or ''
    filtered = (text == '') and zone.entries or find(text)
    for _, entry in ipairs(filtered) do
        entry.npc_info = row_sub(entry)
    end
    if ui.list then ui.list:set_items(filtered) end
    if ui.count then
        if #zone.entries == 0 then
            ui.count:text(dats[zone.id] and 'Could not read the zone DAT.' or 'No DAT mapped for this zone.')
        elseif text == '' then
            ui.count:text(string.format('%d entities in zone DAT', #zone.entries))
        else
            ui.count:text(string.format('%d of %d match "%s"', #filtered, #zone.entries, text))
        end
    end
end

local function refresh_zone_header()
    if ui.header then
        ui.header:text(zone_name(zone.id))
    end
end

---------------------------------------------------------------------------
-- Scanning
---------------------------------------------------------------------------
local function scan(entry)
    if not entry then return end
    local token = os.clock()
    entry.pending = token
    entry.status = STATE_PENDING

    local p = packets.new('outgoing', 0x016, {['Target Index'] = entry.index})
    packets.inject(p)

    coroutine.schedule(function()
        if entry.pending == token then
            entry.pending = nil
            entry.status = STATE_GONE
            entry.live = entry.live or {}
            entry.live.note = 'No reply (not spawned?)'
            ui.dirty = true
        end
    end, settings.scan_timeout)

    ui.dirty = true
end

-- Use whatever the client already knows about a nearby entity
local function seed_from_memory(entry)
    local mob = windower.ffxi.get_mob_by_index(entry.index)
    if mob and mob.id == entry.id and mob.valid_target then
        entry.live = {
            x = mob.x, y = mob.y, z = mob.z,
            hpp = mob.hpp, status = mob.status,
            seen = os.time(), source = 'client memory',
        }
    end
end

local function select_entry(entry)
    selected = entry
    seed_from_memory(entry)
    scan(entry)
    refresh_rows()
end

local function scan_all()
    scan_all_token = scan_all_token + 1
    local token = scan_all_token
    local queue = {}
    for i = 1, math.min(#filtered, settings.scan_all_max) do
        queue[i] = filtered[i]
    end
    if #filtered > settings.scan_all_max then
        windower.add_to_chat(207, string.format('[ScanZone] Scanning the first %d of %d entries. Narrow the search to scan the rest.',
            settings.scan_all_max, #filtered))
    end

    coroutine.schedule(function()
        for _, entry in ipairs(queue) do
            if token ~= scan_all_token then return end
            scan(entry)
            coroutine.sleep(settings.scan_all_delay)
        end
    end, 0)
end

---------------------------------------------------------------------------
-- Map pane
---------------------------------------------------------------------------
-- Moves a panel child to a new offset so later panel drags keep it there
local function set_child_offset(widget, ox, oy)
    for _, child in ipairs(ui.panel._children) do
        if child.widget == widget then
            child.offset_x, child.offset_y = ox, oy
            break
        end
    end
    local px, py = ui.panel:get_pos()
    widget:pos(px + ox, py + oy)
end

-- Centres a marker of `size` px on map pixel (u, v); hides it off the map
local function place(widget, size, u, v, loc)
    local o = ui.map_origin
    local px = u * o.size / loc.width
    local py = v * o.size / loc.height
    if px < 0 or py < 0 or px > o.size or py > o.size then
        widget:hide()
        return nil
    end
    local ox = math.floor(o.x + px - size / 2 + 0.5)
    local oy = math.floor(o.y + py - size / 2 + 0.5)
    set_child_offset(widget, ox, oy)
    widget:show()
    return ox, oy
end

local function hide_markers()
    for _, dot in ipairs(ui.map_dots) do dot:hide() end
    ui.map_target_ring:hide()
    ui.map_target:hide()
    ui.map_player_ring:hide()
    ui.map_player:hide()
    ui.map_name:hide()
end

local function render_map()
    ui.map_last = os.clock()
    if not ui.map_img or not ui.visible or ui.panel:is_collapsed() then return end
    local s = theme.s

    hide_markers()

    local me = windower.ffxi.get_mob_by_target('me')
    local target = selected and selected.live and selected.live.x and selected or nil

    -- Show the target's map if we have one, otherwise the map you're on
    local fx, fy, fz
    if target then
        fx, fy, fz = target.live.x, target.live.y, target.live.z
    elseif me then
        fx, fy, fz = me.x, me.y, me.z
    end
    if not fx then
        ui.map_img:hide()
        ui.map_caption:text('Waiting for a position...')
        return
    end

    local loc, err = zonemap.locate(zone.id, fx, fy, fz)
    if not loc then
        ui.map_img:hide()
        ui.map_caption:text(err)
        return
    end
    if ui.map_path ~= loc.image then
        ui.map_img:path(loc.image)
        ui.map_path = loc.image
    end
    ui.map_img:alpha(255)
    ui.map_img:show()

    -- Everything else in the current search that is up
    local n = 0
    for _, e in ipairs(filtered) do
        if n >= #ui.map_dots then break end
        if e ~= target and e.status == STATE_FOUND and e.live and e.live.x then
            local u, v = zonemap.project(loc, zone.id, e.live.x, e.live.y, e.live.z)
            if u then
                n = n + 1
                place(ui.map_dots[n], s(5), u, v, loc)
            end
        end
    end

    local caption = {loc.label or 'Map'}

    if me then
        local u, v
        if target then
            u, v = zonemap.project(loc, zone.id, me.x, me.y, me.z)
        else
            u, v = loc.u, loc.v
        end
        if u then
            place(ui.map_player_ring, s(9), u, v, loc)
            place(ui.map_player, s(5), u, v, loc)
            caption[#caption + 1] = 'You ' .. (zonemap.grid(me.x, me.y, me.z) or '?')
        else
            caption[#caption + 1] = 'You: other floor'
        end
    end

    if target then
        place(ui.map_target_ring, s(11), loc.u, loc.v, loc)
        local ox, oy = place(ui.map_target, s(7), loc.u, loc.v, loc)
        if ox then
            ui.map_name:text(target.name)
            set_child_offset(ui.map_name, ox + s(10), oy - s(4))
            ui.map_name:show()
        end
        caption[#caption + 1] = target.name .. ' ' .. (zonemap.grid(fx, fy, fz) or '?')
        if target.status == STATE_GONE then
            caption[#caption + 1] = '(last known)'
        end
    end

    ui.map_caption:text(table.concat(caption, '   '))
end

---------------------------------------------------------------------------
-- UI construction
---------------------------------------------------------------------------
local function save_settings()
    if ui.panel then
        settings.pos.x, settings.pos.y = ui.panel:get_pos()
    end
    settings:save()
end

local function build_ui()
    local s = theme.s
    local pad = theme.padding
    local left_w = s(460)
    local cw = left_w - pad * 2
    local map_px = settings.show_map and s(settings.map_size) or 0
    local width = settings.show_map and (left_w + map_px + pad) or left_w
    local top = theme.title_height + pad

    ui.panel = widgets.Panel({
        x = settings.pos.x,
        y = settings.pos.y,
        width = width,
        height = 200,
        title = 'ScanZone',
        title_font = theme.font_headline,
        title_size = theme.title_size,
        on_close = function()
            ui.visible = false
            save_settings()
        end,
    })

    ui.header = widgets.Label({
        text = zone_name(zone.id),
        font = theme.font_headline,
        size = theme.header_title_size,
        color = theme.text_bright,
    })
    ui.panel:add_child(ui.header, pad, top)

    ui.count = widgets.Label({
        size = theme.header_sub_size,
        font = theme.font_label,
        color = theme.text_dim,
        bold = false,
    })
    ui.panel:add_child(ui.count, pad, top + s(22))

    local input_y = top + s(42)
    ui.input = widgets.TextInput({
        width = s(300),
        placeholder = 'Search names (e.g. ???, Tonberry, Bhumi)...',
        on_change = function(text) apply_filter(text) end,
    })
    ui.panel:add_child(ui.input, pad, input_y)

    local clear_btn = widgets.Button({
        text = 'Clear',
        size = theme.toolbar_button_size,
        padding = 3,
        on_click = function() ui.input:clear() end,
    })
    ui.panel:add_child(clear_btn, pad + s(308), input_y + 1)

    local scan_all_btn = widgets.Button({
        text = 'Scan all',
        size = theme.toolbar_button_size,
        padding = 3,
        color = theme.accent,
        on_click = scan_all,
    })
    ui.panel:add_child(scan_all_btn, pad + s(358), input_y + 1)

    local list_y = input_y + theme.toolbar_height + s(8)
    local rows = 8
    ui.list = widgets.QuestRowList({
        width = cw,
        visible_count = rows,
        on_item_click = function(entry) select_entry(entry) end,
    })
    ui.panel:add_child(ui.list, pad, list_y)

    local details_y = list_y + rows * (theme.quest_row_height + theme.quest_row_gap) + s(8)
    local heading = widgets.Label({
        text = 'SCAN RESULT',
        font = theme.font_label,
        size = theme.guide_section_size,
        color = theme.guide.section_color,
    })
    ui.panel:add_child(heading, pad, details_y)

    ui.details = widgets.Label({
        font = theme.font_label,
        size = theme.guide_meta_value_size,
        bold = false,
    })
    ui.panel:add_child(ui.details, pad, details_y + s(16))

    local buttons_y = details_y + s(112)
    local rescan_btn = widgets.Button({
        text = 'Rescan',
        size = theme.toolbar_button_size,
        padding = 3,
        color = theme.accent,
        on_click = function() if selected then scan(selected) end end,
    })
    ui.panel:add_child(rescan_btn, pad, buttons_y)

    local copy_btn = widgets.Button({
        text = 'Copy index',
        size = theme.toolbar_button_size,
        padding = 3,
        on_click = function()
            if selected then
                windower.copy_to_clipboard(string.format('%X', selected.index))
                windower.add_to_chat(207, string.format('[ScanZone] Copied %X (%s)', selected.index, selected.name))
            end
        end,
    })
    ui.panel:add_child(copy_btn, pad + s(60), buttons_y)

    local bottom = buttons_y + s(26)

    -- Map pane: zone map image with dots for you, the selected entity and
    -- anything else in the current search that the server says is up.
    -- Prims draw in creation order, so the image goes first.
    if settings.show_map then
        local mx, my = left_w, top
        ui.map_origin = {x = mx, y = my, size = map_px}

        local map_bg = widgets.Image({width = map_px, height = map_px, red = 10, green = 25, blue = 50, alpha = 200})
        ui.panel:add_child(map_bg, mx, my)

        ui.map_img = widgets.Image({width = map_px, height = map_px, alpha = 0})
        ui.panel:add_child(ui.map_img, mx, my)

        ui.map_dots = {}
        for i = 1, 30 do
            local dot = widgets.Image({width = s(5), height = s(5),
                red = theme.accent.red, green = theme.accent.green, blue = theme.accent.blue, alpha = 230})
            ui.panel:add_child(dot, mx, my)
            ui.map_dots[i] = dot
        end

        local function marker(size, c)
            local w = widgets.Image({width = size, height = size, red = c[1], green = c[2], blue = c[3], alpha = 255})
            ui.panel:add_child(w, mx, my)
            return w
        end
        ui.map_target_ring = marker(s(11), {0, 0, 0})
        ui.map_target = marker(s(7), {255, 183, 2})
        ui.map_player_ring = marker(s(9), {0, 0, 0})
        ui.map_player = marker(s(5), {255, 255, 255})

        ui.map_name = widgets.Label({
            font = theme.font_label,
            size = theme.card_sub_size,
            color = theme.accent_amber,
            bg_alpha = 170, bg_red = 3, bg_green = 14, bg_blue = 34,
            padding = 1,
        })
        ui.panel:add_child(ui.map_name, mx, my)

        ui.map_caption = widgets.Label({
            font = theme.font_label,
            size = theme.card_sub_size,
            color = theme.text_dim,
            bold = false,
        })
        ui.panel:add_child(ui.map_caption, mx, my + map_px + s(4))

        bottom = math.max(bottom, my + map_px + s(22))
    end

    ui.panel:content_height(bottom - theme.title_height)

    apply_filter('')
    update_details()
end

local function show_ui()
    if not ui.panel then build_ui() end
    ui.panel:show()
    ui.visible = true
    if ui.map_img then render_map() end
end

-- Rebuild the window (e.g. map pane toggled), keeping the search text
local function rebuild_ui()
    local was_visible = ui.visible
    local text = ui.input and ui.input:text() or ''
    if ui.panel then
        save_settings()
        ui.panel:destroy()
    end
    ui.panel, ui.input, ui.list, ui.details, ui.header, ui.count = nil, nil, nil, nil, nil, nil
    ui.map_img, ui.map_path, ui.map_origin, ui.map_dots = nil, nil, nil, nil
    ui.visible = false

    build_ui()
    if text ~= '' then
        ui.input._value = text
        ui.input:_update_display()
        apply_filter(text)
    end
    if was_visible then show_ui() end
end

local function hide_ui()
    if ui.panel then
        save_settings()
        ui.panel:hide()
    end
    ui.visible = false
end

local function toggle_ui()
    if ui.visible then hide_ui() else show_ui() end
end

local function on_zone(zone_id)
    scan_all_token = scan_all_token + 1
    selected = nil
    zonemap.reset()
    load_zone(zone_id)
    refresh_zone_header()
    if ui.input and ui.input:text() ~= '' then
        ui.input:clear()   -- triggers apply_filter('')
    else
        apply_filter('')
    end
    update_details()
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
windower.register_event('keyboard', function(dik, down, flags, blocked)
    -- Enter finishes typing in the search box
    if dik == 0x1C and down and ui.input and ui.input._focused then
        ui.input:blur()
        return true
    end
    return widgets.handle_keyboard(dik, down, flags, blocked)
end)

windower.register_event('prerender', function()
    widgets.tick_inputs()
    -- Throttle row repaints; 0x00E packets can arrive many times per second
    if ui.dirty and ui.visible and os.clock() - ui.last_refresh > 0.25 then
        refresh_rows()
    end
    if ui.map_img and ui.visible and os.clock() - (ui.map_last or 0) > 0.2 then
        render_map()
    end
end)

windower.register_event('incoming chunk', function(id, original)
    if id ~= 0x00E then return end

    local index = original:unpack('H', 0x08 + 1)
    local entry = zone.by_index[index]
    if not entry then return end

    local p = packets.parse('incoming', original)
    local mask = p['Mask']
    entry.pending = nil
    entry.live = entry.live or {}
    local live = entry.live
    live.seen = os.time()
    live.source = 'server reply'
    live.note = nil

    if bit.band(mask, 0x01) ~= 0 then
        live.x, live.y, live.z = p['X'], p['Y'], p['Z']
    end
    if bit.band(mask, 0x04) ~= 0 then
        live.hpp = p['HP %']
        live.status = p['Status']
    end

    if bit.band(mask, 0x20) ~= 0 or (live.hpp == 0 and bit.band(mask, 0x04) ~= 0) then
        entry.status = STATE_GONE
        live.note = 'Despawned / out of range'
    else
        entry.status = STATE_FOUND
    end

    ui.dirty = true
end)

windower.register_event('zone change', function(new_id)
    on_zone(new_id)
end)

windower.register_event('login', function()
    config.reload(settings)
    on_zone(windower.ffxi.get_info().zone)
end)

windower.register_event('logout', function()
    save_settings()
    scan_all_token = scan_all_token + 1
end)

windower.register_event('unload', function()
    save_settings()
    widgets.cleanup()
end)

---------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------
windower.register_event('addon command', function(...)
    local args = {...}
    local cmd = args[1] and args[1]:lower() or 'toggle'
    local rest = table.concat(args, ' ', 2)

    if cmd == 'toggle' then
        toggle_ui()
    elseif cmd == 'show' then
        show_ui()
    elseif cmd == 'hide' then
        hide_ui()
    elseif cmd == 'reset' then
        settings.pos.x, settings.pos.y = 200, 150
        if ui.panel then ui.panel:pos(200, 150) end
        settings:save()
    elseif cmd == 'map' then
        settings.show_map = not settings.show_map
        settings:save()
        windower.add_to_chat(207, '[ScanZone] Map pane: ' .. (settings.show_map and 'ON' or 'OFF'))
        if ui.panel then rebuild_ui() end
    elseif cmd == 'mapsize' then
        local n = tonumber(args[2] or '')
        if not n or n < 150 or n > 800 then
            windower.add_to_chat(167, '[ScanZone] Usage: //sz mapsize <150-800>  (now ' .. settings.map_size .. ')')
            return
        end
        settings.map_size = n
        settings:save()
        if ui.panel then rebuild_ui() end
    elseif cmd == 'autoshow' then
        settings.visible_on_load = not settings.visible_on_load
        settings:save()
        windower.add_to_chat(207, '[ScanZone] Auto-show on load: ' .. (settings.visible_on_load and 'ON' or 'OFF'))
    elseif cmd == 'find' then
        if rest == '' then
            windower.add_to_chat(167, '[ScanZone] Usage: //sz find <name>')
            return
        end
        local results = find(rest)
        if #results == 0 then
            windower.add_to_chat(128, string.format('[ScanZone] Did not find any entities with name: %s', rest))
        end
        for _, e in ipairs(results) do
            windower.add_to_chat(128, string.format('[ScanZone] %s  TargetIndex: 0x%X', e.name, e.index))
        end
        -- Mirror the search in the window
        show_ui()
        ui.input._value = rest
        ui.input:_update_display()
        apply_filter(rest)
    elseif cmd == 'scan' then
        local index = tonumber(args[2] or '', 16)
        if not index then
            windower.add_to_chat(167, '[ScanZone] Usage: //sz scan <hex index>')
            return
        end
        local entry = zone.by_index[index]
        if not entry then
            -- Not in the DAT (e.g. dynamic entity); track it ad hoc
            entry = {name = string.format('Index 0x%X', index), id = 0, index = index, status = STATE_IDLE}
            zone.by_index[index] = entry
        end
        show_ui()
        select_entry(entry)
    elseif cmd == 'help' then
        windower.add_to_chat(207, 'ScanZone commands:')
        windower.add_to_chat(207, '  //sz               - Toggle the window')
        windower.add_to_chat(207, '  //sz show/hide     - Show or hide the window')
        windower.add_to_chat(207, '  //sz find <name>   - Search the zone DAT (chat + window)')
        windower.add_to_chat(207, '  //sz scan <hex>    - Ask the server about a target index')
        windower.add_to_chat(207, '  //sz map           - Toggle the map pane')
        windower.add_to_chat(207, '  //sz mapsize <px>  - Map pane size (default 330)')
        windower.add_to_chat(207, '  //sz reset         - Reset window position')
        windower.add_to_chat(207, '  //sz autoshow      - Toggle showing the window on load')
    else
        windower.add_to_chat(167, '[ScanZone] Unknown command "' .. cmd .. '". Use //sz help')
    end
end)

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
local info = windower.ffxi.get_info()
if info.logged_in then
    load_zone(info.zone)
end

if settings.visible_on_load then
    show_ui()
end
