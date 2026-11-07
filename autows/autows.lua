_addon.name = 'SimpleHotShot'
_addon.author = 'Adam'
_addon.version = '1.1'

local last_check = 0
local check_interval = 0.5 -- Seconds between checks to prevent spam

windower.register_event('load', function()
    print('SimpleHotShot loaded! Ready to fire Hot Shot at 1000 TP.')
end)

windower.register_event('prerender', function()
    local curr_time = os.clock()
    if curr_time - last_check < check_interval then return end
    last_check = curr_time

    local player = windower.ffxi.get_player()
    -- Check if player exists, is engaged (status 1), and has 1000+ TP
    if player and player.status == 1 and player.vitals.tp >= 1000 then
        windower.send_command('input /ws "Sniper Shot" <t>')
    end
end)