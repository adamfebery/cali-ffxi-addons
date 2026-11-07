-- DNC GearSwap - Char2
--
-- Tauret main hand, Fusetto +2 off hand.
--
-- Same conventions as the THF file: main/sub live ONLY in sets.weapons and are
-- equipped ONLY by an explicit //gs c command. No main/sub in any TP, WS or
-- idle set, so nothing can swap a weapon out from under you mid-fight and
-- nothing resets your TP by accident.
--
-- Commands:
--   //gs c weapons   equip Tauret + Fusetto +2
--   //gs c ws        equip the Evisceration set for inspection
--
-- All gear below was read from the 2026-09-17 gearinfo dump
-- (addons/gearinfo/data/Char2_data.lua), DNC-legal only.
--
-- Storage data for Char2 DOES exist now: addons/findAll/data/Char2.lua
-- (401 items across every bag). The older allgear.csv is Char1-only and stale.
-- GearSwap can still only equip from inventory and wardrobe1-8 - anything in a
-- satchel, sack, case, locker or storage is skipped SILENTLY, leaving whatever
-- was already in that slot. If a slot never changes, that is the first suspect.
--
-- OFF-HAND TP BONUS CAVEAT: TP Bonus applies to a weapon skill only from the
-- MAIN hand. A TP Bonus weapon in the sub slot contributes nothing to WS
-- damage. Fusetto +2 also drops off-hand base damage from Leisilonu +2's
-- DMG:90 to DMG:38, and gives up Dagger skill +242, Parrying +242, Magic
-- Accuracy skill +188 and Evasion+22. Swap back if the TP Bonus does not
-- show up on your weapon skills.

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function user_setup()
    select_default_macro_book()
end

function job_setup()
end

