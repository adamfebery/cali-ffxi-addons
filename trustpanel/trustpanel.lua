_addon.name = 'trustpanel'
_addon.author = 'Char1'
_addon.version = '5.0'
_addon.commands = {'trustpanel', 'tp'}

-- One button. Click it to cycle every other character through:
--   BUFF ONLY  - not engaged, no weapon skills, just buffing
--   SAVAGE     - assist me, engage when I engage. Char2 (BRD) and
--                Char3 (COR) spam Savage Blade, my own Trust spams
--                Shijin Spiral. Shijin then Savage Blade OR Savage Blade then
--                Shijin is Light, so Lights happen by themselves.
--                (CombatMode Auto: they run in to 2 yalms of the mob and melee it)
--   LIGHT SC   - same engage, but follow skillchain steps instead of spamming:
--                me Shijin Spiral > Char2 Savage Blade = Light (2 steps)
--   DARK SC    - Char3 Sniper Shot > Char2 Savage Blade (Distortion)
--                > me Asuran Fists = Darkness
--                Plans are the 'Light' / 'BrdDark' sets in trust/data/skillchains/.
-- Nobody bursts: Char2 is on BRD. Drag the button to move it. Commands go
-- out through the Send addon.

local texts = require('texts')
local config = require('config')

local BARD = 'Char2'
local ORDER = {'buff', 'sb', 'sc', 'dark'}

local settings = config.load({x = 400, y = 300, mode = 'buff'})

local LOOK = {
    buff = {label = ' TRUSTS: BUFF ONLY ',         r = 40,  g = 70,  b = 140, chat = 'buff only'},
    sb   = {label = ' TRUSTS: SAVAGE + SHIJIN ',   r = 200, g = 110, b = 20,  chat = 'Savage Blade spam, me Shijin Spiral spam'},
    sc   = {label = ' TRUSTS: LIGHT SC ',          r = 130, g = 40,  b = 160, chat = 'Light: Shijin Spiral > Savage Blade'},
    dark = {label = ' TRUSTS: DARK SC ',           r = 60,  g = 60,  b = 60,  chat = 'Darkness: Sniper Shot > Savage Blade > Asuran Fists'},
}

local button = texts.new('', {
    pos = {x = settings.x, y = settings.y},
    bg = {alpha = 220, red = 40, green = 70, blue = 140},
    text = {font = 'Consolas', size = 11, stroke = {width = 1, alpha = 200}},
    flags = {bold = true, draggable = false},
    padding = 4,
})

local function draw()
    local look = LOOK[settings.mode] or LOOK.buff
    button:text(look.label .. '\n   (click to switch)')
    button:bg_color(look.r, look.g, look.b)
    button:show()
end

-- Each entry is {target, trust command}; target '@others' or a character name.
local function send_all(cmds)
    local out = {}
    for _, c in ipairs(cmds) do
        out[#out + 1] = 'send ' .. c[1] .. ' trust ' .. c[2]
    end
    windower.send_command(table.concat(out, '; wait 0.5; '))
end

local function engage_cmds()
    local me = windower.ffxi.get_player()
    -- Char2's BRD file: Naegling (+ Fusetto off-hand on /DNC /NIN). Without
    -- it he can still be holding Kali from songs and has no Savage Blade.
    windower.send_command('send ' .. BARD .. ' gs c weapons')
    return {
        {'@others', 'assist ' .. (me and me.name or '')},
        {'@others', 'set CombatMode Auto'},
        {'@others', 'set AutoEngageMode Mirror'},
        {'@others', 'set AutoMagicBurstMode Off'},
    }
end

local function set_mode(mode)
    local cmds
    if mode == 'sb' then
        cmds = engage_cmds()
        cmds[#cmds + 1] = {'@others', 'sc spam Savage Blade'}
        windower.send_command('trust sc spam Shijin Spiral')
    elseif mode == 'sc' or mode == 'dark' then
        local plan = (mode == 'sc') and 'Light' or 'BrdDark'
        cmds = engage_cmds()
        cmds[#cmds + 1] = {'@others', 'set WeaponSkillSettingsMode ' .. plan}
        cmds[#cmds + 1] = {'@others', 'set AutoSkillchainMode Auto'}
        -- my own Trust does its step (Shijin Spiral / Asuran Fists)
        windower.send_command('trust set WeaponSkillSettingsMode ' .. plan
            .. '; wait 0.5; trust set AutoSkillchainMode Auto')
    else
        cmds = {
            {'@others', 'set CombatMode Off'},
            {'@others', 'set AutoEngageMode Off'},
            {'@others', 'set AutoSkillchainMode Off'},
        }
    end
    send_all(cmds)
    settings.mode = mode
    config.save(settings)
    draw()
    windower.add_to_chat(207, 'trustpanel: ' .. LOOK[mode].chat)
end

local function next_mode()
    for i, m in ipairs(ORDER) do
        if m == settings.mode then
            return ORDER[i % #ORDER + 1]
        end
    end
    return ORDER[1]
end

-- Click = next mode. Press and move more than a few pixels = drag.
-- (Like gearbar: ignore the 'blocked' flag - another addon claims every
-- click, so honouring it meant the button never saw one.)
local press
local function over(x, y)
    if not button:visible() then return false end
    local bx, by = button:pos()
    local w, h = button:extents()
    w, h = (w and w > 0) and w or 200, (h and h > 0) and h or 40
    return x >= bx and x <= bx + w and y >= by and y <= by + h
end

windower.register_event('mouse', function(kind, x, y)
    if kind == 1 and over(x, y) then
        local bx, by = button:pos()
        press = {x = x, y = y, dx = x - bx, dy = y - by, moved = false}
        return true
    elseif kind == 0 and press then
        if math.abs(x - press.x) + math.abs(y - press.y) > 4 then press.moved = true end
        if press.moved then button:pos(x - press.dx, y - press.dy) end
        return true
    elseif kind == 2 and press then
        local p = press
        press = nil
        if p.moved then
            settings.x, settings.y = button:pos()
            config.save(settings)
        else
            set_mode(next_mode())
        end
        return true
    end
end)

windower.register_event('addon command', function(cmd)
    cmd = (cmd or ''):lower()
    if LOOK[cmd] then
        set_mode(cmd)
    elseif cmd == 'hide' then
        button:hide()
    elseif cmd == 'show' then
        draw()
    else
        windower.add_to_chat(207, 'trustpanel: //tp buff | //tp sb | //tp sc | //tp dark | //tp show | //tp hide  (or click the button)')
    end
end)

windower.register_event('load', 'login', draw)
