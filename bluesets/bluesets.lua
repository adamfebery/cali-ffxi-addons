-- bluesets: sets your blue spells in one command, from a priority list.
--
-- Each set below is a PRIORITY LIST, not a fixed set. The addon walks it top
-- to bottom and takes every spell you actually KNOW that still fits in your
-- 20 slots and your set points. So when you learn something new it slots in
-- automatically, without editing anything. A {all = {...}} entry is
-- all-or-nothing (the Triple Attack trio only counts with all three).
--
--   //bluesets [set]       set spells (default set: melee). Not while engaged.
--   //bluesets preview [set]  show what it WOULD set, change nothing
--   //bluesets max <n>     your blue magic set point limit (default 55)
--   //bluesets list        list the sets
--   //bluesets announce    tell gearbar which set is on (it shows it above
--                          the BLU plate; also sent by itself on any change)
--   //bs ...               short form
--
-- Set points: 55 at level 99, +1 per Assimilation merit (up to +5), +1 per
-- tier of the "Blue Magic Point Bonus" job point category (up to +20). The
-- game doesn't expose your total to addons, so tell it with //bs max <n> -
-- the number is on the in-game Set Spells screen.
_addon.name = 'bluesets'
_addon.author = 'Char1'
_addon.version = '1.0'
_addon.commands = {'bluesets', 'bs'}

local res = require('resources')
local config = require('config')

local settings = config.load({max_points = 55})

