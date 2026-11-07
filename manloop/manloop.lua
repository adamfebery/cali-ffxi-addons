_addon.name     = 'manloop'
_addon.author   = 'Adam'
_addon.version  = '1.2.0'
_addon.commands = {'manloop', 'ml'}

require('logger')

-- element -> maneuver buff id (res/buffs.lua 300-307)
local buff_ids = {
    Fire = 300, Ice = 301, Wind = 302, Earth = 303,
    Thunder = 304, Water = 305, Light = 306, Dark = 307,
}
local ORDER = {'Fire', 'Ice', 'Wind', 'Earth', 'Thunder', 'Water', 'Light', 'Dark'}
local MANEUVER_RECAST = 210
local REPAIR_RECAST = 206
local REPAIR_RANGE = 12
local OVERLOAD = 299
-- Repair won't fire at all without one of these in the ammo slot
local oils = {[18731] = true, [18732] = true, [18733] = true, [19185] = true}

-- can't use job abilities / pet commands while any of these are up
local blocking = {
    [2] = true, [7] = true, [10] = true, [14] = true, [16] = true,   -- sleep, petrify, stun, charm, amnesia
    [19] = true, [28] = true, [193] = true, [261] = true, [OVERLOAD] = true, -- sleep, terror, lullaby, impairment
}

-- Burden model, same numbers as autocontrol/burden.lua: +15 per maneuver,
-- 15 everywhere on activate, halved by Cooldown, -1 every 3s (Heat Sink: faster
-- per Water Maneuver up). Overload risk starts once an element goes past threshold.
local BURDEN_PER_MANEUVER = 15
local BASE_THRESHOLD = 30
local HEAT_SINK = 8610
local heat_sink_decay = {[0] = 2, [1] = 4, [2] = 5, [3] = 6}
local threshold_gear = {
    [11101] = 40, -- Cirque Farsetto +2
    [11201] = 20, -- Cirque Farsetto +1
    [14930] = 5,  -- Pup. Dastanas
    [15030] = 5,  -- Pup. Dastanas +1
    [16281] = 5,  -- Buffoon's Collar
    [16282] = 5,  -- Buffoon's Collar +1
    [20520] = 40, -- Midnights
    [26263] = 10, -- Visucius's Mantle
    [26932] = 40, -- Kara. Farsetto
    [26933] = 40, -- Kara. Farsetto +1
    [27960] = 5,  -- Foire Dastanas
    [27981] = 5,  -- Foire Dastanas +1
    [28634] = 5,  -- Dispersal Mantle
}
-- pet command ability id -> what it does to burden
local pet_actions = {
    [136] = 'activate', [310] = 'activate', [139] = 'deactivate', [309] = 'cooldown',
    [141] = 'Fire', [142] = 'Ice', [143] = 'Wind', [144] = 'Earth',
    [145] = 'Thunder', [146] = 'Water', [147] = 'Light', [148] = 'Dark',
}

local wanted = {Wind = 2, Water = 1}
local repair_at = 50   -- automaton HP% to Repair at; false = off
local running = false
local next_check = 0
local last_block = nil
local oil_warned = false
local burden = {}
local burden_known = false

local function counts(buffs)
    local have = {}
    for _, id in ipairs(buffs) do
        for el, bid in pairs(buff_ids) do
            if id == bid then have[el] = (have[el] or 0) + 1 end
        end
    end
    return have
end

local function set_all(v)
    for _, el in ipairs(ORDER) do burden[el] = v end
end

-- Loaded mid-session we can't know real burden, so assume the worst plausible:
-- activate's 15 plus 15 for every maneuver of that element still up.
local function estimate_burden()
    local player = windower.ffxi.get_player()
    local have = player and counts(player.buffs) or {}
    for _, el in ipairs(ORDER) do
        burden[el] = BURDEN_PER_MANEUVER * (1 + (have[el] or 0))
    end
    burden_known = true
end

local function threshold()
    local t = BASE_THRESHOLD
    local items = windower.ffxi.get_items()
    if not items or not items.equipment then return t end
    for slot, index in pairs(items.equipment) do
        if not slot:find('_bag$') and index ~= 0 then
            local item = windower.ffxi.get_items(items.equipment[slot .. '_bag'], index)
            if item and threshold_gear[item.id] then t = t + threshold_gear[item.id] end
        end
    end
    return t
end

local function oil_loaded()
    local items = windower.ffxi.get_items()
    local eq = items and items.equipment
    if not eq or eq.ammo == 0 then return false end
    local item = windower.ffxi.get_items(eq.ammo_bag, eq.ammo)
    return item and oils[item.id] or false
end

local function decay_rate()
    local mjob = windower.ffxi.get_mjob_data()
    local heat_sink = false
    for _, id in pairs(mjob and mjob.attachments or {}) do
        if id == HEAT_SINK then heat_sink = true break end
    end
    if not heat_sink then return 1 end
    local player = windower.ffxi.get_player()
    local water = player and counts(player.buffs).Water or 0
    return heat_sink_decay[math.min(water, 3)]
end

local function decay()
    local rate = decay_rate()
    for _, el in ipairs(ORDER) do
        burden[el] = math.max(0, (burden[el] or 0) - rate)
    end
    coroutine.schedule(decay, 3)
end

