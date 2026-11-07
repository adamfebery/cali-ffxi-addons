-- RDM GearSwap - Char2
--
-- Built 2026-10-04 from Char2's gearinfo dump (18:38) + findAll bag list,
-- checked against BG-Wiki's Red Mage page and Finans Gearset Guides/Red_Mage.
-- Every item named here is one Char2 owns, RDM can wear, and sits in the
-- inventory or a wardrobe (GearSwap can't equip from anything else).
--
-- What the build rests on: the FULL Atrophy +3 set. Five pieces give a set
-- bonus of Accuracy / Magic Accuracy +60, so most sets keep all five on and
-- only swap the slots where something else clearly wins.
--
-- Same conventions as Char2's BRD.lua:
--   * weapons change ONLY by //gs c command, so casting never swaps them
--     and never resets TP. Naegling and Tauret both carry Magic Accuracy
--     skill +250 and MAcc+40, so enfeebling from the sword loses nothing;
--   * RDM has no Dual Wield of its own. The off-hand is a second weapon
--     only under /NIN or /DNC (dual_wield()), otherwise Archduke's Shield.
--
-- Commands:
--   //gs c sword     Naegling  (+ Tauret under /NIN /DNC, else Archduke's Shield)
--   //gs c dagger    Tauret    (+ Naegling under /NIN /DNC, else Archduke's Shield)
--   //gs c dt        toggle the DT engaged set (also: dt on / dt off)
--
-- vs THE GUIDES - what they build around that Char2 doesn't own yet, roughly
-- biggest first: Sucellos's Cape (FC / MND / WSD), Lethargy +3 (enfeebling
-- potency, Composure duration on others), Vitiation +3/+4 (enfeebling skill,
-- enhancing skill), Crocea Mors / Daybreak / Murgleis, Telchine (enhancing
-- duration), Malignance, Nyame, Stikini Rings, Regal/Snotra Earrings,
-- Duelist's Torque, Embla Sash. (Kishar Ring, Ghostfyre Cape and the
-- Bunzi's set + Rod arrived in the 2026-11-07 dump and are now used.)
--
-- MOVE THESE IF YOU WANT THEM (not equippable from where they are):
--   satchel  Olympus Sash   Enhancing magic skill +5 (Temper / En-spells / Gain)
--
-- Breakpoints the guides care about, and where you are:
--   Fast Cast: cap 80%. RDM's Fast Cast V trait is 30%; the precast set adds
--   30% more = 60%. Sucellos's Cape (+10) is the biggest single step up.
--   Frazzle III / Distract III want enfeebling skill 610 / 625 - out of reach
--   without Vitiation and Lethargy, so this file goes for accuracy instead.

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()
end

function user_setup()
    DT_MODE = false
    select_default_macro_book()
end

-- RDM has no Dual Wield trait. This is the single gate for every sub-slot
-- decision, same helper and same two subjobs as BRD.lua / COR.lua.
function dual_wield()
    return player.sub_job == 'NIN' or player.sub_job == 'DNC'
end

