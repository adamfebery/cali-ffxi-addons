-- SCH GearSwap (Char1) - nuke / magic burst, heal / support, enfeeble,
-- Drain / Aspir, and an optional melee TP + weapon skill mode.
--
-- Rebuilt 2026-09-29 around the Academic +3 set (head / body / hands / legs /
-- feet, wardrobe3), checked against bg-wiki's Community Scholar Guide. Every
-- item named here is one Char1 owns and SCH can wear.
--
-- STILL TO MOVE into a wardrobe (as of the 2026-09-29 12:21 parse) - only
-- the club pair, and only if you want //gs c club:
--   locker   Cagliostro's Rod, Culminus
-- Everything else the sets name is in inventory or a wardrobe. Theurgist's
-- Slacks (wardrobe3), Argute M.board, Scholar's M.board and Vermillion Cloak
-- are no longer used by any set.
--
-- Same conventions as WAR / SAM / COR:
--   * weapons live ONLY in sets.weapons and change only by //gs c command,
--     so casting never swaps your staff and melee TP is never reset;
--   * Arbatel Earring goes in the RIGHT ear only ("Right ear:" stats);
--   * overlays go in job_post_midcast, after Mote's base set, so they stick.
--
-- Commands:
--   //gs c staff     Venabulum + Daduchos Grip (default nuke / melee staff)
--   //gs c marin     Marin Staff + Daduchos Grip (Fast Cast+2, wind MAB+10)
--   //gs c club      Cagliostro's Rod + Culminus (MAB 16 + 20 on the shield)
--   //gs c pole      Malignance Pole + Daduchos Grip (DT-20%, HP+150 - survival)
--   //gs c mb        toggle magic burst mode (Acad. Gown +3's MB+10 on nukes)
--   //gs c acc       toggle nuke accuracy (Mote CastingMode Normal/Resistant)
--   //gs c prebuff   party prebuff: Reraise, Accession Protect / Shell,
--                    Accession + Perpetuance Regen (press again to cancel)
--   //gs c selfbuff  Stoneskin, Blink, Aquaveil
--   //gs c melee     toggle melee mode: TP set while engaged (off = you stay
--                    in idle gear when engaged, the usual caster setup)
--
-- vs THE COMMUNITY GUIDE - what it recommends that you don't own yet:
--   Arbatel +3 (Loafers: MB Bonus II + Klimaform, Bonnet: Rapture / Regen,
--   Bracers: Perpetuance, Pants: +99 effective MAcc in aligned Arts),
--   Pedagogy +3 (Gown: Sublimation / enhancing duration, Bracers: Cure
--   Potency II, Pants: Drain/Aspir, M.Board: Grimoire casting time),
--   Bunzi's Rod / Musa / Akademos / Daybreak / Marin Staff +1, Fi Follet Cape,
--   Argute Stole, Bookworm's Cape, Telchine, Mpaca's Staff.
--   Not chosen: Apollo's Staff for cures (a weapon swap resets TP), Impact
--   (needs Twilight Cloak).

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()
end

function user_setup()
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal')
    state.MeleeMode = M(false, 'Melee Mode')
    state.MagicBurst = M(false, 'Magic Burst')
    -- Set by the Trust addon ("gs c set MagicBurstMode Single") right before
    -- each of its bursts. Single wears the burst gear for one nuke, then
    -- job_aftercast turns it back Off. //gs c mb still forces it on for all.
    state.MagicBurstMode = M{['description']='Magic Burst', 'Off', 'Single', 'Always'}
end