local function wanted_string()
    local out = {}
    for _, el in ipairs(ORDER) do
        if (wanted[el] or 0) > 0 then out[#out + 1] = wanted[el] .. 'x ' .. el end
    end
    return #out > 0 and table.concat(out, ', ') or 'nothing'
end

-- one-shot chat note when we're waiting on something, so a stall isn't silent
local function blocked(reason)
    if last_block ~= reason then
        last_block = reason
        if reason then log('waiting: ' .. reason) end
    end
end

windower.register_event('prerender', function()
    if not running then return end
    local now = os.clock()
    if now < next_check then return end
    next_check = now + 1

    local player = windower.ffxi.get_player()
    if not player or player.main_job ~= 'PUP' then return blocked('not PUP main') end
    if player.status ~= 0 and player.status ~= 1 then return blocked('not idle/engaged') end

    local pet = windower.ffxi.get_mob_by_target('pet')
    if not pet or pet.hpp == 0 then return blocked('no automaton out') end

    -- Overload only locks maneuvers, so Repair still gets a look while overloaded
    local overloaded = false
    for _, id in ipairs(player.buffs) do
        if id == OVERLOAD then
            overloaded = true
        elseif blocking[id] then
            return blocked('status ailment')
        end
    end

    if not repair_at or pet.hpp >= repair_at then oil_warned = false end
    local recasts = windower.ffxi.get_ability_recasts()
    if repair_at and pet.hpp < repair_at and (recasts[REPAIR_RECAST] or 0) == 0 then
        if not oil_loaded() then
            -- own flag: the maneuver code below would otherwise reset last_block every tick
            if not oil_warned then
                oil_warned = true
                log('automaton below ' .. repair_at .. '% but no oil in ammo slot - can\'t Repair')
            end
        elseif math.sqrt(pet.distance) > REPAIR_RANGE then
            return blocked('automaton out of Repair range')
        else
            blocked(nil)
            windower.send_command('input /ja "Repair" <me>')
            next_check = now + 3
            return
        end
    end

    if overloaded then return blocked('Overloaded') end
    if (recasts[MANEUVER_RECAST] or 0) > 0 then return end

    if not burden_known then estimate_burden() end
    local have = counts(player.buffs)
    local limit = threshold()
    local held = {}
    for _, el in ipairs(ORDER) do
        if (have[el] or 0) < (wanted[el] or 0) then
            if burden[el] + BURDEN_PER_MANEUVER <= limit then
                blocked(nil)
                windower.send_command('input /pet "' .. el .. ' Maneuver" <me>')
                next_check = now + 3   -- let the buff land before re-counting
                return
            end
            held[#held + 1] = el
        end
    end
    blocked(#held > 0 and (table.concat(held, '/') .. ' burden too high') or nil)
end)

windower.register_event('action', function(act)
    if act.category ~= 6 then return end
    local player = windower.ffxi.get_player()
    if not player or act.actor_id ~= player.id then return end
    local what = pet_actions[act.param]
    if not what then return end
    if what == 'activate' then
        set_all(BURDEN_PER_MANEUVER)
        burden_known = true
    elseif what == 'deactivate' then
        set_all(0)
        burden_known = true
    elseif not burden_known then
        estimate_burden()   -- buffs already include this maneuver/cooldown result
    elseif what == 'cooldown' then
        for _, el in ipairs(ORDER) do burden[el] = burden[el] / 2 end
    else
        burden[what] = burden[what] + BURDEN_PER_MANEUVER
    end
end)

windower.register_event('zone change', function()
    next_check = os.clock() + 10
    set_all(BURDEN_PER_MANEUVER)
end)

windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower() or 'help'
    local args = {...}
    if cmd == 'start' or cmd == 'on' then
        running = true
        last_block = nil
        log('keeping up ' .. wanted_string())
    elseif cmd == 'stop' or cmd == 'off' then
        running = false
        log('stopped')
    elseif cmd == 'set' then
        local new, total = {}, 0
        for i = 1, #args, 2 do
            local el = args[i] and (args[i]:sub(1, 1):upper() .. args[i]:sub(2):lower())
            local n = tonumber(args[i + 1])
            if not buff_ids[el] or not n or n < 0 then
                return error('usage: //ml set wind 2 water 1')
            end
            new[el] = n
            total = total + n
        end
        if total > 3 then return error('max 3 maneuvers total') end
        wanted = new
        log('set to ' .. wanted_string())
    elseif cmd == 'repair' then
        local arg = args[1] and args[1]:lower()
        local pct = tonumber(arg)
        if arg == 'off' then
            repair_at = false
        elseif pct and pct > 0 and pct <= 100 then
            repair_at = pct
        else
            return error('usage: //ml repair <hp%> | off')
        end
        log('Repair ' .. (repair_at and ('below ' .. repair_at .. '% HP') or 'off'))
    elseif cmd == 'status' then
        local player = windower.ffxi.get_player()
        local have = player and counts(player.buffs) or {}
        local out, load = {}, {}
        if not burden_known then estimate_burden() end
        for _, el in ipairs(ORDER) do
            if have[el] then out[#out + 1] = have[el] .. 'x ' .. el end
            if burden[el] > 0 then load[#load + 1] = ('%s %d'):format(el, burden[el]) end
        end
        log((running and 'running' or 'stopped') .. ' | want: ' .. wanted_string()
            .. ' | have: ' .. (#out > 0 and table.concat(out, ', ') or 'none'))
        log(('burden (limit %d, -%d/3s): %s'):format(threshold(), decay_rate(),
            #load > 0 and table.concat(load, ', ') or 'none'))
        log('Repair: ' .. (repair_at and ('below ' .. repair_at .. '% HP') or 'off')
            .. ' | oil ' .. (oil_loaded() and 'loaded' or 'NOT loaded'))
    else
        log('//ml start | stop | set <element> <n> [...] | repair <hp%>|off | status')
    end
end)

set_all(0)
coroutine.schedule(decay, 3)
