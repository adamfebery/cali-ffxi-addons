-- gearbar - FFXIV-style clickable buttons for your GearSwap modes, weapons
-- and weapon skills. The bar rebuilds itself for each job from
-- jobs/<Name>/<JOB>.lua or jobs/<JOB>.lua.
--
-- A button lights up (gold ring) when:
--   equip = {...}   those items are equipped            (weapons)
--   on / off        GearSwap's chat line says so         (modes, DT)
-- and dims when the weapon its `needs` names isn't in hand (weapon skills).
--
-- Art is drawn by tools/make_art.py. A button whose label has no drawn face
-- yet still works: it gets its kind's plain frame with a text label.
--
-- //gb help for commands. Alt + drag moves the bar.

_addon.name = 'gearbar'
_addon.author = 'Char1'
_addon.version = '1.0.0'
_addon.commands = {'gearbar', 'gb'}

require('tables')
require('strings')
require('sets')
require('chat')                -- string.strip_format
local config = require('config')
local texts = require('texts')
local images = require('images')
local res = require('resources')

local defaults = {
    visible = true,
    x = 400,
    y = 820,
    size = 52,           -- button size in pixels (art is 64, scaled)
    gap = 6,             -- between buttons
    group_gap = 14,      -- between kinds (weapons | modes | weapon skills)
    row_gap = 10,        -- between stacked rows (row=2 sits above row 1)
    menu_timeout = 8,    -- seconds an open pop-out menu stays up untouched
    tooltips = true,
}
local settings = config.load(defaults)

local ART = windower.addon_path .. 'art/'
local ART_SIZE, GLOW = 64, 8        -- must match tools/make_art.py
local FACE_INSET = 3                 -- make_art.py FACE_INSET: 3 for the ffxi style, 6 for --style ffxiv

local function say(msg)
    windower.add_to_chat(207, 'gearbar: ' .. msg)
end

-- 75 -> "1:15", 12.2 -> "13" (cooldown counters and tooltips).
local function format_secs(secs)
    secs = math.ceil(secs)
    if secs >= 60 then
        return ('%d:%02d'):format(math.floor(secs / 60), secs % 60)
    end
    return tostring(secs)
end

---------------------------------------------------------------------------
-- Job files
---------------------------------------------------------------------------

local function load_lua(path)
    if not windower.file_exists(path) then
        return nil
    end
    local chunk, err = loadfile(path)
    if not chunk then
        say(err)
        return nil
    end
    local ok, result = pcall(chunk)
    if not ok then
        say(tostring(result))
        return nil
    end
    return result
end

-- Character folder first, like GearSwap does.
local function load_job(name, job)
    return load_lua(windower.addon_path .. 'jobs/' .. name .. '/' .. job .. '.lua')
        or load_lua(windower.addon_path .. 'jobs/' .. job .. '.lua')
end

local function safe(label)
    return (label:gsub('[^%w]', '_'))
end

---------------------------------------------------------------------------
-- Bar
---------------------------------------------------------------------------

local bar = {job = nil, buttons = {}, plate = nil, hits = {}}
local tooltip = texts.new('', {
    bg = {alpha = 225, red = 14, green = 22, blue = 52},
    text = {size = 10, font = 'Consolas', red = 235, green = 238, blue = 248,
            stroke = {width = 1, alpha = 160, red = 0, green = 0, blue = 0}},
    padding = 5,
    flags = {draggable = false},
})

-- A short tag above the job plate (e.g. the BLU spell set), set with
-- //gb plate <key> <text> - normally sent by another addon (bluesets).
-- Buttons with `label_on = '<key>'` light while that key is shown.
local plate_label = texts.new('', {
    bg = {alpha = 215, red = 14, green = 22, blue = 52},
    text = {size = 9, font = 'Consolas', red = 217, green = 180, blue = 90,
            stroke = {width = 1, alpha = 160, red = 0, green = 0, blue = 0}},
    padding = 2,
    flags = {bold = true, draggable = false},
})

