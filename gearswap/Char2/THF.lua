-- THF GearSwap - Char2
--
-- Sword = Naegling (+ Tauret in the off-hand under Dual Wield)
--
-- Same conventions as the COR and WAR files on Char1: main/sub/ammo live ONLY
-- in sets.weapons and are equipped ONLY by an explicit //gs c command. No
-- main/sub in any TP, WS or idle set, so nothing can swap your weapon out from
-- under you mid-fight, and nothing resets your TP by accident.
--
-- Commands:
--   //gs c weapons   equip Naegling (+ Tauret off-hand if the subjob dual wields)
--   //gs c ws        equip the Savage Blade set for inspection
--
-- All gear below was read from the 2026-09-11 gearinfo dump (addons/
-- Char2_data.lua), THF-legal only.
--
-- NO STORAGE DATA EXISTS FOR CHAR2. findAll's allgear.csv only covers Char1,
-- so unlike the WAR file there is no "blocked upgrades" list here. GearSwap can
-- only equip from inventory and wardrobe1-8; anything sitting in a satchel,
-- sack, case, locker or storage is skipped SILENTLY, leaving whatever was
-- already in that slot. If a slot never changes, that is the first suspect -
-- run //findall on Char2 and the gaps become visible.

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
    -- Weapons. The only set that ever touches main/sub/ammo.
    ---------------------------------------------------------------------------

    -- Naegling is iL119, DMG:166 / Delay:240, and carries "Sword skill +250".
    -- That skill line is what makes a sword viable on THF at all - THF's own
    -- sword rating is poor, and the weapon supplies the skill instead. Its
    -- "Savage Blade" damage +15% is MAIN HAND ONLY.
    sets.weapons = {
        main="Naegling",
        ammo="Seeth. Bomblet +1",     -- Accuracy+13, Attack+13 - THF-legal, and
                                      -- the ammo slot was otherwise empty
    }

    -- Off-hand under Dual Wield. THF has NO Dual Wield of its own - it only
    -- exists with /NIN or /DNC - so Tauret is illegal in the sub slot on any
    -- other subjob. Tauret is iL119 DMG:125, and its "Evisceration" bonus is
    -- main-hand only, so here it is purely a stat stick (DEX+15, Accuracy+40,
    -- Attack+30).
    --
    -- Sub slot ONLY, deliberately: Suppanomimi's Dual Wield enhancement is dead
    -- without the subjob too, but an earring does not belong in a weapons set -
    -- current_tp_set() swaps it into the TP set instead, so //gs c weapons stays
    -- true to the main/sub/ammo rule at the top of this file.
    sets.OffhandDW = {
        sub="Tauret",
    }

    sets.weaponsDW = set_combine(sets.weapons, sets.OffhandDW)

    ---------------------------------------------------------------------------
    -- Melee TP
    ---------------------------------------------------------------------------

    -- FOUR MUMMU PIECES ARE LIVE HERE: Bonnet +2, Jacket +2, Gamash. +2 and
    -- Mummu Ring, all set id 477. Its tiers, straight from the dump, are
    -- DEX/AGI/CHR +8 / +12 / +16 / +32 at 2 / 3 / 4 / 5 pieces, so this set
    -- collects +16 DEX, AGI and CHR on top of the pieces' own stats.
    --
    -- MUMMU WRISTS ARE NOT PART OF THAT SET - the dump gives them no set bonus
    -- at all, despite the name. They hold the hands slot on their own merits
    -- (Haste+5%, "Double Attack"+3%, Critical hit rate+3%). If you would rather
    -- have accuracy than the procs, Meg. Gloves +2 is Accuracy+47 against the
    -- Wrists' +25 - that is the one slot in this set with a real alternative.
    --
    -- HASTE IS WAY OVER THE CAP, WHICH IS WHY THE WAIST IS NOT SAILFI:
    --   head 8 + body 4 + hands 5 + legs 9 + feet 4 = 30% against a 25% cap.
    -- Sailfi Belt +1's Haste+9% would be pure overflow, so the waist spends
    -- itself on Kentarch Belt +1 instead (Accuracy+14, "Double Attack"+3%, and a
    -- Unity "Store TP"+1~5). Sailfi goes back only if you drop two haste pieces.
    --
    -- Crit rate totals 8% from gear (Bonnet +2 5%, Wrists 3%), before Mummu
    -- Gamash. +2's own +5% - worth knowing because Sneak Attack does not need
    -- it but ordinary swings do.
    sets.engaged = {
        head="Mummu Bonnet +2",       -- Haste+8%, Acc+44, Crit+5%, Mummu 4pc
        body="Mummu Jacket +2",       -- Haste+4%, Acc+46, "Store TP"+6, Crit+9%
        hands="Mummu Wrists",         -- Haste+5%, DA+3%, Crit+3% (no set bonus)
        legs="Volte Tights",          -- Haste+9%, Acc+38, "Store TP"+8, STR+46
        feet="Mummu Gamash. +2",      -- Haste+4%, Acc+42, Crit+5%, Mummu 4pc
        neck="Anu Torque",            -- Attack+20, "Store TP"+7
        waist="Kentarch Belt +1",     -- Acc+14, DA+3% - see the haste note above
        left_ear="Brutal Earring",    -- Enhances "Double Attack", "Store TP"+1
        right_ear="Alabaster Earring",-- Damage taken-5%, HP+100. Swapped for
                                      -- Suppanomimi automatically under Dual
                                      -- Wield - see current_tp_set().
        left_ring="Mummu Ring",       -- Acc+6, Crit+3%, Mummu 4pc
        right_ring="Petrov Ring",     -- DA+1%, "Store TP"+5, STR/DEX+3
        back="Toutatis's Cape",       -- augmented: Acc+20, Attack+20, STR+30 total
    }

    ---------------------------------------------------------------------------
    -- Weapon skill: Savage Blade (Naegling)
    ---------------------------------------------------------------------------

    -- 50% STR / 50% MND, so every slot below was picked on STR+MND combined,
    -- with accuracy and weapon skill damage breaking the ties.
    --
    -- Best STR+MND per slot out of everything THF-legal in the dump:
    --   head  Megh. Visor +1   43 | Mummu Bonnet +2  34 | Skulker's Bonnet 26
    --   body  Rawhide Vest     55 | Mummu Jacket +2  48 | Megh. Cuirie     46
    --   hands Meg. Gloves +2   57 | Mummu Wrists     42 | Valorous-class    -
    --   legs  Meg. Chausses +2 63 | Volte Tights     53 | Mummu Kecks      48
    --   feet  Meg. Jam. +1     36 | Mummu Gamash. +2 27 | Skulk. Poulaines 16
    --
    -- THE BODY IS THE ONE DELIBERATE LOSS. Rawhide Vest wins the modifier by 7
    -- (55 against 48) but gives up 31 accuracy (Acc+15 against Mummu's +46).
    -- A weapon skill that misses does zero damage regardless of its modifier,
    -- so Mummu Jacket +2 keeps the slot on a mule that is not accuracy-capped.
    -- Swap to Rawhide Vest only if you are landing everything.
    --
    -- TOUTATIS'S CAPE FINALLY GETS USED. The BRD file has a standing note that
    -- this cape is "THF only and cannot be worn here" - on THF it can: STR+20
    -- and STR+10 on the augments, Accuracy+20, Attack+20, Weapon skill damage
    -- +10%, Damage taken-4%. It is the single best piece in this set, and you
    -- own exactly one, so there is no duplicate-augment trap to guard against.
    --
    -- DEAD SLOTS, and nothing owned fixes them: neck (Anu Torque's Attack+20 is
    -- the best of a thin field - no THF-legal neck you own carries STR or MND)
    -- and the second earring, since Brutal's Double Attack does not fire on a
    -- weapon skill. Suppanomimi's Sword skill +5 is real accuracy on Naegling,
    -- which is why it takes an ear here whether or not you are dual wielding.
    sets.precast.WS = {
        ammo="Seeth. Bomblet +1",     -- Acc+13, Attack+13
        head="Meghanada Visor +1",    -- STR+24 MND+19, Acc+42
        body="Mummu Jacket +2",       -- STR+28 MND+20, Acc+46 - see note above
        hands="Meg. Gloves +2",       -- STR+23 MND+34, Acc+47, WSD+7%
        legs="Meg. Chausses +2",      -- STR+40 MND+23, Acc+49
        feet="Meg. Jam. +1",          -- STR+20 MND+16, Acc+40
        neck="Anu Torque",            -- Attack+20 - dead slot, see above
        waist="Sailfi Belt +1",       -- Unity Attack+10~15, TA+2%. Haste is
                                      -- irrelevant in a WS set, so Kentarch's
                                      -- accuracy is the alternative if missing.
        left_ear="Suppanomimi",       -- Sword skill +5 = real accuracy
        right_ear="Brutal Earring",   -- dead slot, see above
        left_ring="Meghanada Ring",   -- Acc+6, Attack+6
        right_ring="Petrov Ring",     -- STR+3 DEX+3
        back="Toutatis's Cape",       -- STR+30, Acc+20, Attack+20, WSD+10%
    }

    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})

    -- Evisceration is THF's own dagger weapon skill and is NOT set up here -
    -- it is a Tauret main-hand weapon skill (DEX-based, multi-hit), and this
    -- file mains Naegling. If you ever want it, it wants a crit/DEX set, not
    -- this STR/MND one, so it needs its own table rather than reusing this.

    ---------------------------------------------------------------------------
    -- Idle
    ---------------------------------------------------------------------------

    -- Untyped Damage taken -19% (Murky Ring 10, Alabaster 5, Toutatis 4), plus
    -- physical-only -12% from the Meghanada pieces and -3% from Mummu Kecks.
    sets.idle = {
        ammo="Seeth. Bomblet +1",
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
        back="Toutatis's Cape",       -- Damage taken-4%
    }
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