function init_gear_sets()

    ---------------------------------------------------------------------------
    -- Weapons (only equipped by command)
    ---------------------------------------------------------------------------

    sets.weapons = {}
    sets.weapons.Staff = {
        main="Venabulum",             -- iL119: INT+20 MAB+28 Magic Damage+217 Conserve MP+5
        sub="Daduchos Grip",           -- Acc/MAcc+30 Haste+3% PDL+8% DT-3% (inventory). Guide nuke grip is Enki Strap (not owned)
    }
    sets.weapons.Marin = {
        main="Marin Staff",           -- iL119: MAB+28 MAcc+15 Fast Cast+2% Wind MAB+10 (locker)
        sub="Daduchos Grip",
    }
    -- 2026-10-18: Malignance Pole - the guide's weapon for both its MDB and
    -- DT sets. Damage taken -20% stacks with idle's -28% to reach -48%, and
    -- Magic Accuracy skill +215 beats Venabulum, but there's no MAB or
    -- Magic Damage, so swap back to the staff for nuking.
    sets.weapons.Pole = {
        main="Malignance Pole",       -- DT-20%, HP+150, VIT+40, MAcc skill +215 (inventory)
        sub="Daduchos Grip",
    }
    sets.weapons.Club = {
        main="Cagliostro's Rod",      -- MAB+16 MND+20 MAcc+13 (locker)
        sub="Culminus",               -- MAB+20 Magic Damage+75 (locker)
    }

    ---------------------------------------------------------------------------
    -- Precast
    ---------------------------------------------------------------------------

    -- Fast Cast: Acad. Mortar. +3 (8%) + Acad. Bracers +3 (9%, the guide's
    -- best FC hands) + Naji's Loop (1%) + Jhakri set bonus from Slops + Ring
    -- (2 pieces = 1%) = 19%. Acad. Loafers +3 add "Grimoire: spellcasting
    -- time -12%", a separate multiplier that applies when your Arts matches
    -- the spell (Light Arts / Addendum: White for white magic, Dark Arts /
    -- Addendum: Black for black) - so it's always worn here.
    -- (Was: five Jhakri pieces for set Fast Cast +4.)
    -- 2026-10-18: Malignance Earring adds Fast Cast+4% -> 23%.
    -- 2026-10-21 GearSwap-Optimizer pass: the five empty slots take HP/DT
    -- pieces that cost no fast cast (DT-8%, HP 186 -> 332). Its full pick also
    -- swapped the Loafers and both Jhakri pieces out, but it can't see the
    -- Grimoire -12% or the Jhakri set bonus, so those stay.
    sets.precast.FC = {
        head="Acad. Mortar. +3",      -- Fast Cast+8%
        body="Acad. Gown +3",         -- HP+91
        hands="Acad. Bracers +3",     -- Fast Cast+9%
        legs="Jhakri Slops +1",
        feet="Acad. Loafers +3",      -- Grimoire: spellcasting time -12%
        neck="Elite Royal Collar",    -- DT-5%
        waist="Plat. Mog. Belt",      -- DT-3%, HP+10%
        back="Pahtli Cape",
        left_ear="Malignance Earring",-- Fast Cast+4%
        right_ear="Eabani Earring",
        left_ring="Jhakri Ring",
        right_ring="Naji's Loop",     -- Fast Cast+1% (safe)
    }

    -- Cures: Pahtli Cape "Cure" spellcasting time -8% on top.
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {back="Pahtli Cape"})   -- sack
    sets.precast.FC.Curaga = sets.precast.FC.Cure

    -- Low-TP overlay for weapon skills whose fTP scales with TP.
    sets.MoonshadeWS = {left_ear="Moonshade Earring"}

    ---------------------------------------------------------------------------
    -- Midcast: black magic
    ---------------------------------------------------------------------------

    -- Free nukes and helixes: INT, then MAB, then MAcc (the guide's order).
    -- Jhakri +1 stays over Academic here - the Academic pieces carry little
    -- or no MAB (head +20, the rest 0) against Jhakri's 36-39 each.
    sets.midcast['Elemental Magic'] = {
        ammo="Ghastly Tathlum +1",    -- Magic Damage+11, MP+35 (Path A)
        head="Jhakri Coronal +1",     -- INT+33 MAB+38 MAcc+38
        body="Psycloth Vest",         -- INT+32 MAB+25
        hands="Jhakri Cuffs +1",      -- INT+33 MAB+37 (sack)
        legs="Jhakri Slops +1",       -- INT+49 MAB+39 MAcc+39
        feet="Jhakri Pigaches +1",    -- INT+30 MAB+36 Magic burst damage+5
        neck="Sibyl Scarf",           -- INT+10 MAB+10
        waist="Plat. Mog. Belt",      -- no MAB belt owned; DT-3% instead (locker)
        left_ear="Malignance Earring",-- INT+8 MAB+8 MAcc+10 (beats Moldavite's MAB+5)
        right_ear="Arbatel Earring",  -- RIGHT ear: MAB+7 Magic Damage+7, MAcc+7 augment
        left_ring="Acumen Ring",      -- INT+2 MAB+4
        right_ring="Jhakri Ring",     -- MAB+3 Magic burst damage+2
        back="Lugh's Cape",           -- INT+22 MAcc+20 Magic Damage+20 MAB+10
    }

    -- //gs c acc: the full Academic set for magic accuracy - each piece has
    -- MAcc+46~52, the 5-piece set bonus adds MAcc+60, and the loafers add
    -- "Grimoire: MAcc+20" under Dark Arts. Costs most of your MAB, so it's
    -- for targets that resist, not a default.
    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {
        head="Acad. Mortar. +3",
        body="Acad. Gown +3",
        hands="Acad. Bracers +3",
        legs="Acad. Pants +3",
        feet="Acad. Loafers +3",
        neck="Erra Pendant",          -- MAcc+17 (sack)
        left_ring="Vertigo Ring",     -- INT+5 MAcc+5 (case)
    })

    -- //gs c mb: Acad. Gown +3 is Magic burst damage+10, making 17% with the
    -- Jhakri Pigaches (+5) and Ring (+2) already in the nuke set. The guide's
    -- next step is Arbatel Loafers +3 (MB Bonus II).
    sets.magic_burst = {
        body="Acad. Gown +3",         -- MB+10 INT+44 MAcc+50 (trades Psycloth's MAB+25)
    }

    -- Kaustra is dark elemental - Archon Ring's dark MAB+5 comes from the
    -- dark-element overlay in job_post_midcast, like Noctohelix.
    sets.midcast.Kaustra = sets.midcast['Elemental Magic']

    -- Enfeebling (Sleep, Sleep II, Dispel, Break, Dispelga - all INT-based):
    -- magic accuracy, so the full Academic set. The guide calls Acad. Gown +3
    -- "great for dark arts enfeeble".
    sets.midcast['Enfeebling Magic'] = {
        ammo="Hydrocera",             -- MAcc+6
        head="Acad. Mortar. +3",      -- MAcc+52
        body="Acad. Gown +3",         -- MAcc+50 INT+44
        hands="Acad. Bracers +3",     -- MAcc+48
        legs="Acad. Pants +3",        -- MAcc+49 INT+44
        feet="Acad. Loafers +3",      -- MAcc+46, Grimoire MAcc+20; set bonus MAcc+60
        neck="Erra Pendant",          -- MAcc+17
        waist="Plat. Mog. Belt",
        left_ear="Malignance Earring",-- MAcc+10 INT+8
        right_ear="Arbatel Earring",  -- MAcc+7
        left_ring="Vertigo Ring",     -- MAcc+5 INT+5
        right_ring="Jhakri Ring",     -- MAcc+6
        back="Lugh's Cape",           -- MAcc+20
    }

    -- Drain / Aspir: potency, dark magic and MAcc. Acad. Gown +3 is on the
    -- guide's list for these ("Dark Arts"+24 boosts dark magic under DA).
    sets.midcast.Drain = set_combine(sets.midcast['Enfeebling Magic'], {
        neck="Erra Pendant",          -- Drain/Aspir potency+5, dark skill+10, MAcc+17
        left_ear="Hirudinea Earring", -- Enhances Drain and Aspir (sack)
        left_ring="Archon Ring",      -- Dark MAcc+5
    })
    sets.midcast.Aspir = sets.midcast.Drain

    ---------------------------------------------------------------------------
    -- Midcast: white magic
    ---------------------------------------------------------------------------

    -- Cures: Acad. Pants +3 "Cure" potency+15% (the guide: "quickly cap Cure
    -- Potency I") + Naji's Loop 1%, and the Academic pieces are also your
    -- best MND (37-43 each). 2026-10-18: Vanya Hood's Cure potency+10%
    -- (26% total) beats the Mortarboard's extra MND+10.
    sets.midcast.Cure = {
        ammo="Hydrocera",             -- MND+3
        head="Vanya Hood",            -- Cure potency+10%, MND+27, Conserve MP+6
        body="Acad. Gown +3",         -- MND+39
        hands="Acad. Bracers +3",     -- MND+43
        legs="Acad. Pants +3",        -- MND+39, Cure potency+15%
        feet="Acad. Loafers +3",      -- MND+29
        waist="Plat. Mog. Belt",
        back="Pahtli Cape",           -- MND+8
        left_ring="Naji's Loop",      -- Cure potency+1%
        right_ring="Vertigo Ring",    -- MND+5
    }
    sets.midcast.Curaga = sets.midcast.Cure

    -- Regen: Lugh's Cape carries "Regen" effect duration +15 as a base stat.
    -- (The guide's regen potency pieces - Arbatel Bonnet, Telchine, Musa -
    -- aren't owned.)
    sets.midcast.Regen = {back="Lugh's Cape"}

    -- Everything else enhancing: enhancing skill.
    sets.midcast['Enhancing Magic'] = {
        body="Argute Gown",           -- Enhancing magic skill+7 (locker)
    }

    ---------------------------------------------------------------------------
    -- Weapon skills (melee mode). Weapons still only change by command.
    ---------------------------------------------------------------------------

    -- Physical staff WS (Shattersoul, Spirit Taker, Full Swing ...).
    sets.WS_BASE = {
        head="Jhakri Coronal +1",     -- STR+28 INT+33 Acc+38 Att+38
        body="Psycloth Vest",         -- STR+21 INT+32
        hands="Jhakri Cuffs +1",      -- WSD+5% Acc+37
        legs="Jhakri Slops +1",       -- STR+44 INT+49
        feet="Jhakri Pigaches +1",
        neck="Peacock Amulet",        -- Accuracy+10
        left_ear="Ishvara Earring",   -- WSD+2%, replaced by Moonshade below 2750 TP
        right_ear="Telos Earring",    -- Acc/Att+10
        left_ring="Cornelia's Ring",  -- WSD+10%
        right_ring="Karieyh Ring",    -- WSD+3%
        back="Lugh's Cape",
    }
    sets.precast.WS = sets.WS_BASE

    -- Cataclysm: MAGICAL dark, 30% STR / 30% INT, fTP 1.75 / 3.75 / 6.5.
    -- Usable only with WAR / MNK / WHM / PLD / GEO as main or sub (bg-wiki).
    sets.precast.WS['Cataclysm'] = set_combine(sets.midcast['Elemental Magic'], {
        left_ring="Archon Ring",
        right_ring="Cornelia's Ring",
    })

    ---------------------------------------------------------------------------
    -- Idle / melee
    ---------------------------------------------------------------------------

    -- Worn over the idle set only while running (see 'gearinfo' in
    -- job_self_command). Standing still keeps the DT legs below.
    sets.Kiting = {legs="Track Pants +1"}   -- Movement speed +8% (2026-10-31)

    -- Acad. Gown +3's Refresh+3 replaces Vermillion Cloak (which also blocked
    -- the head slot), and the Academic pieces bring big Magic Evasion.
    -- Acad. Mortar. +3 is also the guide's "best piece for sublimation"
    -- (Sublimation+4), so it's worn here all the time.
    -- DT: Defending -10, Murky -10, Elite Royal Collar -5, Plat. Mog. -3 = -28%.
    sets.idle = {
        ammo="Hydrocera",
        head="Acad. Mortar. +3",      -- Sublimation+4, Magic Evasion+95
        body="Acad. Gown +3",         -- Refresh+3, MP+173
        hands="Volte Bracers",        -- Magic Evasion+102, status resistance+10
        legs="Acad. Pants +3",        -- Magic Evasion+127
        feet="Acad. Loafers +3",      -- Magic Evasion+127
        neck="Elite Royal Collar",    -- DT-5% (Regen+3 only for San d'Oria citizens;
                                      -- if you're Windurst, Sibyl Scarf's Refresh+1
                                      -- is the better idle neck)
        waist="Plat. Mog. Belt",      -- DT-3%, HP+10% (locker)
        left_ear="Moonshade Earring",
        right_ear="Arbatel Earring",
        left_ring="Defending Ring",   -- DT-10%
        right_ring="Murky Ring",      -- DT-10%, MP+30
        back="Lugh's Cape",
    }
    sets.resting = sets.idle

    -- Melee TP (//gs c melee). Jhakri keeps its Attack; the Academic set's
    -- Accuracy+60 bonus would cost all of it.
    sets.engaged = {
        head="Jhakri Coronal +1",     -- Acc+38 Att+38 Haste+3%
        body="Psycloth Vest",         -- Haste+3%
        hands="Jhakri Cuffs +1",      -- Acc+37 Att+37
        legs="Jhakri Slops +1",       -- Acc+39 Store TP+7 Haste+2%
        feet="Jhakri Pigaches +1",    -- Acc+36
        neck="Peacock Amulet",        -- Acc+10
        waist="Swift Belt",           -- Haste+4% Acc+3
        left_ear="Telos Earring",     -- Acc/Att+10 STP+5 DA+1%
        right_ear="Brutal Earring",   -- Double Attack, STP+1
        left_ring="Chirich Ring",     -- Acc+7 STP+5
        right_ring="Petrov Ring",     -- DA+1% STP+5
        back="Lugh's Cape",
    }
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' and player.tp < 2750 then
        equip(sets.MoonshadeWS)
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic' then
        if state.MagicBurst.value or state.MagicBurstMode.value ~= 'Off' then
            equip(sets.magic_burst)
        end
        -- Dark elemental nukes (Noctohelix, Kaustra): Archon Ring's dark MAB+5.
        if spell.element == 'Dark' then
            equip({left_ring="Archon Ring"})
        end
    end
end

---------------------------------------------------------------------------
-- Prebuff (//gs c prebuff, //gs c selfbuff)
--
-- The Community Scholar Guide's order, minus what SCH can't cast (Barspells,
-- Haste): Reraise, then Accession Protect, Accession Shell, and Accession +
-- Perpetuance Regen ("the biggest one") - 4 stratagem charges. Self:
-- Stoneskin, Blink, Aquaveil. Each uses the best tier you KNOW (Protect V
-- until you buy it falls back to IV, and so on), and the next step is sent
-- from aftercast - GearSwap also calls aftercast for interrupted / refused
-- actions, so a failed step is skipped, not stalled on. A 12s safety timer
-- skips anything that never answers. Press it again to cancel.
---------------------------------------------------------------------------

local prebuff = nil   -- {steps = {...}, expect = name, token = n} while running
local prebuff_token = 0

local function knows_spell(name)
    local r = gearswap.res.spells:with('en', name)
    local known = windower.ffxi.get_spells()
    return r and known and known[r.id] and true or false
end

local function best_known(names)
    for _, name in ipairs(names) do
        if knows_spell(name) then
            return name
        end
    end
end

local function prebuff_stop(why)
    prebuff = nil
    add_to_chat(122, 'GearSwap: prebuff stopped (' .. why .. ')')
end

local function prebuff_next(after_spell)
    local step = prebuff and table.remove(prebuff.steps, 1)
    if not step then
        if prebuff then prebuff_stop('done') end
        return
    end
    prebuff.expect = step.name
    prebuff_token = prebuff_token + 1
    -- After a spell the game needs a moment before the next action.
    local wait = after_spell and 2.8 or 1.3
    send_command(('wait %.1f; input %s; wait 12; gs c prebuff_check %d'):format(wait, step.cmd, prebuff_token))
end

local function prebuff_start(kind)
    if prebuff then
        prebuff_stop('cancelled')
        return
    end
    local steps = {}
    local function ja(name)
        steps[#steps + 1] = {name = name, cmd = '/ja "' .. name .. '" <me>'}
    end
    local function ma(name)
        if name then
            steps[#steps + 1] = {name = name, cmd = '/ma "' .. name .. '" <me>'}
        end
    end

    if kind == 'party' then
        if not (buffactive['Light Arts'] or buffactive['Addendum: White']) then
            ja('Light Arts')          -- Accession / Perpetuance need it
        end
        ma(best_known({'Reraise III', 'Reraise II', 'Reraise'}))
        local pro = best_known({'Protect V', 'Protect IV', 'Protect III', 'Protect II', 'Protect'})
        if pro then ja('Accession') ma(pro) end
        local shell = best_known({'Shell V', 'Shell IV', 'Shell III', 'Shell II', 'Shell'})
        if shell then ja('Accession') ma(shell) end
        local regen = best_known({'Regen V', 'Regen IV', 'Regen III', 'Regen II', 'Regen'})
        if regen then ja('Accession') ja('Perpetuance') ma(regen) end
    else
        for _, name in ipairs({'Stoneskin', 'Blink', 'Aquaveil'}) do
            if knows_spell(name) then ma(name) end
        end
    end

    if #steps == 0 then
        add_to_chat(122, 'GearSwap: prebuff - nothing to cast')
        return
    end
    local names = {}
    for _, s in ipairs(steps) do names[#names + 1] = s.name end
    add_to_chat(122, 'GearSwap: prebuff running: ' .. table.concat(names, ' > '))
    prebuff = {steps = steps}
    prebuff_next(false)
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic' and state.MagicBurstMode.value == 'Single' then
        state.MagicBurstMode:set('Off')
    end
    if prebuff and spell.english == prebuff.expect then
        prebuff_next(spell.action_type == 'Magic')
    end
end

-- Engaged but not in melee mode: stay in idle (refresh / DT) gear.
function customize_melee_set(meleeSet)
    if not state.MeleeMode.value then
        return sets.idle
    end
    return meleeSet
end

function job_self_command(cmdParams, eventArgs)
    local cmd = cmdParams[1] and cmdParams[1]:lower() or ''

    -- gearinfo sends 'gs c gearinfo <dw> <haste> <moving> <ma>' a few times a
    -- second. Only the moving flag is used: sets.Kiting goes on over the idle
    -- set while you run, and comes off (back to the DT legs) when you stop.
    if cmd == 'gearinfo' then
        local moving = cmdParams[4] == 'true'
        if moving ~= gearinfo_moving then
            gearinfo_moving = moving
            if player.status == 'Idle' and not midaction() then
                handle_equipping_gear(player.status)
            end
        end
        eventArgs.handled = true
        return
    end

    if cmd == 'staff' or cmd == 'marin' or cmd == 'club' or cmd == 'pole' then
        local key = ({staff = 'Staff', marin = 'Marin', club = 'Club', pole = 'Pole'})[cmd]
        equip(sets.weapons[key])
        add_to_chat(122, 'GearSwap: weapons = ' .. sets.weapons[key].main)

    elseif cmd == 'melee' then
        state.MeleeMode:toggle()
        add_to_chat(122, 'GearSwap: Melee mode ' .. (state.MeleeMode.value and 'ON' or 'OFF'))
        handle_equipping_gear(player.status)

    elseif cmd == 'mb' then
        state.MagicBurst:toggle()
        add_to_chat(122, 'GearSwap: Magic Burst mode ' .. (state.MagicBurst.value and 'ON' or 'OFF'))

    elseif cmd == 'prebuff' then
        prebuff_start('party')
    elseif cmd == 'selfbuff' then
        prebuff_start('self')
    elseif cmd == 'prebuff_check' then
        -- The 12s safety timer: if that step never reached aftercast, skip it.
        if prebuff and tonumber(cmdParams[2]) == prebuff_token then
            add_to_chat(122, 'GearSwap: prebuff - ' .. tostring(prebuff.expect) .. ' got no answer, skipping')
            prebuff_next(true)
        end

    elseif cmd == 'acc' then
        state.CastingMode:cycle()
        add_to_chat(122, 'GearSwap: Nuke mode = '
            .. (state.CastingMode.value == 'Resistant' and 'Accuracy' or 'Normal'))
    end
end

-- Lockstyle, same as your other jobs. Macro book 7 is a guess - set it to
-- your SCH book.
LOCKSTYLE_SET = 39

function select_default_macro_book()
    set_macro_page(1, 7)
    add_to_chat(122, 'GearSwap: macro book 7 page 1 for SCH')
    if LOCKSTYLE_SET and LOCKSTYLE_SET > 0 then
        add_to_chat(122, 'GearSwap: applying lockstyleset ' .. LOCKSTYLE_SET
            .. ' for ' .. (player and player.main_job or '?') .. ' (5s delay)')
        send_command('wait 5; input /lockstyleset ' .. LOCKSTYLE_SET
            .. '; wait 2; input /echo GearSwap: lockstyleset ' .. LOCKSTYLE_SET .. ' sent.')
    end
end

-- Running while idle: add sets.Kiting (Track Pants +1) on top of the idle set.
function customize_idle_set(idleSet)
    if gearinfo_moving and sets.Kiting then
        return set_combine(idleSet, sets.Kiting)
    end
    return idleSet
end