local SETS = {
    -- Naegling / Savage Blade melee, Darkness-chain bursts, a few utilities.
    melee = {
        'Erratic Flutter',                              -- Haste, the biggest melee buff
        -- Dual Wield: 8 trait points per tier. These five = 24 = DW III.
        'Quad. Continuum', 'Delta Thrust', 'Barbed Crescent', 'Molting Plumage', 'Blazing Bound',
        -- Triple Attack: 16 trait points, ALL THREE or it's no better than /WAR's DA.
        {all = {'Thrashing Assault', 'Heavy Strike', 'Empty Thrash'}},
        -- The rest of the guide's "Advanced DD" spec. Everything down to
        -- Magic Fruit IS that spec (18 spells, 75 points), and all of it is
        -- learned as of 2026-10-04. Sweeping Gouge -> Tenebral Crush is the
        -- guide's upgrade once you learn it.
        -- Glutinous Dart cut 2026-10-24 to make room for Magic Hammer (its
        -- 4 Max HP Boost points do nothing alone). Spec is now 17 / 73.
        'Fantod', 'Sudden Lunge', 'Sinker Drill', 'Paralyzing Triad',
        'Sweeping Gouge', 'Nat. Meditation', 'Diffusion Ray',
        'Magic Fruit',                                  -- flex: self-heal
        -- Below here: fillers for the 3 slots / 7 points the spec leaves.
        -- Blank Gaze first (2026-10-12): single-target dispel.
        'Blank Gaze',
        -- Magic Hammer (2026-10-24): light nuke + MP drain. Trust's
        -- AutoRestoreManaMode gambit casts it under 25% MP. It replaced
        -- Dark Orb: 73 + Blank Gaze 2 + Magic Hammer 4 + Regurgitation 1 = 80.
        -- SINGLE-TARGET ONLY: every level-99 Darkness nuke (Scouring Spate,
        -- Tenebral Crush, Spectral Floe, Entomb, Embalming Earth, Rending
        -- Deluge) is AoE and pulls extra mobs. Those live in the nuke set.
        'Magic Hammer', 'Regurgitation',
        'Dark Orb', 'Glutinous Dart',                   -- only if points free up
        -- Store TP (Fantod + Sickle Slash) and Accuracy Bonus (Dimensional
        -- Death) - only if the slots above didn't fill.
        'Sickle Slash', 'Dimensional Death',
        'Head Butt',                                    -- stun
        'Cocoon', 'Metallic Body',                      -- cheap defence
        'Wild Carrot',                                  -- heal (+ Resist Sleep with Pollen)
        -- Extras once the above are in, best first.
        'Tail Slap',                                    -- Store TP II, stun
        'Mortal Ray', 'Animating Wail',                 -- Dual Wield IV
        'Pollen', 'Death Scissors', 'Exuviation',
        'Uppercut', 'Battle Dance',
    },
    -- Omen AoE: melee core + AoE nukes / sleeps for Omen trash packs. All 20
    -- spells = 80 points. All learned as of 2026-10-12 (Silent Storm and
    -- Occultation were the last two). Listed in
    -- priority order: if your limit is under 80 the LAST spells that don't
    -- fit are the ones left out.
    omenaoe = {
        'Barbed Crescent', 'Delta Thrust', 'Empty Thrash', 'Heavy Strike',
        'Thrashing Assault', 'Sudden Lunge', 'Fantod',
        'Screwdriver', 'Silent Storm', 'Tem. Upheaval', 'Occultation',
        'Dream Flower', 'Sheep Song', 'Nat. Meditation', 'Cocoon',
        'Erratic Flutter', 'Magic Fruit', 'Regeneration',
        'Entomb', 'Spectral Floe',
        -- Fillers for the 2 slots / 11 points the two unlearned spells
        -- leave: Dual Wield I -> II. Once Silent Storm and Occultation are
        -- learned these no longer fit and drop out by themselves.
        'Molting Plumage', 'Blazing Bound',
    },
    -- Nuke / burst focus: every level-99 nuke you know first.
    nuke = {
        'Erratic Flutter',
        'Tenebral Crush', 'Scouring Spate', 'Spectral Floe', 'Entomb', 'Embalming Earth',
        'Anvil Lightning', 'Searing Tempest', 'Silent Storm', 'Tem. Upheaval', 'Blinding Fulgor',
        'Molting Plumage', 'Rending Deluge', 'Subduction',
        'Dream Flower', 'Sound Blast', 'Memento Mori',  -- Magic Attack Bonus
        'Cocoon', 'Metallic Body', 'Magic Fruit', 'Wild Carrot', 'Pollen', 'Head Butt',
        'Regurgitation', 'Mysterious Light',
        -- Fillers (2026-10-06: the list above left 2 slots / 5 points):
        -- dispel and an AoE sleep to get out of trouble. The unlearned
        -- nukes above push these out as you learn them.
        'Blank Gaze', 'Sheep Song',
    },
    -- Pure AoE (rebuilt 2026-10-18 for traits). 17 spells, 80 points.
    -- Trait points (8 = one tier; your 1200 JP gifts add +2 tiers):
    --   Evasion Bonus      Silent Storm 8 + Tem. Upheaval 8 + Occultation 4
    --                      + Screwdriver 4 = 24 -> tier V (was 20 -> IV)
    --   Magic Attack Bonus Spectral Floe 8 + Memento Mori 4 + Sound Blast 4
    --                      + Cursed Sphere 4 + Dream Flower 4 = 24 -> tier V
    --                      (was 16 -> IV)
    --   Magic Acc. Bonus   Tenebral Crush 8 -> III
    -- Heals: White Wind (AoE, scales with max HP), Magic Fruit (big single),
    -- Pollen (1 pt filler). Pre-pull buffs for the gearbar AOE > PRE button:
    -- Occultation, Cocoon, Memento Mori.
    -- Entomb is essential (user, 2026-10-18), so Anvil Lightning (thunder)
    -- and Blinding Fulgor (light) are the ones left out. There is no "spell interruption" trait on
    -- BLU; that only comes from gear and Aquaveil.
    aoe = {
        'Tenebral Crush',     -- dark, Defense Down, MAcc Bonus
        'Spectral Floe',      -- ice, Terror, MAB 8
        'Entomb',             -- earth, Petrify - ESSENTIAL, never drop
        'Searing Tempest',    -- fire, Burn
        'Silent Storm',       -- wind, Silence, Evasion 8
        'Scouring Spate',     -- water, Attack Down
        'Tem. Upheaval',      -- wind, 6 pts, Evasion 8
        'Memento Mori',       -- pre-pull: Magic Atk. Boost, MAB 4
        'Occultation',        -- pre-pull: shadows, Evasion 4
        'Cocoon',             -- pre-pull: Defense Boost, 1 pt
        'Screwdriver',        -- Evasion 4 (3 pts) - completes Evasion 24
        'Sound Blast',        -- MAB 4 (1 pt)
        'Cursed Sphere',      -- water AoE nuke, MAB 4 (2 pts)
        'Dream Flower',       -- AoE sleep for emergencies, MAB 4 (3 pts)
        'White Wind',         -- AoE heal (5 pts)
        'Magic Fruit',        -- single-target heal (3 pts)
        'Pollen',             -- small heal, last point (1 pt)
        -- Only if something above isn't learned yet:
        'Anvil Lightning',    -- thunder, Stun
        'Blinding Fulgor',    -- light, Flash
        'Subduction',         -- wind, Weight, MAB 8
        'Embalming Earth',    -- earth, Slow
        'Rending Deluge',     -- water, Dispel
    },
    -- Tank (2026-10-23), from the BLU job guide's enmity table, built from
    -- Char1's bluexport of 2026-10-23. 20 spells, 76 points with what's
    -- learned now. The [NL] spells aren't learned yet: they're placed where
    -- they belong, so when you learn one it slots in and the bottom of the
    -- list drops off.
    -- Trait points (your 1200 JP gifts add +2 tiers):
    --   Evasion Bonus    Silent Storm 8 + Tem. Upheaval 8 + Occultation 4
    --                    + Screwdriver 4 = 24 -> V
    --   Defense Bonus    Entomb 8 -> III
    --   Max HP Boost     Restoral 8 -> III
    --   Auto Regen       Healing Breeze 4 + Sheep Song 4 = 8
    --   Fast Cast        Erratic Flutter 8
    tank = {
        'Erratic Flutter',    -- Haste, Fast Cast trait
        -- Burst enmity (VE ~1000). None learned yet.
        'Jettatura',          -- [NL] VE 1020, gaze stun
        'Temporal Shift',     -- [NL] VE 1020, AoE stun
        'Actinic Burst',      -- [NL] VE 1080, AoE flash, 24 MP
        -- Steady enmity (CE/VE 320 each).
        'Fantod',             -- fastest cast
        'Blank Gaze',         -- dispel
        'Geist Wall',         -- AoE dispel, 30s recast
        'Sheep Song',         -- AoE sleep, 22 MP
        'Soporific',          -- AoE sleep
        'Exuviation',         -- 640 per party member; Diffusion it
        'Triumphant Roar',    -- Diffusion it for party-wide enmity
        'Sudden Lunge',       -- stun
        'Head Butt',          -- stun
        -- Defence and heals.
        'Barrier Tusk',       -- [NL] ~-15% damage taken, after gear
        'Occultation',        -- shadows, Evasion 4
        'Cocoon',             -- Defense +50%
        'Metallic Body',      -- Stoneskin
        'Magic Fruit',        -- big single heal
        'Healing Breeze',     -- AoE heal, Auto Regen 4
        'Restoral',           -- self heal, Max HP Boost 8
        -- Traits.
        'Entomb',             -- Defense Bonus 8
        'Silent Storm',       -- Evasion 8
        'Tem. Upheaval',      -- Evasion 8
        'Screwdriver',        -- Evasion 4
        -- Fallbacks.
        'Magnetite Cloud', 'Wild Carrot', 'Regeneration', 'Dark Orb',
    },
    -- Tank DW: the tank set plus Dual Wield, for meleeing while you tank
    -- (Naegling + Machaera / Nibiru on any subjob). Delta Thrust + Barbed
    -- Crescent = 8 DW points = Dual Wield III (25%) with your gifts, for 4 set
    -- points. To make room: Soporific (Sheep Song is the AoE sleep) and Head
    -- Butt (Sudden Lunge is the stun) are out. 20 spells, 73 points.
    tankdw = {
        'Erratic Flutter',
        {all = {'Delta Thrust', 'Barbed Crescent'}},    -- Dual Wield III
        'Jettatura', 'Temporal Shift', 'Actinic Burst',   -- [NL]
        'Fantod', 'Blank Gaze', 'Geist Wall', 'Sheep Song',
        'Exuviation', 'Triumphant Roar', 'Sudden Lunge',
        'Barrier Tusk',                                   -- [NL]
        'Occultation', 'Cocoon', 'Metallic Body',
        'Magic Fruit', 'Healing Breeze', 'Restoral',
        'Entomb', 'Silent Storm', 'Tem. Upheaval', 'Screwdriver',
        -- Fallbacks.
        'Head Butt', 'Soporific', 'Wild Carrot', 'Regeneration',
    },
}

