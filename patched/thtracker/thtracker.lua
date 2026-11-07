--Copyright © 2017, Krizz
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of thtracker nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL KRIZZ BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- 1.3 (local edit, 2026-10-18):
--   * Shows a mob as soon as YOU land a hit / spell / ability on it, at the
--     TH your equipped gear gives (base text + augments, e.g. Valorous Hose),
--     instead of waiting for the first "TH increases to N" proc message.
--   * Keeps the highest level seen; procs from anyone still raise it.
--   * Shows "(gear)" until a proc confirms the level, then "(proc)".
--   * //th pos x y now works and is saved (it read the wrong params before).
--   * //th bonus N adds TH from job traits/gifts that gear can't show
--     (saved per main job). /THF adds +1 on its own.

_addon.name = 'THTracker'
_addon.author = 'Krizz'
_addon.version = 1.3
_addon.commands = {'thtracker', 'th'}

config = require('config')
texts = require('texts')
packets = require('packets')
res = require('resources')
extdata = require('extdata')
require('logger')
require('sets')

defaults = {}
defaults.pos = {}
defaults.pos.x = 1000
defaults.pos.y = 200
defaults.color = {}
defaults.color.alpha = 200
defaults.color.red = 200
defaults.color.green = 200
defaults.color.blue = 200
defaults.bg = {}
defaults.bg.alpha = 200
defaults.bg.red = 30
defaults.bg.green = 30
defaults.bg.blue = 30
defaults.bonus = {}

settings = config.load(defaults)

th = texts.new('${th_string}', settings)

-- [mob id] = {level = n, confirmed = bool}
local th_table = {}

-- Reactions that mean the action didn't land, so nothing was tagged.
local miss_messages = S{15, 63, 85, 158, 188, 282, 284, 354, 31, 32, 106}

local equip_slots = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear',
    'body', 'hands', 'left_ring', 'right_ring', 'back', 'waist', 'legs', 'feet'}

local function th_from_text(text)
    local n = text and text:match('Treasure Hunter"?%s*%+(%d+)')
    return tonumber(n) or 0
end

local desc_cache = {}
local function base_th(id)
    if desc_cache[id] == nil then
        local d = res.item_descriptions[id]
        desc_cache[id] = th_from_text(d and d.en)
    end
    return desc_cache[id]
end

function gear_th()
    local items = windower.ffxi.get_items()
    if not items or not items.equipment then return 0 end
    local total = 0
    for _, slot in ipairs(equip_slots) do
        local index, bag = items.equipment[slot], items.equipment[slot..'_bag']
        if index and index > 0 then
            local item = windower.ffxi.get_items(bag, index)
            if item and item.id and item.id > 0 then
                total = total + base_th(item.id)
                local ok, ext = pcall(extdata.decode, item)
                if ok and ext and ext.augments then
                    for _, aug in ipairs(ext.augments) do
                        total = total + th_from_text(aug)
                    end
                end
            end
        end
    end
    return total
end

local function job_bonus()
    local player = windower.ffxi.get_player()
    if not player then return 0 end
    local bonus = tonumber(settings.bonus[player.main_job:lower()]) or 0
    if player.sub_job == 'THF' and player.main_job ~= 'THF' then
        bonus = bonus + 1
    end
    return bonus
end

local function record(mob_id, level, confirmed)
    local entry = th_table[mob_id]
    if not entry then
        th_table[mob_id] = {level = level, confirmed = confirmed}
    elseif level > entry.level then
        entry.level = level
        entry.confirmed = confirmed
    elseif level == entry.level and confirmed then
        entry.confirmed = true
    else
        return
    end
    update_text()
end

windower.register_event('addon command', function(command, ...)
    command = command and command:lower()
    local params = {...}

    if command == 'pos' then
        local posx, posy = tonumber(params[1]), tonumber(params[2])
        if posx and posy then
            th:pos(posx, posy)
            settings.pos.x, settings.pos.y = posx, posy
            settings:save()
        end
    elseif command == 'hide' then
        th:hide()
    elseif command == 'show' then
        th:show()
    elseif command == 'bonus' then
        local player = windower.ffxi.get_player()
        local n = tonumber(params[1])
        if player and n then
            settings.bonus[player.main_job:lower()] = n
            settings:save()
        end
        log('Job TH bonus for '..(player and player.main_job or '?')..': '..job_bonus()..' (incl. /THF), gear now: '..gear_th())
    elseif command == 'gear' then
        log('Equipped gear TH: '..gear_th()..', job bonus: '..job_bonus())
    elseif command == 'clear' then
        th_table = {}
        update_text()
    else
        print('th help : Shows help message')
        print('th pos <x> <y> : Positions the box (saved)')
        print('th hide : Hides the box')
        print('th show : Shows the box')
        print('th gear : Prints the TH your equipped gear gives')
        print('th bonus <n> : Extra TH from traits/gifts for this main job (/THF is automatic)')
        print('th clear : Forgets all tracked mobs')
    end
end)

windower.register_event('action', function(act)
    local player = windower.ffxi.get_player()
    local mine = player and act.actor_id == player.id
    local tag_level

    for _, target in ipairs(act.targets) do
        for _, action in ipairs(target.actions) do
            if action.has_add_effect and action.add_effect_message == 603 then
                record(target.id, action.add_effect_param, true)
            elseif act.category == 3 and action.message == 608 then
                record(target.id, action.param, true)
            elseif mine and target.id ~= player.id and not miss_messages:contains(action.message)
                    and S{1, 2, 3, 4, 6}:contains(act.category) then
                local mob = windower.ffxi.get_mob_by_id(target.id)
                if mob and mob.is_npc and mob.spawn_type == 16 then
                    tag_level = tag_level or (gear_th() + job_bonus())
                    if tag_level > 0 then
                        record(target.id, tag_level, false)
                    end
                end
            end
        end
    end
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x038 then
        local packet = packets.parse('incoming', data)
        if th_table[packet['Mob']] and packet['Type'] == 'kesu' then
            th_table[packet['Mob']] = nil
            update_text()
        end
    elseif id == 0x00E then
        local packet = packets.parse('incoming', data)
        if th_table[packet['NPC']] and packet['Status'] == 0 and packet['HP %'] == 100 then
            th_table[packet['NPC']] = nil
            update_text()
        end
    end
end)

windower.register_event('zone change', function()
    th_table = {}
    update_text()
end)

windower.register_event('target change', function()
    update_text()
end)

function update_text()
    local current_string
    local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
    local entry = target and th_table[target.id]
    if entry then
        current_string = target.name..'\n TH: '..entry.level..(entry.confirmed and ' (proc)' or ' (gear)')
        th:show()
    else
        current_string = ''
        th:hide()
    end
    th.th_string = current_string
end
