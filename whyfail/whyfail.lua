-- whyfail: when the game says "cannot perform that action" (or another
-- "can't do that" line), print the last few commands that were sent, so you
-- can see which one the game rejected. Load: //lua l whyfail
_addon.name = 'whyfail'
_addon.version = '1.0'
_addon.commands = {'whyfail'}

local recent = {}      -- {time, text}, newest last
local KEEP = 6
local last_report = 0

local PATTERNS = {
    'cannot perform that action',
    'unable to use',
    'cannot use that',
    'must wait longer',
}

local function remember(text)
    recent[#recent + 1] = {os.clock(), text}
    if #recent > KEEP then table.remove(recent, 1) end
end

-- Commands typed or sent by addons (Trust uses /ja, /ma, /ws, /pet, /ra...).
windower.register_event('outgoing text', function(original, modified)
    local t = (modified ~= '' and modified or original)
    if t:match('^/') or t:match('^input /') then
        remember(t)
    end
end)

-- Actions sent as raw packets (0x01A) rather than chat commands.
local res = require('resources')
local CATS = {[2]='engage', [3]='magic', [4]='disengage', [7]='weapon skill', [9]='job ability',
              [0x0F]='switch target', [0x10]='ranged attack'}
windower.register_event('outgoing chunk', function(id, data, modified, injected)
    if id ~= 0x01A then return end
    local cat = modified:unpack('H', 0x0B)
    local param = modified:unpack('H', 0x0D)
    local name
    if cat == 9 then name = res.job_abilities[param] and res.job_abilities[param].en
    elseif cat == 7 then name = res.weapon_skills[param] and res.weapon_skills[param].en
    elseif cat == 3 then name = res.spells[param] and res.spells[param].en end
    remember(('[packet] %s%s'):format(CATS[cat] or ('category '..cat), name and (' '..name) or ''))
end)

windower.register_event('incoming text', function(original, modified, mode)
    local low = original:lower()
    for _, p in ipairs(PATTERNS) do
        if low:find(p, 1, true) then
            local now = os.clock()
            if now - last_report < 1 then return end   -- don't double-print one failure
            last_report = now
            local lines = {}
            for i = #recent, math.max(1, #recent - 2), -1 do
                lines[#lines + 1] = ('%.1fs ago: %s'):format(now - recent[i][1], recent[i][2])
            end
            windower.add_to_chat(207, '[whyfail] last commands: ' .. (#lines > 0 and table.concat(lines, ' | ') or 'none seen'))
            return
        end
    end
end)
