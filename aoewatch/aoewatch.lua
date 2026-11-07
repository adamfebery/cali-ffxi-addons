-- aoewatch: names whoever in your party (or their pet) uses an action that
-- hits more than one monster. Load: //lua l aoewatch
_addon.name = 'aoewatch'
_addon.version = '1.0'
_addon.commands = {'aoewatch'}

local res = require('resources')

-- Action categories -> how to name the param.
local function action_name(cat, param)
    local r
    if cat == 3 then r = res.weapon_skills[param]
    elseif cat == 4 or cat == 8 then r = res.spells[param]
    elseif cat == 6 or cat == 14 or cat == 15 then r = res.job_abilities[param]
    elseif cat == 11 or cat == 7 then r = res.monster_abilities[param] or res.weapon_skills[param]
    elseif cat == 13 then r = res.job_abilities[param]
    elseif cat == 5 then r = res.items[param] end
    local kinds = {[1]='melee', [2]='ranged attack', [3]='weapon skill', [4]='spell', [5]='item',
                   [6]='job ability', [11]='TP move', [13]='pet ability', [14]='job ability', [15]='job ability'}
    return (r and r.en or ('#'..param)), (kinds[cat] or ('category '..cat))
end

-- Ids of everyone in the party/alliance and their pets.
local function party_ids()
    local ids = {}
    local party = windower.ffxi.get_party() or {}
    for _, key in ipairs({'p0','p1','p2','p3','p4','p5','a10','a11','a12','a13','a14','a15','a20','a21','a22','a23','a24','a25'}) do
        local m = party[key] and party[key].mob
        if m then
            ids[m.id] = m.name
            if m.pet_index then
                local pet = windower.ffxi.get_mob_by_index(m.pet_index)
                if pet then ids[pet.id] = pet.name..' ('..m.name..'\'s pet)' end
            end
        end
    end
    return ids
end

windower.register_event('action', function(act)
    if act.target_count < 2 then return end
    local ids = party_ids()
    local who = ids[act.actor_id]
    if not who then return end

    local hit = {}
    for _, t in ipairs(act.targets) do
        local m = windower.ffxi.get_mob_by_id(t.id)
        if m and m.spawn_type == 16 then hit[#hit + 1] = m.name end
    end
    if #hit < 2 then return end

    local name, kind = action_name(act.category, act.param)
    windower.add_to_chat(167, ('[aoewatch] %s used %s "%s" on %d monsters: %s'):format(
        who, kind, name, #hit, table.concat(hit, ', ')))
end)
