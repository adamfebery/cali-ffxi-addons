-- COR GearSwap - Gun / Melee
--
-- Gun    = Anarchy +2 (TP Bonus +1000) or Doomsday (MAB/AGI/DA augments)
--          + Eminent Bullet. //gs c anarchy / //gs c doomsday picks the one
--          you hold - see GUNS for which suits Leaden Salute at what TP.
-- Roll   = Compensator, borrowed for Phantom Roll only
-- Melee  = Naegling + Nusku Shield           (Savage Blade)
-- /DNC   = Naegling + Lanun Knife in the off-hand (Dual Wield)
--
-- Same conventions as SAM.lua: main/sub/ammo live ONLY in sets.weapons and are
-- equipped ONLY by an explicit //gs c command. No main/sub/ammo in any TP, WS
-- or idle set, so nothing can swap your sword or your bullets out from under
-- you mid-fight.
--
-- There are three exceptions. The first is the range slot on a Phantom Roll:
-- Compensator's Phantom Roll duration +20 only counts if the gun is worn as the
-- roll lands, so it is equipped in sets.precast.CorsairRoll and put back by
-- job_aftercast. Both guns fire Eminent Bullet, so the ammo slot never changes.
--
-- The second is the sub slot under Dual Wield. With /DNC (or /NIN) the off-hand
-- can hold Lanun Knife instead of Nusku Shield, and it is wanted on both TP and
-- Savage Blade, so the melee TP set and the Savage Blade precast carry it. It is
-- never baked into the base sets - Lanun Knife in the sub slot is illegal without a
-- Dual Wield subjob - so it lives in sets.OffhandDW and is combined in.
--
-- The third is the main hand on a Phantom Roll: Lanun Knife's Path C roll
-- augment only counts in the main hand, so job_post_precast swaps it in for the
-- roll and job_aftercast puts Naegling back (skipped under Dual Wield, where the
-- one knife is already in the off-hand). See sets.RollKnife.
--
-- The fourth is an EMPTY ammo slot. Trust opens a Bullet Pouch when you are
-- under 10 Bullets, but the game never loads a new stack into the slot for you,
-- so refill_ammo() loads Eminent Bullet, else Bullet, from inventory or any
-- wardrobe - only when the slot is empty, so it can never swap out anything
-- you chose to wear.
--
-- Commands:
--   //gs c weapons     equip the full loadout (gun + sword + shield + bullet)
--   //gs c ranged      TP mode: shooting
--   //gs c melee       TP mode: swinging
--   //gs c lockback / //gs c unlockback
--
-- Camulus's Mantle is augmented DEX+20 / Accuracy+20 Attack+20 / Accuracy+10 /
-- "Double Attack"+10% / Damage taken-4%, so Accuracy totals +30 across two
-- separate augment lines. Still no Weapon Skill Damage and no
-- ranged stat at all, so the ranged sets keep using Amemet Mantle +1 (Ranged
-- Attack+15) - but the Damage taken-4% is new and makes the cape earn its idle
-- slot on defence as well as its TP slot on offence.
--
-- YOU NOW OWN TWO OF THIS CAPE - the augmented one above and a bare one with no
-- augments at all. GearSwap matches back="Camulus's Mantle" by NAME, so with two
-- in your bags it equips whichever it happens to find first, and roughly half
-- the time that is the empty one. Nothing in the log tells you this happened.
-- Every set therefore goes through the CAMULUS table defined at the top of
-- init_gear_sets, which pins the augments. Augment matching is a SUBSET test:
-- the two lines listed there are enough to tell the capes apart, and the ones
-- left out (Attack+20, Damage taken-4%) do not have to be written down.
--
-- If the back slot ever comes up EMPTY on COR, this is the first suspect: an
-- augment string that no longer matches what the game reports. Re-augmenting the
-- cape is what would do it. Re-run the gearinfo parse and read the ["augments"]
-- array for Camulus's Mantle out of addons/gearinfo/data/Char1_data.lua - those
-- strings are the exact ones GearSwap compares against.

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function user_setup()
    -- Melee first: M{} defaults to its first entry, and melee gear while
    -- shooting costs you less than ranged gear while swinging.
    state.TPMode = M{['description']='TP Mode', 'Melee', 'Ranged'}
    
    -- GearInfo's display toggles are saved per character in
    -- gearinfo/data/<name>_settings.xml, so they survive job changes on their own.
    -- Re-sending them from user_setup() (which Mote re-runs on EVERY job change)
    -- only produced a burst of GearInfo log lines in chat. Configure it once with
    -- //gi ... by hand instead.

    -- Quick Draw binds. These belong here rather than in scripts/init.txt
    -- because a bind set here only exists while COR.lua is loaded and is torn
    -- down again by file_unload() below - so Alt+D is free for other jobs
    -- instead of being a permanent global the way the Char2 bard binds are.
    --
    -- Alt+D and Alt+L are unused: init.txt currently claims f1-f6, ^q, ^v,
    -- ^f1-^f6, !f1-!f6, !f10, ^f10, %end and sysrq, and none of those collide.
    --
    -- <t> is the current target. Swap it for <stnpc> if you would rather pick
    -- the target off a sub-target cursor than fire at whatever is selected.
    send_command('bind !d input /ja "Dark Shot" <t>')
    send_command('bind !l input /ja "Light Shot" <t>')
end