function init_gear_sets()

    ---------------------------------------------------------------------------
    -- Weapons - the only sets that ever touch main/sub
    ---------------------------------------------------------------------------

    -- Archduke's Shield: INT/MND+20, Refresh+1. The shield when single-wielding.
    sets.weapons = {}
    sets.weapons.Sword    = {main="Naegling", sub="Archduke's Shield"}
    sets.weapons.SwordDW  = {main="Naegling", sub="Tauret"}
    sets.weapons.Dagger   = {main="Tauret",   sub="Archduke's Shield"}
    sets.weapons.DaggerDW = {main="Tauret",   sub="Naegling"}

    ---------------------------------------------------------------------------
    -- Precast
    ---------------------------------------------------------------------------

    -- Fast Cast 30% gear + 30% trait = 60% (cap 80%).
    --   Atrophy Chapeau +3 16, Aya. Cosciales +2 6, Loquac. Earring ~2,
    --   Teal Saio +1 / Cuffs +1 / Pigaches +1 = 3-piece Teal bonus 6.
    -- Three Teal pieces beat the full five-piece Teal set (10%): head and
    -- legs do more than 4% between them on their own.
    sets.precast.FC = {
        head="Atrophy Chapeau +3",    -- Fast Cast+16%
        body="Teal Saio +1",          -- Teal set piece
        hands="Teal Cuffs +1",        -- Teal set piece
        legs="Aya. Cosciales +2",     -- Fast Cast+6%, DT-5%
        feet="Teal Pigaches +1",      -- Teal set piece (3 pieces = FC+6%)
        left_ear="Loquac. Earring",   -- Fast Cast+2%
        right_ear="Alabaster Earring",-- DT-5%
        left_ring="Murky Ring",       -- DT-10%
        right_ring="Kishar Ring",     -- Fast Cast+4% (2026-11-07) -> 64%
    }

    ---------------------------------------------------------------------------
    -- Midcast - Enfeebling. Magic accuracy first: nothing lands if it's
    -- resisted. Full Atrophy +3 (MAcc set bonus +60, MND/INT 29-44 a piece,
    -- Tabard Enfeebling skill+21), Null Shawl MAcc+50.
    ---------------------------------------------------------------------------

    sets.midcast['Enfeebling Magic'] = {
        ammo="Hydrocera",             -- MND+3, MAcc+6
        head="Atrophy Chapeau +3",    -- MAcc+54, MND+37 INT+37
        body="Atrophy Tabard +3",     -- MAcc+55, MND+43, Enfeebling skill+21
        hands="Atrophy Gloves +3",    -- MND+43
        legs="Atrophy Tights +3",     -- MND+39 INT+44
        feet="Atro. Boots +3",        -- MND+29 (5/5 Atrophy: MAcc+60)
        neck="Farr Torque",           -- MAcc+1 - the only MAcc neck you own
        waist="Obstin. Sash",         -- MND+5, Enfeebling duration+5%
        left_ear="Loquac. Earring",
        right_ear="Alabaster Earring",
        left_ring="Ayanmo Ring",      -- MAcc+6
        right_ring="Kishar Ring",     -- MAcc+5, Enfeebling duration+10% (2026-11-07)
        back="Null Shawl",            -- MAcc+50
    }

    -- Dispel, Sleep, Silence, Break, Bind, Gravity: pure accuracy. Eschan
    -- Stone's MAcc+7 over the Sash's MND/duration.
    sets.midcast.EnfeeblingAcc = set_combine(sets.midcast['Enfeebling Magic'], {
        waist="Eschan Stone",         -- MAcc+7
    })

    ---------------------------------------------------------------------------
    -- Midcast - Enhancing
    ---------------------------------------------------------------------------

    -- Duration (Haste, Protect, Shell, Phalanx on others, Flurry ...):
    -- Atrophy Gloves +3 is your only duration piece (+20%). Tights add
    -- Enhancing skill+21 for the skill-scaled spells (Temper, En-spells,
    -- Gain, Phalanx, Stoneskin).
    sets.midcast['Enhancing Magic'] = {
        head="Atrophy Chapeau +3",
        body="Atrophy Tabard +3",
        hands="Atrophy Gloves +3",    -- Enhancing magic duration+20%
        legs="Atrophy Tights +3",     -- Enhancing magic skill+21
        feet="Atro. Boots +3",
        left_ear="Loquac. Earring",
        right_ear="Alabaster Earring",
        left_ring="Murky Ring",
        right_ring="Ayanmo Ring",
        back="Null Shawl",
    }

    -- Refresh: the Tabard's "Refresh" potency +2 (already on above, but named
    -- here so Mote picks the Refresh map explicitly).
    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        body="Atrophy Tabard +3",     -- "Refresh" potency+2
    })

    ---------------------------------------------------------------------------
    -- Midcast - Healing
    ---------------------------------------------------------------------------

    -- Cure: MND + Cure potency. Atrophy Tights +3 Cure potency+12%, and the
    -- rest of the Atrophy set is your highest MND in every slot.
    -- 2026-11-07: Bunzi's Robe (Cure potency+15%, same MND+43) over the
    -- Tabard, and Ghostfyre Cape (Cure potency+6%) over Null Shawl.
    -- Cure potency 12% -> 33% (cap 50%).
    sets.midcast.Cure = {
        ammo="Hydrocera",
        head="Atrophy Chapeau +3",    -- MND+37
        body="Bunzi's Robe",          -- Cure potency+15%, MND+43
        hands="Atrophy Gloves +3",    -- MND+43
        legs="Atrophy Tights +3",     -- Cure potency+12%, MND+39
        feet="Atro. Boots +3",        -- MND+29
        waist="Obstin. Sash",         -- MND+5
        left_ear="Loquac. Earring",
        right_ear="Alabaster Earring",
        left_ring="Murky Ring",
        right_ring="Ayanmo Ring",
        back="Ghostfyre Cape",        -- Cure potency+6%
    }
    sets.midcast.Curaga = sets.midcast.Cure

    ---------------------------------------------------------------------------
    -- Midcast - Elemental. 2026-11-07: FULL BUNZI'S. Every piece is MAB+30,
    -- MAcc+40, and beats the old slot on INT too (Robe 48 vs 43, Gloves 34
    -- vs 28, Pants 51 vs 44, Sabots 32 vs 25). Magic burst damage 7+10+8+9+6
    -- = +40, the MB cap, so the Chapeau's MB+10 isn't needed. MAB 69 -> 150.
    -- Ghastly Tathlum: Magic Damage+10. Naegling's MAB+16 / Magic Damage+217
    -- still help; Bunzi's Rod (new) is better for nuking but weapons only
    -- change by command - see the summary in GS Changes.md.
    ---------------------------------------------------------------------------

    sets.midcast['Elemental Magic'] = {
        ammo="Ghastly Tathlum",       -- Magic Damage+10, MP+30
        head="Bunzi's Hat",           -- MAB+30, MB+7, INT+34
        body="Bunzi's Robe",          -- MAB+30, MB+10, INT+48
        hands="Bunzi's Gloves",       -- MAB+30, MB+8, INT+34
        legs="Bunzi's Pants",         -- MAB+30, MB+9, INT+51
        feet="Bunzi's Sabots",        -- MAB+30, MB+6, INT+32
        neck="Farr Torque",
        waist="Eschan Stone",         -- MAB+7, MAcc+7
        left_ear="Loquac. Earring",
        right_ear="Alabaster Earring",
        left_ring="Ayanmo Ring",
        right_ring="Murky Ring",
        back="Null Shawl",            -- MAcc+50
    }

    ---------------------------------------------------------------------------
    -- Idle. Refresh: Tabard +3 and Archduke's Shield. 2026-11-07: Bunzi's
    -- Hat -7 / Gloves -8 / Pants -9 / Sabots -6 replace Zucchetto -3 and
    -- Cosciales -5. DT-26% -> -48%: Bunzi's 30, Alabaster 5, Murky 10,
    -- Ayanmo Ring 3. Sabots also Magic Evasion 150 vs the Boots' 127.
    ---------------------------------------------------------------------------

    sets.idle = {
        ammo="Hydrocera",
        head="Bunzi's Hat",           -- DT-7%
        body="Atrophy Tabard +3",     -- Refresh+3
        hands="Bunzi's Gloves",       -- DT-8%
        legs="Bunzi's Pants",         -- DT-9%
        feet="Bunzi's Sabots",        -- DT-6%, Magic Evasion+150
        neck="Farr Torque",
        waist="Eschan Stone",
        left_ear="Alabaster Earring", -- DT-5%, HP+100
        right_ear="Loquac. Earring",
        left_ring="Murky Ring",       -- DT-10%
        right_ring="Ayanmo Ring",     -- DT-3%
        back="Null Shawl",            -- Evasion / Magic Evasion+50
    }

    ---------------------------------------------------------------------------
    -- Melee. No main/sub here - see the weapon sets.
    -- Haste is far past the 26% gear cap (Zucchetto 6, Tabard 3, Gloves 3,
    -- Volte 9, Boots 4, Sailfi 9, Alabaster 5), so every slot after that
    -- goes to accuracy and TP. Tabard + Gloves + Boots = 3 Atrophy pieces,
    -- Accuracy+30 from the set bonus.
    ---------------------------------------------------------------------------

    sets.engaged = {
        head="Aya. Zucchetto +2",     -- Acc+44, STP+6, Haste+6%, DT-3%
        body="Atrophy Tabard +3",     -- Refresh+3 (Atrophy 1/3)
        hands="Atrophy Gloves +3",    -- Acc+53, Att+30, DEX+43 (2/3)
        legs="Volte Tights",          -- STP+8, Acc+38, Haste+9%
        feet="Atro. Boots +3",        -- Acc+56 (3/3: Acc+30)
        neck="Anu Torque",            -- Att+20, STP+7
        waist="Sailfi Belt +1",       -- Haste+9%, TA+2%
        left_ear="Brutal Earring",    -- DA+5%, STP+1
        right_ear="Alabaster Earring",-- Haste+5%, DT-5%
        left_ring="Petrov Ring",      -- DA+1%, STP+5
        right_ring="Rajas Ring",      -- STP+5, STR/DEX+5
        back="Null Shawl",            -- Acc+50, DA+7%, STP+7
    }

    -- /NIN or /DNC: Suppanomimi (Dual Wield+5) in for the Alabaster.
    sets.engagedDW = set_combine(sets.engaged, {
        right_ear="Suppanomimi",
    })

    -- DT (2026-11-07): Bunzi's Hat -7, Gloves -8, Pants -9, Murky -10,
    -- Ayanmo Ring -3, Alabaster -5 = DT-42% (was -26%). Haste stays past the
    -- cap (Hat 6, Tabard 3, Gloves 3, Pants 5, Boots 4, Sailfi 9, Alabaster 5).
    -- Gloves add "Double Attack"+8%; costs the Atrophy 3pc (Acc+30 -> 2pc +15).
    sets.engagedDT = set_combine(sets.engaged, {
        head="Bunzi's Hat",           -- DT-7%, Acc+40, Haste+6%
        hands="Bunzi's Gloves",       -- DT-8%, Acc+40, DA+8%
        legs="Bunzi's Pants",         -- DT-9%, Acc+40, Haste+5%
        left_ring="Murky Ring",       -- DT-10%
        right_ring="Ayanmo Ring",     -- DT-3%
    })
    sets.engagedDTDW = set_combine(sets.engagedDT, {
        left_ear="Suppanomimi",       -- keep Alabaster (DT), lose Brutal
    })

    ---------------------------------------------------------------------------
    -- Weapon skills
    ---------------------------------------------------------------------------

    -- SAVAGE BLADE: STR 50% / MND 50%, WSD. Full Atrophy is STR+MND 66-82 a
    -- slot AND Accuracy+60; Gloves add WSD+6%. Karieyh WSD+3%.
    sets.precast.WS['Savage Blade'] = {
        ammo="Hydrocera",             -- MND+3
        head="Atrophy Chapeau +3",    -- STR+29 MND+37
        body="Atrophy Tabard +3",     -- STR+31 MND+43
        hands="Atrophy Gloves +3",    -- WSD+6%, STR+21 MND+43, Att+30
        legs="Atrophy Tights +3",     -- STR+35 MND+39
        feet="Atro. Boots +3",        -- (5/5: Acc+60)
        neck="Anu Torque",            -- Att+20
        waist="Sailfi Belt +1",       -- Att+10~15
        left_ear="Brutal Earring",
        right_ear="Alabaster Earring",
        left_ring="Karieyh Ring",     -- WSD+3%
        right_ring="Rajas Ring",      -- STR+5
        back="Penetrating Cape",      -- Att+20
    }

    -- SANGUINE BLADE (sword) / AEOLIAN EDGE (dagger): magical. MAB from the
    -- elemental set, Gloves for WSD.
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.midcast['Elemental Magic'], {
        hands="Atrophy Gloves +3",    -- WSD+6%
        left_ring="Karieyh Ring",     -- WSD+3%
    })
    sets.precast.WS['Aeolian Edge'] = sets.precast.WS['Sanguine Blade']

    -- EVISCERATION (Tauret): DEX, crit. Melee set with WSD.
    sets.precast.WS['Evisceration'] = set_combine(sets.engaged, {
        left_ring="Karieyh Ring",
    })
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

