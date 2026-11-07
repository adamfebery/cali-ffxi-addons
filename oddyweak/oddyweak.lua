_addon.name = 'OddyWeak'
_addon.author = 'Char1'
_addon.version = '1.0'
_addon.commands = {'oddyweak', 'ow'}

require('luau')
local config = require('config')
local texts = require('texts')

local resistances = require('sheol_resistances')
local types = require('sheol_types')

local defaults = {
    sheol = 'C',
    pos = {x = 400, y = 200},
    text = {font = 'Consolas', size = 10},
    bg = {alpha = 200},
}
local settings = config.load(defaults)
local box = texts.new('', {pos = settings.pos, text = settings.text, bg = settings.bg, flags = {draggable = true}})

local odyssey_zones = S{298, 279}

-- extra resistance a mob gets to its family's damage type inside each Sheol: {regular, NM/Agon}
local sheol_factor = {
    A = {1.000, 1.000},
    B = {0.750, 0.625},
    C = {0.500, 0.375},
}

local physical = {'Slashing', 'Piercing', 'Blunt'}
local elements = {'Fire', 'Ice', 'Wind', 'Earth', 'Lightning', 'Water', 'Light', 'Dark'}

-- weapon types each job can use well, by damage type
local job_weapons = {
    WAR = {Slashing = 'Great Axe, Axe, Great Sword, Sword', Piercing = 'Polearm, Dagger', Blunt = 'Club, Staff'},
    MNK = {Blunt = 'Hand-to-Hand, Staff, Club'},
    WHM = {Blunt = 'Club, Staff'},
    BLM = {Piercing = 'Dagger', Blunt = 'Staff, Club'},
    RDM = {Slashing = 'Sword', Piercing = 'Dagger', Blunt = 'Club'},
    THF = {Slashing = 'Sword', Piercing = 'Dagger, Marksmanship, Archery', Blunt = 'Hand-to-Hand'},
    PLD = {Slashing = 'Sword, Great Sword', Piercing = 'Polearm', Blunt = 'Club, Staff'},
    DRK = {Slashing = 'Scythe, Great Sword, Axe, Great Axe, Sword', Piercing = 'Dagger', Blunt = 'Club'},
    BST = {Slashing = 'Axe, Scythe, Sword', Piercing = 'Dagger', Blunt = 'Club'},
    BRD = {Slashing = 'Sword', Piercing = 'Dagger', Blunt = 'Staff, Club'},
    RNG = {Slashing = 'Axe, Sword', Piercing = 'Archery, Marksmanship, Dagger'},
    SAM = {Slashing = 'Great Katana, Sword', Piercing = 'Polearm, Archery', Blunt = 'Club'},
    NIN = {Slashing = 'Katana, Sword', Piercing = 'Dagger, Marksmanship, Archery', Blunt = 'Club, Hand-to-Hand'},
    DRG = {Slashing = 'Sword', Piercing = 'Polearm, Dagger', Blunt = 'Staff, Club'},
    SMN = {Piercing = 'Dagger', Blunt = 'Staff, Club'},
    BLU = {Slashing = 'Sword', Blunt = 'Club'},
    COR = {Slashing = 'Sword', Piercing = 'Dagger, Marksmanship'},
    PUP = {Piercing = 'Dagger', Blunt = 'Hand-to-Hand, Club'},
    DNC = {Slashing = 'Sword', Piercing = 'Dagger', Blunt = 'Hand-to-Hand'},
    SCH = {Piercing = 'Dagger', Blunt = 'Staff, Club'},
    GEO = {Piercing = 'Dagger', Blunt = 'Club, Staff'},
    RUN = {Slashing = 'Great Sword, Sword, Axe, Great Axe', Blunt = 'Club'},
}

local last_target_id

-- "Nostos Crab" -> "Crab", "Agon Yojimbo" -> "Yojimbo"; NMs have no prefix
local function strip_name(name)
    local prefix, rest = name:match('^(%a+)%s(.+)$')
    if prefix == 'Nostos' then
        return rest, nil
    elseif prefix == 'Agon' then
        return rest, 'Agon'
    end
    return name, 'NM'
end