-- Mote calls this when the job file unloads (job change, //gs reload, logout).
-- Without it the binds survive onto whatever job you switch to.
function file_unload()
    send_command('unbind !d')
    send_command('unbind !l')
end

function job_setup()
end

function init_gear_sets()

    -- The augmented Camulus's Mantle, pinned by augment so the bare duplicate in
    -- your bags can never be equipped in its place. See the header note above.
    -- Two augments are listed, not five: GearSwap only requires that every
    -- augment named here is present on the item, so this is enough to exclude a
    -- cape with no augments while giving the fewest strings that can go stale.
    -- Both strings are copied verbatim from the gearinfo dump of 2026-09-06 -
    -- note the abbreviation and the inner quotes, which are part of the string.
    CAMULUS = {
        name="Camulus's Mantle",
        augments={'DEX+20','"Dbl.Atk."+10'},
    }

    -- 2026-10-21: two more Camulus's Mantles are augmented now (invdump export),
    -- so there are three. Pinned the same way. Strings are from the gearinfo dump.
    --   CAMULUS_WSD    STR+20 / Acc+20 Atk+20 / STR+10 / WSD+10% / Regen+5 (Savage Blade)
    --   CAMULUS_MAGIC  AGI+20 / Magic Damage+10 / WSD+10%         (Leaden Salute, Wildfire)
    CAMULUS_WSD = {
        name="Camulus's Mantle",
        augments={'STR+20','Weapon skill damage +10%'},
    }
    CAMULUS_MAGIC = {
        name="Camulus's Mantle",
        augments={'AGI+20','Magic Damage +10'},
    }

    -- WHICH GUN TO HOLD (//gs c doomsday / //gs c anarchy). You can't swap
    -- guns for a single WS - changing the range weapon resets TP to 0 - so
    -- this is the gun you carry while building TP.
    --
    --   Anarchy +2  DMG 49, weapon Lv99, TP Bonus +1000, no Marksmanship skill
    --   Doomsday    DMG 120, iL119, Marksmanship skill +242, and your Alluvion
    --               augments: MAB+24, "Double Attack"+4, STR+19 AGI+19
    --
    -- Leaden Salute is a magical WS: base damage comes from the weapon's LEVEL
    -- (bg-wiki: 152 for Lv99, 152 + (iL-99)*2.45 = 201 for iL119), not its
    -- DMG. Modelled with this file's LEADEN set, Doomsday vs Anarchy +2:
    --     WS at 1000 TP  -18%     2000 TP  -1%     2250 TP +10%
    --     2500 TP        +20%     2750+ TP +30%
    -- (same within 2% for base AGI 100-130 and mob INT 150-250). Below 2000 the
    -- +1000 TP Bonus wins; from 2000 up it hits the 3000 cap and Doomsday's
    -- level, MAB and AGI win.
    --
    -- Doomsday also helps everything that isn't a gun WS: "Double Attack"+4
    -- works from the range slot for melee TP, STR+19 feeds Savage Blade, and
    -- Last Stand / Detonator use the gun's DMG (120 vs 49) and skill.
    -- Anarchy +2 is still the gun for firing Leaden or Last Stand at 1000 TP.
    GUNS = {doomsday = 'Doomsday', anarchy = 'Anarchy +2'}
    GUN_TP_BONUS = {['Anarchy +2'] = 1000, ['Doomsday'] = 0}
    -- The default on load. Kept as Anarchy +2 so nothing changes until you
    -- choose; set it to GUNS.doomsday if you mostly melee and WS at 2000+.
    current_gun = current_gun or GUNS.anarchy

    -- The only set that ever touches main/sub/ammo. It also sets your default
    -- gun; Phantom Roll is the only thing that borrows the range slot.
    -- Stinger Bullet is deliberately absent: it is RNG-only, COR cannot fire it.
    sets.weapons = {
        main="Naegling",              -- Savage Blade
        sub="Nusku Shield",           -- RACC+20, RATK+20, STP+3 - COR/RNG legal
        range=current_gun,            -- see GUNS above; //gs c doomsday / anarchy
        ammo="Eminent Bullet",        -- DMG 238, iL117, RNG/COR - fires from either gun
    }

    -- The off-hand under Dual Wield. Lanun Knife is COR-only (DMG:131 Delay:189,
    -- HP+140, Accuracy+40, Ranged Accuracy+40, Magic Accuracy+40, Magic Damage
    -- +201) and is the best off-hand you own: Rhadamanthus is DMG:106 with only
    -- Accuracy+13, and Joyeuse's DMG:35 is far too low to be worth a hand.
    -- Savage Blade is a 2-hit WS, and under Dual Wield the second hit swings the
    -- OFF-hand - so a 131-damage dagger there instead of a shield is a gain on
    -- the weaponskill as well as on TP.
    sets.OffhandDW = {sub="Lanun Knife"}

    -- Full loadout when the subjob grants Dual Wield. //gs c weapons picks
    -- between this and sets.weapons by reading the subjob.
    sets.weaponsDW = set_combine(sets.weapons, sets.OffhandDW)

    -- What job_aftercast puts back after a roll borrowed Compensator. No TP, WS
    -- or idle set contains a range slot, so without an explicit put-back you
    -- would carry on fighting with the roll gun still equipped.
    sets.TPGun = {range=current_gun}      -- follows //gs c doomsday / anarchy

    -- Main hand for a Phantom Roll, and what job_aftercast puts back after it.
    -- Lanun Knife's Path C augment only works in the MAIN hand. At its current
    -- rank that is "Phantom Roll" duration +17 (stacks with Compensator, the
    -- gloves and the cape) and "Phantom Roll"+3 (does NOT stack - Barataria
    -- Ring's +5 is the one that applies, so the ring stays). Swapping the main
    -- hand resets TP, but Compensator's range swap already does that on every
    -- roll, so the knife costs nothing extra. Equipped from job_post_precast,
    -- and skipped under Dual Wield: there is only one knife and it is already
    -- in the off-hand, where the augment does nothing.
    sets.RollKnife = {main="Lanun Knife"}
    sets.RollKnifeBack = {main="Naegling"}

    ---------------------------------------------------------------------------
    -- Ranged attack
    ---------------------------------------------------------------------------

    -- Precast RA: Snapshot only - shortens the shot windup.
    -- Anarchy +2 has no Snapshot. 2026-10-18: Comm. Charm +1 joins the Jambeaux.
    sets.precast.RA = {
        neck="Comm. Charm +1",        -- Snapshot+3, RACC+20 (wardrobe3)
        feet="Meg. Jam. +2",          -- Snapshot+10
    }

    -- Midcast RA: this is the set that actually decides shot damage.
    sets.midcast.RA = {
        head="Lanun Tricorne +2",     -- RATK+72, RACC+27, Haste+8% - best ranged head by a mile
        body="Meg. Cuirie +2",        -- RACC+50, RATK+46, crit dmg+6%
        hands="Meg. Gloves +2",       -- RACC+47, RATK+43
        legs="Meg. Chausses +2",      -- RACC+49, RATK+45
        feet="Meg. Jam. +2",          -- RACC+46, RATK+42, Snapshot+10
        neck="Peacock Amulet",        -- RACC+10. Kept on purpose: Accuracy-10 is irrelevant when shooting
        waist="Ponente Sash",         -- AGI+9, RATK+15. Was "Aristo Belt", which you don't
                                      -- own (not in any bag, 2026-09-28 findAll), so this
                                      -- slot silently kept whatever the TP set had on.
        left_ear="Telos Earring",     -- Acc/RACC/Atk/RATK +10, STP+5
        right_ear="Chas. Earring +1", -- Recycle+11 (ammo conservation), Enmity-8
        left_ring="Chirich Ring",
        right_ring="Petrov Ring",
        back="Amemet Mantle +1",      -- RATK+15. Camulus's has zero ranged stats, so it loses here
    }

    ---------------------------------------------------------------------------
    -- Melee TP
    ---------------------------------------------------------------------------

    -- Two real TP sets, switched by //gs c melee / //gs c ranged.
    -- Kept in their own table rather than as sets.engaged subtables: a
    -- self-referencing set table is a recursion hazard inside GearSwap.
    sets.TP = {}

    -- Swinging Naegling: melee Accuracy and Haste matter.
    sets.TP.Melee = {
        head="Meghanada Visor +2",    -- Acc+48, Haste+4% (Lanun has Haste+8% but no melee Accuracy)
        body="Malignance Tabard",     -- Acc+50, Haste+4%, STP+11, DT-9%, PDL+6%
        hands="Meg. Gloves +2",       -- Acc+47, Haste+4%
        legs="Meg. Chausses +2",      -- Acc+49, Haste+4%, TA+5%
        feet="Malignance Boots",      -- 2026-10-18: Acc+50, STP+9, DT-4%, Haste+3%.
                                      -- Replaces Lanun Bottes +2 (Acc+33, PDT-5%;
                                      -- their WSD+5% does nothing in a TP set).
                                      --
                                      -- WAS "Lanun Bottes +1", which you no longer own -
                                      -- you upgraded to +2 and the old name stopped
                                      -- matching anything, so this slot was silently
                                      -- keeping whatever was already on it.
                                      --
                                      -- The old note here also had the haste maths wrong.
                                      -- It counted only the armour and called the set 20%,
                                      -- under the 25% cap. It left out Sailfi Belt +1's
                                      -- Haste+9%: head 4 + body 4 + hands 4 + legs 4 +
                                      -- feet 4 + waist 9 = 29%, so you are 4% OVER the cap
                                      -- and the feet haste is pure overflow.
                                      --
                                      -- That inverts the old trade. Against Meg. Jam. +2
                                      -- (Acc+46, Haste+2%) the haste is worth nothing
                                      -- either way, so it is now just Acc 33 vs 46. The +2
                                      -- narrowed that gap from 46 points to 13 and pays it
                                      -- back with PDT-5%, so it stays - but if you are
                                      -- missing on a hard target, Meg. Jam. +2 is still
                                      -- the one slot to put back.
        neck="Defiant Collar",        -- Acc+8, Subtle Blow+3, TA+1%
        waist="Sailfi Belt +1",
        left_ear="Telos Earring",
        right_ear="Brutal Earring",   -- Double Attack
        left_ring="Chirich Ring",
        right_ring="Petrov Ring",
        back=CAMULUS,                 -- Acc+30, Atk+20, "Double Attack"+10% - the DA makes
                                      -- this the cape's best slot by a distance
    }

    -- Same set with the off-hand filled. Kept as a separate table rather than
    -- edited into sets.TP.Melee so the shield build stays intact for subjobs
    -- with no Dual Wield; current_tp_set() picks between them at equip time.
    --
    -- Suppanomimi (Dual Wield+5) only belongs here. /DNC at subjob level 49 gives
    -- Dual Wield II = 15% delay reduction; +5 takes that to 20%, which is about
    -- a 6% faster swing - ahead of the Double Attack+5% on the Brutal Earring it
    -- displaces. It goes in the RIGHT ear because Suppanomimi is legal in either
    -- ear while Telos is the better left-ear piece (Acc+10, Atk+10, "Store TP"+5,
    -- and the same again for ranged), so this is the cheaper of the two swaps.
    --
    -- It is deliberately NOT in sets.TP.Melee: with Nusku Shield in the off-hand
    -- you are not dual wielding and Dual Wield+5 does literally nothing there.
    --
    -- Hiza. Sune-Ate (Dual Wield+5, Haste+3%) is the other DW piece you own and
    -- is still left out, though the reason changed when Lanun Bottes +2 took the
    -- feet slot: the cost is no longer Meg. Jam. +2's Accuracy+46 but the boots'
    -- Haste+4% and PDT-4%. Hiza gives back 3% of that Haste and buys Dual Wield
    -- +5 on top of Suppanomimi's, so it is a closer call than it was - test it if
    -- you want, but it stays off by default.
    --
    -- 2026-10-21 GearSwap-Optimizer pass: Malignance Chapeau and Gloves,
    -- Samnuha Tights, Bladeborn + Steelflash (Suppanomimi out). TP 8.57s ->
    -- 6.74s, DT -22% -> -33%, still 99% hit rate vs an Apex Toad. (The optimizer
    -- also wanted Coiste Bodhar in ammo; left out - the ammo slot holds bullets.)
    sets.TP.MeleeDW = set_combine(sets.TP.Melee, sets.OffhandDW, {
        head="Malignance Chapeau",
        hands="Malignance Gloves",
        legs="Samnuha Tights",
        left_ear="Bladeborn Earring",
        right_ear="Steelflash Earring",
    })

    -- Shooting: melee Accuracy is irrelevant, so hold the ranged gear between
    -- shots instead of swapping to melee gear and back. Same gear as midcast.RA
    -- (Lanun's Haste+8% and RATK+72 stay on).
    sets.TP.Ranged = sets.midcast.RA

    -- Mote's own fallback if anything reaches it before the mode is read.
    sets.engaged = sets.TP.Melee

    ---------------------------------------------------------------------------
    -- Weapon skills
    ---------------------------------------------------------------------------

    -- Shared WSD core. Cornelia's Ring and Karieyh Ring are all-jobs.
    sets.WS_BASE = {
        hands="Meg. Gloves +2",       -- WSD+7%
        waist="Sailfi Belt +1",
        right_ear="Ishvara Earring",  -- WSD
        left_ring="Karieyh Ring",     -- WSD+3%, Regain+5
        right_ring="Cornelia's Ring", -- WSD+10%
        back=CAMULUS,                 -- Acc+30, Atk+20. Still no WSD, and the Double
                                      -- Attack does nothing on a weaponskill - it is here
                                      -- for the Attack+20, plus DEX+20 and Accuracy+30 that
                                      -- feed the WS accuracy check rather than its damage
    }

    -- Savage Blade (Naegling) - STR/MND physical.
    sets.SAVAGE = set_combine(sets.WS_BASE, {
        head="Meghanada Visor +2",
        body="Malignance Tabard",
        legs="Meg. Chausses +2",
        feet="Lanun Bottes +2",       -- WSD+5%, Acc+33, STR+17, MND+17, Haste+4%, PDT-5%.
                                      -- WSD-first, by preference: WSD% is a flat multiplier
                                      -- on the whole weaponskill and cannot be wasted,
                                      -- whereas Meg. Jam. +2's Attack+42 is worth nothing
                                      -- once you are attack-capped on the target.
                                      --
                                      -- What it costs, for the record: Meg. Jam. +2 is
                                      -- STR 23 + MND 19 = 42 mod stat against Lanun's
                                      -- 17 + 17 = 34, plus Accuracy 46 vs 33. So this is
                                      -- 8 mod stat, 13 accuracy and 42 attack traded for
                                      -- a guaranteed +5%. Put Meg. Jam. +2 back if you are
                                      -- fighting well under the attack cap.
        neck="Rep. Plat. Medal",      -- STR+10 Attack+30. Was Defiant Collar: Acc+8 plus
                                      -- Subtle Blow and Triple Attack, all dead on a WS.
        left_ear="Telos Earring",     -- Atk+10 Acc+10. Was Thrud Earring, which COR CANNOT
                                      -- equip - GearSwap skipped it and the slot fell
                                      -- through to whatever the TP set had on.
        -- 2026-10-21 GearSwap-Optimizer pass: +15.5% unbuffed, +16.7% fully
        -- buffed. Most of it is the STR/WSD cape; Herculean Vest and Boots add
        -- the rest (this overrides the Lanun Bottes note above).
        back=CAMULUS_WSD,
        body="Herculean Vest",        -- TA+3 aug, STR+2, Acc+13
        feet="Herculean Boots",       -- WSD+5% aug, DEX+8, Attack+12
    })

    -- Last Stand (Anarchy +2) - ranged physical, wants RATK not STR. The gun's
    -- TP Bonus +1000 lands here automatically; see job_precast for the Moonshade
    -- interaction it creates.
    sets.LASTSTAND = set_combine(sets.WS_BASE, {
        head="Lanun Tricorne +2",     -- RATK+72
        body="Meg. Cuirie +2",        -- RATK+46
        legs="Meg. Chausses +2",
        feet="Lanun Bottes +2",       -- WSD+5%, RATK+46. WSD-first here too, and the RATK
                                      -- is a straight +4 over Meg. Jam. +2. Detonator
                                      -- inherits this slot.
                                      --
                                      -- READ THIS IF SHOTS START MISSING. Lanun Bottes +2
                                      -- has NO Ranged Accuracy at all - its Accuracy+33 is
                                      -- melee only and does nothing on a gun. So this swap
                                      -- gives up RACC 46 and AGI 10 (AGI being the mod
                                      -- stat). That is not a damage trade like the Savage
                                      -- Blade one above: it is hit rate, and WSD+5%
                                      -- multiplies zero on a miss. Meg. Jam. +2 is the
                                      -- revert, and it also carries the only Snapshot+10
                                      -- you own if that ever matters here.
        neck="Peacock Amulet",        -- RACC+10, correct for a ranged WS
        left_ear="Telos Earring",
        back="Amemet Mantle +1",      -- RATK+15; Camulus's has no ranged stat at all
    })

    -- Detonator (Anarchy +2) - 70% AGI, 2.0 attack modifier, Marksmanship.
    -- fTP 1.5 / 2.5 / 5.0, so it gains far more from reaching 3000 than Last Stand
    -- does; the gun's TP Bonus +1000 gets you there at 2000 real TP.
    -- Same AGI/RATK shell as Last Stand, differing in two slots where Detonator's
    -- heavier attack scaling makes raw damage worth more than the accuracy:
    sets.DETONATOR = set_combine(sets.LASTSTAND, {
        neck="Rep. Plat. Medal",      -- RATK+30 over Peacock Amulet's RACC+10. Swap back
                                      -- to Peacock if you are missing shots on the WS.
        waist="Ponente Sash",         -- AGI+9, RATK+15. Sailfi Belt +1 inherited from
                                      -- WS_BASE gives Haste and Attack, both of which do
                                      -- nothing for a ranged weapon skill.
    })

    -- Leaden Salute (Death Penalty, but usable with any gun once the WS is unlocked).
    -- WHICH GUN you hold matters as much as this set - see GUNS near the top:
    -- Anarchy +2 below 2000 TP, Doomsday from 2000 up (up to +30%).
    -- MAGICAL dark damage, 100% AGI, damage term is (pAGI - mINT) x 2. fTP 4.0/6.7/10.0.
    --
    -- Ranged Attack does NOTHING here, so this deliberately does not reuse the Last
    -- Stand shell: Lanun's RATK+72, Meg. Cuirie's RATK+46 and Amemet's RATK+15 are all
    -- dead on a magical WS. Priority is AGI, then Magic Attack Bonus, then WSD.
    sets.LEADEN = set_combine(sets.WS_BASE, {
        head="Herculean Helm",        -- AGI+25 with MAB+19 (base 10 + augment 9). Lanun
                                      -- Tricorne +2 has AGI+36 but zero MAB, and community
                                      -- consensus is MAB-first for this WS.
        body="Malignance Tabard",     -- AGI+42; no MAB body worth taking over it
        legs="Herculean Trousers",    -- AGI+32 with MAB+15, over Meg. Chausses +2's
                                      -- AGI+42 / MAB+0. Still the MAB-over-AGI call,
                                      -- but the +2 upgrade narrowed it to 10 AGI vs
                                      -- 15 MAB - worth re-testing if you can parse it.
        feet="Lanun Bottes +2",       -- AGI+44, MAB+48, WSD+5%, MAcc+26.
                                      --
                                      -- WAS Herculean Boots (AGI+43, MAB+24 = 10 base +14
                                      -- augment, WSD+5%, MAcc+24). The +2 boots win every
                                      -- axis that matters here: +24 MAB, +1 AGI, +2 MAcc,
                                      -- identical WSD. MAB+48 on one slot is the single
                                      -- biggest magic-damage piece you own, and Leaden
                                      -- Salute is the WS that cares most about it.
                                      --
                                      -- Meg. Jam. +2 has AGI+54 but zero MAB - still the
                                      -- wrong call, by an even wider margin than before.
        neck="Sibyl Scarf",           -- MAB+10. Rep. Plat. Medal is RATK, useless here.
        waist="Ponente Sash",         -- AGI+9. Sailfi from WS_BASE gives Haste/Attack, dead.
        left_ear="Moonshade Earring", -- MAB+4 and TP Bonus. Moldavite Earring is MAB+5 but
                                      -- currently sits in your locker, which GearSwap
                                      -- cannot equip from - move it if you want the +1.
        left_ring="Archon Ring",      -- Dark Elemental MAB+5. Leaden Salute is DARK
                                      -- elemental, so this beats Karieyh Ring's WSD+3%.
                                      -- In wardrobe3 as of 2026-09-28, so it now equips
                                      -- (it used to sit in your case, where it couldn't).
        -- right_ring stays Cornelia's Ring (WSD+10%) from WS_BASE - too strong to drop.
        -- hands/right_ear inherited from WS_BASE for the WSD (7% / 2%).
        --
        -- 2026-10-21 GearSwap-Optimizer pass: +15.1%. The AGI / Magic Damage
        -- cape is the big one; Moldavite Earring (in a wardrobe now) replaces
        -- Ishvara, Eschan Stone the Ponente Sash, and Cornelia's + Karieyh
        -- replace Archon + Cornelia's (dropping Archon costs only 0.2%).
        back=CAMULUS_MAGIC,
        right_ear="Moldavite Earring",
        waist="Eschan Stone",
        left_ring="Cornelia's Ring",
        right_ring="Karieyh Ring",
    })

    -- Low-TP overlay: TP Bonus is wasted at the 3000 TP cap.
    -- SLUG SHOT - physical ranged, 70% AGI, fTP 5.0 FLAT. TP does not add damage;
    -- it only removes the accuracy penalty: Ranged Accuracy -50 at 1000 TP, +-0
    -- at 2000 (bg-wiki). So this is the Last Stand shell with accuracy first:
    --   feet  Meg. Jam. +2 back over Lanun Bottes +2 - the bottes have NO ranged
    --         accuracy (their Acc+33 is melee), and a miss here loses the whole
    --         5.0 fTP shot. Also AGI+54, the mod stat.
    -- Neck stays Peacock Amulet (RACC+10) from Last Stand for the same reason.
    -- The gun matters: Anarchy +2's TP Bonus +1000 turns a 1000 TP shot into a
    -- 2000 TP one with no penalty; Doomsday instead brings Marksmanship skill
    -- +242 (accuracy) and DMG 120 vs 49 (physical shots DO use gun DMG).
    sets.SLUGSHOT = set_combine(sets.LASTSTAND, {
        feet="Meg. Jam. +2",          -- RACC+46, RATK+42, AGI+54
    })

    -- WILDFIRE - magical FIRE, 60% AGI, fTP 5.5 FLAT (TP only lowers enmity:
    -- -10% / -40% / -75%). Same priorities as Leaden Salute (AGI, MAB, WSD),
    -- so it is the Leaden set with one change:
    --   left_ring  Karieyh Ring (WSD+3%) back over Archon Ring - Archon's MAB+5
    --              is DARK only and does nothing for a fire WS.
    -- Moonshade Earring stays for its MAB+4, not its TP Bonus.
    -- Like Leaden, base damage comes from the gun's LEVEL, and with a flat fTP
    -- Anarchy +2's TP Bonus buys nothing - hold Doomsday for Wildfire.
    -- Unlocked by "Kupofried's Weapon Skill Moogle Magic"; until then the WS
    -- just fails and this set never fires.
    -- 2026-10-21: LEADEN now wears Cornelia's + Karieyh itself, so the Archon
    -- swap-out is no longer needed (it would have put Karieyh in both rings).
    -- With the cape, Moldavite and Eschan inherited from LEADEN: +14.9%.
    sets.WILDFIRE = set_combine(sets.LEADEN, {})

    sets.MoonshadeWS = {left_ear="Moonshade Earring"}

    -- Flat-fTP weapon skills: TP does not raise their damage, so Moonshade's
    -- TP Bonus is worthless on them and it would only displace a real earring.
    FLAT_FTP_WS = S{'Slug Shot', 'Wildfire'}

    -- Weapon skills that fire the gun, and so inherit Anarchy +2's TP Bonus.
    -- A ranged weapon's TP Bonus does nothing for a melee WS like Savage Blade.
    RANGED_WS = S{'Last Stand','Detonator','Wildfire','Leaden Salute',
                  'Slug Shot','Split Shot','Sniper Shot','Numbing Shot','Hot Shot'}

    sets.precast.WS['Savage Blade'] = sets.SAVAGE
    sets.precast.WS['Last Stand']   = sets.LASTSTAND
    sets.precast.WS['Detonator']    = sets.DETONATOR
    sets.precast.WS['Leaden Salute'] = sets.LEADEN
    sets.precast.WS['Slug Shot']    = sets.SLUGSHOT
    sets.precast.WS['Wildfire']     = sets.WILDFIRE

    ---------------------------------------------------------------------------
    -- Phantom Roll
    ---------------------------------------------------------------------------

    -- Roll gear must be on AT THE MOMENT OF THE ROLL. Compensator gives
    -- Phantom Roll duration +20, and Lanun Tricorne +2 gives a 50% chance at
    -- the party-job bonus without that job present - but only if it is equipped
    -- on the initial roll. Both are precast-only; duration is fixed when the
    -- buff lands, so do NOT lock these slots.
    sets.precast.CorsairRoll = {
        range="Compensator",          -- Phantom Roll duration +20; job_aftercast swaps it back
        head="Lanun Tricorne +2",     -- 50% proc on the job bonus without the job present
        hands="Chasseur's Gants +1",  -- "Phantom Roll" effect duration +50 - the largest
                                      -- single source you own, and this slot used to be
                                      -- unnamed, so it fell through to whatever the TP or
                                      -- idle set had on (Meg. Gloves +2, zero roll duration).
                                      -- Also enhances "Allies' Roll".
        back=CAMULUS,                 -- BASE stat, not an augment: "Phantom Roll" effect
                                      -- duration +30. Second only to the Chasseur's gloves.
                                      -- Named explicitly because the back slot used to fall
                                      -- through to whatever was already on - harmless from
                                      -- idle, where the cape is worn anyway, but in Ranged
                                      -- TP mode that is Amemet Mantle +1, and the +30 was
                                      -- silently lost on every roll made while shooting.
        left_ring="Barataria Ring",   -- "Phantom Roll"+5, COR-only. Does NOT stack with
                                      -- Merirosvo Ring ("Phantom Roll"+3) or Regal Necklace,
                                      -- so only the stronger one is worn.
        right_ring="Luzaf's Ring",    -- Increases "Phantom Roll" AREA OF EFFECT (8' -> 15').
                                      -- A different stat from Barataria's "Phantom Roll"+5,
                                      -- which is potency - so the two rings do not compete
                                      -- and both are worth wearing.
                                      --
                                      -- Like every other piece in this set it only counts
                                      -- at the instant the roll lands, and this slot was
                                      -- previously unnamed, so it fell through to whatever
                                      -- the TP or idle set had on (Petrov Ring, no roll
                                      -- stat at all). Range only matters for reaching your
                                      -- party, so it does nothing solo - harmless there.
    }

    -- Tactician's Roll body. Navarch's Frac +1 was never owned, so this overlay
    -- did nothing until 2026-10-18: Chasseur's Frac +1 (wardrobe3) has the same
    -- "Enhances Tactician's Roll" (chance of extra TP per tick). Worth the body
    -- swap for this one roll only.
    sets.precast.CorsairRoll["Tactician's Roll"] =
        set_combine(sets.precast.CorsairRoll, {body="Chasseur's Frac +1"})

    -- Double-Up is part of the same roll, so it wants the same gear.
    sets.precast.CorsairRoll['Double-Up'] = sets.precast.CorsairRoll

    ---------------------------------------------------------------------------
    -- Job abilities
    ---------------------------------------------------------------------------

    -- Lanun Bottes +2 is Reforged Relic feet: "Enhances 'Wild Card' effect".
    -- That enhancement grants one invisible re-roll whenever Wild Card lands on
    -- a 1 or a 2 - the two useless results - so the odds move from 1/6 each to
    -- roughly 1/18 for a 1 or 2 and 4/18 (22%) for each of 3 through 6. It is a
    -- pure proc bonus with no gear stat behind it, so it only counts if the
    -- boots are ON at the instant the ability fires; this is the whole reason
    -- the file now has a precast.JA table at all.
    --
    -- Mote reaches this without a hook: default_precast looks up
    -- sets.precast.JA[spell.english] for any ability. Only the feet slot is
    -- named, so every other slot keeps whatever the idle or TP set had on.
    sets.precast.JA = {}
    sets.precast.JA['Wild Card'] = {feet="Lanun Bottes +2"}

    ---------------------------------------------------------------------------
    -- Quick Draw
    ---------------------------------------------------------------------------

    -- All eight shots come through as spell.type == "CorsairShot", so this is
    -- the set Mote reaches for by default. The six ELEMENTAL shots (Fire, Ice,
    -- Wind, Earth, Thunder, Water) are damage, and damage scales off Magic
    -- Attack Bonus, Magic Damage and AGI.
    --
    -- The old note here said you own no COR-legal MAB gear, sourced from
    -- allgear.csv. That is wrong twice over: allgear.csv is an inventory list
    -- with no stats in it at all, and the gearinfo dump shows you do own MAB -
    -- Herculean Trousers (+15) and Boots (+14) on their augments, Sibyl Scarf
    -- (+10), Moldavite Earring (+5). This set is still the plain Meghanada
    -- ranged-accuracy block and is left alone here on purpose: retuning the
    -- damage shots is a separate job from adding the two utility shots below.
    sets.midcast.CorsairShot = {
        head="Lanun Tricorne +2",
        body="Meg. Cuirie +2",
        hands="Meg. Gloves +2",
        legs="Meg. Chausses +2",
        feet="Meg. Jam. +2",
        back=CAMULUS,
    }

    -- LIGHT SHOT and DARK SHOT are the two shots you do not press for damage.
    -- Their value is the status effect they carry, and a status effect either
    -- lands or is resisted on a MAGIC ACCURACY check. Magic Attack Bonus,
    -- Magic Damage and AGI do nothing for that - so these two get their own
    -- set, built on magic accuracy alone.
    --
    -- Mote finds them without a hook: get_named_set() looks for
    -- sets.midcast.CorsairShot[spell.english] before falling back to the base
    -- CorsairShot table, and there is no spellMap on Corsair shots to get in
    -- the way. A named sub-table REPLACES the base rather than merging with
    -- it, which is why every slot is written out below.
    --
    -- Best COR-legal magic accuracy you own, by slot:
    --   head  Lanun Tricorne +2   27
    --   body  Malignance Tabard   50   nothing else is within 40
    --   legs  Herculean Trousers  36   (base 15 + "Mag. Acc."+21 augment)
    --   feet  Mummu Gamashes      24   (Herculean Boots also 24 - a real tie)
    --   ear   Chas. Earring +1    11   on the augment
    --   ring  Vertigo Ring         5
    -- Hands, neck, waist and back are dead: not one COR-legal piece you own in
    -- those four slots carries Magic Accuracy at all. They keep the base
    -- CorsairShot pieces so the set stays self-contained.
    sets.QuickDrawMacc = {
        head="Lanun Tricorne +2",     -- MAcc+27
        body="Malignance Tabard",     -- MAcc+50
        hands="Meg. Gloves +2",       -- dead slot, see above
        legs="Herculean Trousers",    -- MAcc+36 with the augment
        feet="Malignance Boots",      -- MAcc+50 (was Mummu Gamashes, MAcc+24)
        right_ear="Chas. Earring +1", -- Mag. Acc.+11 on the augment. Sortie
                                      -- earring - RIGHT ear only, its stat line
                                      -- is slot-gated and reads "Right ear:".
        left_ring="Vertigo Ring",     -- MAcc+5
        back=CAMULUS,                 -- dead slot, see above
    }

    -- The two shots differ in exactly one slot, and it is easy to miss why.
    -- Archon Ring is not flat magic accuracy - it reads "DARK Elemental Magic
    -- Accuracy+5". Dark Shot is the dark element, so the ring counts; Light
    -- Shot is the light element, so it counts for nothing there and the slot
    -- goes to Defending Ring's DT-10% instead.
    sets.midcast.CorsairShot['Light Shot'] = set_combine(sets.QuickDrawMacc, {
        right_ring="Defending Ring",  -- no second MAcc ring applies here
    })

    sets.midcast.CorsairShot['Dark Shot'] = set_combine(sets.QuickDrawMacc, {
        right_ring="Archon Ring",     -- Dark Elemental MAcc+5 - dark shot, so it counts
    })

    ---------------------------------------------------------------------------
    -- Idle
    ---------------------------------------------------------------------------

    -- PDT: head -5, hands -4, feet -4 = -13% physical. Untyped DT counts toward
    -- every category: Tabard -9%, Elite Royal Collar -5%, Defending Ring -10%,
    -- Murky Ring -10% and now the cape -4% = -38% untyped. That is -51%
    -- physical / -38% magical, and physical is over the game's -50% damage-taken
    -- cap - so the cape's -4% buys only 1% more physical here but a full 4% more
    -- magical, which is the half that was not already capped.
    -- Legs are Crimson Cuisses for Movement Speed+12% rather than Meg.
    -- Chausses +1's PDT-5%. If you would rather keep the mitigation and only
    -- get the speed on demand, move Crimson Cuisses to a sets.Kiting table and
    -- toggle it with //gs c toggle Kiting.
    -- 2026-10-21 GearSwap-Optimizer pass: DT -43% -> -47%, PDT -9% -> -10%,
    -- HP 204 -> 300. Malignance Gloves, Lanun Bottes +2, Platinum Moogle Belt,
    -- Eabani + Infused earrings. Crimson Cuisses stay (the optimizer doesn't
    -- value movement speed).
    sets.idle = {
        head="Meghanada Visor +2",    -- PDT-5%
        body="Malignance Tabard",     -- DT-9%, magic evasion+139, MDB+8
        hands="Malignance Gloves",    -- DT-5%, was Meg. Gloves +2 (PDT-4%)
        legs="Crimson Cuisses",       -- Movement Speed+12% passive, COR-legal. Trades away
                                      -- Meg. Chausses +2 (PDT-6%, HP+35) - idle is for travel.
        feet="Lanun Bottes +2",       -- PDT-5%, was Malignance Boots (DT-4%)
        neck="Elite Royal Collar",    -- DT-5%, VIT+10, Regen+3 if San d'Oria
        waist="Plat. Mog. Belt",      -- DT-3%, HP+10%
        left_ear="Eabani Earring",
        right_ear="Infused Earring",
        left_ring="Defending Ring",   -- DT-10%
        right_ring="Murky Ring",      -- DT-10%; preserves Defending Ring while replacing Chirich's Regen+1
        back=CAMULUS,                 -- DT-4% on the augment; see the cap note above
    }
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

-- True when the subjob grants Dual Wield, i.e. when the sub slot can legally
-- hold Lanun Knife instead of Nusku Shield.
--
-- Read live rather than cached at load. GearSwap reloads this file on a MAIN job
-- change only; a subjob change fires sub_job_change (Mote re-runs user_setup,
-- NOT init_gear_sets), so a flag computed in init_gear_sets would go stale the
-- moment you swapped /WAR for /DNC without changing main job.
function dual_wield()
    return player.sub_job == 'DNC' or player.sub_job == 'NIN'
end

-- The TP set for the current mode, with the off-hand added when the subjob can
-- actually hold one. Everything that equips a TP set goes through here.
-- Ranged mode is left alone: while shooting, Nusku Shield's RACC+20 / RATK+20
-- beats a dagger you are not swinging.
function current_tp_set()
    if state.TPMode.value == 'Melee' and dual_wield() then
        return sets.TP.MeleeDW
    end
    return sets.TP[state.TPMode.value]
end

-- NOTE: this is job_POST_precast, not job_precast, and it has to be.
-- Mote calls job_precast BEFORE default_precast equips the weaponskill set, and
-- GearSwap's equip() merges into one pending list where the LAST write to a slot
-- wins - so an overlay equipped in job_precast is silently overwritten by the WS
-- set's own entry for that slot. That is what was happening to Moonshade: every
-- WS set here except Leaden Salute names left_ear, so the swap never landed.
-- job_post_precast runs after the set is equipped, so its overlays stick.
function job_post_precast(spell, action, spellMap, eventArgs)
    -- Lanun Knife into the main hand for the roll (see sets.RollKnife). Done
    -- here rather than in sets.precast.CorsairRoll because it depends on the
    -- subjob, and this covers the Tactician's Roll variant too.
    if spell.type == 'CorsairRoll' then
        if not dual_wield() then
            equip(sets.RollKnife)
        end
        return
    end

    if spell.type ~= 'WeaponSkill' then return end

    -- Off-hand Lanun Knife on Savage Blade: the WS's second hit comes from the
    -- off-hand under Dual Wield. Overlaid rather than baked into sets.SAVAGE
    -- because the sub slot is illegal without a Dual Wield subjob.
    if spell.english == 'Savage Blade' and dual_wield() then
        equip(sets.OffhandDW)
    end

    -- Moonshade only matters below the 3000 TP cap. The held gun's TP Bonus
    -- counts toward a ranged WS (Anarchy +2: +1000, so Moonshade is dead weight
    -- from 2000; Doomsday: none, so 2750). A melee WS gets nothing from the
    -- gun, so it keeps 2750.
    local gun_bonus = RANGED_WS:contains(spell.english) and (GUN_TP_BONUS[player.equipment.range] or 0) or 0
    local cap = gun_bonus > 0 and (3000 - gun_bonus) or 2750
    if player.tp < cap and not FLAT_FTP_WS:contains(spell.english) then
        equip(sets.MoonshadeWS)
    end
end

-- Refill an EMPTY ammo slot. Called before a shot (so a shot on an empty slot
-- still fires) and after every action (so the slot is refilled as soon as the
-- last bullet goes, or as soon as Trust opens a Bullet Pouch).
--
-- Loads the first of AMMO_PRIORITY found in inventory or wardrobes 1-8 (the
-- bags GearSwap can equip from). Only these are ever loaded - never a one-off
-- rare bullet (Hauksbok, Animikii ...) that a shot or WS would use up.
-- Orichalc. Bullet first while you're using them (MAB+2 for Leaden Salute).
-- Its DMG 89 vs Eminent's 238 matters for shots, Last Stand and Slug Shot,
-- so move Eminent back to the front if you go back to shooting.
AMMO_PRIORITY = {'Orichalc. Bullet', 'Eminent Bullet', 'Bullet'}
local AMMO_BAGS = {'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
                   'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}

local function find_ammo()
    local items = windower.ffxi.get_items()
    -- `res` is not in the job-file environment; reach it through `gearswap`
    -- (same as NIN.lua's find_shuriken).
    local resources = gearswap and gearswap.res
    if not items or not resources or not resources.items then
        return nil
    end
    local have = {}
    for _, bag in ipairs(AMMO_BAGS) do
        local contents = items[bag]
        if type(contents) == 'table' then
            for _, entry in pairs(contents) do
                if type(entry) == 'table' and entry.id and entry.id > 0 and (entry.count or 0) > 0 then
                    local info = resources.items[entry.id]
                    if info and info.en then
                        have[info.en] = true
                    end
                end
            end
        end
    end
    for _, name in ipairs(AMMO_PRIORITY) do
        if have[name] then
            return name
        end
    end
end

function refill_ammo()
    if player.equipment.ammo ~= 'empty' then
        return
    end
    local name = find_ammo()
    if name then
        equip({ammo=name})
        add_to_chat(122, 'GearSwap: ammo slot was empty - loaded ' .. name)
    end
end

function job_precast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Ranged Attack' then
        refill_ammo()
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    refill_ammo()

    -- Put the default gun back after a roll borrowed Compensator. Nothing else
    -- touches the range slot, so this is the only thing standing between you and
    -- weapon-skilling with the wrong gun on.
    if spell.type == 'CorsairRoll' then
        equip(sets.TPGun)
        -- Naegling back after the roll borrowed Lanun Knife. Unconditional on
        -- status: no TP or idle set has a main slot, so nothing else would.
        if not dual_wield() then
            equip(sets.RollKnifeBack)
        end
    end

    if player.status == 'Engaged' then
        equip(current_tp_set())
    end
end

function job_handle_equipping_gear(playerStatus, eventArgs)
    if playerStatus == 'Engaged' then
        equip(current_tp_set())
        eventArgs.handled = true
    end
end

function job_self_command(cmdParams, eventArgs)
    local cmd = cmdParams[1] and cmdParams[1]:lower() or ''

    if cmd == 'weapons' then
        -- Which off-hand you get is decided by the subjob, not by a flag, so
        -- //gs c weapons is safe to press on any subjob.
        if dual_wield() then
            equip(sets.weaponsDW)
            add_to_chat(122, 'GearSwap: ' .. current_gun .. ' / Naegling / Lanun Knife / Eminent Bullet'
                .. ' (Dual Wield from /' .. player.sub_job .. ')')
        else
            equip(sets.weapons)
            add_to_chat(122, 'GearSwap: ' .. current_gun .. ' / Naegling / Nusku / Eminent Bullet')
        end

    elseif cmd == 'doomsday' or cmd == 'anarchy' then
        -- Every set that names the gun follows current_gun, so the roll
        -- put-back and //gs c weapons keep the one you chose.
        current_gun = GUNS[cmd]
        sets.weapons.range = current_gun
        sets.weaponsDW.range = current_gun
        sets.TPGun.range = current_gun
        equip(sets.TPGun)
        add_to_chat(122, 'GearSwap: gun = ' .. current_gun .. ' (swapping the gun resets TP)')

    elseif cmd == 'ranged' or cmd == 'gun' then
        state.TPMode:set('Ranged')
        if player.status == 'Engaged' then equip(current_tp_set()) end
        add_to_chat(122, 'GearSwap: TP mode = Ranged')

    elseif cmd == 'melee' then
        state.TPMode:set('Melee')
        if player.status == 'Engaged' then equip(current_tp_set()) end
        add_to_chat(122, 'GearSwap: TP mode = Melee')

    elseif cmd == 'lockback' then
        send_command('gs disable back')
        add_to_chat(122, 'GearSwap: BACK SLOT LOCKED')

    elseif cmd == 'unlockback' then
        send_command('gs enable back')
        add_to_chat(122, 'GearSwap: BACK SLOT UNLOCKED')
    end
end

-- Lockstyle. The game clears style lock every time you change jobs, so it has
-- to be re-applied - Mote calls select_default_macro_book() on load and on job
-- change, which is the right place for it.
--
-- SET THIS to your in-game equipset number (the "Set###" in the Macros menu).
-- The placeholder below is a guess. A number with no matching equipset fails
-- silently, so if your appearance does not lock, this is the first thing to check.
-- Set it to 0 to lock to whatever you happen to be wearing at that moment.
LOCKSTYLE_SET = 39

function select_default_macro_book()
    set_macro_page(1, 5)
    add_to_chat(122, 'GearSwap: macro book 5 page 1 for COR')
    -- ~5s delay is required: /lockstyleset lands too early after a job change
    -- and is silently dropped. The game also enforces ~10s between changing
    -- one active lock to another.
    -- Announce it. /lockstyleset fails SILENTLY when the equipset number does
    -- not exist, so saying which set we asked for turns an invisible no-op into
    -- an obvious one: if chat says 39 and your appearance never changes, 39 is
    -- the wrong number. Check it in the in-game Macros menu.
    if LOCKSTYLE_SET and LOCKSTYLE_SET > 0 then
        add_to_chat(122, 'GearSwap: applying lockstyleset ' .. LOCKSTYLE_SET
            .. ' for ' .. (player and player.main_job or '?') .. ' (5s delay)')
        send_command('wait 5; input /lockstyleset ' .. LOCKSTYLE_SET
            .. '; wait 2; input /echo GearSwap: lockstyleset ' .. LOCKSTYLE_SET .. ' sent.')
    else
        add_to_chat(122, 'GearSwap: clearing style lock (5s delay)')
        send_command('wait 5; input /lockstyleset')
    end
end