local ACC_ENFEEBLES = S{
    'Dispel', 'Sleep', 'Sleep II', 'Sleepga', 'Silence', 'Break', 'Bind',
    'Gravity', 'Gravity II',
}

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Enfeebling Magic' and ACC_ENFEEBLES:contains(spell.english) then
        equip(sets.midcast.EnfeeblingAcc)
    end
end

function current_engaged_set()
    if DT_MODE then
        return dual_wield() and sets.engagedDTDW or sets.engagedDT
    end
    return dual_wield() and sets.engagedDW or sets.engaged
end

function job_handle_equipping_gear(playerStatus, eventArgs)
    if playerStatus == 'Engaged' then
        equip(current_engaged_set())
        eventArgs.handled = true
    end
end

function job_self_command(cmdParams, eventArgs)
    local cmd = cmdParams[1] and cmdParams[1]:lower() or ''

    if cmd == 'sword' then
        equip(dual_wield() and sets.weapons.SwordDW or sets.weapons.Sword)
        add_to_chat(122, 'GearSwap: Naegling / ' .. (dual_wield() and 'Tauret' or "Archduke's Shield"))

    elseif cmd == 'dagger' then
        equip(dual_wield() and sets.weapons.DaggerDW or sets.weapons.Dagger)
        add_to_chat(122, 'GearSwap: Tauret / ' .. (dual_wield() and 'Naegling' or "Archduke's Shield"))

    elseif cmd == 'dt' then
        local arg = cmdParams[2] and cmdParams[2]:lower() or nil
        if arg == 'on' then DT_MODE = true
        elseif arg == 'off' then DT_MODE = false
        else DT_MODE = not DT_MODE end
        add_to_chat(122, 'GearSwap: DT mode ' .. (DT_MODE and 'ON (DT-42%)' or 'OFF'))
        if player.status == 'Engaged' then equip(current_engaged_set()) end
    end
end

-- TODO: set these to Char2's real RDM macro book and lockstyle. With the
-- book left nil the macro book isn't touched; LOCKSTYLE_SET = 0 locks to
-- whatever you're wearing.
RDM_MACRO_BOOK = nil
LOCKSTYLE_SET = 0

function select_default_macro_book()
    if RDM_MACRO_BOOK then
        set_macro_page(1, RDM_MACRO_BOOK)
    end
    if LOCKSTYLE_SET and LOCKSTYLE_SET > 0 then
        send_command('wait 5; input /lockstyleset ' .. LOCKSTYLE_SET)
    else
        send_command('wait 5; input /lockstyleset')
    end
end
