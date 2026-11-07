-- WHM GearSwap (Char3) - built 2026-10-18 from Char3's gearinfo dump,
-- following Job Guides\WHM - White Mage.md. Every item named here is one
-- Char3 owns and WHM can wear. HealBot picks the spells; this file only
-- picks the gear, so the two work together.
--
-- 2026-10-18 (second dump): Weatherspoon Corona / Robe / Cuffs / Souliers,
-- Cleric's Torque and Sors Shield added. Every slot is now filled; where
-- nothing owned helps a set, the slot takes DT / HP / magic evasion instead.
--
-- 2026-10-24 (invdump + third gearinfo dump): Theo. Mitts +1 and Theo.
-- Duckbills +1 go into base (more MND, magic evasion, Healing / Enhancing /
-- Enfeebling skill, SIRD-25%). Cure keeps Weather. Cuffs for the potency;
-- Holy keeps Weather. Souliers for the MAB. Aptitude Mantle +1 fills back.
--
-- 2026-10-24 (second invdump): Theophany Cap, Theo. Bliaut, Theo. Pantaloons.
-- Cap -> base + Cure + cure precast; Bliaut -> Cure only (Doublet's Refresh+2
-- and Macc+39 win elsewhere); Pantaloons -> new Cursna and Regen sets only
-- (Volte Hose wins elsewhere). Tlamiztli Collar is melee-only, unused.
--
-- 2026-10-25 (third invdump): Theophany Cap -> +2, Theo. Bliaut -> +1, plus
-- NQ Orison Pantaloons. Cap +2 (Cure potency +11%, Macc+37, MND+32) also
-- takes enfeebling from Weather. Corona. Bliaut +1 now has Refresh+2, but the
-- Doublet still wins idle on magic evasion (123 vs 80) and MDB (8 vs 6), so
-- the Bliaut stays Cure-only. Orison Pantaloons (DEF:36 MND+2) is unused: it
-- is the start of the Ebers Pant. path (Magian 4178 -> +1, then Monisette).
--
-- 2026-10-25 (fourth invdump): Ebers Pantaloons (NQ) - the guide's "must
-- have": 5% of every Cure comes back as MP. Cure / Curaga legs (over Volte
-- Hose, MND 22 vs 23), plus Healing magic precast (casting time -12%,
-- Divine Benison+1 = more Fast Cast on -na spells). Not idle: the Hose has
-- more magic evasion and MDB, and the Ebers has no DT until +2.
--
-- 2026-10-25 (fifth invdump): Ababinili (Cure potency +23%, Unity ranking
-- +6~10% more, Cure casting time -10%) + Dominie's Grip (Cure casting time
-- -2%). Cures swap to the staff: grip in precast, Mensch Strap +1 (PDT/
-- Regen) in midcast. That puts potency over the 50% cap, so Cure hands go
-- from Weather. Cuffs (8%, MND+17) to Theo. Mitts +1 (MND+38). Holy also
-- takes the staff for Magic Damage+186. Idle / enfeebling keep Queller Rod.
--
-- Totals:
--   Cure potency  50% capped (Ababinili +1 24 + Unity 6~10, Theophany Cap +2
--                 11, Bunzi's Robe 15 = 56-60%; see 2026-10-30 below).
--   Fast Cast     10% (Volte Doublet), Cure spellcasting time -19%
--                 (Ababinili +1 11, Dominie's Grip 2, Theophany Cap +2 6).
--   Refresh       +3 idle (Doublet 2, Queller 1).
--   DT            -15% base (Staunch 2, Murky 10, Thurandaut 3), plus Bunzi's
--                 Sabots 6 / Bunzi's Robe 10 where worn (idle up to -31%).
--
-- Back slot: Alaunus's Cape (MND+19 so far) - the guide's WHM cape.
--
-- Upgrades, in the order the guide's starter sets would slot them in:
--   Cure:   potency is capped - next is MND / DT / Conserve MP: Ebers
--           Pant. +2 (DT-12%), Mendi. Earring, Vanya Clogs,
--           Glorious Earring, Janniston Ring, Lebeche Ring
--   FC:     Gendewitha Gages, Inyanga Jubbah +2, Witful Belt, Loquac. Earring
--   Idle:   Inyanga +2 set, Defending Ring, Carrier's Sash
--   Cape:   finish Alaunus's augments (MND+20, then Cure potency / FC / DT)
--
-- Bags: Queller Rod, Sors Shield, Volte Doublet, all four Weatherspoon pieces,
-- Cleric's Torque, Ghastly Tathlum, Bathy Choker, all five Theophany pieces, Orison Pantaloons
-- and Alaunus's Cape are in INVENTORY - move them to a wardrobe when
-- there's room.
--
-- 2026-10-27 (gearinfo redump): Ababinili upgraded to Ababinili +1 (Cure
-- potency +24%, Cure casting time -11%, healing/enhancing skill +11).
--
-- 2026-10-30 (findAll dump): Alaunus's Cape, augmented MND+19 so far (base:
-- DEF:15 "Afflatus Solace"+10 "Cursna"+25). Replaces Aptitude Mantle +1 in
-- base, so every set gets the MND (bigger cures, Macc, Holy damage), Cursna
-- gets +25, and Afflatus Solace cures put up more Stoneskin. Keep feeding it
-- Ambuscade threads for the rest of the augments. In INVENTORY. Aptitude
-- Mantle +1 is now unused - put it back on by hand if you want capacity points.
--
-- Weapons: Queller Rod + Sors Shield in base (Refresh+1, Macc). Cures and
-- Holy swap to Ababinili +1 + a grip - WHM has no TP to lose, so that's free.
--
-- 2026-10-30 (gearinfo redump): Bunzi's Robe and Bunzi's Sabots (unranked).
--   Robe (Cure potency +15%, DT-10%, MND+43, Magic Evasion+139, MDB+11):
--     Cure body over Theo. Bliaut +1 (7%). Potency is now 56-60% without
--     Cleric's Torque, so the neck stays on Bathy Choker. Also enfeebling
--     (Macc+40, DT) and Holy (MAB+30, Magic Damage+30). Idle body when MP is
--     75% or more; below that the Volte Doublet's Refresh+2 comes back
--     (Dane's idle rule). Checked after every cast and status change.
--   Sabots (DT-6%, Magic Evasion+150, MND+33): base feet, so idle is DT-31%
--     (DT-21% on the refresh body). Holy feet (MAB+30, Magic Damage+30 over
--     Souliers' MAB+10). Midcasts keep Theo. Duckbills +1 for Spell
--     interruption rate down 25% and Enhancing / Enfeebling skill +17.
--   Both in INVENTORY.
--
-- 2026-10-31 (gearinfo redump): Ebers Pant. +1 replaces the NQ (6% of each
-- Cure back as MP, MND+33, Healing magic casting time -13%, Divine Benison+2)
-- in Cure and Healing magic precast. Idle keeps Volte Hose (status
-- resistance, MDB+7). Kishar Ring (Fast Cast+4%, Magic Accuracy+5,
-- Enfeebling duration +10%) takes the right ring from Thurandaut in precast
-- and enfeebling / divine / Holy - DT-3% matters less there. In INVENTORY.

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()
end

function user_setup()
end

function init_gear_sets()

    ---------------------------------------------------------------------------
    -- Base: DT / HP / magic evasion in every slot. Every other set starts
    -- from this and only replaces the slots where it has something better.
    ---------------------------------------------------------------------------

    local base = {
        main="Queller Rod",           -- "Refresh"+1, Enmity-10
        sub="Sors Shield",            -- HP+10 MP+54, "Cure" potency +3%
        ammo="Staunch Tathlum",       -- DT-2%, Spell interruption rate -10%, status resistance+10
        head="Theophany Cap +2",      -- Magic Evasion+85, MDB+6, Enmity-5, Haste+6%
        body="Volte Doublet",         -- "Refresh"+2, Magic Evasion+123, MDB+8
        hands="Theo. Mitts +1",       -- Magic Evasion+37, MND+38, Healing magic skill +17, Enmity-5
        legs="Volte Hose",            -- Magic Evasion+102, MDB+7, status resistance
        feet="Bunzi's Sabots",        -- DT-6%, Magic Evasion+150, MDB+8, MND+33
        neck="Bathy Choker",          -- "Regen"+2, HP+30
        back="Alaunus's Cape",        -- MND+19, "Afflatus Solace"+10, "Cursna"+25
        waist="Salire Belt",          -- MP+25
        left_ear="Eabani Earring",    -- HP+45, Evasion+15, Magic Evasion+8
        right_ear="Phawaylla Earring",-- Evasion+7
        left_ring="Murky Ring",       -- DT-10%, Spell interruption rate down 3%
        right_ring="Thurandaut Ring", -- DT-3%
    }

    ---------------------------------------------------------------------------
    -- Precast
    ---------------------------------------------------------------------------

    -- Fast Cast 14%: Doublet 10 (already in base) + Kishar Ring 4. Your subjob adds more
    -- (/RDM Fast Cast trait 15%, /SCH Light Arts 2%). Cure spellcasting time
    -- -11% on cures: Sors Shield 5 + Theophany Cap +2 6 (both already in base).
    sets.precast.FC = set_combine(base, {
        right_ring="Kishar Ring",     -- "Fast Cast"+4%
    })
    -- Every Healing magic spell (-na, Erase, Raise, Cursna).
    sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {
        legs="Ebers Pant. +1",        -- Healing magic casting time -13%, "Divine Benison"+2
    })
    sets.precast.FC.Cure = set_combine(sets.precast.FC['Healing Magic'], {
        main="Ababinili +1",          -- "Cure" spellcasting time -11%
        sub="Dominie's Grip",         -- "Cure" spellcasting time -2%
        head="Theophany Cap +2",      -- "Cure" spellcasting time -6%
    })
    sets.precast.FC.Curaga = sets.precast.FC.Cure

    ---------------------------------------------------------------------------
    -- Midcast
    ---------------------------------------------------------------------------

    -- Cures: Cure potency first, then MND (more MND = bigger cures), then the
    -- DT / spell-interruption pieces from base so a cure lands while you're hit.
    sets.midcast.Cure = set_combine(base, {
        main="Ababinili +1",          -- "Cure" potency +24% (+6~10% Unity ranking), MND+12
        sub="Mensch Strap +1",        -- PDT-5%, "Regen"+3
        head="Theophany Cap +2",      -- "Cure" potency +11%, MND+32
        body="Bunzi's Robe",          -- "Cure" potency +15%, DT-10%, MND+43
        hands="Theo. Mitts +1",       -- MND+38 - potency is capped without Weather. Cuffs' 8%
        legs="Ebers Pant. +1",        -- 6% of Cure amount back as MP, MND+33
        feet="Theo. Duckbills +1",    -- MND+24, Spell interruption rate down 25%
        waist="Salire Belt",          -- MND+5
    })
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.CureSelf = sets.midcast.Cure

    -- -na spells, Raise, Cursna: base already has Theo. Mitts +1 (Healing
    -- magic skill +17, helps Cursna). Erase gets Cleric's Torque ("Erase"+1,
    -- one more debuff removed per cast).
    sets.midcast.StatusRemoval = set_combine(base, {
        feet="Theo. Duckbills +1",    -- Spell interruption rate down 25%
    })
    sets.midcast.Erase = set_combine(sets.midcast.StatusRemoval, {
        neck="Cleric's Torque",       -- "Erase"+1
    })
    sets.midcast['Healing Magic'] = sets.midcast.StatusRemoval
    sets.midcast.Cursna = set_combine(sets.midcast.StatusRemoval, {
        legs="Theo. Pantaloons",      -- Enhances "Cursna" effect
        back="Alaunus's Cape",        -- "Cursna"+25
    })

    -- Enhancing (Haste, Protect, Shell, Regen, Bar spells, Stoneskin).
    sets.midcast['Enhancing Magic'] = set_combine(base, {
        feet="Theo. Duckbills +1",    -- Enhancing magic skill +17, Spell interruption rate down 25%
    })
    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
        legs="Theo. Pantaloons",      -- Increases "Regen" effect duration
    })

    -- Enfeebling and Divine debuffs (Slow, Paralyze, Silence, Repose, Flash):
    -- Magic Accuracy, then MND.
    sets.midcast['Enfeebling Magic'] = set_combine(base, {
        main="Queller Rod",           -- Magic Accuracy+15, Magic Accuracy skill +215
        head="Theophany Cap +2",      -- Magic Accuracy+37, MND+32 (Corona: Macc+10, MND+17)
        body="Bunzi's Robe",          -- Magic Accuracy+40, MND+43, DT-10%
        hands="Theo. Mitts +1",       -- MND+38
        legs="Volte Hose",            -- Magic Accuracy+37, MND+23
        feet="Theo. Duckbills +1",    -- Enfeebling magic skill +17, MND+24
        waist="Salire Belt",          -- Magic Accuracy+4, MND+5
        right_ring="Kishar Ring",     -- Magic Accuracy+5, Enfeebling magic duration +10%
    })
    sets.midcast['Divine Magic'] = sets.midcast['Enfeebling Magic']

    -- Holy / Banish damage: Magic Attack Bonus / Magic Damage.
    sets.midcast.Holy = set_combine(sets.midcast['Enfeebling Magic'], {
        main="Ababinili +1",          -- Magic Damage+186, "Magic Atk. Bonus"+24, Magic Accuracy skill +228
        sub="Mensch Strap +1",        -- PDT-5% (a staff can't hold Sors Shield)
        ammo="Ghastly Tathlum",       -- Magic Damage+10
        body="Bunzi's Robe",          -- "Magic Atk. Bonus"+30, Magic Damage+30
        feet="Bunzi's Sabots",        -- "Magic Atk. Bonus"+30, Magic Damage+30
        left_ear="Friomisi Earring",  -- "Magic Atk. Bonus"+10
        right_ear="Hecate's Earring", -- "Magic Atk. Bonus"+6
    })
    sets.midcast.Banish = sets.midcast.Holy

    ---------------------------------------------------------------------------
    -- Idle
    ---------------------------------------------------------------------------

    -- MP below 75%: the base set (Refresh+3, DT-21%, Regen+2).
    -- MP 75% or more: Bunzi's Robe instead of the Doublet (DT-31%, Refresh+1).
    -- Worn over the idle set only while running (see 'gearinfo' in
    -- job_self_command). Standing still keeps the DT legs.
    sets.Kiting = {legs="Track Pants +1"}   -- Movement speed +8% (2026-10-31)

    sets.idle = set_combine(base, {})
    sets.idle.HighMP = set_combine(sets.idle, {
        body="Bunzi's Robe",          -- DT-10%, Magic Evasion+139, MDB+11
    })
    sets.resting = sets.idle
    sets.engaged = sets.idle
end

function customize_idle_set(idleSet)
    if player.mpp >= 75 then
        idleSet = set_combine(idleSet, sets.idle.HighMP)
    end
    -- Running: Track Pants +1 (see job_self_command).
    if gearinfo_moving and sets.Kiting then
        idleSet = set_combine(idleSet, sets.Kiting)
    end
    return idleSet
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
end
