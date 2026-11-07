-- BRD GearSwap - Char2
--
-- Melee = Naegling (Savage Blade). Songs borrow Kali for Singing skill +10.
--
-- ==========================================================================
-- RULE 1: GEARSWAP NEVER TOUCHES THE RANGE OR AMMO SLOT.
-- ==========================================================================
-- Miracle Cheer is equipped BY HAND and stays on. There is no range= and no
-- ammo= line anywhere in this file - not in a set, not in a command, not in a
-- hook. Hydrocera is gone too: it was in the weapon and song sets, so engaging
-- and then singing pulled it into the ammo slot. Same rule, same fix.
--
-- That is the whole mechanism, and it is airtight for a simple reason:
-- GearSwap only ever changes slots that appear in a set. A slot it is never
-- told about is a slot it cannot touch. No lock needed, no watchdog needed,
-- no re-equipping needed.
--
-- Everything that went wrong before came from this file trying to be clever
-- about that slot:
--   * Blurred Harp / Linos / Pan's Horn swap sets - swapped it out by design.
--   * disable('range') pinning - locked the slot, and when the one-shot equip
--     missed, locked it on EMPTY with no way to recover.
--   * range=INSTRUMENT in every set - churned the slot on every single
--     equipment event for no benefit.
--   * a prerender watchdog - a background loop to undo a problem this file
--     should simply not create.
-- All of it is gone. The slot is yours.
--
-- One thing this file genuinely cannot help with: your Windower F1 bind in
-- scripts/init.txt, and scripts/brd_buffs.txt, both run GAME-SIDE commands
--     /equip range "Blurred Harp"      (after Valor Minuet V)
--     /equip range "Linos"             (at the very end)
-- Those never pass through GearSwap, so nothing here can stop them - and the
-- rotation ends holding Linos, which has no additional song effect and no
-- duration override. Every song sung after it lands at the base 2:00 with a
-- slot fewer. Delete those two lines and the problem is gone for good.
--
-- //gs c check reports what is in the slot. It only READS - it will not
-- "helpfully" equip anything.
--
-- ==========================================================================
-- RULE 2: NO GRIPS, EVER. Naegling is a Sword and Kali is a Dagger - both one
-- handed - and a grip only equips with a TWO handed weapon. Elder's Grip +1
-- was in the old weapon and song sets and could never once have equipped, and
-- Clemency Grip (new in the 2026-09-12 dump) is the same story - do not add it.
-- No shield either: of the shields on this character (Acheron, Adapa,
-- Archduke's, Nusku) not one carries the BRD job flag.
--
-- THE SUB SLOT IS NO LONGER ALWAYS EMPTY - see RULE 3.
-- ==========================================================================
-- RULE 3: THE SUB SLOT IS SUBJOB-GATED. BRD has no Dual Wield of its own, so
-- a second weapon only equips under /DNC or /NIN. Every set that touches sub
-- goes through dual_wield(), and on any other subjob this file behaves exactly
-- as it did before - main hand only. Nothing here can strand you holding a
-- weapon you cannot use.
-- ==========================================================================
--
-- BRIOSO IS A FIVE-PIECE NOW - the two missing slots turned up
--   Brioso Roundlet +3   head   MAcc+61, CHR+41, String inst. +13, "Paeon"+2
--   Brioso Justau. +3    body   MAcc+64, CHR+43, Singing +17, String +14,
--                               Song spellcasting time -15%
--   Brioso Cuffs +2      hands  MAcc+38, CHR+34, DEX+33, MND+37, Haste+3%,
--                               Singing skill +15, "Lullaby"+1
--   Brioso Cannions +2   legs   MAcc+46, CHR+28, STR+28, MND+28, Haste+5%,
--                               WIND inst. +17, Damage taken-4%
--   Brioso Slippers +3   feet   MAcc+46, CHR+48, WIND inst. +14,
--                               Song duration +15%
-- All five carry set id 112. Numbers above are from the 2026-09-09 gearinfo
-- export (addons/silc_new.lua), which is the first dump on this machine to
-- contain the Cuffs and the Cannions at all.
--
-- Four things follow, and all four are new:
--
-- 1. THE SET BONUS IS A 5-PIECE NOW. Set id 112 tiers, straight out of the
--    stat dump: 2pc +15 / 3pc +30 / 4pc +45 / 5pc +60 to Accuracy, Ranged
--    Accuracy AND Magic Accuracy. Head + body + feet was three. Adding the
--    hands and the legs makes five, so the song set below gets a flat
--    MAcc+60 where it used to get +30.
--
-- 2. THE SONG SET GAINS +26 MAGIC ACCURACY AND A PILE OF SKILL. The two
--    swaps are almost free on raw MAcc and enormous on everything else:
--      hands  Dastanas +2 MAcc+43 -> Cuffs +2    MAcc+38   = -5
--      legs   Shalwar +2  MAcc+45 -> Cannions +2 MAcc+46   = +1
--      set    3pc +30             -> 5pc +60              = +30
--                                                   net    = +26 MAcc
--    On top of that, +15 Singing skill and +17 Wind instrument skill that the
--    Inyanga pieces did not have. Song magic accuracy and song potency both
--    scale off Singing skill, so the +26 is the small half of this change.
--    Running totals in the song set now: Singing skill 42 (Justau. +3 17,
--    Cuffs +2 15, Kali 10) and Wind instrument skill 31 (Cannions +2 17,
--    Slippers +3 14). The old file managed 27 and 14.
--
--    Nothing was given up. Dastanas' "Magic skills +20" covers the magic
--    skills, not Singing and not instrument skill, so a song never saw it;
--    Shalwar's Song duration +17% is dead under Miracle Cheer. Both pieces
--    keep their place in the idle set, which is the set that wanted them.
--
-- 3. THE WIND INSTRUMENT PROBLEM IS SOLVED PROPERLY, and there is a
--    correction attached. The old file credited Kali with "Wind instrument
--    skill +10" and built the case for it on that. Kali's dump entry reads
--    Dagger +242, Parrying +242, Magic Accuracy skill +201, SINGING skill
--    +10 - there is no wind line on it and never was. Kali stays the song
--    main hand on the Singing skill and the MAcc. All 31 wind skill comes
--    from Cannions +2 and Slippers +3.
--
-- 4. THE HANDS ARE NOW A BRIOSO SLOT IN THE MELEE AND WS SETS TOO, which is
--    the part that was left open last time pending these numbers. Details at
--    sets.engaged and sets.precast.WS; the short version is that Cuffs +2
--    beats Wayfarer Cuffs outright (more DEX, same Haste, and it turns the
--    melee Brioso 2pc into a 3pc for Accuracy+15) and beats Dastanas +2 for
--    Savage Blade by trading 2 points of STR+MND for that same Accuracy+15.
--
--    SUPERSEDED 2026-09-15: Perfection Plate. and Perfection Gaunt. took the
--    body AND hands in sets.engaged, sets.engagedDT and sets.precast.WS.
--    Brioso Justau. +3 and Cuffs +2 are song pieces only now. Details at
--    each set.
--
-- Miracle Cheer's 15 minutes is a FIXED OVERRIDE, not a bonus: song duration
-- gear (including Slippers +3's +15%) does not stack with it and is ignored.
-- Potency is NOT overridden, so All songs +2, Singing skill and wind
-- instrument skill still count - which is what the song set below buys.
--
-- Commands:
--   //gs c weapons   equip Naegling, plus Fusetto +2 off-hand under /DNC, /NIN
--   //gs c songs     equip Kali (the song main hand)
--   //gs c dagger    DAGGER MODE: Tauret (+ Fusetto +2 under /DNC, /NIN) and
--                    engaging keeps the dagger. //gs c weapons turns it off.
--   //gs c check     report what is in the range slot - read only
--   //gs c dt        toggle the defensive engaged set
--
-- Slots GearSwap manages here: main, head, body, hands, legs, feet, neck,
-- waist, ears, rings, back, and - under /DNC or /NIN only - sub. It does NOT
-- manage range or ammo, on any subjob.

INSTRUMENT = "Miracle Cheer"

-- THREE Intarabus's Capes share one name, and GearSwap matches a bare name to
-- whichever copy it finds first. Every back= line below names one of these, so
-- the Fast Cast cape can never land in the WS set or vice versa. Augment
-- matching is a subset test - one distinguishing string per cape is enough.
CAPE_FC  = { name="Intarabus's Cape", augments={'"Fast Cast"+10','Damage taken-5%'} }
CAPE_WSD = { name="Intarabus's Cape", augments={'Weapon skill damage +10%'} }

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function user_setup()
    -- Clear any range lock left over from an earlier version of this file.
    -- disable_table lives in GearSwap's statics.lua and //gs reload does not
    -- re-run statics, so a disable('range') from a previous load survives a
    -- reload. Nothing here disables it any more, but this cleans up the state.
    enable('range')

    select_default_macro_book()
end

function job_setup()
    -- Songs that land an effect on an ENEMY. These want magic accuracy, not
    -- duration or potency, or they simply get resisted.
    DEBUFF_SONGS = S{'Lullaby', 'Elegy', 'Threnody', 'Finale', 'Requiem', 'Nocturne'}
end

function is_debuff_song(spell)
    for name in DEBUFF_SONGS:it() do
        if spell.english:contains(name) then return true end
    end
    return false
end

-- Read only. Reports, never equips.
function report_instrument()
    local worn = player and player.equipment and player.equipment.range
    if worn == INSTRUMENT then
        add_to_chat(122, 'GearSwap: range slot = ' .. tostring(worn)
            .. ' - correct. Songs get the extra effect and 15 min duration.')
    else
        add_to_chat(104, 'GearSwap: range slot = "' .. tostring(worn) .. '", not '
            .. INSTRUMENT .. '. Equip it by hand - GearSwap does not manage this slot. '
            .. 'Songs cast now land at the base 2:00 with a slot fewer.')
    end
end

function init_gear_sets()

    ---------------------------------------------------------------------------
    -- Weapons.  No range, no ammo - see Rule 1. Sub only under /DNC or /NIN -
    -- see Rule 3.
    ---------------------------------------------------------------------------

    sets.weapons = {
        main="Naegling",              -- Savage Blade, Acc+40, Atk+30, WS dmg+15%
    }

    -- DUAL WIELD SET, /DNC or /NIN only.
    --
    -- THE OFF-HAND IS FUSETTO +2, AND IT STAYS THERE. Its "TP Bonus +1000"
    -- augment is the whole point of the set: Savage Blade at 1000 TP fires at
    -- the fTP of 2000 TP, every single time, with no swap that can fail to
    -- register. Leaving it equipped is the reliable way to get that - a sub
    -- swapped in during WS precast is one dropped packet away from a Savage
    -- Blade at plain 1000 TP, and you cannot tell from the damage number
    -- whether it worked.
    --
    -- WHAT IT COSTS, stated plainly so the trade is on the record:
    --   Tauret        DMG 125  Delay 180  Acc+40 Atk+30 MAcc+40 DEX/INT/MND+15
    --   Leisilonu +2  DMG  90  Delay 183  Eva+22
    --   Fusetto +2    DMG  38  Delay 186  TP Bonus +1000
    -- Fusetto gives up 87 off-hand DMG and Tauret's Acc+40 / MND+15 to buy a
    -- guaranteed fTP tier on the weapon skill. Off-hand damage is a small
    -- share of a Savage Blade build's output and the WS is where the damage
    -- actually is, so this is a defensible call - but if you ever want the TP
    -- phase back, sub="Tauret" on the line below is the entire change.
    --
    -- WHAT DUAL WIELD ACTUALLY BUYS YOU. At BRD99/DNC49 the subjob grants Dual
    -- Wield II (15%), and Suppanomimi in sets.engagedDW takes it to 20%:
    --   (240 + 186) x (1 - 0.20) / 2 = 170 delay per hand
    -- against 240 single-wielding Naegling. That is 29% faster swings AND a
    -- second weapon swinging - the largest melee gain available to this
    -- character right now, and it costs nothing but a subjob.
    sets.weaponsDW = {
        main="Naegling",              -- Savage Blade, Acc+40, Atk+30, WS dmg+15%
        sub={name="Fusetto +2",       -- DMG 38, Delay 186, TP Bonus +1000
             augments={'none','none','TP Bonus +1000','none'}},
    }

    -- Kali is the song main hand for Singing skill +10, which counts on every
    -- song, plus Magic Accuracy skill +201 and MAcc+10. It does NOT carry Wind
    -- instrument skill - the old comment here claimed a "+10 wind augment" that
    -- is nowhere in the stat dump. Wind skill comes from the feet and the legs.
    sets.songweapons = {
        main="Kali",
    }

    -- DAGGER MODE (//gs c dagger). Tauret is the Evisceration weapon: its
    -- main-hand "Evisceration damage +50%" dwarfs anything Kali offers, and it
    -- is DMG 125 / Delay 180 against Kali's 100 / 201. Under /DNC or /NIN the
    -- off-hand stays Fusetto +2 - TP Bonus +1000 raises Evisceration's
    -- TP-scaled crit rate the same way it raises Savage Blade's fTP.
    sets.dagger = {
        main="Tauret",                -- "Evisceration" damage +50%. WARDROBE
    }
    sets.daggerDW = {
        main="Tauret",
        sub={name="Fusetto +2",
             augments={'none','none','TP Bonus +1000','none'}},
    }

    ---------------------------------------------------------------------------
    -- Precast
    ---------------------------------------------------------------------------

    -- ~32% Fast Cast: Jubbah 14 + cape 10 + Cosciales 6 + Loquacious.
    --
    -- Brioso Justau. +3's "Song spellcasting time -15%" is a separate
    -- multiplier from Fast Cast. At +2 it was -8% and clearly worse than
    -- Jubbah's "Fast Cast"+14%; at +3 the two are close enough that it is no
    -- longer obvious, and the +3 also stacks its cut on top of whatever Fast
    -- Cast the rest of the set brings. Left on Jubbah because Justau. +3 is
    -- needed in midcast anyway and a precast body that has to be swapped out
    -- again buys nothing. Worth timing in-game if you care.
    --
    -- 2026-10-16: TEAL 3-PIECE. Teal Pigaches +1 were here alone, which gets
    -- no set bonus. Set 118 tiers are Fast Cast +4/+6/+8/+10% at 2/3/4/5
    -- pieces, and the head and hands (Inyanga Tiara / Dastanas) carried no
    -- Fast Cast at all - so Teal Chapeau +1 + Teal Cuffs +1 there make a
    -- 3-piece for a free +6%: ~32% -> ~38%. Teal Slops +1 for the 4-piece
    -- would cost Cosciales' +6% for +2%, and Teal Saio +1 for the 5-piece
    -- would cost the Jubbah's +14% for +2% - both worse.
    --
    -- 2026-11-07: Bunzi's Hat ("Fast Cast"+10%) takes the head from Teal
    -- Chapeau +1. Teal drops from 3pc (+6%) to 2pc (+4%), so net +8%.
    -- Kishar Ring ("Fast Cast"+4%) takes Ayanmo Ring's place. ~38% -> ~50%.
    sets.precast.FC = {
        head="Bunzi's Hat",           -- "Fast Cast"+10%, DT-7%
        body="Inyanga Jubbah +2",     -- "Fast Cast"+14%
        hands="Teal Cuffs +1",        -- Teal set (2pc = FC+4%)
        legs="Aya. Cosciales +2",     -- "Fast Cast"+6%, Haste+9%
        feet="Teal Pigaches +1",      -- Teal set
        neck="Moonbow Whistle",
        waist="Sailfi Belt +1",       -- No waist you own carries a song stat, so
                                      -- Haste+9% is the best use of the slot.
                                      -- (Flagellant's Rope is back in the dump,
                                      -- but Haste+8% only under Paralysis - it
                                      -- is not an upgrade here.)
        left_ear="Loquac. Earring",   -- Enhances "Fast Cast"
        right_ear="Alabaster Earring",
        left_ring="Kishar Ring",      -- "Fast Cast"+4%
        right_ring="Murky Ring",
        back=CAPE_FC,                 -- "Fast Cast"+10 on the augment
    }

    -- Copied with set_combine rather than written as
    --   sets.precast.FC.BardSong = sets.precast.FC
    -- which puts the table inside itself - the self-reference hazard the SAM
    -- file warns about.
    sets.precast.FC.BardSong = set_combine(sets.precast.FC, {})

    ---------------------------------------------------------------------------
    -- Song midcast
    ---------------------------------------------------------------------------

    -- FIVE Brioso pieces now, not three: head + body + hands + legs + feet is
    -- the 5-piece tier of set 112, worth Magic Accuracy+60 on top of the MAcc
    -- the pieces already carry. That is +30 over the old three-piece set, and
    -- it is the single biggest change this file has ever taken in one step.
    --
    -- What left the set, and why it is not missed:
    --   hands was Inyan. Dastanas +2  MAcc+43 against Cuffs +2's 38, so five
    --                             points of MAcc. Its "Magic skills +20" reads
    --                             well and does nothing here: it covers the
    --                             magic skills, not Singing and not instrument
    --                             skill, so a song never saw it.
    --   legs  was Inyanga Shalwar +2  MAcc+45 against Cannions +2's 46, so the
    --                             leg swap is a gain even before the set, and
    --                             its Song duration +17% is dead under Miracle
    --                             Cheer's fixed 15 minutes anyway.
    -- Five points of MAcc out, thirty back from the set tier, and +15 Singing
    -- and +17 Wind instrument skill on top. Both Inyanga pieces are still the
    -- right call in the idle set, which is where they stay.
    --
    -- "Lullaby"+1 on the Cuffs is live on every Lullaby cast from this set -
    -- see the note on sets.midcast.SongDebuff below.
    --
    -- The slots Brioso does not cover:
    --   neck  Moonbow Whistle     All songs +2, CHR+18, MAcc+18.
    --   back  Intarabus's Cape    the augment is the value: MAcc+30 total,
    --                             CHR+20, on top of "Madrigal"/"Prelude"+1.
    -- 2026-11-07 DUMP: every Brioso piece was upgraded, so the old names
    -- (Roundlet +3 / Justau. +3 / Cuffs +2 / Cannions +2 / Slippers +3) no
    -- longer matched anything owned and this set was equipping NOTHING in
    -- those five slots. Renamed to what is in the bags now:
    --   head  Roundlet +4  MAcc 61->71, String +14
    --   body  Just. +4     MAcc 64->74, Singing +18, Song cast time -15%
    --   hands Cuffs +3     MAcc 38->48, Singing +17, "Lullaby"+2
    --   legs  Cannions +3  MAcc 46->56, Wind +19, DT-8%
    --   feet  Slippers +4  MAcc 46->56, CHR+50, Wind +15
    -- = +50 MAcc on the pieces, 5pc set bonus unchanged.
    sets.SongCore = {
        main="Kali",                  -- Singing skill +10, MAcc+10 (no wind)
        head="Brioso Roundlet +4",    -- MAcc+71, CHR+43, "Paeon"+2
        body="Brioso Just. +4",       -- MAcc+74, CHR+45, Singing skill +18
        hands="Brioso Cuffs +3",      -- MAcc+48, Singing +17, "Lullaby"+2
        legs="Brioso Cannions +3",    -- MAcc+56, Wind inst. +19, DT-8%
        feet="Brioso Slippers +4",    -- MAcc+56, CHR+50, Wind inst. skill +15
        neck="Moonbow Whistle",       -- All songs +2, CHR+18, MAcc+18
        waist="Sailfi Belt +1",       -- no song waist owned; Haste is the filler
        left_ear="Alabaster Earring",
        right_ear="Loquac. Earring",
        left_ring="Ayanmo Ring",      -- MAcc+6
        right_ring="Murky Ring",
        back=CAPE_FC,                 -- augment: CHR+20, MAcc+30 total
    }

    sets.midcast.Song = set_combine(sets.SongCore, {})

    -- DEBUFF songs want magic accuracy over potency. There is nothing left to
    -- trade for it: SongCore is now the full five-piece Brioso set plus the
    -- highest-MAcc neck, back and rings on the character, so the highest-MAcc
    -- loadout and the highest-potency loadout are the same eleven pieces.
    --
    -- Worth knowing rather than acting on: Brioso Cuffs +2 carry "Lullaby"+1,
    -- and Lullaby is in DEBUFF_SONGS. Because the Cuffs sit in SongCore the
    -- bonus already applies to every Lullaby without this branch doing
    -- anything - it does not need pulling out into a special case. The branch
    -- stays a separate name purely so a future MAcc piece is a one-line change
    -- here rather than a rewrite of the midcast hook.
    --
    -- THAT PIECE ARRIVED in the 2026-09-25 dump: Null Shawl, flat Magic
    -- Accuracy+50 against the song cape's MAcc+30 / CHR+20. dCHR feeds song
    -- accuracy on a tapering scale, so 20 CHR is worth well under 20 MAcc at
    -- the margins a debuff actually lands on - the Shawl is a net gain here.
    -- Buff songs keep the Intarabus: MAcc does nothing for them, and its
    -- "Madrigal"/"Prelude"+1 does.
    -- 2026-10-16: Famine Sash (MAcc+4, new) over Sailfi Belt +1 - the first
    -- waist on this character with any magic accuracy. Buff songs keep
    -- Sailfi: MAcc does nothing for them.
    -- 2026-11-07: Kishar Ring (MAcc+5) over Murky Ring, which has no MAcc.
    sets.midcast.SongDebuff = set_combine(sets.SongCore, {
        waist="Famine Sash",          -- MAcc+4. INVENTORY
        right_ring="Kishar Ring",     -- MAcc+5
        back="Null Shawl",            -- MAcc+50
    })

    ---------------------------------------------------------------------------
    -- Idle and defence
    ---------------------------------------------------------------------------

    sets.idle = {
        head="Inyanga Tiara +2",
        body="Inyanga Jubbah +2",     -- Magic Damage taken-8%
        hands="Inyan. Dastanas +2",
        legs="Inyanga Shalwar +2",    -- Magic Damage taken-6%
        feet="Inyan. Crackows +2",    -- New in the 2026-09-11 dump, and it is the
                                      -- FIFTH Inyanga piece here: set 16 tiers are
                                      -- Refresh +1/+2/+3/+4 at 2/3/4/5 pieces, so
                                      -- the head+body+hands+legs 4pc (Refresh+3)
                                      -- becomes 5pc (Refresh+4). Against Wayfarer
                                      -- Clogs it also brings Magic Evasion 147 vs
                                      -- 100 and Magic damage taken-3%, for 1% less
                                      -- Haste. The Clogs' own "Refresh"+3 line was
                                      -- always dead here - it needs a second
                                      -- Wayfarer piece and this set has none.
                                      -- Song, melee and WS feet stay Slippers +3.
        neck="Moonbow Whistle",
        waist="Sailfi Belt +1",
        left_ear="Alabaster Earring", -- Haste+5%
        right_ear="Loquac. Earring",
        left_ring="Ayanmo Ring",      -- Damage taken-3%
        right_ring="Murky Ring",      -- Damage taken-10%
        back=CAPE_FC,                 -- Damage taken-5%
    }

    ---------------------------------------------------------------------------
    -- Melee and weapon skill
    ---------------------------------------------------------------------------

    -- PERFECTION PLATE. + PERFECTION GAUNT. (new in the 2026-09-15 dump) took
    -- the body and hands from Brioso Justau. +3 / Cuffs +2:
    --   body  Justau. +3   DEX+31 STR+29  Haste+3%  no Acc/Atk
    --         Plate.       DEX+44 STR+46  Haste+4%  Acc+41 Atk+41 STP+7 Crit+7% DT-7%
    --   hands Cuffs +2     DEX+33 STR+11  Haste+3%  no Acc/Atk
    --         Gaunt.       DEX+51 STR+27  Haste+4%  Acc+41 Atk+41 STP+3 Crit+3% DT-3%
    -- That breaks Brioso from a 3-piece to a lone Slippers +3, so the set's
    -- Accuracy+30 is gone. The two pieces bring Accuracy+82 to replace it:
    -- net Acc+52, Attack+82, DEX+31, Store TP+10, Crit+10%, DT-10%.
    --
    -- HASTE, 26% against the 25% cap, now from armour alone:
    --   head  Zucchetto +2  6   legs  Volte Tights  9
    --   body  Plate.        4   feet  Slippers +3   3
    --   hands Gaunt.        4
    -- Alabaster Earring used to be the slot spent purely to clear the cap. It
    -- isn't needed any more, so that ear goes to Suppanomimi (Sword skill +5 =
    -- real accuracy and attack on Naegling). DROP ANY OF THOSE FIVE and you fall
    -- under 25%. Put Alabaster or Sailfi Belt +1 (Haste+9%) back if you do.
    --
    -- Ayanmo (set 96) is still a lone Zucchetto here, because Volte Tights have
    -- the legs. The Zucchetto keeps the head on its own Accuracy+44, "Store
    -- TP"+6 and Haste+6%. Brioso Roundlet +3 would only make Brioso a 2-piece
    -- (Acc+15) for the 44 accuracy it gives up.
    --
    -- ACCURACY: 44 (head) + 41 (body) + 41 (hands) + 38 (legs) + 30 (neck)
    --         + 13 (waist) + 6 (Ayanmo Ring) = 213 flat (was 161), with
    --         DEX+155 from the armour (was 124).
    --
    -- THE LEGS ARE VOLTE TIGHTS NOW - new in the 2026-09-11 gearinfo dump.
    -- Against the Aya. Cosciales +2 they replace:
    --   Cosciales +2  Acc+45  Haste+9%  STR+33  DEX+11  DT-5%  Ayanmo 2pc
    --   Volte Tights  Acc+38  Haste+9%  STR+46  DEX+0   "Store TP"+8  "Subtle Blow"+8
    -- Same haste, so the cap math above is untouched. The trade is 7 accuracy,
    -- 11 DEX, DT-5% and the Ayanmo set bonus (STR/VIT/MND, none of which a TP
    -- set needs) for Store TP+8 - faster TP, more Savage Blades. If Char2
    -- starts missing, Cosciales +2 is the revert. Cosciales keeps its place in
    -- the Savage Blade set, where STR+MND is what counts. Cannions +2 stay a
    -- song piece.
    --
    -- THE NECK IS NO LONGER DEAD: Bard's Charm +2 (Accuracy+30, "Quadruple
    -- Attack"+3%) arrived in the same dump. Moonbow Whistle has no melee stat,
    -- so it keeps only the song set. Swapping necks does not touch TP.
    --
    -- 2026-09-25 DUMP - two new pieces here:
    --   head  Perfection Masque replaces Zucchetto +2. Same Haste+6% (cap
    --         math above untouched), Acc 44 -> 41, STP 6 -> 5, but Attack+41,
    --         Crit+5% and DT-5% that the Zucchetto does not have. Ayanmo was
    --         already a lone piece here, so no set bonus is lost.
    --   back  Null Shawl: Acc+50, "Double Attack"+7%, "Store TP"+7. The slot
    --         was never actually dead - the DEX/Acc/"Store TP"+10 Intarabus
    --         was in the dump all along - but the Shawl beats that too:
    --         +30 Acc and DA+7% for 3 STP, 30 DEX and 20 Attack.
    -- 2026-11-07: Bunzi's Gloves over Perfection Gaunt. "Double Attack"+8%
    -- and DT-8% (vs -3%) for 1 Acc, 11 DEX, STP+3 and Crit+3%. Haste is
    -- 4% -> 3%, so armour haste is now 25% - still exactly at the cap. Do not
    -- drop another haste piece without putting Sailfi Belt +1 back.
    sets.engaged = {
        head="Perfection Masque",     -- Haste+6%, Acc+41 Atk+41, STP+5, Crit+5%, DT-5%
        body="Perfection Plate.",     -- Haste+4%, Acc+41 Atk+41, DEX+44, STP+7, Crit+7%, DT-7%
        hands="Bunzi's Gloves",       -- Haste+3%, Acc+40 Atk+40, "Double Attack"+8%, DT-8%
        legs="Volte Tights",          -- Haste+9%, Acc+38, STR+46, "Store TP"+8
        feet="Revelation Sab.",       -- Su5. Acc+42 Atk+42, "Store TP"+5, Crit+5%,
                                      -- DT-5%, STR+36 DEX+40. Haste+3% is the SAME
                                      -- as the Brioso Slippers +3 it replaces, so the
                                      -- 26% gear haste total is unchanged. Brioso is
                                      -- only 1 piece here, so no set bonus is lost.
        neck="Bard's Charm +2",       -- Accuracy+30, "Quadruple Attack"+3%
        waist="Kentarch Belt +1",     -- Acc+14, "Double Attack"+3%, Unity STP+1~5
        left_ear="Suppanomimi",       -- Sword skill +5; Dual Wield +5% when /DNC or /NIN
        right_ear="Brutal Earring",   -- Enhances "Double Attack", "Store TP"+1
        left_ring="Ayanmo Ring",      -- Acc+6
        right_ring="Petrov Ring",     -- "Double Attack"+1%, "Store TP"+5, STR/DEX+3
        back="Null Shawl",            -- Acc+50, "Double Attack"+7%, "Store TP"+7
    }

    -- ENGAGED WHILE DUAL WIELDING. Now identical to sets.engaged, and only ever
    -- reached under /DNC or /NIN.
    --
    -- This used to be the set where Suppanomimi pushed Brutal Earring out,
    -- because Alabaster had to stay for the haste cap. The Perfection pieces
    -- cleared the cap from armour alone (see above), so sets.engaged already
    -- wears Suppanomimi in the left ear AND keeps Brutal in the right. Dual
    -- Wield 20% (DW II 15% + Suppanomimi 5%) and Brutal's Double Attack+5% are
    -- both live at once - no trade left to make. Kept as its own name so the
    -- toggle code, and any future DW-only piece, still have somewhere to go.
    --
    -- THE ONLY DUAL WIELD PIECE CHAR2 OWNS IS SUPPANOMIMI. There is no
    -- Ptero-ptyx, no Dudgeon or Heishi earring, no DW body. So 20% is the
    -- ceiling until something else drops.
    sets.engagedDW = set_combine(sets.engaged, {})

    -- ENGAGED, BUT DEFENSIVE. Toggled with //gs c dt - see job_self_command.
    -- Same slots as sets.engaged, rebuilt on mitigation instead of accuracy.
    --
    -- UNTYPED "Damage taken" is the only line that cuts every kind of damage,
    -- and these eight are all of it that Char2 owns:
    --   head  Zucchetto +2      -3%    ear   Alabaster Earring  -5%
    --   body  Perfection Plate. -7%    ring  Murky Ring        -10%
    --   hands Perfection Gaunt. -3%    ring  Ayanmo Ring        -3%
    --   legs  Cosciales +2      -5%    back  Intarabus's Cape   -5%
    -- = -41% against everything. The feet add -3% that only applies to MAGIC
    -- damage (Crackows +2), so this is roughly -41% physical / -44% magic.
    --
    -- THE PERFECTION PIECES (2026-09-15) replaced Inyanga Jubbah +2 (Magic
    -- Damage taken-8%) and Inyan. Dastanas +2 (Magic Damage taken-4%):
    --   physical  -31% -> -41%     magic  -46% -> -44%
    -- Ten points of physical for two of magic, plus Accuracy+82. What it
    -- gives up besides that:
    --   - About 28 Magic Evasion (Jubbah 120 + Dastanas 77 -> 98 + 71).
    --   - The Inyanga 3-piece "Refresh"+2. Body, hands and feet were three
    --     Inyanga pieces; only the Crackows are left.
    -- If Char2 is taking mostly magic, or is running out of MP while
    -- meleeing, put Jubbah +2 / Dastanas +2 back.
    --
    -- TWO PIECES THAT LOOK LIKE MITIGATION AND ARE NOT, both checked in the
    -- 2026-09-11 dump - do not "fix" this set by adding them:
    --   Artsieq Cuffs   "PET: Damage taken-4%" - pet only, worth nothing here.
    --   Miasmic Pants   "PHYSICAL Damage taken-3%" - real, but Cosciales +2
    --                   beats it with an untyped -5% plus Haste+9% and Acc+45.
    --
    -- HASTE is not a casualty: 6 (head) + 4 (body) + 4 (hands) + 9 (legs)
    -- + 2 (feet) + 5 (ear) + 9 (waist) = 39%, still clear of the 25% cap, so
    -- swinging speed is identical to the offensive set.
    --
    -- ACCURACY: 44 (head) + 41 (body) + 41 (hands) + 45 (legs) + 30 (neck)
    -- + 6 (ring) = 207, against 213 in sets.engaged. The Perfection pieces
    -- took almost all the cost out of this set. It used to drop to 95.
    --
    -- THE CAPE IS PINNED BY AUGMENT ON PURPOSE. You own THREE Intarabus's
    -- Capes and only this one carries Damage taken-5%; the other two are the
    -- DEX/"Store TP" and DEX/"Weapon skill damage" pairs. GearSwap matches
    -- back="Intarabus's Cape" by NAME, so a bare name equips whichever it finds
    -- first - the same trap as Char1's two Camulus's Mantles. Augment matching
    -- is a subset test, so the two strings below are enough to tell them apart.
    --
    -- 2026-09-25: Perfection Masque takes the head, DT-3% -> -5%, so the set
    -- is now -43% untyped. Its Ayanmo 2pc with Cosciales (STR/VIT/MND+8)
    -- does nothing for mitigation.
    --
    -- 2026-11-07 BUNZI'S: Robe -10%, Gloves -8%, Pants -9% replace Plate -7%,
    -- Gaunt -3%, Cosciales -5%. Armour DT 25% -> 37%, and the set would sit at
    -- -60%, past the -50% cap. So the two least useful DT pieces go back to
    -- offence: right ring Ayanmo (-3%) -> Petrov (STP+5), back FC cape (-5%)
    -- -> Null Shawl (Acc+50, DA+7%, STP+7). Result: -52%, i.e. capped, with
    -- Bunzi's Magic Evasion 112-150 a piece on top. Haste 34%, still capped.
    sets.engagedDT = {
        head="Perfection Masque",     -- Damage taken-5%, Haste+6%, Acc+41
        body="Bunzi's Robe",          -- Damage taken-10%, Haste+3%, Acc+40, MEva+139
        hands="Bunzi's Gloves",       -- Damage taken-8%, Haste+3%, Acc+40, DA+8%
        legs="Bunzi's Pants",         -- Damage taken-9%, Haste+5%, Acc+40, MEva+150
        feet="Revelation Sab.",       -- Su5. DT-5% applies to ALL damage; the Inyanga
                                      -- crackows it replaces read "Magic Damage
                                      -- taken-3%", magic only. Also Haste 2%->3% and
                                      -- Acc/Atk+42. Costs MEva 147->110 and MDB 8->6.
                                      -- Inyanga was 1 piece here, so no Refresh tier lost.
        neck="Bard's Charm +2",       -- no BRD neck you own has a defensive line,
                                      -- so the slot keeps its Accuracy+30
        waist="Sailfi Belt +1",       -- no defensive waist owned; Haste+9%
        left_ear="Alabaster Earring", -- Damage taken-5%, Haste+5%, HP+100
        right_ear="Brutal Earring",   -- no defensive earring owned; keeps the
                                      -- Double Attack rather than sitting empty
        left_ring="Murky Ring",       -- Damage taken-10% - the single biggest piece
        right_ring="Petrov Ring",     -- "Store TP"+5 - DT is capped without Ayanmo
        back="Null Shawl",            -- Acc+50, DA+7%, STP+7 - DT capped without the cape
    }

    -- DT AND DUAL WIELDING AT THE SAME TIME. Same one-ear change as
    -- sets.engagedDW, for the same reason - and here Brutal Earring is even
    -- easier to give up, because the DT set is not trying to deal damage.
    sets.engagedDTDW = set_combine(sets.engagedDT, {
        right_ear="Suppanomimi",      -- Dual Wield +5%, Sword skill +5
    })

    -- SAVAGE BLADE off Naegling - 50% STR / 50% MND. Both modifiers weigh the
    -- same, so every slot below was picked on STR+MND combined, with accuracy
    -- breaking the ties.
    --
    -- Best STR+MND per slot out of everything BRD-legal you own:
    --   head  Roundlet +3 61 | Zucchetto +2 45 | Tiara +2 43
    --   body  Perfection Plate. 73 | Justau. +3 67 | Jubbah +2 59
    --   hands Perfection Gaunt. 58 | Dastanas +2 50 | Cuffs +2 48
    --   legs  Cosciales +2 59 | Shalwar +2  57 | Miasmic Pants 53
    --   feet  Revelation Sab. 50 | Slippers +3 44 | Wayfarer Clogs 27
    --         (Revelation Sab. added by the 2026-09-18 dump; it also brings
    --          Attack+42 and Crit+5%, which no other feet in this slot have)
    --
    -- THE PERFECTION PIECES (2026-09-15) win body and hands outright. Each one
    -- is the top modifier in its slot AND carries Accuracy+41 Attack+41, which
    -- nothing else BRD-legal here has. Against Justau. +3 / Cuffs +2:
    --   STR+MND +16, Attack+82, Accuracy+82.
    -- They broke Brioso from a 3-piece to a lone Slippers +3, which lost the
    -- set's Accuracy+30. Net accuracy was still +52. As of the 2026-09-18 dump
    -- the Revelation Sab. take the last Brioso piece out of this set entirely,
    -- so there is no Brioso set bonus left here to lose - and the sabatons'
    -- own Accuracy+42 more than covers the +30 that went with it.
    --
    -- The head stays Zucchetto +2, and with Brioso gone it's no longer a tie:
    --   Roundlet +3  -> Brioso 2pc (Acc+15 from set), no Ayanmo. Mod 61.
    --   Zucchetto +2 -> Ayanmo 2pc with Cosciales (STR+8 MND+8), so 45 + 16 =
    --                   61 too, and Accuracy+44 on the piece.
    -- Same modifier, 29 more accuracy. Zucchetto.
    --
    -- Still true, and worth repeating because the item descriptions invite the
    -- mistake: you own NO Weapon Skill Damage gear that BRD can wear. Every
    -- Inyanga and Brioso "Accuracy" line is Magic Accuracy, and Alabaster
    -- Earring's and Murky Ring's Accuracy+15 is Pet: Accuracy. Toutatis's Cape
    -- has Weapon skill damage +10% and is sitting in your inventory - it is
    -- THF only and cannot be worn here.
    --
    -- Volte Tights (new, see the melee set) do NOT take the legs here: STR+46
    -- MND+7 = 53 against Cosciales +2's STR+33 MND+26 = 59, with 7 less
    -- accuracy, and they would break Ayanmo on top. Cosciales stays.
    --
    -- 2026-09-25 DUMP:
    --   head  Perfection Masque over Zucchetto +2. STR+40 MND+19 = 59 against
    --         the Zucchetto's 45 + Ayanmo 2pc 16 = 61, so two points of
    --         modifier and 3 Acc for Attack+41. Attack wins that easily.
    --   back  The "dead slot" note was wrong: the Intarabus with WEAPON SKILL
    --         DAMAGE +10% (plus DEX+30, Acc+20 Atk+20) has been in the dump the
    --         whole time, and so the "no WSD gear" line above was wrong too.
    --         WSD+10% beats anything else for this slot, Null Shawl included.
    --   waist Eschan Stone over Sailfi Belt +1: Attack+15 flat (Sailfi's is
    --         +10~15 Unity-dependent) plus Accuracy+15. Sailfi's Haste does
    --         nothing during a weapon skill.
    --   (Ygnas's Resolve +1 also arrived with "Weapon skill damage"+25%, but
    --    it is Reives only. Not worth a slot.)
    --
    -- The neck used to be dead; Bard's Charm +2 now fills it for Accuracy+30. Suppanomimi
    -- is the only earring that does anything - Sword skill +5 is real accuracy
    -- on Naegling. Brutal's Double Attack does not fire on a weapon skill, so
    -- the second ear goes to Alabaster for the HP+100 and DT-5%.
    sets.precast.WS = {
        head="Perfection Masque",     -- STR+40 MND+19, Acc+41 Atk+41
        body="Perfection Plate.",     -- STR+46 MND+27 = 73, Acc+41 Atk+41
        hands="Perfection Gaunt.",    -- STR+27 MND+31 = 58, Acc+41 Atk+41
        legs="Aya. Cosciales +2",     -- STR+33 MND+26 = 59, Acc+45 (still beats
                                      -- Volte's 53 without the Ayanmo bonus)
        feet="Revelation Sab.",       -- Su5. STR+36 MND+14 = 50 vs Brioso's 44, and it
                                      -- adds Attack+42 and Crit+5% which Brioso has
                                      -- none of.
        neck="Bard's Charm +2",       -- Accuracy+30. No STR/MND on it, but the
                                      -- slot had nothing melee at all before
        waist="Eschan Stone",         -- Acc+15 Atk+15
        left_ear="Suppanomimi",       -- Sword skill +5 = real accuracy
        right_ear="Alabaster Earring",-- HP+100, DT-5%; its Accuracy+15 is Pet only
        left_ring="Ayanmo Ring",      -- Acc+6, and with Cosciales +2 it's the
                                      -- Ayanmo 2pc (STR/MND+8) - keep it
        -- 2026-10-03 dump: Karieyh Ring (WSD+3%, WS Acc+5) over Petrov's
        -- STR+3 DEX+3. Savage Blade's damage is mostly its first hit, which is
        -- exactly what WSD multiplies - same reasoning as Char1's sets.
        right_ring="Karieyh Ring",    -- WSD+3%, WS Acc+5, Regain+5. INVENTORY
        back=CAPE_WSD,                -- Weapon skill damage +10%, Acc+20 Atk+20
    }

    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})

    -- EVISCERATION (2026-10-16 dump). Five hits, DEX 50% modifier, and TP
    -- raises its crit rate - so the set is DEX + crit + Attack/Accuracy on
    -- every hit. Weapon skill damage only touches the first of the five hits,
    -- which is why the WSD pieces here are kept only where nothing better
    -- competes for the slot.
    --   head  Perfection Masque  DEX+37 Crit+5% Atk+41 (Zucchetto's DEX+39 has
    --         no crit and no attack, and the Ayanmo STR/MND bonus is useless)
    --   body  Perfection Plate.  DEX+44 Crit+7%
    --   hands Perfection Gaunt.  DEX+51 Crit+3%
    --   legs  Cosciales +2       DEX+11 Acc+45 (Volte Tights have DEX+0)
    --   feet  Revelation Sab.    DEX+40 Crit+5% Atk+42
    --   ears  Brutal + Alabaster. Suppanomimi is Sword skill - dead on a dagger.
    --   rings Rajas (DEX+2~5) + Karieyh (WS Acc+5, WSD+3%)
    --   back  CAPE_WSD carries DEX+30 Acc/Atk+20 as well as the WSD, so it is
    --         the best Evisceration cape too.
    -- Crit+20% total from the Perfection set and Revelation.
    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
        legs="Aya. Cosciales +2",     -- DEX+11 Acc+45
        left_ear="Brutal Earring",    -- Suppanomimi's Sword skill does nothing here
        right_ear="Alabaster Earring",
        left_ring="Rajas Ring",       -- DEX+2~5
        right_ring="Karieyh Ring",    -- WS Acc+5, WSD+3%. INVENTORY
    })
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

