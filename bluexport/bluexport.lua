-- bluexport: writes every blue spell you know, the spells currently set, your
-- active job traits and BLU job points to data/<name>_blu.txt, so the set can
-- be planned outside the game.
--
--   //bluexport        write the file (be on BLU to capture the set spells)
_addon.name = 'bluexport'
_addon.author = 'Char1'
_addon.version = '1.0'
_addon.commands = {'bluexport', 'bluex'}

local res = require('resources')

local function spell_name(id)
    local s = res.spells[id]
    return s and s.en or ('?' .. tostring(id))
end

-- get_mjob_data().spells holds the set spells. Depending on the client build
-- the ids are either real spell ids (512+) or offset by 512; accept both.
local function set_spell_id(raw)
    if not raw or raw == 0 then return nil end
    local s = res.spells[raw]
    if s and s.type == 'BlueMagic' then return raw end
    s = res.spells[raw + 512]
    if s and s.type == 'BlueMagic' then return raw + 512 end
    return nil
end

local function export()
    local player = windower.ffxi.get_player()
    if not player then return end
    local lines = {}
    local function add(s) lines[#lines + 1] = s end

    add('# bluexport for ' .. player.name .. ' - ' .. os.date('%Y-%m-%d %H:%M'))
    add('main job: ' .. tostring(player.main_job) .. ' ' .. tostring(player.main_job_level)
        .. '  sub: ' .. tostring(player.sub_job) .. ' ' .. tostring(player.sub_job_level))
    local jp = player.job_points and player.job_points.blu
    if jp then
        add('BLU job points spent: ' .. tostring(jp.jp_spent) .. '  (100 / 1200 gifts add set points)')
    end

    -- Currently set spells (only readable while BLU is your main job).
    add('')
    add('## SET SPELLS (name | set points)')
    local total = 0
    if player.main_job == 'BLU' then
        local mjob = windower.ffxi.get_mjob_data()
        for _, raw in ipairs(mjob and mjob.spells or {}) do
            local id = set_spell_id(raw)
            if id then
                local pts = res.spells[id].blu_points or 0
                total = total + pts
                add(spell_name(id) .. ' | ' .. pts)
            end
        end
        add('total set points used: ' .. total)
    else
        add('(not on BLU - change to BLU and run //bluexport again to capture these)')
    end

    -- Active job traits right now (from the current set + level).
    add('')
    add('## ACTIVE JOB TRAITS')
    local abil = windower.ffxi.get_abilities()
    for _, tid in ipairs(abil and abil.job_traits or {}) do
        local t = res.job_traits[tid]
        add(t and t.en or ('?' .. tid))
    end

    -- Every blue spell learned, with points and level.
    add('')
    add('## KNOWN BLUE SPELLS (name | set points | level)')
    local known = windower.ffxi.get_spells() or {}
    local list = {}
    for id, have in pairs(known) do
        local s = res.spells[id]
        if have and s and s.type == 'BlueMagic' then
            list[#list + 1] = s
        end
    end
    table.sort(list, function(a, b) return a.en < b.en end)
    for _, s in ipairs(list) do
        add(s.en .. ' | ' .. tostring(s.blu_points) .. ' | ' .. tostring(s.levels and s.levels[16] or '?'))
    end
    add('known: ' .. #list)

    -- And the ones you DON'T know yet, so the plan can say what to learn.
    add('')
    add('## NOT YET LEARNED (name | set points | level)')
    local missing = {}
    for id, s in pairs(res.spells) do
        if s.type == 'BlueMagic' and not known[id] then
            missing[#missing + 1] = s
        end
    end
    table.sort(missing, function(a, b) return a.en < b.en end)
    for _, s in ipairs(missing) do
        add(s.en .. ' | ' .. tostring(s.blu_points) .. ' | ' .. tostring(s.levels and s.levels[16] or '?'))
    end

    local dir = windower.addon_path .. 'data/'
    if not windower.dir_exists(dir) then windower.create_dir(dir) end
    local path = dir .. player.name .. '_blu.txt'
    local f = io.open(path, 'w')
    if not f then
        windower.add_to_chat(167, 'bluexport: could not write ' .. path)
        return
    end
    f:write(table.concat(lines, '\n') .. '\n')
    f:close()
    windower.add_to_chat(207, 'bluexport: ' .. #list .. ' known spells written to data/' .. player.name .. '_blu.txt')
end

windower.register_event('addon command', function()
    export()
end)
