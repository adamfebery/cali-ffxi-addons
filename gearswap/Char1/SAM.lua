-- SAM GearSwap - GKT / Polearm
--
-- GKT TP     = Masamune
-- Polearm TP = Shining One
--
-- GKT WS     = Fudo / Gekko / Kasha / Shoha / Ageha
-- Polearm WS = Stardiver / Sonic Thrust / Impulse Drive
--
-- Weapons live ONLY in sets.weapons and are equipped ONLY by an explicit
-- //gs c command. TP and WS sets contain no main/sub, so engaging and
-- finishing a WS can never change the weapon you are holding.
--
-- Commands:
--   //gs c gkt
--   //gs c polearm
--   //gs c dt         TP mode: capped damage taken
--   //gs c normal     TP mode: full offence (default)
--   //gs c th         toggle Treasure Hunter +3 over the TP set
--   //gs c lockback
--   //gs c unlockback

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function user_setup()
    state.WeaponMode = M{['description']='Weapon', 'GKT', 'Polearm'}
    -- Offence first: M{} defaults to its first entry, and you should have to ask
    -- for the DT set rather than silently lose Store TP to it.
    state.TPMode = M{['description']='TP Mode', 'Normal', 'DT'}
    -- Trust the game, not the mode: start off matching what is actually equipped.
    sync_weapon_mode()
    
    -- GearInfo's display toggles are saved per character in
    -- gearinfo/data/<name>_settings.xml, so they survive job changes on their own.
    -- Re-sending them from user_setup() (which Mote re-runs on EVERY job change)
    -- only produced a burst of GearInfo log lines in chat. Configure it once with
    -- //gi ... by hand instead.

    -- Mote never calls select_default_macro_book() itself, so it is called
    -- here. user_setup() runs on load (job change) and on every subjob change,
    -- which re-applies the macro book and lockstyle both times.
    select_default_macro_book()
end

-- Polearms this lua knows about. Anything not listed is treated as GKT.
polearms = S{'Shining One', 'Nibiru Lance'}

function current_weapon_mode()
    local main = player and player.equipment and player.equipment.main
    if polearms:contains(main or '') then
        return 'Polearm'
    end
    return 'GKT'
end

function sync_weapon_mode()
    local actual = current_weapon_mode()
    if state.WeaponMode.value ~= actual then
        state.WeaponMode:set(actual)
    end
    return actual
end