-- DT toggle. Off by default, so nothing changes until you ask for it with
-- //gs c dt. Deliberately a plain flag rather than Mote's DefenseMode: this
-- file never set up state.DefenseMode or its sets.defense tables, and half-
-- wiring that system would give you a toggle that silently equips nothing.
DT_MODE = false

-- Dagger mode: which weapons the engage hook and aftercast hand back. Off =
-- Naegling (Savage Blade), on = Tauret (Evisceration). Not persisted - a
-- //gs reload starts on the sword.
DAGGER_MODE = false

function current_weapons()
    if DAGGER_MODE then
        return dual_wield() and sets.daggerDW or sets.dagger
    end
    return dual_wield() and sets.weaponsDW or sets.weapons
end

-- BRD has no Dual Wield of its own. This is the single gate for every
-- sub-slot decision in the file - see Rule 3 in the header. Same helper, same
-- name, same two subjobs as COR.lua.
function dual_wield()
    return player.sub_job == 'DNC' or player.sub_job == 'NIN'
end

-- The four-way pick: offensive or DT, dual wielding or not.
function current_engaged_set()
    if DT_MODE then
        return dual_wield() and sets.engagedDTDW or sets.engagedDT
    end
    return dual_wield() and sets.engagedDW or sets.engaged
end

