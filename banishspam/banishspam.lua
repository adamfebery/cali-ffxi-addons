-- banishspam: casts Banish on your current target on a timer.
--
-- Banish has a 15s recast, so it fires as soon as the recast is up and
-- the interval just sets how often it checks (default 7s).
--
--   //bspam            toggle on/off
--   //bspam on | off
--   //bspam every <s>  set the interval in seconds
_addon.name = 'banishspam'
_addon.author = 'Char1'
_addon.version = '1.0'
_addon.commands = {'banishspam', 'bspam'}

local res = require('resources')

local SPELL = res.spells[28] -- Banish
local enabled = false
local interval = 7
local last_try = 0

local function say(msg)
    windower.add_to_chat(207, 'banishspam: ' .. msg)
end

local function try_cast()
    local player = windower.ffxi.get_player()
    local target = windower.ffxi.get_mob_by_target('t')
    if not player or not target then return end

    -- A live monster within Banish's range (distance is stored squared).
    if target.spawn_type ~= 16 or target.hpp == 0 then return end
    if math.sqrt(target.distance) > SPELL.range + target.model_size then return end

    -- Not while dead, resting, in a cutscene or out of MP.
    if player.status ~= 0 and player.status ~= 1 then return end
    if player.vitals.mp < SPELL.mp_cost then return end

    -- Banish needs to be known (via WHM sub) and off recast.
    if not windower.ffxi.get_spells()[SPELL.id] then return end
    if (windower.ffxi.get_spell_recasts()[SPELL.recast_id] or 0) > 0 then return end

    windower.send_command('input /ma "Banish" <t>')
end

windower.register_event('prerender', function()
    if not enabled then return end
    local now = os.clock()
    if now - last_try < interval then return end
    last_try = now
    try_cast()
end)

windower.register_event('zone change', function()
    if enabled then
        enabled = false
        say('off (zoned)')
    end
end)

windower.register_event('addon command', function(cmd, arg)
    cmd = cmd and cmd:lower()
    if cmd == 'on' or (cmd == nil and not enabled) then
        enabled = true
        last_try = 0
        say('on - every ' .. interval .. 's')
    elseif cmd == 'off' or cmd == nil then
        enabled = false
        say('off')
    elseif cmd == 'every' and tonumber(arg) then
        interval = math.max(1, tonumber(arg))
        say('interval ' .. interval .. 's')
    else
        say('//bspam [on|off] | //bspam every <seconds>')
    end
end)