local function family_of(mob)
    for family, entry in pairs(types) do
        for i = 2, #entry do
            if entry[i] == mob then
                return family, entry[1]
            end
        end
    end
end

local function color(value)
    if value > 1 then
        return '\\cs(100,255,100)'
    elseif value < 1 then
        return '\\cs(255,100,100)'
    end
    return '\\cs(255,255,255)'
end

local function fmt(value)
    return color(value)..string.format('%d%%', math.floor(value * 100 + 0.5))..'\\cr'
end

local function build(target)
    local mob, tag = strip_name(target.name)
    local row = resistances[mob]
    if not row then
        return nil
    end
    local family, sheol_type = family_of(mob)
    local factor = sheol_factor[settings.sheol:upper()][tag and 2 or 1]

    local mult = {}
    for i, damage_type in ipairs(physical) do
        mult[damage_type] = row[i] * (damage_type == sheol_type and factor or 1)
    end
    local element_mult = {}
    for i, element in ipairs(elements) do
        element_mult[element] = row[i + 4] * (sheol_type == 'Magic' and factor or 1)
    end

    -- best physical type(s)
    local best = 0
    for _, damage_type in ipairs(physical) do
        best = math.max(best, mult[damage_type])
    end
    local use, avoid = L{}, L{}
    for _, damage_type in ipairs(physical) do
        if mult[damage_type] == best then
            use:append(damage_type)
        elseif mult[damage_type] < 1 then
            avoid:append(damage_type)
        end
    end

    -- top two elements
    local sorted = T(elements):copy()
    table.sort(sorted, function(a, b) return element_mult[a] > element_mult[b] end)

    local lines = L{}
    lines:append('\\cs(255,220,120)'..target.name..'\\cr'..(family and ' ('..family..')' or '')..(tag and ' ['..tag..']' or ''))
    lines:append(' Slash '..fmt(mult.Slashing)..'  Pierce '..fmt(mult.Piercing)..'  Blunt '..fmt(mult.Blunt))
    lines:append(' USE: \\cs(100,255,100)'..use:concat('/')..'\\cr'..(avoid:length() > 0 and '   AVOID: \\cs(255,100,100)'..avoid:concat('/')..'\\cr' or ''))

    local player = windower.ffxi.get_player()
    local weapons = job_weapons[player.main_job]
    if weapons then
        local picks = L{}
        for damage_type in use:it() do
            if weapons[damage_type] then
                picks:append(weapons[damage_type])
            end
        end
        lines:append(' '..player.main_job..': '..(picks:length() > 0 and picks:concat(', ') or 'no good weapon type, go magic'))
    end
    lines:append(' Magic: '..sorted[1]..' '..fmt(element_mult[sorted[1]])..', '..sorted[2]..' '..fmt(element_mult[sorted[2]]))
    if sheol_type == 'Magic' then
        lines:append(' \\cs(255,100,100)Resists all magic in Sheol '..settings.sheol:upper()..'\\cr')
    end
    return lines:concat('\n')
end

local function update()
    local info = windower.ffxi.get_info()
    if not info.logged_in or not odyssey_zones:contains(info.zone) then
        if box:visible() then box:hide() end
        last_target_id = nil
        return
    end
    local target = windower.ffxi.get_mob_by_target('t')
    if not target or not target.is_npc then
        if box:visible() then box:hide() end
        last_target_id = nil
        return
    end
    if target.id == last_target_id then
        return
    end
    last_target_id = target.id
    local text = build(target)
    if text then
        box:text(text)
        box:show()
    else
        box:hide()
    end
end

local frame = 0
windower.register_event('prerender', function()
    frame = frame + 1
    if frame % 10 == 0 then
        update()
    end
end)

windower.register_event('addon command', function(command, arg)
    command = command and command:lower() or 'help'
    if command == 'sheol' and arg and sheol_factor[arg:upper()] then
        settings.sheol = arg:upper()
        settings:save()
        last_target_id = nil
        log('Sheol set to '..settings.sheol)
    elseif command == 'save' then
        settings.pos.x, settings.pos.y = box:pos()
        settings:save()
        log('Position saved')
    else
        log('//ow sheol a|b|c  - which Sheol you are in (default C)')
        log('//ow save         - save the box position after dragging it')
    end
end)