-- Mote equips sets.engaged whenever Char2 engages, and there was no hook here
-- to say otherwise. This is that hook: while DT_MODE is on, the defensive set
-- wins, and eventArgs.handled stops Mote putting the offensive set back on top.
-- It now also claims the plain dual-wield case, because Mote's own sets.engaged
-- would drop Suppanomimi.
--
-- Only the Engaged case is claimed, so idle gear still works normally.
function job_handle_equipping_gear(playerStatus, eventArgs)
    if playerStatus ~= 'Engaged' then return end

    -- TAKE THE SWORD BACK THE MOMENT YOU ENGAGE. This is the fix for the Trust
    -- addon firing Aeolian Edge instead of Savage Blade.
    --
    -- sets.SongCore puts Kali in the main hand, and job_aftercast only handed
    -- Naegling back if you were ALREADY engaged. Sing a rotation while idle -
    -- which is the normal way to do it - and you finished holding Kali. None
    -- of the engaged sets name a main or a sub, so engaging did not fix it:
    -- Char2 walked into the fight on a DAGGER.
    --
    -- Two things then went wrong at once. Savage Blade is a Sword weapon skill
    -- and was simply unavailable, and the Trust addon picks its weapon skill
    -- from whatever the MAIN HAND supports - so it took the best dagger weapon
    -- skill it could see, which is Aeolian Edge. The melee was quietly wrong
    -- too: Kali is DMG 100 against Naegling's 166.
    --
    -- Restoring here rather than after every song is deliberate. A song
    -- rotation can stay on Kali start to finish with no weapon churn between
    -- casts, and the sword is back before the first swing lands.
    equip(current_weapons())

    if DT_MODE or dual_wield() then
        equip(current_engaged_set())
        eventArgs.handled = true
    end
