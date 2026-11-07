-- RUN GearSwap - Char3
--
-- Built from addons/Char3_data.lua (the GearInfo stats dump) against the
-- BG-wiki Community Rune Fencer Guide. Every item named below was verified
-- present in that dump AND verified RUN-legal from the item's own ["jobs"]
-- table - not from the guide's wishlist.
--
-- Weapons:
--   Aettir           RUN-only great sword, Acc+70 / M.Eva+50 / WSD+10% augment.
--                    Enmity+10, "Lunge"+10, Physical damage taken II -5%.
--                    This is the tanking weapon and there is no argument.
--   Beryllium Sword  great sword, DMG 289/444, adds "Spinning Slash". DD.
--   Hepatizon Axe +1 great axe, DMG 330/489, STR+15 VIT+15, WS Acc+30.
--                    RUN has Great Axe B (398 cap); the axe's own +242 skill
--                    carries a from-scratch skill and clears Steel Cyclone.
--   Eletta Sword     one-handed, MAcc+30 / MAB+10 / Magic Damage+217. The
--                    Lunge / Swipe stick.
--
-- RUN CANNOT EQUIP SHIELDS - no Shield skill. The sub slot is a grip, and a
-- grip only fits a two-handed weapon. So the one-handed swords run sub=empty.
--
-- Same conventions as WAR.lua / SAM.lua / COR.lua: weapons live ONLY in
-- sets.weapons and are equipped ONLY by an explicit //gs c command. No
-- main/sub in any TP, WS, JA or idle set, so nothing can swap your weapon
-- mid-fight.
--
-- Commands:
--   //gs c aettir      Aettir + Mensch Strap +1        (tank, default)
--   //gs c gs          Beryllium Sword + Balarama Grip (great sword DD)
--   //gs c ga          Hepatizon Axe +1 + Balarama Grip (great axe DD)
--   //gs c eletta      Eletta Sword, sub empty         (Lunge / Swipe)
--
--   //gs c pdt         Defense: max physical    (sets.defense.PDT)
--   //gs c mdt         Defense: max magic eva   (sets.defense.MDT)
--   //gs c dt          Defense: hybrid          (sets.defense.DT)
--   //gs c off         Defense off
--
--   //gs c lockback / //gs c unlockback
--
-- Armour is the full Runeist AF+3 set (all five pieces owned) plus the Erilaz
-- and Turms pieces that beat it in their specific role. See the BLOCKED
-- UPGRADES block at the bottom for the holes.

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function user_setup()
    -- Aettir first: M{} defaults to its first entry, and on RUN the tank
    -- weapon is the default weapon. Nothing here equips a weapon on its own.
    state.WeaponMode = M{['description']='Weapon', 'Aettir', 'GreatSword', 'GreatAxe', 'Eletta'}

    state.OffenseMode:options('Normal', 'Acc', 'DD')

    -- Mote builds the defense set name as
    --   sets.defense[ state[ state.DefenseMode.current .. 'DefenseMode' ].current ]
    -- (Mote-Include.lua:878). So adding 'DT' to DefenseMode and declaring a
    -- state.DTDefenseMode whose value is 'DT' makes it resolve sets.defense.DT
    -- with no extra plumbing - the same path Physical/Magical already take.
    state.DefenseMode:options('None', 'Physical', 'Magical', 'DT')
    state.DTDefenseMode = M{['description']='DT Defense Mode', 'DT'}
end

function job_setup()
end