local function new_image(path)
    return images.new({
        texture = {path = path, fit = false},
        color = {alpha = 255, red = 255, green = 255, blue = 255},
        draggable = false,
    })
end

local OVERLAYS = {'shade', 'active', 'ready', 'dim', 'hover', 'pressed'}

local function destroy_bar()
    for _, b in ipairs(bar.buttons) do
        for _, key in ipairs({'face', 'shade', 'active', 'ready', 'dim', 'hover', 'pressed'}) do
            if b[key] then b[key]:destroy() end
        end
        if b.text then b.text:destroy() end
        if b.cd_text then b.cd_text:destroy() end
    end
    if bar.plate then bar.plate:destroy() end
    bar.buttons, bar.plate, bar.hits, bar.menu = {}, nil, {}, nil
    tooltip:hide()
    plate_label:hide()
end

---------------------------------------------------------------------------
-- Pop-out menus. A button with `opens = 'storms'` swaps the bar for the
-- buttons marked `menu = 'storms'` plus a BACK button; picking one, BACK, or
-- settings.menu_timeout seconds untouched puts the normal bar back.
-- A menu button with `stay = true` leaves the menu open when picked (for
-- rotations), and an opener's own `menu_timeout` overrides the setting.
---------------------------------------------------------------------------

-- Is this button on screen right now?
local function on_screen(b)
    if bar.menu then
        return b.menu == bar.menu or b.is_back == true
    end
    return b.menu == nil and not b.is_back
end

-- The recast timer a button's command uses, from its /ja or /ma name:
-- returns recast id and 'ability' / 'spell', or nil (weapon skills,
-- GearSwap commands). Abilities sharing a timer (Phantom Rolls, Quick Draw)
-- share its id, so they shade together - just as the game treats them.
local function recast_for(cmd)
    -- `send <name> ...` runs on another character, so your recasts don't apply.
    if cmd and cmd:match('^%s*send%s') then
        return nil
    end
    -- /pet commands (PUP maneuvers, Deploy, Retrieve) are job abilities too.
    local ja = cmd and (cmd:match('/ja "([^"]+)"') or cmd:match('/pet "([^"]+)"'))
    if ja then
        local a = res.job_abilities:with('en', ja)
        return a and a.recast_id, 'ability'
    end
    local ma = cmd and cmd:match('/ma "([^"]+)"')
    if ma then
        local s = res.spells:with('en', ma)
        return s and s.recast_id, 'spell'
    end
end

local function subjob_ok(btn, sub)
    if not btn.subjob then
        return true
    end
    for s in btn.subjob:gmatch('%a+') do
        if s:upper() == (sub or ''):upper() then
            return true
        end
    end
    return false
end