end

-- No weapon-skill sub swap: Fusetto +2 is already in the off-hand, so the
-- TP Bonus is simply always on. Nothing to equip, nothing to put back.

function job_midcast(spell, action, spellMap, eventArgs)
    if spell.type ~= 'BardSong' then return end

    if is_debuff_song(spell) then
        equip(sets.midcast.SongDebuff)
    else
        equip(sets.midcast.Song)
    end
    eventArgs.handled = true
end

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Hand the sword back after a song borrowed Kali. The range slot is not
    -- mentioned here or anywhere else. Under /DNC or /NIN this also restates
    -- the off-hand, which costs nothing when it is already correct.
    if spell.type == 'BardSong' and not spell.interrupted then
        if player.status == 'Engaged' then
            equip(current_weapons())
        end
    end
end

function job_self_command(cmdParams, eventArgs)
    local cmd = cmdParams[1] and cmdParams[1]:lower() or ''

    if cmd == 'weapons' then
        DAGGER_MODE = false
        -- Which off-hand you get is decided by the subjob, not by a flag, so
        -- //gs c weapons is safe to press on any subjob. On anything but
        -- /DNC or /NIN this is the old main-hand-only behaviour exactly.
        if dual_wield() then
            equip(sets.weaponsDW)
            add_to_chat(122, 'GearSwap: Naegling / Fusetto +2 - Dual Wield from /'
                .. player.sub_job .. ', TP Bonus +1000 (range slot untouched)')
        else
            equip(sets.weapons)
            add_to_chat(122, 'GearSwap: Naegling (range slot untouched)')
        end

    elseif cmd == 'dagger' then
        DAGGER_MODE = true
        equip(current_weapons())
        add_to_chat(122, 'GearSwap: DAGGER MODE - Tauret'
            .. (dual_wield() and ' / Fusetto +2' or '')
            .. ', Evisceration. //gs c weapons for Naegling.')

    elseif cmd == 'songs' then
        -- Main slot only. Under /DNC the off-hand simply stays put, which is
        -- correct: Kali and Fusetto +2 are both daggers and both legal.
        equip(sets.songweapons)
        add_to_chat(122, 'GearSwap: Kali (range slot untouched)')


    elseif cmd == 'check' then
        report_instrument()

    -- //gs c dt          toggle
    -- //gs c dt on/off   set it explicitly, for a macro or a Trust gambit
    elseif cmd == 'dt' then
        local arg = cmdParams[2] and cmdParams[2]:lower() or nil
        if arg == 'on' then
            DT_MODE = true
        elseif arg == 'off' then
            DT_MODE = false
        else
            DT_MODE = not DT_MODE
        end

        if DT_MODE then
            add_to_chat(122, 'GearSwap: DT mode ON - engaged set is sets.engagedDT '
                .. '(-52% damage taken, capped at -50%).')
        else
            add_to_chat(122, 'GearSwap: DT mode OFF - back to the accuracy set.')
        end

        -- Apply it now rather than waiting for the next status change, which
        -- could be the whole fight away.
        if player.status == 'Engaged' then
            equip(current_engaged_set())
        end
    end
end

-- Chain to Mote's own unload rather than replacing it. Mote-Include only
-- installs its default file_unload "if not file_unload", and this job file
-- defines the name first - so a bare definition here silently suppresses
-- global_on_unload() and leaves F9-F12 bound after a job change.
function file_unload()
    enable('range')
    if global_on_unload then
        global_on_unload()
    end
end

-- TODO: set this to Char2's real in-game number. LOCKSTYLE_SET = 0 locks to
-- whatever you happen to be wearing, which is a safe default but probably not
-- what you want; a wrong number fails silently.
LOCKSTYLE_SET = 0

function select_default_macro_book()
    set_macro_page(1, 1)
    add_to_chat(122, 'GearSwap: macro book 1 page 1 for BRD')

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
