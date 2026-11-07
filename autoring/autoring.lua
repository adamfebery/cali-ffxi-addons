-- autoring: keeps a Capacity Point (and optionally EXP) ring buff up.
--
-- When the Commitment buff (CP rings) or Dedication buff (EXP rings) is
-- missing, it picks the best ring you own that is READY (charges left and
-- off recast, read from the item's own data), locks the ring slot in
-- GearSwap, equips it, waits out the equip delay, uses it, then unlocks the
-- slot so GearSwap puts your normal ring back. The buff stays when the ring
-- comes off.
--
-- By default it only fires while you're ENGAGED, so a 12-hour ring is never
-- burned standing in town.
--
--   //autoring cp | exp | both | off    which buffs to keep up (default cp)
--   //autoring idle                     toggle: also fire when not engaged
--   //autoring now                      try once right now, engaged or not
--   //autoring use <ring name>          test one specific ring right now
--   //autoring status                   what it sees: buffs and ring readiness
_addon.name = 'autoring'
_addon.author = 'Char1'
_addon.version = '1.1'
_addon.commands = {'autoring', 'ar'}

local res = require('resources')
local extdata = require('extdata')
local config = require('config')

local defaults = {
    mode = 'cp',            -- cp | exp | both | off
    engaged_only = true,    -- only use rings while engaged
    slot = 'ring1',         -- the ring slot to borrow (ring1 = left ring)
}
local settings = config.load(defaults)

-- Best first. Names are the in-game short names (res/items.lua).
local KINDS = {
    cp = {
        buff = 579,         -- Commitment
        label = 'CP',
        rings = {'Endorsement Ring', 'Trizek Ring', 'Facility Ring', 'Capacity Ring', 'Vocation Ring'},
    },
    exp = {
        buff = 249,         -- Dedication
        label = 'EXP',
        rings = {'Echad Ring', "Kupofried's Ring", 'Caliber Ring', 'Emperor Band', 'Empress Band',
                 'Chariot Band', 'Resolution Ring', 'Anniversary Ring'},
    },
}

-- The bags /equip can use. Rings anywhere else are owned but out of reach.
local BAGS = {'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
              'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}
local SLOT_FIELD = {ring1 = 'left_ring', ring2 = 'right_ring'}
local MOUNTED = 252

local busy = false
local retry_after = {}      -- ring name -> os.time() before which we skip it
local last_check = 0
local warned_none = {}      -- kind -> true once "no ring ready" was said

local function say(msg)
    windower.add_to_chat(207, 'autoring: ' .. msg)
end

local function has_buff(id)
    local p = windower.ffxi.get_player()
    if not p then return false end
    for _, b in ipairs(p.buffs) do
        if b == id then return true end
    end
    return false
end

local item_ids = {}
local function item_id(name)
    if item_ids[name] == nil then
        local it = res.items:with('en', name)
        item_ids[name] = it and it.id or false
    end
    return item_ids[name]
end

-- Ready = enchanted item with charges left, off recast, and not in our own
-- retry cool-off. Returns the decoded extdata too (for the status command).
local function ring_state(item)
    local ok, ext = pcall(extdata.decode, item)
    if not ok or not ext or ext.type ~= 'Enchanted Equipment' then
        return false, 'no charge data', nil
    end
    if ext.charges_remaining == 0 then
        return false, 'no charges left', ext
    end
    local wait = ext.next_use_time - os.time()
    if wait > 0 then
        return false, string.format('recharging (%dh%02dm)', math.floor(wait / 3600), math.floor((wait % 3600) / 60)), ext
    end
    return true, 'ready', ext
end

-- First ring in priority order that is owned, reachable and ready.
local function find_ready(kind)
    local items = windower.ffxi.get_items()
    for _, name in ipairs(KINDS[kind].rings) do
        local id = item_id(name)
        if id and os.time() >= (retry_after[name] or 0) then
            for _, bag in ipairs(BAGS) do
                local b = items[bag]
                if b and b.enabled ~= false then
                    for _, item in ipairs(b) do
                        if item.id == id and ring_state(item) then
                            return name
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- The item currently in our ring slot, if it's `name`.
local function equipped_item(name)
    local items = windower.ffxi.get_items()
    local eq = items.equipment
    local field = SLOT_FIELD[settings.slot]
    local index, bag = eq[field], eq[field .. '_bag']
    if not index or index == 0 then return nil end
    local item = windower.ffxi.get_items(bag, index)
    if item and item.id == item_id(name) then
        return item
    end
    return nil
end

local function restore()
    windower.send_command('gs enable ' .. settings.slot .. '; wait 0.5; gs c update')
end

local function use_ring(kind, name)
    busy = true
    local k = KINDS[kind]
    say('no ' .. k.label .. ' buff - using ' .. name)

    windower.send_command('gs disable ' .. settings.slot)
    coroutine.sleep(0.5)
    windower.send_command('input /equip ' .. settings.slot .. ' "' .. name .. '"')

    -- Wait for the equip to land.
    local item
    for _ = 1, 20 do
        coroutine.sleep(0.5)
        item = equipped_item(name)
        if item then break end
    end
    if not item then
        say('could not equip ' .. name .. ' - skipping it for 5 minutes')
        retry_after[name] = os.time() + 300
        restore()
        busy = false
        return
    end

    -- Equip delay. ALWAYS wait the item's own delay from res (cast_delay,
    -- 5s for Trizek / Endorsement / Echad) plus a margin first. The ring's
    -- extdata activation_time is NOT trustworthy the instant the ring shows
    -- as equipped - the server hasn't updated it yet, so it reads as already
    -- past. v1.0 trusted it, used the ring ~3s early, and got no buff.
    -- After the base wait, re-read it: if it now says later still, wait more.
    local delay = (res.items[item_id(name)] or {}).cast_delay or 10
    coroutine.sleep(delay + 1.5)
    item = equipped_item(name)
    if item then
        local _, _, ext = ring_state(item)
        local extra = ext and (ext.activation_time - os.time()) or 0
        if extra > 0 then
            coroutine.sleep(math.min(extra, 30) + 1)
        end
    end

    -- Use it. One retry: the first /item can be refused if it lands during
    -- a weapon skill, a spell, or the tail of the equip delay.
    for attempt = 1, 2 do
        windower.send_command('input /item "' .. name .. '" <me>')
        coroutine.sleep(4)
        if has_buff(k.buff) then break end
        if attempt == 1 then
            say(name .. ': no buff yet, trying once more')
            coroutine.sleep(2)
        end
    end
    restore()

    if has_buff(k.buff) then
        say(k.label .. ' buff is up')
        warned_none[kind] = nil
    else
        say(name .. ' did not give the buff - skipping it for 5 minutes. '
            .. 'Check the chat log for the game\'s reason (e.g. "cannot use that item yet").')
        retry_after[name] = os.time() + 300
    end
    busy = false
end

local function active_kinds()
    if settings.mode == 'both' then return {'cp', 'exp'} end
    if KINDS[settings.mode] then return {settings.mode} end
    return {}
end

local function check(force)
    if busy then return end
    local p = windower.ffxi.get_player()
    if not p or has_buff(MOUNTED) then return end
    -- 0 idle, 1 engaged; anything else (dead, resting, chocobo, cutscene) waits.
    if p.status ~= 0 and p.status ~= 1 then return end
    if not force and settings.engaged_only and p.status ~= 1 then return end

    for _, kind in ipairs(active_kinds()) do
        if not has_buff(KINDS[kind].buff) then
            local name = find_ready(kind)
            if name then
                coroutine.schedule(function() use_ring(kind, name) end, 0)
                return
            elseif not warned_none[kind] then
                say('no ' .. KINDS[kind].label .. ' ring ready (//autoring status for details)')
                warned_none[kind] = true
            end
        end
    end
end

windower.register_event('prerender', function()
    local now = os.clock()
    if now - last_check < 5 then return end
    last_check = now
    check(false)
end)

local function status()
    say('mode ' .. settings.mode .. ', ' .. (settings.engaged_only and 'engaged only' or 'engaged or idle')
        .. ', slot ' .. settings.slot)
    local items = windower.ffxi.get_items()
    for _, kind in ipairs({'cp', 'exp'}) do
        local k = KINDS[kind]
        say(k.label .. ' buff: ' .. (has_buff(k.buff) and 'UP' or 'missing'))
        for _, name in ipairs(k.rings) do
            local id = item_id(name)
            for _, bag in ipairs(BAGS) do
                local b = items[bag]
                if b then
                    for _, item in ipairs(b) do
                        if item.id == id then
                            local _, why, ext = ring_state(item)
                            say('  ' .. name .. ' (' .. bag .. '): ' .. why
                                .. (ext and (', ' .. tostring(ext.charges_remaining) .. ' charges') or ''))
                        end
                    end
                end
            end
        end
    end
end

windower.register_event('addon command', function(cmd, ...)
    cmd = (cmd or 'status'):lower()
    if cmd == 'cp' or cmd == 'exp' or cmd == 'both' or cmd == 'off' then
        settings.mode = cmd
        settings:save()
        warned_none = {}
        say('mode = ' .. cmd)
    elseif cmd == 'idle' then
        settings.engaged_only = not settings.engaged_only
        settings:save()
        say(settings.engaged_only and 'only while engaged' or 'engaged or idle')
    elseif cmd == 'now' then
        warned_none = {}
        check(true)
    elseif cmd == 'use' then
        -- //autoring use Trizek Ring - test one specific ring right now.
        local name = table.concat({...}, ' ')
        local kind
        for k, v in pairs(KINDS) do
            for _, r in ipairs(v.rings) do
                if r:lower() == name:lower() then kind, name = k, r end
            end
        end
        if not kind then
            say('unknown ring "' .. name .. '"')
        elseif busy then
            say('busy with another ring')
        else
            retry_after[name] = nil
            coroutine.schedule(function() use_ring(kind, name) end, 0)
        end
    else
        status()
    end
end)