-- Add the Odyssey set (defined below the table so the tank sets stay untouched).
-- Odyssey Sheol C Cruel Joke strat (2026-11-05). Evasion-tank the pack, sleep
-- it, then Unbridled Learning + Cruel Joke (doom, 60 s; stay within 10').
-- Cruel Joke itself is a UL spell: no slot, no points, never listed here.
-- Built from the tank set plus the guide's tools (SE forum / FFXIAH Cruel
-- Joke guide, 2021-24). [NL] = not learned in the 2026-10-25 bluexport; they
-- slot in when learned and push the bottom fallbacks out.
--   Sleeps: Dream Flower (dark) + Sheep Song (LIGHT - Apkallu need a light
--           sleep) + Soporific. Damage wakes them; doom does not.
--   Magic Acc. Bonus: Tenebral Crush 8 - helps Cruel Joke and sleeps land.
--   Evasion Bonus: Silent Storm 8 + Tem. Upheaval 8 + Occultation 4
--                  + Screwdriver 4 = 24 -> V (same as the tank set).
SETS.odyssey = {
    'Erratic Flutter',    -- Haste, Fast Cast trait
    'Dream Flower',       -- AoE sleep (dark)
    'Sheep Song',         -- AoE sleep (light) - Apkallu
    'Tenebral Crush',     -- Magic Acc. Bonus 8
    'Actinic Burst',      -- [NL] AoE flash, big enmity
    'Temporal Shift',     -- [NL] AoE stun
    'Jettatura',          -- [NL] enmity, gaze stun
    'Geist Wall',         -- AoE dispel, enmity
    'Fantod',             -- fast enmity
    'Blank Gaze',         -- dispel, enmity
    'Occultation',        -- shadows, Evasion 4
    'Cocoon',             -- Defense +50%
    'Barrier Tusk',       -- [NL] -15% damage taken after gear, past the 50% cap
    'Magic Fruit',        -- big single heal
    'Restoral',           -- self heal, Max HP Boost
    'Silent Storm',       -- Evasion 8
    'Tem. Upheaval',      -- Evasion 8
    'Screwdriver',        -- Evasion 4
    'Soporific',          -- third AoE sleep
    'Metallic Body',      -- Stoneskin
    -- Fallbacks while the [NL] spells aren't learned.
    'Healing Breeze', 'Exuviation', 'Head Butt', 'Wild Carrot',
}