-- Places every image from settings.x / y. Called on build, drag and resize.
-- Row 1 is the main bar (with the job plate); row 2, 3 ... stack above it,
-- lined up with row 1's first button. Within a row, a gap separates each
-- section (a button's `section`, or its kind when it has none).
local function layout()
    local s = settings.size
    local k = s / ART_SIZE
    local glow = math.floor(GLOW * k + 0.5)
    local x0 = settings.x
    bar.hits = {}

    if bar.plate then
        bar.plate:pos(x0, settings.y)
        bar.plate:size(s, s)
        bar.hits[#bar.hits + 1] = {x = x0, y = settings.y, w = s, h = s}
        bar.plate_x = x0
        x0 = x0 + s + settings.group_gap
    end

    local rows = {}   -- row number -> {x =, section =}
    for _, b in ipairs(bar.buttons) do
        b.visible = on_screen(b)
        if b.visible then
            -- Menu items all sit on row 1 (the rows they'd push are hidden).
            local r = bar.menu and 1 or (b.row or 1)
            local cur = rows[r] or {x = x0}
            rows[r] = cur
            -- An open menu is one group, with a gap only after BACK.
            local section = bar.menu and (b.is_back and 'back' or 'menu') or (b.section or b.kind)
            if cur.section and section ~= cur.section then
                cur.x = cur.x + settings.group_gap - settings.gap
            end
            cur.section = section
            local x, y = cur.x, settings.y - (r - 1) * (s + settings.row_gap)
            cur.x = x + s + settings.gap
            b.x, b.y = x, y
            for _, key in ipairs({'face', 'dim', 'hover', 'pressed'}) do
                b[key]:pos(x, y)
                b[key]:size(s, s)
            end
            b.active:pos(x - glow, y - glow)
            b.active:size(s + 2 * glow, s + 2 * glow)
            if b.ready then
                b.ready:pos(x - glow, y - glow)
                b.ready:size(s + 2 * glow, s + 2 * glow)
            end
            if b.text then
                b.text:size(math.max(8, math.floor(s / 4)))
                b.text:pos(x + math.floor(s * 0.16), y + math.floor(s * 0.3))
            end
            if b.cd_text then
                b.cd_text:size(math.max(9, math.floor(s * 0.3)))
            end
            bar.hits[#bar.hits + 1] = {x = x, y = y, w = s, h = s, btn = b}
        end
    end

    -- Show what's on screen; hide everything belonging to the rest (the
    -- overlays come back through refresh / update_cooldowns as needed).
    for _, b in ipairs(bar.buttons) do
        if b.visible then
            if not b.face:visible() then b.face:show() end
            if b.text and not b.text:visible() then b.text:show() end
        else
            b.face:hide()
            if b.text then b.text:hide() end
            if b.cd_text then b.cd_text:hide() end
            for _, key in ipairs(OVERLAYS) do
                if b[key] then b[key]:hide() end
            end
        end
    end
end

local function build()
    destroy_bar()
    local player = windower.ffxi.get_player()
    if not player or not settings.visible then
        return
    end
    local job = player.main_job
    local defs = load_job(player.name, job)
    if bar.job ~= job then
        bar.label, bar.label_text = nil, nil   -- belonged to the old job
    end
    bar.job = job
    if not defs then
        return
    end

    local plate_path = ART .. 'plate_' .. job .. '.png'
    if windower.file_exists(plate_path) then
        bar.plate = new_image(plate_path)
        bar.plate:show()
    end
    -- Ask whoever owns the plate tag to (re)send it, e.g. 'bs announce'.
    if defs.plate_query then
        windower.send_command(defs.plate_query)
    end

    -- Any pop-out menus? Then add the BACK button (first, so it sits at the
    -- left of every open menu).
    local all = {}
    for _, def in ipairs(defs) do
        if def.menu then
            all[1] = {label = 'BACK', kind = 'utility', is_back = true,
                      name = 'Back to the main bar (also closes by itself when left alone)'}
            break
        end
    end
    for _, def in ipairs(defs) do
        all[#all + 1] = def
    end

    for _, def in ipairs(all) do
        if def.label and def.kind and subjob_ok(def, player.sub_job) then
            local b = setmetatable({}, {__index = def})
            b.chat_lit = def.default and true or false
            local face = ART .. 'face_' .. def.kind .. '_' .. safe(def.label) .. '.png'
            if windower.file_exists(face) then
                b.face = new_image(face)
            else
                -- No drawn face yet (new label): plain frame + text label.
                b.face = new_image(ART .. 'frame_' .. def.kind .. '.png')
                b.text = texts.new(def.label, {
                    bg = {alpha = 0},
                    text = {font = 'Bahnschrift', red = 241, green = 243, blue = 250,
                            stroke = {width = 1, alpha = 170, red = 0, green = 0, blue = 0}},
                    flags = {bold = true, draggable = false},
                })
            end
            -- Shown (or not) by layout(), depending on which menu is open.
            -- Cooldown: a dark shade over the face that drains from the
            -- bottom up as the recast runs down, plus the seconds left.
            b.recast_id, b.recast_kind = recast_for(def.cmd)
            if b.recast_id then
                b.shade = images.new({
                    color = {alpha = 170, red = 8, green = 12, blue = 28},
                    texture = {path = '', fit = false},
                    draggable = false,
                })
                b.cd_text = texts.new('', {
                    bg = {alpha = 0},
                    text = {font = 'Consolas', red = 255, green = 255, blue = 255,
                            stroke = {width = 2, alpha = 255, red = 0, green = 0, blue = 0}},
                    flags = {bold = true, draggable = false},
                })
            end
            b.active = new_image(ART .. 'active.png')
            if def.debuff or def.ready_buff then
                b.ready = new_image(ART .. 'ready.png')
            end
            b.dim = new_image(ART .. 'dim.png')
            b.hover = new_image(ART .. 'hover.png')
            b.pressed = new_image(ART .. 'pressed.png')
            bar.buttons[#bar.buttons + 1] = b
        end
    end
    layout()
    if bar.label_text and bar.plate then
        plate_label:show()
    end
end

---------------------------------------------------------------------------
-- State: what's equipped, what GearSwap last said
---------------------------------------------------------------------------

local equipped = {}

local function read_equipment()
    local eq = windower.ffxi.get_items('equipment')
    local out = {}
    if eq then
        for _, slot in ipairs({'main', 'sub', 'range', 'ammo'}) do
            local index, bag = eq[slot], eq[slot .. '_bag']
            if index and index > 0 then
                local item = windower.ffxi.get_items(bag, index)
                local r = item and res.items[item.id]
                if r then
                    out[slot] = r.en:lower()
                end
            end
        end
    end
    equipped = out
end

local function wearing(want)
    for slot, name in pairs(want) do
        if equipped[slot] ~= name:lower() then
            return false
        end
    end
    return true
end

-- Buffs on you, by lowercase name - for `buff` buttons (e.g. a roll).
local my_buffs = {}

local function read_buffs()
    local out = {}
    local player = windower.ffxi.get_player()
    for _, id in ipairs(player and player.buffs or {}) do
        local b = res.buffs[id]
        if b then
            out[b.en:lower()] = true
        end
    end
    my_buffs = out
end

-- True if you have any of these buffs (`needs_buff = {'Light Arts', ...}`).
local function has_any_buff(list)
    for _, name in ipairs(list) do
        if my_buffs[name:lower()] then
            return true
        end
    end
    return false
end

local function is_lit(b)
    if b.label_on then
        return bar.label == b.label_on
    end
    if b.equip then
        return wearing(b.equip)
    end
    if b.buff then
        return my_buffs[b.buff:lower()] == true
    end
    if b.buff_any then
        return has_any_buff(b.buff_any)
    end
    if b.buff_all then
        -- Lit only while every listed buff is up (e.g. a BUFF menu opener).
        for _, name in ipairs(b.buff_all) do
            if not my_buffs[name:lower()] then
                return false
            end
        end
        return true
    end
    return b.chat_lit
end

-- `on` / `off` may be one text or a list that must all appear.
local function says(text, want)
    if type(want) == 'string' then
        return text:find(want, 1, true) ~= nil
    end
    for _, w in ipairs(want) do
        if not text:find(w, 1, true) then
            return false
        end
    end
    return true
end

windower.register_event('incoming text', function(original)
    if #bar.buttons == 0 or not original:find('GearSwap', 1, true) then
        return
    end
    local text = original:strip_format()
    for _, b in ipairs(bar.buttons) do
        if b.on and says(text, b.on) then
            if b.group then
                for _, other in ipairs(bar.buttons) do
                    if other.group == b.group and other.on then
                        other.chat_lit = false
                    end
                end
            end
            b.chat_lit = true
        elseif b.off and says(text, b.off) then
            b.chat_lit = false
        end
    end
end)

---------------------------------------------------------------------------
-- Debuffs on mobs (lights the cyan "ready" glow on buttons with `debuff`)
--
-- Read from the same action packets the Debuffed addon uses, for anyone's
-- spells: "is afflicted with X" carries the status id; Dia / Bio arrive as
-- damage with the effect attached, so those are read from the spell name.
-- Only what the game shows you is seen - a debuff that landed out of range,
-- or before you loaded in, won't light anything.
---------------------------------------------------------------------------

-- mob id -> {[status name, lowercase] = time it's assumed gone}
local mob_debuffs = {}

-- A backstop in case the wear-off message is missed or a higher tier
-- silently replaces it: no debuff is trusted for longer than this.
local DEBUFF_TIMEOUT = 240

-- Job files may use everyday names; the game's status names are these.
local STATUS_ALIASES = {paralyze = 'paralysis', blind = 'blindness'}

local function status_key(name)
    name = name:lower()
    return STATUS_ALIASES[name] or name
end

local LANDED    = S{236, 237, 268, 271}              -- "is afflicted with" etc.
local SPELL_DMG = S{2, 252, 264}                      -- magic damage (+ effect)
local WORE_OFF  = S{64, 204, 206, 350, 531}
local DIED      = S{6, 20, 113, 406, 605, 646}

local function add_debuff(mob_id, name)
    local mob = windower.ffxi.get_mob_by_id(mob_id)
    if not mob or not mob.is_npc then
        return    -- only enemies; a Bio on you shouldn't light Dark Shot
    end
    mob_debuffs[mob_id] = mob_debuffs[mob_id] or {}
    mob_debuffs[mob_id][status_key(name)] = os.clock() + DEBUFF_TIMEOUT
end

windower.register_event('action', function(act)
    for _, target in ipairs(act.targets or {}) do
        for _, a in ipairs(target.actions or {}) do
            if LANDED:contains(a.message) then
                local buff = res.buffs[a.param]
                if buff then add_debuff(target.id, buff.en) end
            elseif act.category == 4 and SPELL_DMG:contains(a.message) then
                -- Dia, Dia II, Diaga, Bio II ... name the effect by prefix.
                local spell = res.spells[act.param]
                local name = spell and spell.en
                if name and name:find('^Dia') then add_debuff(target.id, 'Dia') end
                if name and name:find('^Bio') then add_debuff(target.id, 'Bio') end
            end
            if DIED:contains(a.message) or DIED:contains(a.add_effect_message) then
                mob_debuffs[target.id] = nil
            end
        end
    end
end)

windower.register_event('action message', function(actor_id, target_id, actor_index, target_index, message_id, param_1)
    if WORE_OFF:contains(message_id) then
        local buff = res.buffs[param_1]
        if buff and mob_debuffs[target_id] then
            mob_debuffs[target_id][status_key(buff.en)] = nil
        end
    elseif DIED:contains(message_id) then
        mob_debuffs[target_id] = nil
    end
end)

windower.register_event('zone change', function()
    mob_debuffs = {}
end)

local function current_target()
    return windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('bt')
end

-- The first of the button's `debuff` names the current target has, or nil.
local function target_debuff(b)
    if not b.debuff then
        return nil
    end
    local mob = current_target()
    local have = mob and mob_debuffs[mob.id]
    if not have then
        return nil
    end
    local now = os.clock()
    for _, name in ipairs(b.debuff) do
        local expiry = have[status_key(name)]
        if expiry and expiry > now then
            return name
        end
    end
end

---------------------------------------------------------------------------
-- Drawing state + mouse
---------------------------------------------------------------------------

local hovered, pressed_btn, flash_until = nil, nil, 0
local mouse_x, mouse_y = 0, 0

local function show_if(img, want)
    if want and not img:visible() then
        img:show()
    elseif not want and img:visible() then
        img:hide()
    end
end

local function refresh()
    local now = os.clock()
    for _, b in ipairs(bar.buttons) do
        if b.visible then
            show_if(b.active, is_lit(b))
            if b.ready then
                show_if(b.ready, target_debuff(b) ~= nil
                    or (b.ready_buff ~= nil and my_buffs[b.ready_buff:lower()] == true))
            end
            show_if(b.dim, (b.needs ~= nil and not wearing(b.needs))
                or (b.needs_buff ~= nil and not has_any_buff(b.needs_buff)))
            show_if(b.hover, hovered == b)
            show_if(b.pressed, pressed_btn == b or (b.flash and now < b.flash))
        end
    end
    if settings.tooltips and hovered then
        local lines = {hovered.name or hovered.label}
        if hovered.opens then
            lines[#lines + 1] = '(click to open)'
        end
        if hovered.needs and not wearing(hovered.needs) then
            local need = {}
            for _, v in pairs(hovered.needs) do need[#need + 1] = v end
            lines[#lines + 1] = 'needs ' .. table.concat(need, ' + ')
        end
        if hovered.needs_buff and not has_any_buff(hovered.needs_buff) then
            lines[#lines + 1] = 'needs ' .. table.concat(hovered.needs_buff, ' or ')
        end
        local d = target_debuff(hovered)
        if d then
            lines[#lines + 1] = d .. ' on your target - this shot enhances it'
        end
        if hovered.ready_buff and my_buffs[hovered.ready_buff:lower()] then
            lines[#lines + 1] = hovered.ready_buff .. ' - ready now'
        end
        if hovered.charges and hovered.charges_left then
            lines[#lines + 1] = ('charges: %d / %d'):format(hovered.charges_left, hovered.charges)
        end
        if hovered.cd_secs then
            lines[#lines + 1] = 'ready in ' .. format_secs(hovered.cd_secs) .. 's'
        end
        tooltip:text(table.concat(lines, '\n'))
        tooltip:pos(hovered.x, hovered.y - 22 * #lines - 8)
        if not tooltip:visible() then tooltip:show() end
    elseif tooltip:visible() then
        tooltip:hide()
    end
end

local ALT_KEYS = S{56, 184}   -- DIK_LMENU, DIK_RMENU
local alt_held = false
local drag

windower.register_event('keyboard', function(dik, pressed)
    if ALT_KEYS:contains(dik) then
        alt_held = pressed
    end
end)

local function hit(x, y)
    for _, h in ipairs(bar.hits) do
        if x >= h.x and x < h.x + h.w and y >= h.y and y < h.y + h.h then
            return h
        end
    end
end

local MOUSE_MOVE, MOUSE_LEFT_DOWN, MOUSE_LEFT_UP = 0, 1, 2

local function set_menu(name, timeout)
    bar.menu = name
    bar.menu_timeout = timeout
    bar.menu_touch = os.clock()
    hovered, pressed_btn = nil, nil
    layout()
    refresh()
end

windower.register_event('mouse', function(kind, x, y)
    if #bar.hits == 0 then
        return
    end
    mouse_x, mouse_y = x, y

    if kind == MOUSE_MOVE then
        if drag then
            settings.x, settings.y = x - drag.dx, y - drag.dy
            layout()
            return true
        end
        local h = hit(x, y)
        local b = h and h.btn
        if h and bar.menu then
            bar.menu_touch = os.clock()   -- still in use: keep it open
        end
        if b ~= hovered then
            hovered = b
            refresh()
        end
        if pressed_btn and pressed_btn ~= b then
            pressed_btn = nil
            refresh()
        end

    elseif kind == MOUSE_LEFT_DOWN then
        local h = hit(x, y)
        if not h then
            return
        end
        if alt_held then
            drag = {dx = x - settings.x, dy = y - settings.y}
        elseif h.btn then
            pressed_btn = h.btn
            refresh()
        end
        return true   -- the click is ours, don't let the game walk / target

    elseif kind == MOUSE_LEFT_UP then
        if drag then
            drag = nil
            config.save(settings)
            return true
        end
        if pressed_btn then
            local b = pressed_btn
            pressed_btn = nil
            local h = hit(x, y)
            if h and h.btn == b then
                b.flash = os.clock() + 0.12
                if b.opens then
                    set_menu(b.opens, b.menu_timeout)
                elseif b.is_back then
                    set_menu(nil)
                else
                    windower.send_command(b.cmd)
                    if b.menu and b.stay then
                        bar.menu_touch = os.clock()   -- rotation menu: stay open
                    elseif b.menu then
                        set_menu(nil)     -- picked one: back to the main bar
                    end
                end
            end
            refresh()
            return true
        end
    end
end)

---------------------------------------------------------------------------
-- Cooldowns
--
-- The shade's height is (time left / the cooldown's full length), where the
-- full length is the value seen when the timer started - so haste and
-- recast gear are already in it, and the timer's units don't matter.
-- For the seconds counter the units do matter, so they're measured: how
-- fast the value falls per real second (1 = seconds, ~60 = 1/60ths).
--
-- `charges=N` (Quick Draw): the timer runs while charges remain, so the
-- shade only appears once they're all spent. One charge's length is learned
-- from the first jump from 0; before that it shades like a normal ability.
---------------------------------------------------------------------------

local function update_cooldowns(now)
    local ability = windower.ffxi.get_ability_recasts() or {}
    local spell = windower.ffxi.get_spell_recasts() or {}
    local s = settings.size
    local inset = math.floor(s * FACE_INSET / ART_SIZE + 0.5)
    local inner = s - 2 * inset

    for _, b in ipairs(bar.buttons) do
        if b.recast_id then
            local v = (b.recast_kind == 'spell' and spell or ability)[b.recast_id] or 0
            local cd = b.cd
            local was_ready = b.prev_v == 0
            b.prev_v = v
            if v <= 0 then
                b.cd = nil
            elseif not cd or v > cd.last + 0.01 then
                -- A new use: from ready, or another charge spent. One
                -- charge's length is only learned from a jump we saw start
                -- at 0 - not from a timer already running at load.
                if b.charges and was_ready then
                    b.charge_len = b.charge_len or v
                end
                b.cd = {total = v, t0 = now, v0 = v, last = v}
            else
                cd.last = v
                local dt = now - cd.t0
                if dt >= 0.5 and cd.v0 > v then
                    b.units = ((cd.v0 - v) / dt) > 20 and 60 or 1
                end
            end

            -- How much of the face to shade, and the seconds to show.
            local frac, left = 0, 0
            cd = b.cd
            if cd then
                if b.charges and b.charge_len then
                    local spent = math.ceil(v / b.charge_len - 0.001)
                    b.charges_left = math.max(0, b.charges - spent)
                    if b.charges_left == 0 then
                        left = v - (b.charges - 1) * b.charge_len
                        frac = left / b.charge_len
                    end
                else
                    b.charges_left = nil
                    left, frac = v, v / cd.total
                end
            else
                b.charges_left = b.charges
            end
            frac = math.max(0, math.min(1, frac))

            -- Hidden buttons (in a closed menu) keep tracking, but don't draw.
            local h = math.floor(frac * inner + 0.5)
            if h >= 1 and b.visible then
                -- Anchored at the top, so colour returns from the bottom up.
                b.shade:pos(b.x + inset, b.y + inset)
                b.shade:size(inner, h)
                if not b.shade:visible() then b.shade:show() end
            elseif b.shade:visible() then
                b.shade:hide()
            end

            b.cd_secs = (frac > 0 and b.units) and left / b.units or nil
            if b.cd_secs and b.visible then
                local str = format_secs(b.cd_secs)
                local fs = math.max(9, math.floor(s * 0.3))
                b.cd_text:text(str)
                -- Rough centring: texts can't centre themselves.
                b.cd_text:pos(b.x + math.floor(s / 2 - #str * fs * 0.33),
                              b.y + math.floor(s / 2 - fs * 0.8))
                if not b.cd_text:visible() then b.cd_text:show() end
            elseif b.cd_text:visible() then
                b.cd_text:hide()
            end
        end
    end
end

local last_poll, last_cd = 0, 0
windower.register_event('prerender', function()
    if #bar.buttons == 0 then
        return
    end
    local now = os.clock()
    if now - last_poll >= 0.25 then
        last_poll = now
        read_equipment()
        read_buffs()
        refresh()
    end
    if now - last_cd >= 0.1 then
        last_cd = now
        update_cooldowns(now)
    end
    if plate_label:visible() and bar.plate_x then
        local w, h = plate_label:extents()
        if w and w > 0 then
            plate_label:pos(bar.plate_x + math.floor((settings.size - w) / 2),
                            settings.y - h - 2)
        end
    end
    -- An open menu left alone closes itself.
    if bar.menu and now - (bar.menu_touch or now) > (bar.menu_timeout or settings.menu_timeout) then
        set_menu(nil)
    end
    -- The cyan "ready" glow breathes (about once a second) so it catches
    -- the eye mid-fight; the gold "on" glow stays steady.
    local alpha = math.floor(165 + 90 * math.sin(now * 6.3))
    for _, b in ipairs(bar.buttons) do
        if b.ready and b.ready:visible() then
            b.ready:alpha(alpha)
        end
    end
end)

---------------------------------------------------------------------------
-- Job changes, login, commands
---------------------------------------------------------------------------

local function rebuild_soon()
    -- Player data lags a moment behind the job change packet.
    coroutine.schedule(function()
        build()
        read_equipment()
        refresh()
    end, 1.5)
end

windower.register_event('load', 'login', rebuild_soon)
windower.register_event('job change', rebuild_soon)
windower.register_event('logout', destroy_bar)

local help = {
    'Alt + drag   move the bar',
    'show / hide  show or hide the bar',
    'size <px>    button size (default 52)',
    'pos <x> <y>  place the bar',
    'tooltips     toggle hover tooltips',
    'reload       reload everything (addon code, button files, art)',
}

windower.register_event('addon command', function(cmd, ...)
    local args = {...}
    cmd = cmd and cmd:lower() or 'help'

    if cmd == 'show' or cmd == 'hide' then
        settings.visible = cmd == 'show'
        config.save(settings)
        build()
    elseif cmd == 'size' and tonumber(args[1]) then
        settings.size = math.max(24, math.min(128, math.floor(tonumber(args[1]))))
        config.save(settings)
        layout()
    elseif cmd == 'pos' and tonumber(args[1]) and tonumber(args[2]) then
        settings.x, settings.y = tonumber(args[1]), tonumber(args[2])
        config.save(settings)
        layout()
    elseif cmd == 'tooltips' then
        settings.tooltips = not settings.tooltips
        config.save(settings)
        say('tooltips ' .. (settings.tooltips and 'on' or 'off'))
    elseif cmd == 'plate' then
        -- //gb plate <key> [text]: tag above the job plate (no key: clear).
        bar.label = args[1] and args[1]:lower() or nil
        bar.label_text = args[1] and table.concat(args, ' ', args[2] and 2 or 1) or nil
        if bar.label_text and bar.plate then
            plate_label:text(bar.label_text)
            plate_label:pos(bar.plate_x or settings.x, settings.y - 18)
            plate_label:show()
        else
            plate_label:hide()
        end
        refresh()
    elseif cmd == 'reload' then
        -- A full addon reload, not just a rebuild: picks up changes to this
        -- file as well as the job button files and new art.
        windower.send_command('lua r gearbar')
    else
        for _, line in ipairs(help) do
            say(line)
        end
    end
end)