function init_gear_sets()

    -- The only sets that ever touch main/sub.
    sets.weapons = {}

    sets.weapons.GKT = {
        main="Masamune",
        sub="Daduchos Grip",
    }

    sets.weapons.Polearm = {
        main="Shining One",
        sub="Daduchos Grip",
    }

    -- Single TP set - the gear was identical for both weapons. No main/sub.
    -- Kept in its own table rather than as sets.engaged subtables: a
    -- self-referencing set table is a recursion hazard inside GearSwap.
    sets.TP = {}

    sets.TP.Normal = {
        ammo="Coiste Bodhar",
        head="Kasuga Kabuto +2",
        body="Kasuga Domaru +3",
        hands="Wakido Kote +3",
        legs="Kasuga Haidate +2",
        feet="Kas. Sune-Ate +2",
        neck={name="Sam. Nodowa +1", augments={'Path: A'}},
        waist="Sailfi Belt +1",
        left_ear="Telos Earring",
        right_ear={name="Kasuga Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+6','Mag. Acc.+6'}},
        left_ring="Chirich Ring",
        right_ring="Petrov Ring",
        back={name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%'}},
    }

    -- Capped damage taken, for when you are eating hits rather than racing a
    -- parse. DT and Haste figures are read from your gearinfo dump
    -- (addons/gearinfo/data/Char1_data.lua). Murky Ring is now cached there
    -- too, and the dump confirms the DT-10% that was previously taken on faith.
    --
    -- The normal TP set already carries -38% without trying:
    --
    --   -9   Kasuga Kabuto +2     head, unchanged          haste 7%, STP 11
    --   -14  Kasuga Domaru +3     body, unchanged          haste 3%, STP 14
    --   -10  Kasuga Haidate +2    legs, unchanged          haste 5%, STP 10
    --   -5   Smertrios's Mantle   back, unchanged
    --   -10  Murky Ring           replaces Chirich Ring        costs 5 STP
    --   -5   Elite Royal Collar   replaces Sam. Nodowa +1      costs 5 STP
    --   ---
    --   -53  capped to -50%
    --
    -- Total cost: 10 Store TP, and nothing else. Neither replacement carries
    -- Haste, so gear haste stays at 31% - still 6% clear of the 25% cap. This
    -- set is haste capped exactly like the normal one. Petrov Ring keeps its
    -- slot: Accuracy+10, Attack+10, "Double Attack"+1%, "Store TP"+5.
    --
    -- Murky Ring rather than Defending Ring: both are all-jobs DT-10%, but
    -- Murky's Path A augment adds Accuracy and critical hit rate as it ranks,
    -- while Defending Ring's line is purely defensive. Defending Ring stays in
    -- sets.idle, where the offence does not matter.
    --
    -- Nothing else you own can help: Sulevia's gauntlets and cuisses carry DT
    -- but are WAR/PLD/DRK/DRG only, and you own no DT feet, ammo or earring.
    -- Plat. Mog. Belt has DT-3% but would cost Sailfi Belt +1's Haste+9% and
    -- drop you under the haste cap - never make that trade.
    sets.TP.DT = set_combine(sets.TP.Normal, {
        neck="Elite Royal Collar",
        left_ring="Murky Ring",
    })

    -- Mote's own fallback if anything reaches it before the mode is read.
    sets.engaged = sets.TP.Normal

    -- Treasure Hunter overlay, toggled with //gs c th. Laid over whichever TP
    -- set is active (Normal or DT), so it only ever replaces these four slots.
    -- SAM/DRG has no native TH, so this is the whole total: TH+4. It is every
    -- SAM-equippable TH piece in the gearinfo dump (rechecked 2026-10-20 - the
    -- Wh. Rarab Cap +1 was missed on 2026-10-02); the only other TH gear
    -- owned, Plun. Armlets and Thief's Knife, is THF-only.
    --
    -- TH only has to be on for the hits that tag the mob - turn it off once
    -- the mob is tagged and you're back to the full TP set.
    --
    -- Cost while on: Kasuga Kabuto +2, Wakido Kote +3 and Kasuga Haidate +2
    -- come off, which drops the Kabuto's DT-9%, Haste+7% and STP+11, the Kote's
    -- Acc+48 and the Haidate's DT-10% and STP+10. Sets.TP.DT loses both DT
    -- pieces, so don't lean on TH mode as a tank set.
    sets.TH = {
        ammo="Per. Lucky Egg",        -- TH+1
        head="Wh. Rarab Cap +1",      -- TH+1 (wardrobe 2)
        hands="Volte Bracers",        -- TH+1, Acc+37, Haste+5%
        legs="Valorous Hose",         -- TH+1 (augment - only pair owned), DA+3%, Haste+5%
    }

    -- Worn over the idle set only while running (see 'gearinfo' in
    -- job_self_command). Standing still keeps the DT legs below.
    sets.Kiting = {legs="Track Pants +1"}   -- Movement speed +8% (2026-10-31)

    -- Idle. Built from allgear.csv (findAll dump), not just this file.
    -- No main/sub - idling must never change the weapon you are holding.
    --
    -- DT total: body -14, legs -10, neck -5, L ring -10, R ring -10, back -5
    -- = -54%, capped at -50%.
    -- 2026-10-31: Mpaca's Gloves and Boots add PDT-14% on top (-68% physical),
    -- spare buffer past the cap, at no HP cost.
    -- Head is Wakido Kabuto +2 for Regain+3 rather than Kasuga Kabuto +2's
    -- DT-9%: a deliberate trade of mitigation for TP while sheathed. With that
    -- head it would be -63%. Either way the cap is met, so the Regain is free.
    -- There is 4% of overflow past the cap, which is the whole budget: dropping
    -- any one -5% piece still caps, but dropping a -10% piece does not.
    -- Where a slot had no defensive option, the TP piece is used as filler.
    sets.idle = {
        ammo="Coiste Bodhar",
        head="Wakido Kabuto +2",              -- Regain+3, HP+57, Haste+7% (gives up Kasuga Kabuto +2: DT-9%, HP+63)
        body="Kasuga Domaru +3",              -- DT-14%, HP+96  (beats Sakonji Domaru +2: HP+91, no DT)
        hands="Mpaca's Gloves",               -- PDT-8%, HP+61 (2026-10-31; was Flam. Manopolas +1, HP+60, no DT)
        legs="Kasuga Haidate +2",             -- DT-10%, HP+70  (beats Wakido Haidate +4: HP+95, no DT)
        feet="Mpaca's Boots",                 -- PDT-6%, HP+50 (2026-10-31; was Kas. Sune-Ate +2, HP+35, no DT)
        neck="Elite Royal Collar",            -- DT-5%, VIT+10, Regen+3 - drop it and you are at -49%, just under cap
        waist="Sailfi Belt +1",
        left_ear="Telos Earring",             -- no defensive earring owned
        right_ear={name="Kasuga Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+6','Mag. Acc.+6'}},
        left_ring="Defending Ring",           -- DT-10%, the best idle ring you own
        right_ring="Murky Ring",              -- DT-10%; replaces Chirich's Regen+1 while preserving Defending Ring
        back={name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%'}},
    }

    -- 2026-10-31: Mpaca's Cap is the head in every GKT and polearm WS set
    -- except Ageha, as in the SAM guide (Bippin's sets). "TP Bonus"+200,
    -- STR+33, Acc/Atk+40, Crit+4%. At 3000 TP the TP Bonus is wasted, so
    -- job_precast puts Flam. Zucchetto +2 back on (the guide does the same at
    -- 3000). Not modelled - the 2026-10-21 optimizer pass predates the Cap.
    sets.GKT_WS = {
        ammo="Knobkierrie",
        head="Mpaca's Cap",
        body="Sakonji Domaru +2",
        hands={name="Valorous Mitts", augments={'"Mag.Atk.Bns."+13','Accuracy+22','Weapon skill damage +4%','Accuracy+19 Attack+19','Mag. Acc.+1 "Mag.Atk.Bns."+1'}},
        legs="Wakido Haidate +4",
        feet={name="Valorous Greaves", augments={'Weapon skill damage +5%','AGI+2','Accuracy+9','Attack+9'}},
        neck={name="Sam. Nodowa +1", augments={'Path: A'}},
        waist="Sailfi Belt +1",
        left_ear="Thrud Earring",
        right_ear="Ishvara Earring",
        left_ring="Karieyh Ring",
        right_ring="Cornelia's Ring",
        back={name="Smertrios's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%'}},
    }

    sets.POLEARM_WS = {
        ammo="Knobkierrie",
        head="Mpaca's Cap",
        body="Sakonji Domaru +2",
        hands={name="Valorous Mitts", augments={'"Mag.Atk.Bns."+13','Accuracy+22','Weapon skill damage +4%','Accuracy+19 Attack+19','Mag. Acc.+1 "Mag.Atk.Bns."+1'}},
        legs="Wakido Haidate +4",
        feet={name="Valorous Greaves", augments={'Weapon skill damage +5%','AGI+2','Accuracy+9','Attack+9'}},
        neck={name="Sam. Nodowa +1", augments={'Path: A'}},
        waist="Sailfi Belt +1",
        left_ear="Thrud Earring",
        right_ear="Ishvara Earring",
        left_ring="Karieyh Ring",
        right_ring="Cornelia's Ring",
        back={name="Smertrios's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%'}},
    }

    -- Stardiver is a four-hit, fTP-replicating WS and Shoha is two-hit.  For
    -- these, favor all-hit value over small first-hit-only WSD pieces:
    -- Brutal's DA can add another full hit, Rajas adds STR to every hit, and
    -- Kasuga feet add STR, Attack and Physical Damage Limit+ to every hit.
    -- The WSD cape and Wakido legs stay: their high STR/WSD remain worthwhile.
    sets.MULTIHIT_WS = set_combine(sets.GKT_WS, {
        feet="Kas. Sune-Ate +2",
        right_ear="Brutal Earring",
        left_ring="Rajas Ring",
    })

    -- Stardiver (2026-10-31): the guide's Stardiver set is Mpaca's Cap,
    -- Doublet, Gloves and Hose - a four-hit WS where Triple Attack and crit on
    -- every hit beat first-hit WSD. Yours are unranked (the guide says R30),
    -- so this is a stat-priority pick, not a modelled one. Feet stay Kasuga.
    sets.STARDIVER = set_combine(sets.MULTIHIT_WS, {
        body="Mpaca's Doublet",       -- STR+39, TA+4%, Crit+7%, Acc/Atk+40
        hands="Mpaca's Gloves",       -- DEX+44 STR+20, TA+3%, Crit+5%, Acc/Atk+40
        legs="Mpaca's Hose",          -- STR+49, TA+4%, Crit+6%, Acc/Atk+40
    })

    -- Tachi: Ageha - 60% CHR / 40% STR, the only great katana WS that weights
    -- CHR at all. It lands Defense Down 25-27% for 3 minutes, and the proc
    -- chance scales with TP.
    --
    -- Treat this as a debuff, not a nuke: Ageha's own damage is incidental,
    -- what matters is that the WS connects so the Defense Down rolls. So this
    -- set is built for accuracy first and the CHR/STR mod second, and it drops
    -- the WSD armour entirely - which costs nothing, because your WSD pieces
    -- are also your worst CHR pieces.
    --
    -- Per slot, scored as 0.6*CHR + 0.4*STR against what GKT_WS uses:
    --
    --   head   Flam. Zucchetto +2 21.6  Acc 44   ->  Kasuga Kabuto +2   25.0  Acc 51
    --   body   Sakonji Domaru +2  30.4  Acc 37   ->  Kasuga Domaru +3   37.6  Acc 64
    --   hands  Valorous Mitts     15.4  Acc 10   ->  Wakido Kote +3     27.6  Acc 48
    --   legs   Wakido Haidate +4  30.8  Acc 59   ->  unchanged, it wins both ways
    --   feet   Valorous Greaves   18.8  Acc 12   ->  Kas. Sune-Ate +2   27.8  Acc 50
    --
    -- Net: +32 mod stat and +110 accuracy over GKT_WS. The Kasuga set carries
    -- the CHR and the accuracy together, so there is no trade to make here.
    --
    -- Accessories keep the GKT_WS choices: you own no CHR neck, waist, ear,
    -- ring, back or ammo at all - the whole slot group is 0 CHR - so there is
    -- nothing to gain by moving them, and WSD/accuracy is the best use left.
    --
    -- Moonshade Earring still applies below 2750 TP via the shared overlay
    -- below, and for once it is doing double duty: its TP Bonus +250 raises
    -- effective TP, which raises Ageha's Defense Down proc rate.
    --
    -- ON THE DEBUFF NOT LANDING - there is nothing to gear for. The Defense
    -- Down is an additional-effect proc, not a magic-accuracy enfeeble, so
    -- Magic Accuracy and CHR do not improve its landing chance. Only two
    -- things matter, and neither is a gear slot:
    --
    --   1. TP at cast time. Proc chance varies with TP. Since the June 2017
    --      buff it lands at a very high rate on normal content, so in practice
    --      the WS just has to connect - hence accuracy first, above.
    --
    --   2. The resist window. Once it lands the target resists reapplication
    --      for ~1.5 min, while the debuff itself runs 3 min. Fire Ageha once
    --      and go back to Fudo/Shoha; spamming it does nothing.
    --
    -- The real failure mode is not a resist, it is the shared slot. Defense
    -- Down holds ONE effect and the last application generally wins:
    --
    --   Tourbillion (BLU)          -33%
    --   Tachi: Ageha               -25%
    --   Armor Break/Shell Crusher  -25%
    --   Angon (DRG)                -20~25%
    --   Full Break, Acid Bolt      -12.5%
    --
    -- So a party member's -12.5% Full Break landing after your -25% Ageha
    -- downgrades the debuff. (Your own WAR.lua has Full Break in it - do not
    -- fire it after a SAM Ageha.) Dia is a SEPARATE group: Dia, Box Step,
    -- Defense Down and Geo-Frailty all stack additively, so Ageha + Dia III +
    -- Frailty is fine. Mob Defense Up (Cocoon, Water Wall) can block or
    -- overwrite it, and Ageha can overwrite those in turn.
    sets.AGEHA = {
        ammo="Knobkierrie",
        head="Kasuga Kabuto +2",
        body="Kasuga Domaru +3",
        hands="Wakido Kote +3",
        legs="Wakido Haidate +4",
        feet="Kas. Sune-Ate +2",
        neck={name="Sam. Nodowa +1", augments={'Path: A'}},
        waist="Sailfi Belt +1",
        left_ear="Thrud Earring",
        right_ear="Ishvara Earring",
        left_ring="Karieyh Ring",
        right_ring="Cornelia's Ring",
        back={name="Smertrios's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%'}},
    }

    -- Low-TP overlay: TP Bonus +250 is wasted at the 3000 TP cap.
    sets.MoonshadeWS = {left_ear="Moonshade Earring"}

    -- Meditate. Duration is fixed when the buff lands, so precast-only is
    -- correct here - do NOT add a 'gs disable head' hold, it just costs you the
    -- TP head for no gain.
    -- The +2 is the right call: same 'Meditate' duration +4 as the +1, but
    -- HP+57 instead of +38, and it adds Regain+3.
    -- Smertrios's Mantle: every copy carries "Meditate" effect duration +8 as
    -- a base stat (gearinfo dump), so the TP cape already gives it while
    -- engaged; naming it here makes sure it's on for an idle Meditate too.
    sets.precast.JA['Meditate'] = {
        head="Wakido Kabuto +2",
        back={name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%'}},
    }

    -- Hasso. Wakido Kote +3 is "Hasso"+4 (gearinfo dump, Char1_data.lua):
    -- it raises the STR bonus Hasso grants, and that bonus is fixed when the
    -- ability goes off - so the gloves have to be ON at activation, not later.
    -- Both TP sets already wear them, but sets.idle does not (it runs
    -- Flam. Manopolas +1 for HP), and Hasso is normally popped while sheathed
    -- or mid-engage. That idle window is the whole reason this set exists.
    -- No 'gs disable hands' hold: the bonus is snapshot, and if it should turn
    -- out to be a worn-while-active effect instead, the TP sets cover it.
    --
    -- Kasuga Haidate +2's separate "Hasso": Haste+3% IS a worn-while-active
    -- line, and it is already in sets.TP.Normal, sets.TP.DT and sets.idle, so
    -- it needs nothing here.
    sets.precast.JA['Hasso'] = {hands="Wakido Kote +3"}

    -- 2026-10-21 GearSwap-Optimizer pass. Fudo keeps GKT_WS (its own set beat
    -- the optimizer's by 2-3%). Kasha and Gekko take Kasuga Domaru +3 over
    -- Sakonji Domaru +2 and Kas. Sune-Ate +2 over Valorous Greaves, and swap
    -- the ears so Thrud sits RIGHT: Moonshade replaces the left ear below
    -- 2750 TP, so this leaves Moonshade + Thrud instead of Moonshade + Ishvara.
    -- Above 2750 the set is the same two earrings.
    --   Kasha  +7.9% unbuffed, +5.0% fully buffed
    --   Gekko  +7.6% unbuffed, +5.0% fully buffed
    sets.KASUGA_GKT_WS = set_combine(sets.GKT_WS, {
        body="Kasuga Domaru +3",
        feet="Kas. Sune-Ate +2",
        left_ear="Ishvara Earring",
        right_ear="Thrud Earring",
    })

    -- Explicitly define every GKT WS.
    sets.precast.WS['Tachi: Fudo']  = sets.GKT_WS
    sets.precast.WS['Tachi: Gekko'] = sets.KASUGA_GKT_WS
    sets.precast.WS['Tachi: Kasha'] = sets.KASUGA_GKT_WS
    sets.precast.WS['Tachi: Shoha'] = sets.MULTIHIT_WS
    sets.precast.WS['Tachi: Ageha'] = sets.AGEHA

    -- Explicitly define the Polearm WSs.
    -- Impulse Drive (optimizer pass): the Kasha swaps plus Flam. Manopolas +1
    -- over Valorous Mitts: +16.0% unbuffed, +4.1% fully buffed. Sonic Thrust
    -- stays on POLEARM_WS (within noise).
    -- 2026-10-31 optimizer pass (with Mpaca's): Impulse Drive takes Mpaca's
    -- Doublet, Gloves and Boots: +11.8% unbuffed, +7.5% buffed. Sonic Thrust
    -- takes the same three (+13.2% / +3.4%, part of that from an ear swap
    -- not applied). Stardiver, Fudo, Kasha, Gekko and Shoha: current sets win
    -- or tie.
    sets.precast.WS['Stardiver']     = sets.STARDIVER
    sets.precast.WS['Sonic Thrust']  = set_combine(sets.POLEARM_WS, {
        body="Mpaca's Doublet",
        hands="Mpaca's Gloves",
        feet="Mpaca's Boots",
    })
    sets.precast.WS['Impulse Drive'] = set_combine(sets.POLEARM_WS, {
        body="Mpaca's Doublet",
        hands="Mpaca's Gloves",
        feet="Mpaca's Boots",
        left_ear="Ishvara Earring",
        right_ear="Thrud Earring",
    })
end

function job_setup()
end

-- Treasure Hunter mode. A plain flag rather than a state.M: it's an overlay on
-- top of TPMode, not a third TP mode, so DT + TH works. While it's on, the
-- TH slots are locked with GearSwap's disable(), so WS, JA and idle sets can't
-- swap them out either.
TH_MODE = false
TH_SLOTS = {'ammo', 'head', 'hands', 'legs'}

-- GearSwap's slot locks live outside this file and survive //gs reload and job
-- changes, but TH_MODE does not. Unlock on unload so a reload never leaves you
-- with TH gear stuck on and the button showing OFF. Mote calls this from its
-- file_unload. Only runs while TH is on, so other manual locks are left alone.
function user_unload()
    if TH_MODE then
        enable(TH_SLOTS)
    end
end

-- The engaged set: the current TP mode, plus the TH overlay while it's on.
function tp_set()
    local tp = sets.TP[state.TPMode.value]
    if TH_MODE then
        return set_combine(tp, sets.TH)
    end
    return tp
end

GKT_WS_LIST     = S{'Tachi: Fudo', 'Tachi: Gekko', 'Tachi: Kasha', 'Tachi: Shoha',
                    'Tachi: Ageha'}
POLEARM_WS_LIST = S{'Stardiver', 'Sonic Thrust', 'Impulse Drive'}

function job_precast(spell, action, spellMap, eventArgs)
    if spell.type ~= 'WeaponSkill' then
        return
    end

    local label
    if GKT_WS_LIST:contains(spell.english) then
        label = 'GKT'
    elseif POLEARM_WS_LIST:contains(spell.english) then
        label = 'Polearm'
    else
        return
    end

    -- Look the set up BY NAME, not by weapon class.
    --
    -- This used to read `ws_set = sets.GKT_WS` / `sets.POLEARM_WS` off the
    -- list match alone, and then set eventArgs.handled, which stops Mote from
    -- ever consulting sets.precast.WS. The per-WS tables below were therefore
    -- dead code: Tachi: Shoha and Stardiver were both firing in the generic
    -- set instead of MULTIHIT_WS, and any new entry (Ageha) would have been
    -- ignored the same way. The weapon-class set is now only the fallback for
    -- a listed WS that has no table of its own.
    local ws_set = sets.precast.WS[spell.english]
        or (label == 'GKT' and sets.GKT_WS or sets.POLEARM_WS)

    equip(ws_set)
    -- Mpaca's Cap's TP Bonus does nothing at the 3000 cap.
    if player.tp >= 3000 and ws_set.head == "Mpaca's Cap" then
        equip({head="Flam. Zucchetto +2"})
    end
    if player.tp < 2750 then
        equip(sets.MoonshadeWS)
        add_to_chat(167, '[GS] '..spell.english..' >> '..label..' WS set / Moonshade @ '..player.tp..' TP')
    else
        add_to_chat(167, '[GS] '..spell.english..' >> '..label..' WS set / Thrud @ '..player.tp..' TP')
    end
    eventArgs.handled = true
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if player.status == 'Engaged' then
        equip(tp_set())
        if spell.type == 'WeaponSkill' then
            add_to_chat(158, '[GS] back to TP set ('..sync_weapon_mode()..
                             ' / '..state.TPMode.value..')')
        end
    end
end

function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Keep the mode honest if the weapon was changed outside GearSwap.
    sync_weapon_mode()
    if playerStatus == 'Engaged' then
        equip(tp_set())
        eventArgs.handled = true
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

    if cmd == 'gkt' then
        state.WeaponMode:set('GKT')
        equip(sets.weapons.GKT)
        add_to_chat(122, 'GearSwap: GKT / Masamune')

    elseif cmd == 'polearm' or cmd == 'pole' then
        state.WeaponMode:set('Polearm')
        equip(sets.weapons.Polearm)
        add_to_chat(122, 'GearSwap: Polearm / Shining One')

    elseif cmd == 'dt' then
        state.TPMode:set('DT')
        if player.status == 'Engaged' then equip(tp_set()) end
        add_to_chat(122, 'GearSwap: TP mode = DT (-50% capped)')

    elseif cmd == 'normal' or cmd == 'tp' then
        state.TPMode:set('Normal')
        if player.status == 'Engaged' then equip(tp_set()) end
        add_to_chat(122, 'GearSwap: TP mode = Normal')

    elseif cmd == 'th' then
        -- ON: put the TH pieces on right now, then LOCK those three slots, so
        -- every set - WS sets included - leaves them alone. That's what makes
        -- an AoE weapon skill (Sonic Thrust) tag everything it hits at TH+4.
        -- equip() merges into the outgoing list before disable() runs, so the
        -- order here is what lets the TH gear through before the lock.
        -- OFF: unlock and go back to the normal set for your status.
        -- gearbar's TH button lights on these exact chat lines.
        TH_MODE = not TH_MODE
        if TH_MODE then
            equip(sets.TH)
            disable(TH_SLOTS)
        else
            enable(TH_SLOTS)
            handle_equipping_gear(player.status)
        end
        add_to_chat(122, 'GearSwap: TH mode '..(TH_MODE and 'ON (TH+4, ammo/head/hands/legs locked)' or 'OFF'))

    elseif cmd == 'style' then
        add_to_chat(122, 'GearSwap: re-applying lockstyleset ' .. (LOCKSTYLE_SET or 0))
        apply_lockstyle(0)

    elseif cmd == 'lockback' then
        send_command('gs disable back')
        add_to_chat(122, 'GearSwap: BACK SLOT LOCKED')

    elseif cmd == 'unlockback' then
        send_command('gs enable back')
        add_to_chat(122, 'GearSwap: BACK SLOT UNLOCKED')
    end
end

-- Lockstyle. The game clears style lock every time you change jobs, so it has
-- to be re-applied. user_setup() calls select_default_macro_book() on load and
-- on subjob change (Mote does NOT call it on its own).
--
-- SET THIS to your in-game equipset number (the "Set###" in the Macros menu).
-- The placeholder below is a guess. A number with no matching equipset fails
-- silently, so if your appearance does not lock, this is the first thing to check.
-- Set it to 0 to lock to whatever you happen to be wearing at that moment.
LOCKSTYLE_SET = 39

-- SAM's 5s delay was too short: the lock was dropped after a job change.
-- Now it fires at 10s, then once more 15s later as a safety net (re-locking
-- the same set is harmless). //gs c style re-applies it by hand at any time.
LOCKSTYLE_DELAY = 10
LOCKSTYLE_RETRY = 15

function apply_lockstyle(delay)
    delay = delay or 0
    if LOCKSTYLE_SET and LOCKSTYLE_SET > 0 then
        send_command('wait ' .. delay .. '; input /lockstyleset ' .. LOCKSTYLE_SET
            .. '; wait 1; input /echo GearSwap: lockstyleset ' .. LOCKSTYLE_SET .. ' sent.')
    else
        send_command('wait ' .. delay .. '; input /lockstyleset')
    end
end

function select_default_macro_book()
    set_macro_page(1, 2)
    add_to_chat(122, 'GearSwap: macro book 2 page 1 for SAM')
    -- /lockstyleset is silently dropped if it lands too soon after a job
    -- change, and fails SILENTLY when the equipset number does not exist:
    -- if chat says 39 and your appearance never changes, 39 is the wrong number.
    add_to_chat(122, 'GearSwap: applying lockstyleset ' .. (LOCKSTYLE_SET or 0)
        .. ' for ' .. (player and player.main_job or '?')
        .. ' (' .. LOCKSTYLE_DELAY .. 's, retry +' .. LOCKSTYLE_RETRY .. 's; //gs c style to redo)')
    apply_lockstyle(LOCKSTYLE_DELAY)
    apply_lockstyle(LOCKSTYLE_DELAY + LOCKSTYLE_RETRY)
end

-- Running while idle: add sets.Kiting (Track Pants +1) on top of the idle set.
function customize_idle_set(idleSet)
    if gearinfo_moving and sets.Kiting then
        return set_combine(idleSet, sets.Kiting)
    end
    return idleSet
end