function init_gear_sets()

    ---------------------------------------------------------------------------
    -- Weapons. The only set that ever touches main/sub.
    ---------------------------------------------------------------------------

    -- Tauret is iL119, DMG:125 / Delay:180, and its Evisceration line is MAIN
    -- HAND ONLY: "Evisceration" damage +50%, and increased critical hit rate
    -- based on LOWER TP. That second clause is the reason this file never
    -- chases TP bonus gear - see the Evisceration set below.
    --
    -- The off-hand is Fusetto +2 (DMG:38 / Delay:186) by explicit request on
    -- 2026-09-18, for its TP Bonus +1000 augment. Leisilonu +2 (DMG:90 /
    -- Delay:183) is the damage-optimal off-hand and is what this file used
    -- before. Three things argue for putting it back:
    --   1. TP Bonus applies to a weapon skill only from the MAIN hand, so the
    --      +1000 is expected to do nothing at all from the sub slot.
    --   2. 52 less base damage on every off-hand swing.
    --   3. Even main-handed it would fight Tauret's own clause, which gives
    --      MORE Evisceration crit the LOWER your TP is.
    -- Leisilonu +2 also carries Dagger skill +242, Parrying +242, Magic
    -- Accuracy skill +188 and Evasion+22, none of which Fusetto +2 has.
    --
    -- No ammo slot: nothing DNC-legal in the dump carries a stat. Seeth.
    -- Bomblet +1 and Knobkierrie are both job-locked away from DNC, and the
    -- only other ammo you own are moogle enchantment items and a Hydrocera.
    sets.weapons = {
        main="Tauret",
        sub="Fusetto +2",       -- off-hand, per request 2026-09-18. Its
                                -- TP Bonus +1000 is an AUGMENT - it shows in
                                -- the gearinfo dump's ["augments"] array, not
                                -- in the item description, which is only the
                                -- stub "DMG:38 Delay:186". See the off-hand
                                -- caveat in the header before trusting it.
    }

    ---------------------------------------------------------------------------
    -- Melee TP
    ---------------------------------------------------------------------------

    -- GEAR HASTE LANDS ON EXACTLY 25%, WHICH IS THE CAP, WITH NOTHING WASTED:
    --   head 8 + body 4 + hands 5 + legs 4 + feet 4 = 25%
    -- That is why the waist is not Sailfi Belt +1 - its Haste+9% would be pure
    -- overflow here - and why the legs are Meg. Chausses +2 rather than Volte
    -- Tights. Volte Tights' Haste+9% would push the total to 30% and spill 5%,
    -- so the real trade in that slot is "Triple Attack"+5% / Acc+49 / Atk+45
    -- against "Store TP"+8 / "Subtle Blow"+8 / Acc+38. Triple Attack wins on a
    -- dual wielder; swap to Volte Tights only if you want the Subtle Blow.
    --
    -- FOUR MUMMU PIECES ARE LIVE: Bonnet +2, Jacket +2, Gamash. +2 and Mummu
    -- Ring, all set id 477. The dump's tiers are DEX/AGI/CHR +8 / +12 / +16 /
    -- +32 at 2 / 3 / 4 / 5 pieces, so this set collects +16 DEX, AGI and CHR.
    --
    -- MUMMU WRISTS ARE NOT PART OF THAT SET. The dump gives them no set id at
    -- all, despite the name, and neither do Mummu Kecks. The Wrists hold the
    -- hands slot on their own line (Haste+5%, "Double Attack"+3%, crit+3%) and
    -- on the fact that their 5% is what completes the haste cap above -
    -- Meg. Gloves +2 is Haste+4%, which would leave the set at 24%.
    --
    -- Crit rate from gear totals 25%: Bonnet 5, Jacket 9, Wrists 3, Gamash 5,
    -- Mummu Ring 3. "Store TP" totals 24: Jacket 6, Anu 7, Patentia 5, Brutal
    -- 1, Petrov 5.
    --
    -- THE WAIST AND ONE EAR ARE THE LIVE DECISION IN THIS SET. Patentia Sash
    -- and Suppanomimi are Dual Wield+5 each, +10 together, on top of DNC's
    -- native Dual Wield trait and whatever you have merited. If that +10 is
    -- pushing you past the delay-reduction cap it is doing nothing, and the
    -- swaps are waist -> Kentarch Belt +1 (Acc+14, DA+3%, Unity "Store TP"+1~5)
    -- and ear -> Alabaster Earring (Haste+5% is also overflow, but DT-5% and
    -- HP+100 are not). Work out your real Dual Wield total before deciding;
    -- it is not a proportional TP loss either way.
    --
    -- THE BACK SLOT IS EMPTY AND CANNOT BE FIXED FROM INVENTORY. Every good
    -- cape in the dump is job-locked away from DNC: Toutatis's Cape is THF
    -- only, and all three Intarabus's Capes are BRD only - one of which is
    -- augmented DEX+20 / Acc+20 Atk+20 / DEX+10 / "Store TP"+10 and would walk
    -- straight into this set if it were legal. What is left for DNC is a
    -- Raptor Mantle, an Aptitude Mantle and a Nexus Cape.
    sets.engaged = {
        head="Mummu Bonnet +2",       -- Haste+8%, Acc+44, crit+5%, Mummu 4pc
        body="Mummu Jacket +2",       -- Haste+4%, Acc+46, "Store TP"+6, crit+9%
        hands="Mummu Wrists",         -- Haste+5%, DA+3%, crit+3% (no set bonus)
        legs="Meg. Chausses +2",      -- Haste+4%, TA+5%, Acc+49, Atk+45
        feet="Mummu Gamash. +2",      -- Haste+4%, Acc+42, crit+5%, Mummu 4pc
        neck="Anu Torque",            -- Attack+20, "Store TP"+7
        waist="Patentia Sash",        -- Dual Wield+5, "Store TP"+5 - see above
        left_ear="Suppanomimi",       -- Dual Wield+5 - see above
        right_ear="Brutal Earring",   -- Enhances "Double Attack", "Store TP"+1
        left_ring="Mummu Ring",       -- Acc+6, crit+3%, Mummu 4pc
        right_ring="Petrov Ring",     -- DA+1%, "Store TP"+5, STR/DEX+3
        -- back: nothing DNC-legal in the dump, see above
    }

    ---------------------------------------------------------------------------
    -- Weapon skill: Evisceration (Tauret)
    ---------------------------------------------------------------------------

    -- Five hits, DEX modifier, and its critical hit rate scales with TP - on
    -- top of which Tauret's main-hand line adds +50% Evisceration damage and
    -- MORE crit the LOWER your TP is. Net effect for gearing: stack DEX, crit
    -- rate and weapon skill damage, and do NOT chase TP bonus. Fusetto +2's
    -- TP Bonus +1000 augment fights this trait head-on if it ever applies -
    -- which, off-hand, it should not. This is unchanged by the 2026-09-18
    -- off-hand swap: no TP bonus gear belongs in the sets below.
    --
    -- Best DEX per slot out of everything DNC-legal in the dump:
    --   head  Mummu Bonnet +2  39 | Megh. Visor +1   30
    --   body  Mummu Jacket +2  48 | Megh. Cuirie     37 | Rawhide Vest    35
    --   hands Meg. Gloves +2   50 | Mummu Wrists     42
    --   legs  (none carry DEX - Meg. Chausses +2 and Mummu Kecks are both 0)
    --   feet  Mummu Gamash. +2 37 | Meg. Jam. +1     31
    --
    -- The hands flip from the TP set: Meg. Gloves +2 is DEX+50 and Weapon
    -- skill damage +7%, which beats Mummu Wrists' Double Attack outright here
    -- because MULTI-ATTACK DOES NOT FIRE DURING A WEAPON SKILL.
    --
    -- The legs are the one genuine toss-up, since neither candidate has DEX:
    -- Meg. Chausses +2 (Acc+49, Atk+45) against Mummu Kecks (crit+4%). Attack
    -- is the better buy unless you are already attack-capped on the target, in
    -- which case take the crit.
    --
    -- Meghanada set id 59 is at two pieces here (Gloves +2, Chausses +2). Its
    -- bonus is "Regen"+3, which is worth nothing in a weapon skill set - do
    -- not treat it as a reason to keep the pair together.
    --
    -- DEAD SLOTS, and nothing owned fixes them: both ears (no DNC-legal ear in
    -- the dump carries DEX, crit or WSD - Brutal's Double Attack cannot fire
    -- on a weapon skill and Suppanomimi's Dual Wield does nothing here), the
    -- neck (Anu Torque's Attack+20 is the best of a field of three), and the
    -- back. The waist is Sailfi Belt +1 purely for its Unity Attack+10~15,
    -- since haste is irrelevant in a weapon skill set.
    sets.precast.WS = {
        head="Mummu Bonnet +2",       -- DEX+39, crit+5%, Acc+44, Mummu 4pc
        body="Mummu Jacket +2",       -- DEX+48, crit+9%, Acc+46, Mummu 4pc
        hands="Meg. Gloves +2",       -- DEX+50, WSD+7%, Acc+47, Atk+43
        legs="Meg. Chausses +2",      -- Atk+45, Acc+49, STR+40 - see above
        feet="Mummu Gamash. +2",      -- DEX+37, crit+5%, Acc+42, Mummu 4pc
        neck="Anu Torque",            -- Attack+20 - dead slot, see above
        waist={name="Sailfi Belt +1", augments={'Path: A'}},  -- Unity Atk+10~15
        left_ear="Brutal Earring",    -- dead slot, see above
        right_ear="Alabaster Earring",-- dead slot, see above
        left_ring="Mummu Ring",       -- crit+3%, Acc+6, Mummu 4pc
        right_ring="Rajas Ring",      -- DEX+2~5, STR+2~5
        -- back: nothing DNC-legal in the dump
    }

    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {})

    ---------------------------------------------------------------------------
    -- Idle
    ---------------------------------------------------------------------------

    -- Untyped Damage taken -18% (Murky Ring 10, Alabaster 5, Mummu Kecks 3),
    -- plus physical-only -14% from the Meghanada pieces.
    sets.idle = {
        head="Meghanada Visor +1",    -- Physical Damage taken-4%
        body="Meghanada Cuirie",      -- Physical Damage taken-6%
        hands="Meg. Gloves +2",       -- Physical Damage taken-4%
        legs="Mummu Kecks",           -- Damage taken-3%, Magic Evasion+107
        feet="Meg. Jam. +1",          -- Physical Damage taken-2%
        neck="Anu Torque",
        waist="Kentarch Belt +1",
        left_ear="Alabaster Earring", -- Damage taken-5%, HP+100
        right_ear="Brutal Earring",
        left_ring="Murky Ring",       -- Damage taken-10%
        right_ring="Meghanada Ring",  -- Physical Damage taken-2%
    }
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

function job_self_command(cmdParams, eventArgs)
    local cmd = cmdParams[1] and cmdParams[1]:lower() or ''

    if cmd == 'weapons' then
        equip(sets.weapons)
        add_to_chat(122, 'GearSwap: Tauret + Fusetto +2')

    elseif cmd == 'ws' then
        equip(sets.precast.WS['Evisceration'])
        add_to_chat(122, 'GearSwap: Evisceration set equipped for inspection.'
            .. ' //gs c update puts your normal gear back.')
    end
end

-- TODO: set this to Char2's real in-game equipset number. LOCKSTYLE_SET = 0
-- locks to whatever you happen to be wearing, which is a safe default but
-- probably not what you want; a wrong number fails silently.
LOCKSTYLE_SET = 0

function select_default_macro_book()
    set_macro_page(1, 1)
    add_to_chat(122, 'GearSwap: macro book 1 page 1 for DNC')

    -- ~5s delay is required: /lockstyleset lands too early after a job change
    -- and is silently dropped.
    if LOCKSTYLE_SET and LOCKSTYLE_SET > 0 then
        add_to_chat(122, 'GearSwap: applying lockstyleset ' .. LOCKSTYLE_SET
            .. ' for ' .. (player and player.main_job or '?') .. ' (5s delay)')
        send_command('wait 5; input /lockstyleset ' .. LOCKSTYLE_SET
            .. '; wait 2; input /echo GearSwap: lockstyleset ' .. LOCKSTYLE_SET .. ' sent.')
    else
        add_to_chat(122, 'GearSwap: locking style to current appearance (5s delay)')
        send_command('wait 5; input /lockstyleset')
    end
end