-- True when the subjob grants Dual Wield, i.e. when the sub slot can legally
-- hold Tauret. Read live rather than cached: GearSwap reloads this file on a
-- MAIN job change only, so a flag computed in init_gear_sets would go stale the
-- moment /NIN was swapped for /WAR without changing main job.
function dual_wield()
    return player.sub_job == 'NIN' or player.sub_job == 'DNC'
end

-- The TP set, with Suppanomimi swapped in when the subjob can actually dual
-- wield. The off-hand itself is NOT set here - that comes from //gs c weapons,
-- because a sub-slot swap resets TP and must never happen mid-fight.
-- Everything that equips a TP set goes through this function.
function current_tp_set()
    if dual_wield() then
        return set_combine(sets.engaged, { right_ear="Suppanomimi" })
    end
    return sets.engaged
end

function job_handle_equipping_gear(playerStatus, eventArgs)
    if playerStatus == 'Engaged' then
        equip(current_tp_set())
        eventArgs.handled = true
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if player.status == 'Engaged' then
        equip(current_tp_set())
    end
end

function job_self_command(cmdParams, eventArgs)
    local cmd = cmdParams[1] and cmdParams[1]:lower() or ''

    if cmd == 'weapons' then
        -- Which off-hand you get is decided by the subjob, not by a flag, so
        -- //gs c weapons is safe to press on any subjob.
        if dual_wield() then
            equip(sets.weaponsDW)
            add_to_chat(122, 'GearSwap: Naegling + Tauret + Seeth. Bomblet +1'
                .. ' (Dual Wield from /' .. player.sub_job .. ')')
        else
            equip(sets.weapons)
            add_to_chat(122, 'GearSwap: Naegling + Seeth. Bomblet +1'
                .. ' (no Dual Wield on /' .. (player.sub_job or '?') .. ')')
        end

    elseif cmd == 'ws' then
        equip(sets.precast.WS['Savage Blade'])
        add_to_chat(122, 'GearSwap: Savage Blade set equipped for inspection.'
            .. ' //gs c update puts your normal gear back.')
    end
end

-- TODO: set this to Char2's real in-game equipset number. LOCKSTYLE_SET = 0
-- locks to whatever you happen to be wearing, which is a safe default but
-- probably not what you want; a wrong number fails silently.
LOCKSTYLE_SET = 0

function select_default_macro_book()
    set_macro_page(1, 1)
    add_to_chat(122, 'GearSwap: macro book 1 page 1 for THF')

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
