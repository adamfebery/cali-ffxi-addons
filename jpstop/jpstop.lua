_addon.name = 'jpstop'
_addon.author = 'Adam'
_addon.version = '1.0'
_addon.commands = {'jpstop'}

require('logger')
local packets = require('packets')

local threshold = 500
local enabled = true
local jp = nil           -- unspent JP on the current main job
local armed = false      -- threshold reached, waiting for combat to end
local clear_since = nil  -- os.clock() when combat was first seen as over
local shutting_down = false

local CLEAR_SECONDS = 6  -- combat must stay over this long before shutting down
local MSG_JP_EARNED = 719 -- "${actor} earns a job point! (Total: ${number})"

local function read_jp()
    local player = windower.ffxi.get_player()
    if not player or not player.job_points then return nil end
    local job = player.job_points[player.main_job:lower()]
    return job and job.jp or nil
end

local function party_ids()
    local ids = {}
    local party = windower.ffxi.get_party()
    if not party then return ids end
    for _, member in pairs(party) do
        if type(member) == 'table' and member.mob then
            ids[member.mob.id] = true
        end
    end
    return ids
end

-- True while we are engaged or anything claimed by the party is still alive nearby.
local function in_combat()
    local player = windower.ffxi.get_player()
    if not player then return true end
    if player.status == 1 then return true end

    local ids = party_ids()
    for _, mob in pairs(windower.ffxi.get_mob_array()) do
        if mob.spawn_type == 16 and mob.hpp > 0 and mob.valid_target
                and ids[mob.claim_id] and mob.distance < 50^2 then
            return true
        end
    end
    return false
end

local function arm()
    if armed or not enabled then return end
    armed = true
    clear_since = nil
    log(('Reached %d JP. Pulling disabled; will /shutdown once the current fight is over.'):format(jp))
    windower.send_command('trust pull off')
end

local function check_jp()
    if jp and jp >= threshold then arm() end
end

local function disarm(reason)
    armed = false
    clear_since = nil
    if reason then log(reason) end
end

windower.register_event('load', 'login', 'job change', function()
    coroutine.schedule(function()
        jp = read_jp()
        if jp then
            log(('Unspent JP: %d / %d (%s)'):format(jp, threshold, enabled and 'armed at threshold' or 'disabled'))
            check_jp()
        end
    end, 2)
end)

windower.register_event('incoming chunk', function(id, data)
    if id ~= 0x02D then return end
    local p = packets.parse('incoming', data)
    local player = windower.ffxi.get_player()
    if not player or p['Player'] ~= player.id then return end
    if p['Message'] % 0x8000 == MSG_JP_EARNED then
        jp = p['Param 1']
        check_jp()
    end
end)

local last_check = 0

windower.register_event('prerender', function()
    if not armed or shutting_down then return end
    local now = os.clock()
    if now - last_check < 1 then return end
    last_check = now
    if in_combat() then
        clear_since = nil
        return
    end
    clear_since = clear_since or now
    if now - clear_since >= CLEAR_SECONDS then
        shutting_down = true
        log('Combat over. Stopping trust and shutting down.')
        windower.send_command('trust stop')
        coroutine.schedule(function()
            if armed then
                windower.send_command('input /shutdown')
            else
                shutting_down = false
            end
        end, 2)
    end
end)

windower.register_event('addon command', function(cmd, arg)
    cmd = cmd and cmd:lower() or 'status'
    if cmd == 'off' or cmd == 'cancel' then
        enabled = false
        shutting_down = false
        disarm('Disabled. Will not shut down.')
    elseif cmd == 'on' then
        enabled = true
        log('Enabled.')
        check_jp()
    elseif cmd == 'set' and tonumber(arg) then
        threshold = tonumber(arg)
        log(('Threshold set to %d.'):format(threshold))
        check_jp()
    else
        jp = read_jp() or jp
        log(('Unspent JP: %s / %d | %s%s'):format(tostring(jp), threshold,
            enabled and 'enabled' or 'disabled', armed and ' | ARMED, waiting for fight to end' or ''))
        log('Commands: //jpstop [status | on | off | set <jp>]')
    end
end)