function init_gear_sets()

    -----------------------------------------------------------------------
    -- Augmented pieces, named once so the augments cannot drift between sets
    -----------------------------------------------------------------------

    -- YOU OWN TWO OGMA'S CAPES. One is augmented HP+60 / Eva+20 M.Eva+20 /
    -- M.Eva+2 / Enmity+10 / PDT-2%; the other has DEX+1 and four empty slots.
    -- Naming the cape without an augments table lets GearSwap grab either one,
    -- and the wrong one is worth literally nothing. Every set below uses this
    -- local, so the good cape is the only one this file can ever equip.
    local Ogma = {name="Ogma's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+2','Enmity+10','Phys. dmg. taken-2%'}}

    -- The only Battuta+ piece you own. Base line is Haste+7%, PDT-3%,
    -- "Phalanx" received +4, M.Eva+36.
    local FutharkBattuta = {name="Futhark Bandeau", augments={'none','none','Enhances "Battuta" effect','none'}}

    -- Adhemar +1 A-path (STR+12 / DEX+12 / Attack+20) - the pure-DD kit.
    -- Adhemar Jacket +1 carries Enmity-8, which is why it never appears in a
    -- tanking set.
    local AdheHead  = {name="Adhemar Bonnet +1",  augments={'STR+12','DEX+12','Attack+20'}}
    local AdheBody  = {name="Adhemar Jacket +1",  augments={'STR+12','DEX+12','Attack+20'}}
    local AdheHands = {name="Adhemar Wrist. +1",  augments={'STR+12','DEX+12','Attack+20'}}

    -- Herculean: the feet are rolled TP/accuracy, the legs are rolled magic.
    -- The legs' Enmity+4 augment exactly cancels the base item's Enmity-4, so
    -- they are enmity-neutral rather than enmity-negative.
    local HercFeet  = {name="Herculean Boots",    augments={'"Store TP"+5','Enmity-4','Accuracy+18 Attack+18','Mag. Acc.+4 "Mag.Atk.Bns."+4','none'}}
    local HercLegs  = {name="Herculean Trousers", augments={'Pet: STR+8','Enmity+4','Accuracy+13 Attack+13','Mag. Acc.+19 "Mag.Atk.Bns."+19','none'}}

    ---------------------------------------------------------------------------
    -- Weapons - the only sets that ever touch main/sub
    ---------------------------------------------------------------------------

    sets.weapons = {}

    -- Mensch Strap +1 (PDT-5%, "Regen"+3) over Balarama Grip (HP+50, Enmity+3)
    -- whenever you are actually tanking: -5% physical off every hit for the
    -- whole fight beats 50 HP and 3 enmity.
    sets.weapons.Aettir = {
        main={name="Aettir", augments={'Accuracy+70','Mag. Evasion+50','Weapon skill damage +10%'}},
        sub="Mensch Strap +1",
    }

    sets.weapons.GreatSword = {
        main="Beryllium Sword",       -- DMG 289/444, STR+10 INT+10, Acc+27, WS Acc+25
        sub="Balarama Grip",          -- HP+50, Great Sword skill+10, Parry+7, Enmity+3
    }

    sets.weapons.GreatAxe = {
        main="Hepatizon Axe +1",      -- DMG 330/489, STR+15 VIT+15, Acc+32, WS Acc+30
        sub="Balarama Grip",
    }

    -- One-handed. No shield (RUN has no Shield skill) and no Dual Wield trait,
    -- so the sub slot is genuinely empty. You are giving up a whole weapon's
    -- worth of damage - this set is for Lunge/Swipe nuking, not for meleeing.
    sets.weapons.Eletta = {
        main="Eletta Sword",          -- MAcc+30, MAB+10, Magic Damage+217
        sub=empty,
    }

    ---------------------------------------------------------------------------
    -- Idle
    ---------------------------------------------------------------------------

    -- Balanced idle: Refresh+3, Regen+17, and the magic evasion that is the
    -- whole reason to bring a RUN. Turms is the M.Eva/Regen chassis; Runeist
    -- Coat +3 is the only Refresh body you own.
    --
    -- Mitigation here: DT-17% (Staunch 2, Murky 10, Moonlight 5) plus PDT-12%
    -- (Erilaz legs 6, Flume 4, Ogma 2), and Mensch Strap +1 adds another
    -- PDT-5% from the weapon set. So -34% physical / -17% magic, before the
    -- Aettir's separate "Physical damage taken II -5%".
    sets.idle = {
        ammo="Staunch Tathlum",       -- DT-2%, SIRD-10%, status resist+10
        head="Turms Cap",             -- M.Eva+99, MDB+6, "Regen"+6, "Regain"+4
        body="Runeist Coat +3",       -- Refresh+3, M.Eva+94, Res. all ele.+39
        hands="Turms Mittens +1",     -- M.Eva+101, "Regen"+6, Parry: recover HP+100
        legs="Erilaz Leg Guards",     -- PDT-6%, Enmity+10, "Inquartata"+1
        feet="Turms Leggings +1",     -- M.Eva+147 (your single biggest M.Eva piece)
        neck="Futhark Torque",        -- M.Eva+20, Enmity+5 - your only real neck
        waist="Flume Belt +1",        -- PDT-4%, converts 2% of damage taken to MP
        left_ear="Eabani Earring",    -- HP+45, M.Eva+8
        right_ear="Phawaylla Earring",
        left_ring="Murky Ring",       -- DT-10%, SIRD-3%
        right_ring="Moonlight Ring",  -- DT-5%, HP+110
        back=Ogma,
    }

    -- Adoulin movement speed. Councilor's Garb is DEF:1 - this is a town set,
    -- never wear it where something can hit you.
    sets.idle.Town = set_combine(sets.idle, {
        body="Councilor's Garb",      -- While in Adoulin: movement speed +25%
    })

    -- Worn over the idle set only while running (see 'gearinfo' in
    -- job_self_command), and by //gs c toggle Kiting. Was Sprinter's Shoes,
    -- whose speed only comes from using them, not wearing them.
    sets.Kiting = {legs="Track Pants +1"}   -- Movement speed +8% (2026-10-31)

    ---------------------------------------------------------------------------
    -- Defense modes  (//gs c pdt / mdt / dt / off)
    --
    -- Do NOT use '//gs c toggle physicaldefense'. Two reasons it cannot work:
    -- get_state() (Mote-SelfCommands.lua:298) matches state names exactly bar
    -- case, and the state is PhysicalDefenseMode - 'physicaldefense' misses and
    -- you get "Unknown field". Even spelled right, toggle errors on a list mode
    -- ("Can only toggle a boolean mode", Modes.lua:352). The long forms are
    -- '//gs c set DefenseMode Physical|Magical|DT|None'; the aliases in
    -- job_self_command are just shorthand for those.
    ---------------------------------------------------------------------------

    -- Max physical mitigation. DT-17% + PDT-20% = -37%, and Mensch Strap +1
    -- from the weapon set takes it to -42%. The cap on DT/PDT stacking is
    -- -50%, so you are 8% short and the Aettir's PDT II -5% sits on top of
    -- that in its own category.
    --
    -- Erilaz Surcoat +1 (i119) is here rather than Runeist Coat +3 for the
    -- enmity retention and the 5%-of-physical-damage-to-MP conversion; you
    -- give up Refresh+3 and 40 M.Eva for it, which is the right trade in a
    -- set whose whole job is eating melee.
    sets.defense.PDT = {
        ammo="Staunch Tathlum",       -- DT-2%
        head=FutharkBattuta,          -- PDT-3%, Haste+7%
        body="Erilaz Surcoat",        -- i119: enmity retention, 5% phys dmg -> MP
        hands="Runeist Mitons +3",    -- PDT-3%
        legs="Erilaz Leg Guards",     -- PDT-6%
        feet=HercFeet,                -- PDT-2%
        neck="Futhark Torque",
        waist="Flume Belt +1",        -- PDT-4%
        left_ear="Eabani Earring",
        right_ear="Phawaylla Earring",
        left_ring="Murky Ring",       -- DT-10%
        right_ring="Moonlight Ring",  -- DT-5%
        back=Ogma,                    -- PDT-2%
    }

    -- Max magic evasion. Roughly 593 M.Eva from armour alone, +50 more from
    -- the Aettir augment, on top of RUN's native Magic Def. Bonus - which the
    -- guide calls the highest in the game.
    --
    -- Rune. Trousers +3 over Feast Hose (M.Eva+107) on purpose: 8 M.Eva is
    -- noise, and the Runeist legs bring PDT-5% and status resist+10 while the
    -- Feast Hose bring Enmity-3.
    sets.defense.MDT = {
        ammo="Staunch Tathlum",       -- status resist+10, DT-2%
        head="Turms Cap",             -- M.Eva+99, MDB+6
        body="Runeist Coat +3",       -- M.Eva+94, MDB+7, Res. all ele.+39
        hands="Turms Mittens +1",     -- M.Eva+101, MDB+5
        legs="Rune. Trousers +3",     -- M.Eva+99, MDB+6, PDT-5%, status resist+10
        feet="Turms Leggings +1",     -- M.Eva+147, MDB+7
        neck="Futhark Torque",        -- M.Eva+20
        waist="Flume Belt +1",        -- PDT-4%
        left_ear="Eabani Earring",    -- M.Eva+8
        right_ear="Phawaylla Earring",
        left_ring="Murky Ring",       -- DT-10%
        right_ring="Moonlight Ring",  -- DT-5%
        back=Ogma,                    -- M.Eva+22
    }

    -- Hybrid. Use this when the damage is mixed and you do not know which of
    -- the two sets above you want.
    --
    -- IMPORTANT, so this set is not misread: it is NOT a higher-DT set. The
    -- general (uncapped-category) "Damage taken" pool Char3 owns is only
    -- three items - Staunch Tathlum -2%, Murky Ring -10%, Moonlight Ring -5%
    -- = -17% - and all three are ALREADY worn by sets.defense.PDT and MDT.
    -- There is no fourth. Mummu Kecks +1 (DT-4%) is MNK/THF/RNG/NIN/COR/DNC,
    -- not RUN (Char3_data.lua:749), and Adoulin's Refuge +1's DT-8% is
    -- "Reives: Damage taken-8%" - dead outside a Reive. So DT-17% is the
    -- ceiling in every defense set and this one cannot beat it.
    --
    -- What it actually does is take the piece in each slot that carries BOTH
    -- physical mitigation and magic defense, instead of going all-in either
    -- way. Against the other two:
    --
    --               physical      magic evasion    MDB
    --   PDT            -37%          405           ~12
    --   MDT            -28%          640           ~31
    --   DT (this)      -34%          543            24
    --
    -- (physical = PDT% + DT%; M.Eva includes the Aettir augment's +50. Add
    -- Mensch Strap +1's PDT-5% from the weapon set to all three, and the
    -- Aettir's Physical damage taken II -5% sits in its own category on top.)
    --
    -- So it gives up 3% physical against the PDT set and buys 138 M.Eva and
    -- 12 MDB with it. That is the trade this mode exists to make.
    --
    -- THE REAL COST IS ENMITY, and it is why this is not simply the default:
    -- dropping Erilaz Leg Guards loses Enmity+10, and dropping Erilaz Surcoat
    -- +1 loses "enmity retention when taking damage +11" plus the 5%-of-
    -- physical-damage-to-MP conversion. Enmity here is 15 (Futhark Torque +5,
    -- Ogma +10) against the PDT set's 25 plus retention. If you are holding
    -- hate against a real DD, stay in //gs c pdt.
    sets.defense.DT = {
        ammo="Staunch Tathlum",       -- DT-2%, SIRD-10%, status resist+10
        head=FutharkBattuta,          -- PDT-3%, Haste+7%, M.Eva+36 (Turms Cap trades the PDT away)
        body="Runeist Coat +3",       -- M.Eva+94, MDB+7, Res. all ele.+39, Refresh+3
        hands="Runeist Mitons +3",    -- PDT-3%, Haste+5%, M.Eva+67
        legs="Rune. Trousers +3",     -- PDT-5%, M.Eva+99, MDB+6, status resist+10 - the one piece that is best in both roles
        feet="Turms Leggings +1",     -- M.Eva+147, MDB+7, "Inquartata"+5 (HercFeet would be PDT-2% and M.Eva+75)
        neck="Futhark Torque",        -- M.Eva+20, Enmity+5
        waist="Flume Belt +1",        -- PDT-4%
        left_ear="Eabani Earring",    -- M.Eva+8
        right_ear="Phawaylla Earring",
        left_ring="Murky Ring",       -- DT-10%
        right_ring="Moonlight Ring",  -- DT-5%
        back=Ogma,                    -- PDT-2%, M.Eva+22, Enmity+10
    }

    ---------------------------------------------------------------------------
    -- Melee TP
    ---------------------------------------------------------------------------

    -- Tanking TP set. Gear Haste 27% (8+4+5+6+4), so the 25% cap is met with
    -- room to spare and the waist is free for Flume Belt +1 instead of
    -- Pya'ekue Belt.
    --
    -- Four Runeist +3 pieces = the 4-piece tier of the AF+3 set bonus,
    -- Accuracy / Ranged Accuracy / Magic Accuracy +45. (Set id 88, tiers
    -- +15/+30/+45/+60 at 2/3/4/5 pieces, read straight out of the dump.)
    -- Erilaz Leg Guards break the 5-piece for Enmity+10 and PDT-6%, which is
    -- the right call on a tank; sets.engaged.Acc below takes the 5-piece.
    --
    -- Rings are Murky + Moonlight (DT-15%) rather than Petrov Ring (Enmity+4,
    -- STP+5). You have 39 enmity in this set already and Petrov's 4 will not
    -- decide a hate fight; 10% off every hit will.
    sets.engaged = {
        ammo="Aqreqaq Bomblet",       -- Enmity+2, HP+20, STR+5
        head="Rune. Bandeau +3",      -- Haste+8%, Acc+47, M.Eva+83
        body="Runeist Coat +3",       -- Haste+4%, Acc+50, Refresh+3
        hands="Runeist Mitons +3",    -- Haste+5%, Acc+48, PDT-3%
        legs="Erilaz Leg Guards",     -- Haste+6%, Enmity+10, PDT-6%
        feet="Runeist Bottes +3",     -- Haste+4%, Acc+46
        neck="Futhark Torque",        -- Enmity+5, M.Eva+20
        waist="Flume Belt +1",        -- PDT-4%
        left_ear="Mache Earring +1",  -- Acc+10, DEX+8, DA+2%
        right_ear="Friomisi Earring", -- Enmity+2
        left_ring="Murky Ring",       -- DT-10%
        right_ring="Moonlight Ring",  -- DT-5%, Acc+8, Atk+8, STP+5
        back=Ogma,                    -- Enmity+10
    }

    -- Accuracy. Full five-piece Runeist +3 for the +60 Acc/MAcc set bonus:
    -- 240 accuracy off the armour itself plus 60 from the set, plus 70 from
    -- the Aettir augment. Haste is still 27%.
    sets.engaged.Acc = set_combine(sets.engaged, {
        legs="Rune. Trousers +3",     -- Acc+49, PDT-5% (gives up Enmity+10)
        left_ring="Moonlight Ring",   -- Acc+8, Atk+8
        right_ring="Enlivened Ring",  -- Acc+7
    })

    -- Pure damage. Nothing in here is a tanking piece - Adhemar Jacket +1 is
    -- Enmity-8 - so only use it when somebody else has hate.
    -- Haste 27%. Triple Attack +14%, Double Attack +2%, Quad +2%, Store TP 26.
    sets.engaged.DD = {
        ammo="Lucky Coin",            -- Acc+8
        head=AdheHead,                -- Haste+8%, TA+4%, STR+31, DEX+33, Atk+20
        body=AdheBody,                -- Haste+4%, TA+4%, Acc+35, Atk+55, Enmity-8
        hands=AdheHands,              -- Haste+5%, TA+4%, STP+7, Acc+32
        legs=HercLegs,                -- Haste+6%, STP+4, Acc+13/Atk+13
        feet=HercFeet,                -- Haste+4%, TA+2, STP+5, Acc+18/Atk+18
        neck="Futhark Torque",
        waist="Windbuffet Belt +1",   -- TA+2%, QA+2%
        left_ear="Mache Earring +1",  -- DA+2%, Acc+10, DEX+8
        right_ear="Eabani Earring",   -- HP+45 - nothing better exists, see gaps
        left_ring="Rajas Ring",       -- STP+5, Subtle Blow+5
        right_ring="Moonlight Ring",  -- Acc+8, Atk+8, STP+5
        back=Ogma,
    }

    ---------------------------------------------------------------------------
    -- Weapon skills
    ---------------------------------------------------------------------------

    -- Generic physical WS. Adhemar's STR/DEX/Attack path is simply the most
    -- weapon-skill stat you own, and the Aettir's WSD+10% applies on top of
    -- everything here.
    --
    -- The ear slots are the weak point of every WS set in this file: you own
    -- no WS earrings at all (no Moonshade, no Ishvara, no Thrud), so the best
    -- available is Mache Earring +1's DEX+8/Acc+10 and then filler.
    sets.precast.WS = {
        ammo="Lucky Coin",            -- Acc+8
        head=AdheHead,                -- STR+31, DEX+33, Atk+20
        body=AdheBody,                -- STR+38, Acc+35, Atk+55
        hands=AdheHands,              -- STR+27, DEX+56, Acc+32, Atk+20
        legs="Rune. Trousers +3",     -- STR+39 - your biggest STR legs
        feet="Runeist Bottes +3",     -- Acc+46, DEX+34
        neck="Futhark Torque",
        waist="Windbuffet Belt +1",   -- Acc+2 (no STR/DEX belt owned)
        left_ear="Mache Earring +1",  -- DEX+8, Acc+10
        right_ear="Eabani Earring",
        left_ring="Rajas Ring",       -- STR+2~5, DEX+2~5
        right_ring="Moonlight Ring",  -- Acc+8, Atk+8
        back=Ogma,
    }

    -- Dimidiation: 80% DEX, twofold, fTP 2.25 / 4.5 / 6.75. RUN's flagship WS
    -- and the reason DEX is worth chasing at all on this job. Unlocked by the
    -- quest "Rune Fencing the Night Away" - if it is not on your WS list yet,
    -- go do that before anything else in this file matters.
    --
    -- DEX from armour here is 196 (33+45+56+23+39). Volte Hose is the only
    -- DEX legs you own (Rune. Trousers +3 have none at all), and Turms
    -- Leggings +1 beat Runeist Bottes +3 on both DEX and accuracy.
    sets.precast.WS['Dimidiation'] = set_combine(sets.precast.WS, {
        legs="Volte Hose",            -- DEX+23, Acc+37
        feet="Turms Leggings +1",     -- DEX+39, Acc+48
    })

    -- Resolution: 73~85% STR depending on merits, fivefold, fTP 0.72 / 1.5 /
    -- 2.25. Five hits means accuracy decides the damage more than STR does -
    -- a whiffed hit is a whole fifth of the weapon skill gone.
    sets.precast.WS['Resolution'] = set_combine(sets.precast.WS, {
        legs="Rune. Trousers +3",     -- STR+39, Acc+49
        feet="Runeist Bottes +3",     -- Acc+46
    })

    -- Every other weapon skill falls through to sets.precast.WS above. That is
    -- deliberate: Resolution and Dimidiation are the two whose modifiers were
    -- verified, and guessing at the rest would just move gear around for no
    -- reason. Add named sets as you confirm them.

    ---------------------------------------------------------------------------
    -- Precast - fast cast
    ---------------------------------------------------------------------------

    -- 14% Fast Cast from gear, and that is the whole of it: Rune. Bandeau +3
    -- is the only Fast Cast piece you own. The rest of the slots are therefore
    -- filled with mitigation rather than left on whatever you were wearing.
    --
    -- This matters less on RUN than on any other caster, because the Inspira-
    -- tion merit grants up to +50% Fast Cast while Vallation or Valiance is
    -- up. Merit Inspiration to 4-5/5 and this set stops being a problem;
    -- buying Fast Cast gear for RUN is close to wasted money.
    sets.precast.FC = {
        ammo="Staunch Tathlum",       -- SIRD-10%
        head="Rune. Bandeau +3",      -- "Fast Cast"+14%
        body="Runeist Coat +3",
        hands="Runeist Mitons +3",
        legs="Rune. Trousers +3",
        feet="Runeist Bottes +3",
        neck="Futhark Torque",
        waist="Flume Belt +1",
        left_ear="Eabani Earring",
        right_ear="Phawaylla Earring",
        left_ring="Murky Ring",       -- SIRD-3%, DT-10%
        right_ring="Moonlight Ring",
        back=Ogma,
    }

    ---------------------------------------------------------------------------
    -- Precast - job abilities
    ---------------------------------------------------------------------------

    -- Vallation / Valiance duration. Runeist Coat +3 is +19, Ogma's Cape is
    -- +15 on the base item (not an augment), so both apply here.
    sets.precast.JA['Vallation'] = {
        body="Runeist Coat +3",
        back=Ogma,
    }
    sets.precast.JA['Valiance'] = sets.precast.JA['Vallation']

    sets.precast.JA['Pflug'] = {feet="Runeist Bottes +3"}       -- "Pflug"+4
    sets.precast.JA['Gambit'] = {hands="Runeist Mitons +3"}     -- duration +16
    sets.precast.JA['Battuta'] = {head=FutharkBattuta}          -- Enhances "Battuta"

    -- Vivacious Pulse heals off Divine Magic skill, and Rune. Trousers +3 are
    -- the only Divine skill piece you own (+19).
    sets.precast.JA['Vivacious Pulse'] = {legs="Rune. Trousers +3"}

    -- Rayke, Liement, One for All, Elemental Sforzo and Odyllic Subterfuge
    -- have no gear in your inventory that touches them. Left unset on purpose
    -- rather than filled with placebo swaps.

    ---------------------------------------------------------------------------
    -- Midcast
    ---------------------------------------------------------------------------

    -- Lunge / Swipe. Magic Attack Bonus +49 from armour, +10 more if you are
    -- holding the Eletta Sword (//gs c eletta), which also brings MAcc+30 and
    -- Magic Damage+217.
    --
    -- NOTE Murky Ring is deliberately absent: its Magic Accuracy+15 is prefixed
    -- "Pet:" in the item text and does nothing for you.
    sets.midcast.Lunge = {
        ammo="Staunch Tathlum",
        head="Rune. Bandeau +3",      -- no MAB head exists in your gear
        body="Runeist Coat +3",
        hands="Runeist Mitons +3",
        legs=HercLegs,                -- MAcc+19, MAB+19 (beats Shned. Tights +1)
        feet=HercFeet,                -- MAcc+4, MAB+4  (Herculean Boots base MAB+10)
        neck="Futhark Torque",
        waist="Salire Belt",          -- MAcc+4, MAB+4
        left_ear="Friomisi Earring",  -- MAB+10, Enmity+2
        right_ear="Hecate's Earring", -- MAB+6
        left_ring="Moonlight Ring",
        right_ring="Petrov Ring",
        back=Ogma,
    }
    sets.midcast.Swipe = sets.midcast.Lunge

    -- Enhancing magic. Skill only - you own no enhancing duration gear
    -- (no Telchine, no Chironic with duration), so Phalanx potency and buff
    -- duration both come purely off skill here.
    sets.midcast['Enhancing Magic'] = {
        hands="Runeist Mitons +3",    -- Enhancing magic skill +19
        legs="Rawhide Trousers",      -- Enhancing magic skill +10
    }
    sets.midcast.Phalanx = sets.midcast['Enhancing Magic']

    -- Futhark Bandeau's "Phalanx" received +4 boosts a Phalanx cast on you by
    -- SOMEONE ELSE, not your own. It is not in the Phalanx set above; wear it
    -- while a RDM/SCH is buffing you (//gs c pxr).
    sets.PhalanxReceived = {head=FutharkBattuta}

    -- Spell interruption rate down. This is the biggest hole in the file:
    -- Staunch Tathlum (-10%) and Murky Ring (-3%) are the only two SIRD pieces
    -- you own, so this set is -13% against a -102% cap. Expect to be
    -- interrupted casting anything while being hit. See BLOCKED UPGRADES.
    sets.midcast.SIRD = set_combine(sets.defense.PDT, {
        ammo="Staunch Tathlum",       -- SIRD-10%
        left_ring="Murky Ring",       -- SIRD-3%
    })

    sets.midcast['Divine Magic'] = {legs="Rune. Trousers +3"}   -- Divine skill +19

    ---------------------------------------------------------------------------
    -- Enmity
    ---------------------------------------------------------------------------

    -- Enmity burst set, for Flash / Provoke / Foil / Blank Gaze and the enmity
    -- job abilities. Enmity +33 from armour, +10 from the Aettir = 43.
    --
    -- That is a long way off the guide's high-end sets, and the reason is that
    -- you own none of the enmity chassis: no Emet Harness, no Halitus Helm,
    -- no Trux or Cryptic Earring, no Eihwaz or Vexer Ring, no Trance Belt,
    -- no Sapience Orb, no Moonlight Necklace. What you have is Erilaz legs,
    -- Ogma's Cape, Futhark Torque, Aqreqaq Bomblet, Friomisi and Petrov.
    --
    -- Deceit Mask (Enmity+3) is NOT used: it is DEF:29 with no haste and no
    -- magic evasion, and three enmity is not worth wearing a level-70 hat into
    -- a fight where something is swinging at you.
    sets.Enmity = {
        ammo="Aqreqaq Bomblet",       -- Enmity+2
        head="Rune. Bandeau +3",
        body="Erilaz Surcoat",        -- i119: enmity retention when taking damage
        hands="Runeist Mitons +3",
        legs="Erilaz Leg Guards",     -- Enmity+10
        feet="Runeist Bottes +3",
        neck="Futhark Torque",        -- Enmity+5
        waist="Flume Belt +1",
        left_ear="Friomisi Earring",  -- Enmity+2
        right_ear="Eabani Earring",
        left_ring="Petrov Ring",      -- Enmity+4
        right_ring="Moonlight Ring",
        back=Ogma,                    -- Enmity+10
    }

    -- Enmity spells (Flash, Foil, Blank Gaze...) want the enmity set, but they
    -- are also cast mid-fight while being hit, so they want SIRD. You cannot
    -- have both with this inventory - the enmity set wins, because an
    -- interrupted Flash and an unresisted-but-low-enmity Flash both fail, and
    -- the enmity gear at least works when the cast lands.
    sets.midcast.Enmity = sets.Enmity
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

-- Hate tools across the subjobs the guide recommends: /WAR (Provoke, Warcry),
-- /WHM or /PLD (Flash), /BLU (the gaze and song line), plus RUN's own Foil.
-- Add to this list rather than writing another branch.
enmity_actions = S{
    'Provoke', 'Warcry', 'Flash', 'Foil', 'Blank Gaze', 'Jettatura',
    'Geist Wall', 'Sheep Song', 'Stinking Gas', 'Soporific',
}

function job_precast(spell, action, spellMap, eventArgs)
    -- Hate first, fast cast second. eventArgs.handled stops Mote replacing
    -- this with sets.precast.FC, which is deliberate: 14% fast cast is not
    -- worth losing the enmity on the one action whose only purpose is enmity.
    if enmity_actions:contains(spell.english) then
        equip(sets.Enmity)
        eventArgs.handled = true
    end
end

function job_midcast(spell, action, spellMap, eventArgs)
    -- Enmity on a spell is applied at completion, not at precast, so the set
    -- has to still be on here.
    if enmity_actions:contains(spell.english) then
        equip(sets.Enmity)
        eventArgs.handled = true
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if player.status == 'Engaged' then
        equip(get_melee_set())
    end
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

    if cmd == 'aettir' or cmd == 'tank' then
        state.WeaponMode:set('Aettir')
        equip(sets.weapons.Aettir)
        add_to_chat(122, 'GearSwap: Aettir + Mensch Strap +1 (tank)')

    elseif cmd == 'gs' or cmd == 'greatsword' then
        state.WeaponMode:set('GreatSword')
        equip(sets.weapons.GreatSword)
        add_to_chat(122, 'GearSwap: Beryllium Sword + Balarama Grip')

    elseif cmd == 'ga' or cmd == 'greataxe' or cmd == 'axe' then
        state.WeaponMode:set('GreatAxe')
        equip(sets.weapons.GreatAxe)
        add_to_chat(122, 'GearSwap: Hepatizon Axe +1 + Balarama Grip')

    elseif cmd == 'eletta' or cmd == 'magic' then
        state.WeaponMode:set('Eletta')
        equip(sets.weapons.Eletta)
        add_to_chat(122, 'GearSwap: Eletta Sword, sub empty (Lunge / Swipe)')

    elseif cmd == 'pdt' then
        state.DefenseMode:set('Physical')
        handle_update({'auto'})
        add_to_chat(122, 'GearSwap: DEFENSE = PDT (max physical)')

    elseif cmd == 'mdt' then
        state.DefenseMode:set('Magical')
        handle_update({'auto'})
        add_to_chat(122, 'GearSwap: DEFENSE = MDT (max magic evasion)')

    elseif cmd == 'dt' then
        state.DefenseMode:set('DT')
        handle_update({'auto'})
        add_to_chat(122, 'GearSwap: DEFENSE = DT (hybrid - less enmity, see notes)')

    elseif cmd == 'off' or cmd == 'nodef' then
        state.DefenseMode:reset()
        handle_update({'auto'})
        add_to_chat(122, 'GearSwap: DEFENSE OFF')

    elseif cmd == 'pxr' then
        equip(sets.PhalanxReceived)
        add_to_chat(122, 'GearSwap: Futhark Bandeau - "Phalanx" received +4')

    elseif cmd == 'lockback' then
        send_command('gs disable back')
        add_to_chat(122, 'GearSwap: BACK SLOT LOCKED')

    elseif cmd == 'unlockback' then
        send_command('gs enable back')
        add_to_chat(122, 'GearSwap: BACK SLOT UNLOCKED')
    end
end

---------------------------------------------------------------------------
-- BLOCKED UPGRADES / GAPS - what is actually holding this set back
---------------------------------------------------------------------------
--
-- These are real holes in the inventory, ranked by how much they cost you.
-- Nothing here is a "nice to have"; each one is a slot currently doing much
-- less than the job wants.
--
--   SIRD, everything     You own 13% spell interruption rate down against a
--                        102% cap. The cheap fixes are all craftable or
--                        trivially farmable: Rawhide Gloves, Carmine Cuisses
--                        +1, and Taeon Chapeau / Tabard / Boots augmented
--                        SIRD-10% each. That alone takes you to roughly 60%
--                        and makes casting under fire possible. Do this first.
--
--   Earrings, both ears  You own no tanking earrings and no weapon skill
--                        earrings. Every set above is running filler
--                        (Phawaylla, Eabani, Mache) in at least one ear.
--                        Odyssey/Sortie targets: Tuisto Earring (HP+150),
--                        Alabaster Earring, Etiolation Earring, Sanare
--                        Earring, Trux and Cryptic Earring for enmity.
--
--   Enmity chassis       43 enmity is thin for a main tank. The single
--                        biggest jumps available are Emet Harness +1 (body),
--                        Halitus Helm (head), Eihwaz Ring, Vexer Ring +1 and
--                        Trance Belt. Sapience Orb in the ammo slot is a
--                        trivial pickup.
--
--   Erilaz +2/+3         Erilaz Surcoat is +1 (i119); Erilaz Leg Guards are
--                        still BASE. Every high-end set in the guide runs +2 or
--                        +3 versions; Erilaz Galea +3 in particular is the
--                        SIRD head AND a Vivacious Pulse piece. You are also
--                        missing Erilaz Gauntlets and Erilaz Greaves entirely,
--                        so the Erilaz "occ. absorbs damage taken" set bonus
--                        is stuck at two pieces.
--
--   Futhark Torque       Base. Futhark Torque +2 is HP+60, STR/MND+15, DT-7%.
--                        Your neck slot is currently M.Eva+20 / Enmity+5 and
--                        nothing else, in every single set in this file.
--
--   Waist                No enmity belt, no STR/DEX belt, no Engraved Belt.
--                        Flume Belt +1 is doing all the work by default and
--                        Windbuffet Belt +1 is the WS waist purely because
--                        nothing else has a stat on it.
--
--   Ogma's Cape          You own two, and the second one is blank (DEX+1).
--                        A second properly-augmented Ogma - Fast Cast+10% or
--                        Enmity+10/DA - would let the WS and FC sets stop
--                        borrowing the tank cape.
--
--   Dimidiation          If "Rune Fencing the Night Away" is not done, the
--                        best weapon skill on the job is not on your list and
--                        sets.precast.WS['Dimidiation'] never fires.

-- Lockstyle. The game clears style lock on every job change, so it has to be
-- re-applied - Mote calls select_default_macro_book() on load and on job
-- change, which is the right place for it.
--
-- SET THIS to your in-game equipset number (the "Set###" in the Macros menu).
-- The placeholder below is a guess. A number with no matching equipset fails
-- silently, so if your appearance does not lock, this is the first thing to check.
-- Set it to 0 to lock to whatever you happen to be wearing at that moment.
LOCKSTYLE_SET = 0

function select_default_macro_book()
    set_macro_page(1, 1)
    add_to_chat(122, 'GearSwap: macro book 1 page 1 for RUN')
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

-- Running while idle: add sets.Kiting (Track Pants +1) on top of the idle set.
function customize_idle_set(idleSet)
    if gearinfo_moving and sets.Kiting then
        return set_combine(idleSet, sets.Kiting)
    end
    return idleSet
end
