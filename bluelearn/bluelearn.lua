-- bluelearn: tells you when a mob has used a TP move you can learn as a blue
-- spell, so you know it's safe to kill it.
--
-- Watches every monster TP move (action category 11). If the move is a blue
-- spell you don't know yet, the mob is marked and you get a chat alert. A
-- box shows your current target's status:
--   green  "KILL IT - used Erratic Flutter"   the move has been seen
--   grey   "no learnable move seen yet"       let it keep using TP moves
-- Learning still isn't guaranteed: you need BLU as main job, enough Blue
-- Magic skill, and the kill has to count for your party. Some NMs never
-- teach.
--
--   //bluelearn            show / hide the box
--   //bluelearn pos <x> <y> move the box
--   //bluelearn reset      forget every mob seen so far
_addon.name = 'bluelearn'
_addon.author = 'Char1'
_addon.version = '1.1'
_addon.commands = {'bluelearn', 'bl'}

local res = require('resources')
local texts = require('texts')
local config = require('config')

local defaults = {
    show = true,
    display = {
        pos = {x = 400, y = 200},
        text = {size = 11, font = 'Consolas'},
        bg = {alpha = 180},
        padding = 4,
    },
}
local settings = config.load(defaults)
local box = texts.new(settings.display)

-- Blue spell names the game abbreviates; the monster's move uses the full name.
local ALIASES = {
    ['Quad. Continuum'] = 'Quadratic Continuum',
    ['Winds of Promy.'] = 'Winds of Promyvion',
    ['Evryone. Grudge'] = "Everyone's Grudge",
    ['O. Counterstance'] = 'Orcish Counterstance',
    ['Nat. Meditation'] = "Nature's Meditation",
    ['Tem. Upheaval'] = 'Tempestuous Upheaval',
    ['Atra. Libations'] = 'Atramentous Libations',
    ['1000 Needles'] = '1,000 Needles',
}

-- monster ability id -> blue spell id
local ability_to_spell = {}
do
    local by_name = {}
    for id, s in pairs(res.spells) do
        if s.type == 'BlueMagic' then
            by_name[ALIASES[s.en] or s.en] = id
        end
    end
    for id, a in pairs(res.monster_abilities) do
        local spell = by_name[a.en]
        if spell then ability_to_spell[id] = spell end
    end
end

-- mob id -> { [spell id] = true } of learnable moves it has used
local seen = {}

-- mob id -> { order = {ability ids, first use first}, count = {[id] = n} }
-- Every TP move the mob has used, learnable or not.
local moves = {}

local function is_blu()
    local p = windower.ffxi.get_player()
    return p and p.main_job == 'BLU'
end

local function knows(spell_id)
    local known = windower.ffxi.get_spells()
    return known and known[spell_id] or false
end

local function spell_names(set)
    local names = {}
    for id in pairs(set) do
        if not knows(id) then names[#names + 1] = res.spells[id].en end
    end
    table.sort(names)
    return names
end

windower.register_event('action', function(act)
    if act.category ~= 11 or not is_blu() then return end

    local m = moves[act.actor_id]
    if not m then
        m = {order = {}, count = {}}
        moves[act.actor_id] = m
    end
    if not m.count[act.param] then m.order[#m.order + 1] = act.param end
    m.count[act.param] = (m.count[act.param] or 0) + 1

    local spell = ability_to_spell[act.param]
    if not spell or knows(spell) then return end

    seen[act.actor_id] = seen[act.actor_id] or {}
    if seen[act.actor_id][spell] then return end
    seen[act.actor_id][spell] = true

    local mob = windower.ffxi.get_mob_by_id(act.actor_id)
    windower.add_to_chat(158, ('bluelearn: %s used %s - learnable, safe to kill!')
        :format(mob and mob.name or 'mob', res.spells[spell].en))
end)

-- A learned spell disappears from every list on its own (knows() is
-- re-checked each draw); the chat line "learns <spell>" needs no handling.

local last_prune = 0
windower.register_event('prerender', function()
    -- Forget mobs that are gone or dead, every 10s.
    local now = os.clock()
    if now - last_prune > 10 then
        last_prune = now
        for id in pairs(seen) do
            local m = windower.ffxi.get_mob_by_id(id)
            if not m or m.hpp == 0 then seen[id] = nil end
        end
        for id in pairs(moves) do
            local m = windower.ffxi.get_mob_by_id(id)
            if not m or m.hpp == 0 then moves[id] = nil end
        end
    end

    if not settings.show or not is_blu() then box:hide() return end

    -- Top line: the zone's weather right now. Many learnable mobs (Byrgen,
    -- Gefyrst, elementals) only spawn in one weather, and it's easy to miss
    -- on screen.
    local info = windower.ffxi.get_info()
    local w = info and res.weather[info.weather]
    local lines = {('Weather: \\cs(150,200,255)%s\\cr'):format(w and w.en or '?')}

    local t = windower.ffxi.get_mob_by_target('t')
    if t and t.is_npc and t.spawn_type == 16 then
        local names = seen[t.id] and spell_names(seen[t.id]) or {}
        if #names > 0 then
            lines[2] = ('\\cs(80,255,120)KILL IT\\cr  %s used: %s'):format(t.name, table.concat(names, ', '))
        else
            lines[2] = ('\\cs(170,170,170)%s - no learnable move seen yet\\cr'):format(t.name)
        end

        -- Every TP move this mob has used, in first-use order:
        -- green = learnable and unknown, blue = a blue spell you know.
        local m = moves[t.id]
        if m then
            local parts = {}
            for _, id in ipairs(m.order) do
                local a = res.monster_abilities[id]
                local name = a and a.en or ('#' .. id)
                if m.count[id] > 1 then name = name .. ' x' .. m.count[id] end
                local spell = ability_to_spell[id]
                if spell and not knows(spell) then
                    name = '\\cs(80,255,120)' .. name .. '\\cr'
                elseif spell then
                    name = '\\cs(150,200,255)' .. name .. '\\cr'
                end
                parts[#parts + 1] = name
            end
            lines[#lines + 1] = 'TP moves: ' .. table.concat(parts, ', ')
        end
    end
    box:text(table.concat(lines, '\n'))
    box:show()
end)

windower.register_event('zone change', function()
    seen = {}
    moves = {}
end)

windower.register_event('addon command', function(cmd, ...)
    cmd = (cmd or ''):lower()
    local args = {...}
    if cmd == 'pos' and tonumber(args[1]) and tonumber(args[2]) then
        settings.display.pos.x, settings.display.pos.y = tonumber(args[1]), tonumber(args[2])
        box:pos(settings.display.pos.x, settings.display.pos.y)
        settings:save()
    elseif cmd == 'reset' then
        seen = {}
        moves = {}
        windower.add_to_chat(207, 'bluelearn: forgot every mob')
    else
        settings.show = not settings.show
        settings:save()
        windower.add_to_chat(207, 'bluelearn: box ' .. (settings.show and 'shown' or 'hidden'))
    end
end)