-- Short names gearbar shows above the BLU plate.
local SHORT = {melee = 'MELEE', omenaoe = 'OMEN', nuke = 'NUKE', aoe = 'AOE', tank = 'TANK', tankdw = 'TANKDW', odyssey = 'ODYS'}

local function say(msg, color)
    windower.add_to_chat(color or 207, 'bluesets: ' .. msg)
end

local blue_ids = {}
for id, s in pairs(res.spells) do
    if s.type == 'BlueMagic' then blue_ids[s.en:lower()] = id end
end

local function spell_id(name) return blue_ids[name:lower()] end

-- Pick the spells: known, unique, within 20 slots and the point limit.
local function plan(set_name)
    local list = SETS[set_name]
    local known = windower.ffxi.get_spells() or {}
    local chosen, points, skipped = {}, 0, {}
    local taken = {}

    local function try(names, label)
        local ids, cost = {}, 0
        for _, n in ipairs(names) do
            local id = spell_id(n)
            if not id then
                skipped[#skipped + 1] = n .. ' (not a blue spell - typo?)'
                return
            end
            if not known[id] then
                if label then skipped[#skipped + 1] = label .. ' (need all three: missing ' .. n .. ')' end
                return
            end
            if not taken[id] then
                ids[#ids + 1] = id
                cost = cost + (res.spells[id].blu_points or 0)
            end
        end
        if #ids == 0 then return end
        if #chosen + #ids > 20 then
            skipped[#skipped + 1] = (label or names[1]) .. ' (no free slot)'
        elseif points + cost > settings.max_points then
            skipped[#skipped + 1] = (label or names[1]) .. ' (' .. cost .. ' pts, over the limit)'
        else
            for _, id in ipairs(ids) do
                chosen[#chosen + 1] = id
                taken[id] = true
            end
            points = points + cost
        end
    end

    for _, entry in ipairs(list) do
        if type(entry) == 'table' then
            try(entry.all, table.concat(entry.all, ' + '))
        else
            try({entry})
        end
    end
    return chosen, points, skipped
end

local function describe(chosen, points)
    local names = {}
    for _, id in ipairs(chosen) do names[#names + 1] = res.spells[id].en end
    say(('%d spells, %d / %d points: %s'):format(#chosen, points, settings.max_points, table.concat(names, ', ')))
end

-- get_mjob_data().spells ids can be real (512+) or offset by 512.
local function equipped_ids()
    local out = {}
    local m = windower.ffxi.get_mjob_data()
    for _, raw in ipairs(m and m.spells or {}) do
        if raw and raw ~= 0 then
            local s = res.spells[raw]
            if s and s.type == 'BlueMagic' then out[raw] = true
            elseif res.spells[raw + 512] then out[raw + 512] = true end
        end
    end
    return out
end

local busy = false

-- Which set are the equipped spells? Exact match with a set's current plan
-- -> its name; mostly the same (16+ shared) -> name with '*' (e.g. you've
-- learned a spell since setting it - re-set to pick it up); else CUSTOM.
local function current_set()
    local have, n = equipped_ids(), 0
    for _ in pairs(have) do n = n + 1 end
    if n == 0 then return 'none', 'EMPTY' end
    local best, best_shared, best_exact = nil, 0, false
    for name in pairs(SETS) do
        local chosen = plan(name)
        local shared = 0
        for _, id in ipairs(chosen) do
            if have[id] then shared = shared + 1 end
        end
        local exact = shared == #chosen and shared == n
        if (exact and not best_exact) or (exact == best_exact and shared > best_shared) then
            best, best_shared, best_exact = name, shared, exact
        end
    end
    if best_exact then return best, SHORT[best] or best:upper() end
    if best and best_shared >= 16 then return best, (SHORT[best] or best:upper()) .. '*' end
    return 'custom', 'CUSTOM'
end

-- Tell gearbar (if loaded) what to show above the BLU plate.
local function announce()
    local p = windower.ffxi.get_player()
    if not p or p.main_job ~= 'BLU' then return end
    local key, short = current_set()
    windower.send_command('gb plate ' .. key .. ' ' .. short)
end

-- Re-announce whenever the equipped spells change (sets, manual edits, job
-- change), checked every 2 s while not mid-set.
local last_sig, last_check = nil, 0
windower.register_event('prerender', function()
    local now = os.clock()
    if busy or now - last_check < 2 then return end
    last_check = now
    local p = windower.ffxi.get_player()
    if not p or p.main_job ~= 'BLU' then last_sig = nil return end
    local ids = {}
    for id in pairs(equipped_ids()) do ids[#ids + 1] = id end
    table.sort(ids)
    local sig = table.concat(ids, ',')
    if sig ~= last_sig then
        last_sig = sig
        announce()
    end
end)

local function apply(set_name)
    local p = windower.ffxi.get_player()
    if not p or p.main_job ~= 'BLU' then return say('you need to be on BLU (main job)', 167) end
    if p.status ~= 0 then return say('stand still and idle first - spells can\'t be changed while engaged', 167) end
    if busy then return say('already setting spells', 167) end

    local chosen, points = plan(set_name)
    if #chosen == 0 then return say('nothing to set', 167) end
    busy = true
    say('setting the ' .. set_name .. ' set...')

    windower.ffxi.reset_blue_magic_spells()
    coroutine.sleep(1.2)
    for slot, id in ipairs(chosen) do
        windower.ffxi.set_blue_magic_spell(id, slot)
        coroutine.sleep(0.6)
    end
    coroutine.sleep(1.5)

    -- Read back what the game actually accepted.
    local have = equipped_ids()
    local missing = {}
    for _, id in ipairs(chosen) do
        if not have[id] then missing[#missing + 1] = res.spells[id].en end
    end
    describe(chosen, points)
    if #missing > 0 then
        say('the game refused: ' .. table.concat(missing, ', ')
            .. ' - if you are over your point limit, lower it with //bs max <n>', 167)
    else
        say('done')
    end
    busy = false
end

windower.register_event('addon command', function(cmd, arg)
    cmd = (cmd or 'melee'):lower()
    if cmd == 'max' then
        local n = tonumber(arg)
        if n and n >= 1 and n <= 80 then
            settings.max_points = n
            settings:save()
            say('set point limit = ' .. n)
        else
            say('usage: //bs max <1-80>  (currently ' .. settings.max_points .. ')', 167)
        end
    elseif cmd == 'preview' then
        local set_name = (arg or 'melee'):lower()
        if not SETS[set_name] then return say('no set "' .. set_name .. '"', 167) end
        local chosen, points, skipped = plan(set_name)
        describe(chosen, points)
        if #skipped > 0 then say('left out: ' .. table.concat(skipped, '; ')) end
    elseif cmd == 'announce' then
        announce()
    elseif cmd == 'list' then
        local names = {}
        for k in pairs(SETS) do names[#names + 1] = k end
        table.sort(names)
        say('sets: ' .. table.concat(names, ', '))
    elseif SETS[cmd] then
        coroutine.schedule(function() apply(cmd) end, 0)
    else
        say('no set "' .. cmd .. '" (//bs list)', 167)
    end
end)
