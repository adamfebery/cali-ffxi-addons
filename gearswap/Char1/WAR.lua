-- WAR GearSwap - Great Axe / Sword / Club
--
-- Great Axe = Lightreaver              (Upheaval spam - see sets.UPHEAVAL)
-- Sword     = Naegling + Blurred Shield (Savage Blade, +15% from Naegling)
-- Club      = Loxotic Mace +1 + Blurred Shield (Judgment - blunt, for skeletons)
-- Dual Wield = Naegling + Sangarius +1  (needs /DNC or /NIN)
-- Polearm   = Shining One + Daduchos Grip (Impulse Drive spam - see sets.IMPULSE)
--
-- Same conventions as SAM.lua and COR.lua: weapons live ONLY in sets.weapons
-- and are equipped ONLY by an explicit //gs c command. No main/sub in any TP,
-- WS, JA or idle set, so nothing can swap your weapon mid-fight.
--
-- Commands:
--   //gs c ga        equip Lightreaver (great axe, 2H - empties sub)
--   //gs c sword     equip Naegling + Blurred Shield
--   //gs c blunt     equip Loxotic Mace +1 + Blurred Shield (or //gs c club)
--   //gs c dw        equip Naegling + Sangarius +1 (only as /DNC or /NIN)
--   //gs c polearm   equip Shining One + Daduchos Grip (or //gs c pole, //gs c so)
--   //gs c dt        toggle DT mode (-32%) over whatever TP set is on
--   //gs c th        toggle Treasure Hunter +4 (ammo/head/hands/legs locked)
--   //gs c lockback / //gs c unlockback
--
-- Armour is Flamma (all five slots, WAR/PLD/DRK/SAM/DRG) plus the two
-- Sulevia's pieces (WAR/PLD/DRK/DRG) where their DT and Triple Attack beat
-- the Flamma equivalent. The same two Sulevia pieces also carry the MND that
-- makes Savage Blade's 50% MND half worth gearing for - see sets.SAVAGE.
-- Your WAR-specific gear - Ravager's Mask (Lv85), Warrior's Lorica (Lv75),
-- Warrior's Cuisses (Lv74) - is pre-119 and loses to Flamma everywhere except
-- one niche Aggressor swap.
--
-- See the BLOCKED UPGRADES block at the bottom of this file for gear you own
-- that is sitting in a bag GearSwap cannot reach.

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function user_setup()
    -- Great Axe first: M{} defaults to its first entry and GA is WAR's
    -- flagship skill. Nothing here equips a weapon on its own regardless.
    state.WeaponMode = M{['description']='Weapon', 'GreatAxe', 'Sword', 'Club', 'DualSword', 'Polearm'}
    
    -- GearInfo's display toggles are saved per character in
    -- gearinfo/data/<name>_settings.xml, so they survive job changes on their own.
    -- Re-sending them from user_setup() (which Mote re-runs on EVERY job change)
    -- only produced a burst of GearInfo log lines in chat. Configure it once with
    -- //gi ... by hand instead.
end

function job_setup()
end

function init_gear_sets()

    -- The only sets that ever touch main/sub.
    sets.weapons = {}

    sets.weapons.GreatAxe = {
        main="Lightreaver",           -- WAR-only, iL119, DMG 273 / Delay 504, Acc+20, STP+5
        sub=empty,                    -- great axe is two-handed
    }

    sets.weapons.Sword = {
        main="Naegling",              -- iL119, Savage Blade +15% in main hand
        sub="Blurred Shield",         -- iL119 WAR/PLD/DRK, Acc+15, Atk+15, WSD+5%
    }

    -- Blunt, for skeletons and anything else that shrugs off slashing.
    -- 2026-11-07: Loxotic Mace +1 replaces Mafic Cudgel. It is the WAR guide's
    -- club ("Club: Loxotic Mace +1 ... Judgment / Black Halo"). Yours is Path A,
    -- unranked: DMG 190 / Delay 334 (Cudgel 142 / 278, so ~11% more damage per
    -- second and a much bigger base for Judgment), Acc+21, Atk+21, DEX+10 from
    -- Unity (its latent Acc/Atk+31 only works under 50% HP - ignore it). It gives up the Cudgel's PDT-10% and
    -- Enmity+6. One-handed, so Blurred Shield stays and Fencer still applies.
    --
    -- THE CLUB SKILL LINE IS WHY THIS WORKS. Warrior's own Club rating is B-
    -- (cap ~388), but skill only rises by swinging a club, and Char1's is
    -- presumably near zero. The Mace's "Club skill +242" (Cudgel had +228)
    -- clears True Strike (175) and Judgment (200) immediately, and Black Halo's
    -- 230 too - but Black Halo still needs the Orastery Woes quest.
    -- Hexa Strike is WHM/GEO only unless you main-hand a Beryllium Mace.
    -- Mafic Cudgel stays in wardrobe 3 if you want the PDT-10% back.
    sets.weapons.Club = {
        main="Loxotic Mace +1",       -- iL119, DMG 190 / Delay 334, Acc+21, Atk+21, Club skill +242
        sub="Blurred Shield",         -- same shield as the Sword set
    }

    -- Dual Wield sword, for /DNC (Dual Wield II at sub Lv49, 15% delay
    -- reduction) or /NIN (Dual Wield III at sub Lv45+, 25%).
    -- WAR has no Dual Wield of its own, so the game refuses a weapon in the
    -- sub slot on any other subjob - //gs c dw checks the subjob first.
    --
    -- Sangarius +1 is the only real off-hand you own: DA+3%, TA+3%, Attack+26,
    -- and it stacks with the DA/TA already in sets.engaged. The other swords
    -- that fit the sub slot are Deacon Sword (Acc+18, but it's in your case,
    -- so GearSwap can't reach it) and a pile of DMG:1 costume weapons.
    -- Naegling stays in the main hand so Savage Blade keeps its +15%. While
    -- you're dual wielding, the off-hand also adds a hit to Savage Blade.
    --
    -- Dual wielding also switches off Fencer. That WAR trait (+500 TP Bonus
    -- and +10% crit rate at 99) only works with nothing but a shield in the
    -- off-hand. The //gs c sword set keeps it. This one trades it for faster
    -- swings and an extra Savage Blade hit.
    -- Polearm. Shining One is two-handed, so the sub slot takes a grip.
    -- Daduchos Grip (Acc+30, Haste+3%, PDL+8%, DT-3%; 2026-11-05, was Tzacab).
    -- Balarama Grip is in your case and only has Great Sword skill.
    sets.weapons.Polearm = {
        main="Shining One",           -- iL119, DMG 333 / Delay 480, Acc+40, Atk+30, Impulse Drive +40%
        sub="Daduchos Grip",
    }

    sets.weapons.DualSword = {
        main="Naegling",              -- Savage Blade +15% (main hand only)
        sub="Sangarius +1",           -- iL119, DMG 158 / Delay 281, Atk+26, DA+3%, TA+3%
    }

    ---------------------------------------------------------------------------
    -- Melee TP
    ---------------------------------------------------------------------------

    -- Gear haste 27% (cap 25). Double Attack +53% (legs 8, body 8, hands 6,
    -- feet 6, Boii 7, Brutal 5, Coiste 3, cape 10). Triple Attack +8% (head
    -- 5, Sailfi 2, Defiant 1). DT -23% (Plate 10, Gauntlets 8, cape 5) plus
    -- the Cuisses' Physical DT-4%.
    --
    -- PUMMELER'S (2026-10-09 export), modelled for the Savage Blade loop -
    -- melee plus one Savage per ~1000 TP, so TP/sec drives ~3/4 of damage:
    --   legs  Pumm. Cuisses +2 over Sulev. Cuisses +2: +2.7% (no haste
    --         buffs) to +6.4% (magic haste capped), and still +5% with
    --         accuracy short. Haste+6% takes gear haste 23 -> 25% cap and
    --         DA+8% out-hits Sulevia's TA+4%; it costs Attack+49, STR-12 and
    --         DT-7% -> PDT-4%. Sulevia stays in the WS sets (Savage -6.7%).
    --   feet  Pumm. Calligae +2 - in at the user's request (2026-10-09).
    --         The model had them behind Flam. Gambieras +2 (-11% when
    --         accuracy is short, at best +2% next to the Cuisses): STP 2 vs
    --         6, Acc-6, DEX-13, and the Flamma set bonus drops a tier. The
    --         Pummeler 2-piece Acc+15 doesn't make it up. If she misses a
    --         lot, Gambieras are the swap back. The DW and Great Axe /
    --         Polearm sets below pin feet to Gambieras, so only the
    --         single-wield set wears the Calligae.
    --
    -- SAKPATA (2026-10-09 export):
    --   hands  Sakpata's Gauntlets over Sulev. Gauntlets +2 - Haste 4 vs 3,
    --          same DA+6%, DT-8 vs -5, Physical damage limit+6%, for Acc-3
    --          Att-7. A straight upgrade.
    --   body   Sakpata's Plate over Flamma Korazin +2 - DA+8%, Attack+40,
    --          DT-10%, PDL+8%. It costs STP+9, Acc+6 and DEX+14, and drops
    --          Flamma to 2 pieces (set bonus STR/DEX/VIT +16 -> +8): about 22
    --          Accuracy in all. More hits and Attack win on normal targets.
    --          If you're missing a lot (high-evasion mobs), put Korazin back.
    --
    -- BOII EARRING IS RIGHT EAR ONLY. Its stat line literally reads
    -- 'Right ear: "Double Attack"+7% "Subtle Blow"+5' - the Sortie earrings are
    -- slot-gated, so in the left ear it contributes nothing at all. You own
    -- exactly one, so the left ear takes Brutal Earring. Never mirror it.
    sets.engaged = {
        ammo="Coiste Bodhar",         -- DA+3%, STP+3 - WAR-legal, and the slot was empty
        head="Flam. Zucchetto +2",    -- Haste+4%, TA+5%, Acc+44, STP+6
        body="Sakpata's Plate",       -- Haste+2%, DA+8%, Acc/Att+40, DT-10%, PDL+8%
        hands="Sakpata's Gauntlets",  -- Haste+4%, DA+6%, Acc/Att+40, DT-8%, PDL+6%
        legs="Pumm. Cuisses +2",      -- Haste+6%, DA+8%, Acc+46, PDT-4%
        feet="Pumm. Calligae +2",     -- Haste+4%, DA+6%, Acc+36, Att+30, STP+2 (wardrobe2)
        neck="Defiant Collar",        -- Acc+8, Subtle Blow+3, TA+1%
        waist="Sailfi Belt +1",
        left_ear="Brutal Earring",    -- Enhances Double Attack, "Store TP"+1
        right_ear={name="Boii Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+7','Mag. Acc.+7'}},
        left_ring="Chirich Ring",
        right_ring="Petrov Ring",
        back="Cichol's Mantle",       -- DEX+20, Acc+20 Atk+20, DA+10, DT-5%
    }

    -- Dual Wield TP (//gs c dw, as /DNC or /NIN). Suppanomimi (DW+5) takes
    -- the left ear from Brutal Earring (DA+5%, STP+1). Modelled with this
    -- set's own gear, Naegling + Sangarius +1, and bg-wiki's TP-per-hit table:
    --
    --   /DNC  DW 10% -> 15%   delay per hand 234 -> 221   TP/hit 99 -> 95
    --         melee damage +3.0%   TP per second -0.9%
    --   /NIN  DW 15% -> 20%   melee damage +3.3%   TP per second -2.9%
    --
    -- CAUTION: those rows used the wrong subjob tiers. At sub Lv49 /DNC has
    -- Dual Wield II (15%, so the real step is 15 -> 20) and /NIN has Dual
    -- Wield III (25%, so 25 -> 30). +5 DW is still a ~6% delay cut from either
    -- base, so the verdict should hold, but the figures above need re-running.
    --
    -- WHY DW BEATS DA HERE:
    --   - TP per hit is NOT proportional to delay. The table has a fixed
    --     61 TP base, so cutting delay 5.6% only costs ~4% TP per hit.
    --   - DW+5 speeds up every hit on both hands.
    --   - DA+5% only adds a hit on rounds where Triple Attack didn't proc,
    --     and this set already has ~50% DA. That's only ~2.5% more hits.
    -- Same result with no haste, Haste II or capped magic haste: WAR/DNC can
    -- never reach the 80% delay cap, so haste doesn't change the ratio.
    -- Boii stays in the right ear (slot-gated).
    sets.engaged.DW = set_combine(sets.engaged, {
        feet="Flam. Gambieras +2",    -- Calligae are single-wield only
        left_ear="Suppanomimi",       -- AGI+2, Sword skill +5, Dual Wield +5% (wardrobe2)
    })

    -- Great Axe TP (//gs c ga). Built for Upheaval spam through the Trust
    -- addon, which weapon skills as soon as TP reaches 1000. Upheaval does
    -- ~74% of the damage in that loop, so TP per second outweighs melee
    -- damage per hit. Scored against every combination of your reachable
    -- gear (scratch model, bg-wiki formulas); three swaps from sets.engaged:
    --
    --   hands  Sulev. Gauntlets +2 -> Flam. Manopolas +1  STP+5, Crit+7%
    --   legs   Sulev. Cuisses +2   -> Flamma Dirs +2      STP+8, Haste+4%
    --   neck   Defiant Collar      -> Rep. Plat. Medal    STR+10, Attack+30
    --
    -- Result: about +4.4% total damage per second. Gear haste goes from 22% to
    -- the 25% cap. STP goes from 40 to 53, so each hit gives 214 TP instead of
    -- 196. With five Flamma pieces the set bonus was STR/VIT +32 (four now -
    -- see the Sakpata note below, +24). The same
    -- three swaps won with no haste and with Haste II, at enemy defense 1200
    -- and 1600, and at every Double Attack total tested.
    --
    -- THE COST IS DEFENSE: DT goes from -17% to -5% (just the cape). If you're
    -- the one taking hits, sets.engaged is the safer choice.
    --
    -- Chirich + Petrov stay. Rajas Ring scored +0.3%, which is within the
    -- model's noise, and Chirich keeps 7 more Accuracy.
    --
    -- 2026-10-09: Sakpata's Gauntlets now take hands from the Manopolas.
    -- Same Haste+4%; DA+6% gives ~+5% more hits, beating the Manopolas'
    -- STP+5 (~+2% TP per hit) even for TP per second, and adds Attack+40,
    -- DT-8% and PDL+6% (the Manopolas' Crit+7% doesn't touch Upheaval).
    -- The body stays Flamma Korazin +2, NOT Sakpata's Plate: in this
    -- TP-per-second loop the Plate's lost STP+9 and ~22 Accuracy cancel its
    -- DA+8% / Attack+40 (rough estimate: about even). Korazin also keeps the
    -- Flamma count at 4 here (head, body, legs, feet).
    --
    -- 2026-10-21 GearSwap-Optimizer pass: accuracy swaps at no DT cost. Against
    -- an Apex Toad (Minuet V/IV, Chaos/Samurai X) hit rate goes 71% -> 89%,
    -- same TP speed: Amar Cluster, Defiant Collar, Steelflash in the left ear
    -- (Boii keeps the right), Flamma + Chirich rings.
    sets.engaged.GreatAxe = set_combine(sets.engaged, {
        ammo="Amar Cluster",          -- Acc+10, STR+2
        body="Flamma Korazin +2",
        hands="Sakpata's Gauntlets",
        legs="Flamma Dirs +2",
        feet="Flam. Gambieras +2",    -- Calligae are single-wield only
        neck="Defiant Collar",        -- was Rep. Plat. Medal
        left_ear="Steelflash Earring",
        left_ring="Flamma Ring",
        right_ring="Chirich Ring",
    })

    -- Polearm TP (//gs c polearm). The same set wins with Shining One (DMG 333
    -- / Delay 480): about +5.8% total damage over sets.engaged, with Impulse
    -- Drive about 73% of the damage. It held with no haste and Haste II, and
    -- at polearm skill 350 or 200 with enemy DEF 1200 or 1600. The trade is
    -- the same: DT drops to -5%. Its own name, so a polearm-only change stays
    -- a one-liner.
    --
    -- 2026-10-21 optimizer pass: its own set now. Keeps Coiste Bodhar, and
    -- Telos + Steelflash take both ears (Boii out): 3% faster TP, hit rate
    -- 81% -> 95% vs an Apex Toad, same DT.
    sets.engaged.Polearm = set_combine(sets.engaged.GreatAxe, {
        ammo="Coiste Bodhar",
        left_ear="Telos Earring",
        right_ear="Steelflash Earring",
    })

    -- Club TP (//gs c club) - single wield, built for WAR/DRG. 2026-11-07.
    -- Loxotic Mace +1 + Blurred Shield keeps Fencer, and the WAR guide calls
    -- /DRG the preferred sub for Fencer builds. No Dual Wield here: the club
    -- set never takes an off-hand weapon, so /NIN or /DNC buys nothing.
    -- What /DRG gives at sub 49: Attack Bonus I, Accuracy Bonus I (+10 Acc),
    -- Damage Limit+ I, Smite I, WS Damage Boost I, Conserve TP I, plus Jump /
    -- High Jump (free TP / enmity drop) and Ancient Circle.
    --
    -- One swap from sets.engaged: Accuracy Bonus covers Defiant Collar's Acc+8,
    -- so the neck goes to attack. Rep. Plat. Medal STR+10 Attack+30 over
    -- Defiant's TA+1% / Subtle Blow+3. Not modelled - stat priority only. If
    -- you are missing a lot (Apex/high-evasion), put Defiant Collar back.
    -- Everything else in sets.engaged already suits a slow one-hander with
    -- Fencer: Sakpata body/hands (DA, PDL), Pummeler's legs/feet (DA, Haste),
    -- Boii right ear, Brutal left, Chirich + Petrov.
    sets.engaged.Club = set_combine(sets.engaged, {
        neck="Rep. Plat. Medal",      -- STR+10, Attack+30 (wardrobe3)
    })

    -- DT mode (//gs c dt toggles it; the gearbar DT button sends that).
    -- Laid OVER whichever weapon's TP set is on, so it works for sword, DW,
    -- great axe and polearm alike. Damage taken, all untyped:
    --   body Sakpata's Plate -10, hands Sakpata's Gauntlets -8, legs Sulev.
    --   Cuisses +2 -7 (these put back what the Great Axe / Polearm sets
    --   trade away), neck Elite Royal Collar -5, ring Defending Ring -10,
    --   plus Cichol's Mantle -5 that every TP set already wears = -45%.
    -- Malignance Tabard (-9%) is in your wardrobe but is not WAR-equippable.
    sets.DTOverlay = {
        body="Sakpata's Plate",
        hands="Sakpata's Gauntlets",
        legs="Sulev. Cuisses +2",
        neck="Elite Royal Collar",    -- wardrobe3
        right_ring="Defending Ring",  -- replaces Petrov Ring
    }

    -- Treasure Hunter +4 (//gs c th, the gearbar TH button). WAR has no
    -- native TH, so it's all gear - every WAR-legal TH piece you own. The
    -- slots are locked while it's on so WS / JA sets can't swap them out.
    -- Costs: Coiste-type ammo, the TP head, hands and legs - and in DT mode
    -- Sakpata's Gauntlets (-8%) and Sulev. Cuisses +2 (-7%).
    -- TH sticks at the highest level that landed, so tag the mob once and
    -- toggle it off.
    sets.TH = {
        ammo="Per. Lucky Egg",        -- TH+1. wardrobe
        head="Wh. Rarab Cap +1",      -- TH+1. Synergy 2026-10-15 - must be in a wardrobe
        hands="Volte Bracers",        -- TH+1. wardrobe3
        legs="Valorous Hose",         -- TH+1 (augment). wardrobe3
    }

    ---------------------------------------------------------------------------
    -- Weapon skills
    ---------------------------------------------------------------------------

    -- Shared WSD core. Cornelia's Ring, Karieyh Ring and Ishvara are all-jobs.
    -- Your WSD options are thin: Meg. Gloves +2 and Wakido Haidate +3 are the
    -- big WSD pieces in your inventory and neither is WAR-legal.
    sets.WS_BASE = {
        ammo="Knobkierrie",           -- Attack+23, WSD+6% - WAR-legal, and the slot was empty
        head="Flam. Zucchetto +2",
        body="Flamma Korazin +2",
        hands="Flam. Manopolas +1",   -- Crit+7%, Haste+4%
        legs="Flamma Dirs +2",        -- STR+53, the biggest STR piece you own
        feet="Flam. Gambieras +2",
        neck="Rep. Plat. Medal",      -- STR+10 Attack+30 (was Defiant Collar: Acc+8, TA+1%)
        waist="Sailfi Belt +1",
        -- Moonshade (job_post_precast) always lands in the LEFT ear, so the
        -- weaker earring goes there. Thrud (STR+10 VIT+10 WSD+3%) beats
        -- Ishvara (WSD+2%) outright, so Thrud sits in the right ear and
        -- survives the Moonshade swap - same layout as sets.UPHEAVAL.
        left_ear="Ishvara Earring",   -- WSD+2%, replaced by Moonshade at low TP
        right_ear="Thrud Earring",    -- STR+10, WSD+3%
        left_ring="Karieyh Ring",     -- WSD+3%, Regain+5
        right_ring="Cornelia's Ring", -- WSD+10%
        back="Cichol's Mantle",       -- Acc+20 Atk+20, DA+10
    }

    -- UPHEAVAL - the Great Axe WS to spam. 4 hits, 73~85% VIT.
    --
    -- Why Upheaval:
    --   - Ukko's Fury needs Ukonvasara/Maschu/Shamash.
    --   - King's Justice needs the Mythic quest.
    --   - Steel Cyclone is one hit.
    --   - Fell Cleave is an AoE with a flat 2.75 fTP.
    -- Needs the "Martial Mastery" quest and 357 Great Axe skill (Lightreaver's
    -- +242 covers the skill).
    --
    -- HOW IT SCALES: the TP multiplier (1.0 / 3.5 / 6.5) applies to the FIRST
    -- hit only. Hits 2-4 are fTP 1.0 but still get the VIT modifier. Gear WSD
    -- is also first-hit only. Trust fires at ~1000-1300 TP (+250 Moonshade),
    -- so only about a third of the damage rides on hit 1. Attack and extra
    -- hits outweigh WSD at that TP. That's why this isn't WS_BASE:
    --
    --   hands  Sulev. Gauntlets +2   VIT+45 Attack+47 DA+6%  (Manopolas: VIT+35, no Atk)
    --   legs   Sulev. Cuisses +2     Attack+49 TA+4%         (Dirs: no Atk)
    --   neck   Rep. Plat. Medal      STR+10 Attack+30        (Defiant: TP stats)
    --   ear    Thrud Earring (R)     STR+10 VIT+10 WSD+3%
    --   ring   Flamma Ring           4th Flamma piece: +8 STR/VIT, Acc+6 (beat Karieyh's WSD+3%)
    --
    -- Modelled about +20% Upheaval damage over the old WS_BASE mapping. The
    -- left ear is Moonshade on every spam WS (job_precast below 2750 TP).
    -- Ishvara is only there for the rare 2750+ Upheaval. Cichol's Mantle's
    -- DA+10 helps here too: multi-attack can proc twice during a WS.
    --
    -- NOT CHOSEN: Valorous Mitts (WSD+4%) and Valorous Greaves (WSD+5%). With
    -- WSD on the first hit only, they lose more to missing VIT and Attack.
    --
    -- SAKPATA'S PLATE - kept OUT on purpose (modelled 2026-10-09). With your
    -- accuracy capped it's +3.7% (Upheaval) / +2.6% (Impulse Drive) from
    -- Attack+40. But hits 2-4 don't get the WS accuracy bonus, and the
    -- Plate costs ~22 Accuracy (Acc-6, DEX-14, Flamma set bonus down a
    -- tier), so when accuracy is short it's -4.1% / -2.7%. If you're never
    -- missing (easy targets, or Acc food), swap body="Sakpata's Plate" in.
    -- Sakpata's Gauntlets lose to Sulevia in both (-0.3%): less Attack.
    sets.UPHEAVAL = {
        ammo="Knobkierrie",           -- Attack+23, WSD+6%
        head="Flam. Zucchetto +2",
        body="Flamma Korazin +2",
        hands="Sulev. Gauntlets +2",
        legs="Sulev. Cuisses +2",
        feet="Flam. Gambieras +2",
        neck="Rep. Plat. Medal",      -- wardrobe3
        waist="Sailfi Belt +1",
        left_ear="Ishvara Earring",   -- replaced by Moonshade below 2750 TP
        right_ear="Thrud Earring",
        left_ring="Flamma Ring",
        right_ring="Cornelia's Ring", -- WSD+10%
        back="Cichol's Mantle",       -- Acc/Atk+20, DA+10
    }

    -- Every Great Axe WS below uses this set. Steel Cyclone (60% STR / 60%
    -- VIT) and the STR ones gain from the same Attack and STR/VIT that
    -- Upheaval wants.
    sets.GA_WS = sets.UPHEAVAL

    -- IMPULSE DRIVE (Shining One) - 2 hits, 100% STR, fTP 1.0 / 3.0 / 5.5
    -- on the first hit only. Shining One adds +40% damage to BOTH hits and
    -- +5% crit rate per 1000 TP spent. Needs the "Methods Create Madness"
    -- quest. Shining One's +250 Polearm skill covers the 240 requirement.
    --
    -- The model picked exactly the UPHEAVAL gear. STR, Attack and first-hit
    -- WSD all pull the same way, and Rep. Plat. Medal / Thrud / Flamma Ring
    -- are STR pieces too.
    --
    -- THE ONE CLOSE CALL - hands:
    --   - Flam. Manopolas +1 (Crit+7%, DEX+42) only wins if gear crit rate
    --     applies to Impulse Drive. BG-Wiki doesn't confirm it; Shining One's
    --     page says its bonus gives crits to polearm WS that "normally lack it".
    --   - If gear crit applies: Manopolas +1.4%.
    --   - If it doesn't: Manopolas -5.9% (no crits to buy, and it drops
    --     Sulevia's Attack+47).
    -- Sulevia is the safe side of that bet. Parse it yourself if you want to
    -- test Manopolas.
    sets.IMPULSE = sets.UPHEAVAL

    -- Savage Blade (Naegling) - 50% STR / 50% MND. The old note here said you
    -- own no MND gear worth slotting; the gearinfo dump says otherwise. Two
    -- slots change, and both are strict gains:
    --
    --   hands  Flam. Manopolas +1  STR 19 + MND 24 = 43   Acc+37, no Attack
    --          Sulev. Gauntlets +2 STR 23 + MND 32 = 55   Acc+43, Attack+47
    --          -> +12 mod stat, +47 Attack, +6 Acc. Manopolas only gave up
    --             Crit+7%, which Savage Blade does not use (it is not a crit
    --             WS), plus Haste/STP that a WS set never benefits from.
    --
    --   legs   Flamma Dirs +2      STR 53 + MND 14 = 67   Acc+45, no Attack
    --          Sulev. Cuisses +2   STR 47 + MND 20 = 67   Acc+45, Attack+49
    --          -> identical mod stat, +49 Attack for free. Dirs' bigger raw
    --             STR is exactly cancelled by Sulevia's bigger MND, because
    --             Savage Blade weights the two equally.
    --
    -- Everything else is already the best WAR-legal piece you own, and
    -- Naegling's own "Savage Blade" damage +15% still does the heavy lifting.
    --
    -- Both Sulevia pieces are WAR/PLD/DRK/DRG and both sit in wardrobe2, so
    -- this set is equippable as written.
    --
    -- NOT YET MODELLED: Valorous Greaves (WSD+5%, Atk+21) and Valorous Mitts
    -- (WSD+4%). They lost in the Upheaval set, but Savage Blade puts nearly
    -- all its damage on hit 1 (fTP 4.0 / 10.25 / 13.75), the only hit WSD
    -- touches. Rough estimate: Greaves ~+2% even after dropping Flamma from
    -- 3 pieces to 2 (-8 STR), Mitts about even vs Sulevia. Both cost
    -- Accuracy - model before swapping.
    --
    -- SAKPATA (modelled 2026-10-09, bg-wiki physical WS formula, Savage at
    -- ~1800 TP with Fencer + Moonshade, mob DEF 1100-1800):
    --   body  Sakpata's Plate over Flamma Korazin +2: +2.4% damage. Attack+40
    --         and MND+8 outweigh STR-1 and the Flamma set bonus dropping a
    --         tier (-8 STR). Still +0.9% with accuracy short of the cap -
    --         nearly all of Savage Blade is hit 1, which gets +100 WS Acc.
    --   hands Sakpata's Gauntlets LOSE to Sulevia here (-0.2%): Attack 40 vs
    --         47. Their Physical damage limit+6% never comes into play - the
    --         attack/defense ratio stays under the pDIF cap unless the mob's
    --         DEF is below ~470.
    --   2026-10-09: hands set to Sakpata's Gauntlets anyway, at the user's
    --   request (keep Sakpata in every Savage Blade set) - the -0.2% is noise.
    sets.SAVAGE = set_combine(sets.WS_BASE, {
        body="Sakpata's Plate",
        hands="Sakpata's Gauntlets",
        legs="Sulev. Cuisses +2",
    })

    -- JUDGMENT (Loxotic Mace +1) - 50% STR / 50% MND, which is the SAME split as
    -- Savage Blade, so this is sets.SAVAGE under another name: the two Sulevia
    -- pieces are in it for their MND, exactly as documented above. Kept as its
    -- own name rather than pointing sets.precast.WS['Judgment'] straight at
    -- sets.SAVAGE so that a future club-only piece is a one-line change here.
    --
    -- THE BODY WAS CHECKED AND STAYS FLAMMA. Two pieces looked like upgrades on
    -- a quick field scan of the gearinfo dump and neither survives reading the
    -- actual stat line:
    --   Flamma Korazin +2  STR+43 MND+20 = 63   Accuracy+46   <- stays
    --   Emet Harness       STR+25 MND+23 = 48   Accuracy+10~20 (Unity)
    --   Souveran Cuirass   STR+29 MND+16 = 45   Accuracy+28
    -- Korazin wins the modifier by 15 AND the accuracy by 36. (The dump's flat
    -- ["STR"] field reports 8 for Korazin - that number is a set bonus, not the
    -- item's STR. Always rank off the description text.)
    --
    -- WHY JUDGMENT AND NOT TRUE STRIKE: True Strike is 100% STR with a
    -- guaranteed crit but fTP 1.0 flat, while Judgment's fTP climbs 3.5 / 8.75
    -- / 12.0 at 1000 / 2000 / 3000 TP. With this much Store TP you reach 3000
    -- often, and 12.0 fTP beats a crit on half-wasted MND. True Strike is still
    -- mapped below for low-TP situations - it takes the pure-STR set.
    sets.JUDGMENT = sets.SAVAGE

    -- Low-TP overlay: TP Bonus is wasted at the 3000 TP cap.
    sets.MoonshadeWS = {left_ear="Moonshade Earring"}

    -- Great Axe. Extra keys are harmless if a WS is not unlocked for you -
    -- the set simply never fires.
    --
    -- 2026-10-21 optimizer pass: Steel Cyclone and Fell Cleave get Sakpata's
    -- Plate (and Cyclone the Gauntlets) plus Cornelia's + Karieyh rings. They
    -- won unbuffed AND buffed, unlike Upheaval (-2.8% unbuffed, +4.7% buffed),
    -- which keeps the accuracy reasoning above.
    --   Steel Cyclone  +1.5% unbuffed, +17.2% fully buffed
    --   Fell Cleave    +2.6% unbuffed, +9.0% fully buffed (with no Moonshade -
    --                  TP only widens its area; see NO_MOONSHADE below)
    sets.precast.WS['Steel Cyclone'] = set_combine(sets.GA_WS, {
        body="Sakpata's Plate",
        hands="Sakpata's Gauntlets",
        left_ring="Cornelia's Ring",
        right_ring="Karieyh Ring",
    })
    sets.precast.WS['Upheaval']      = sets.GA_WS
    sets.precast.WS["Ukko's Fury"]   = sets.GA_WS
    sets.precast.WS['Fell Cleave']   = set_combine(sets.GA_WS, {
        body="Sakpata's Plate",
        left_ear="Thrud Earring",
        right_ear="Steelflash Earring",
        left_ring="Cornelia's Ring",
        right_ring="Karieyh Ring",
    })
    sets.precast.WS['Raging Rush']   = sets.GA_WS
    sets.precast.WS['Keen Edge']     = sets.GA_WS
    sets.precast.WS['Sturmwind']     = sets.GA_WS
    sets.precast.WS['Iron Tempest']  = sets.GA_WS
    sets.precast.WS['Full Break']    = sets.GA_WS
    sets.precast.WS['Armor Break']   = sets.GA_WS
    sets.precast.WS['Weapon Break']  = sets.GA_WS

    -- Polearm. Impulse Drive is the one to spam. The others are
    -- STR-weighted physical WS that take the same set.
    sets.precast.WS['Impulse Drive'] = sets.IMPULSE
    sets.precast.WS['Sonic Thrust']  = sets.IMPULSE
    sets.precast.WS['Penta Thrust']  = sets.IMPULSE
    sets.precast.WS['Double Thrust'] = sets.IMPULSE
    sets.precast.WS['Skewer']        = sets.IMPULSE

    -- Sword.
    sets.precast.WS['Savage Blade']  = sets.SAVAGE
    sets.precast.WS['Requiescat']    = sets.SAVAGE
    sets.precast.WS['Vorpal Blade']  = sets.SAVAGE
    sets.precast.WS['Circle Blade']  = sets.SAVAGE

    -- Club. Split by modifier, not by weapon: the ones that want MND get the
    -- Sulevia set, the pure-STR ones get the plain WSD core.
    --   Judgment        200 skill   50% STR / 50% MND
    --   Shining Strike    5 skill   40% STR / 40% MND
    --   Seraph Strike    40 skill   40% STR / 40% MND
    sets.precast.WS['Judgment']       = sets.JUDGMENT
    sets.precast.WS['Shining Strike'] = sets.JUDGMENT
    sets.precast.WS['Seraph Strike']  = sets.JUDGMENT
    --   Black Halo      230 skill   30% STR / 70% MND (needs the Orastery Woes quest)
    sets.precast.WS['Black Halo']     = sets.JUDGMENT
    --   True Strike     175 skill   100% STR (and a guaranteed crit)
    --   Skullbreaker    150 skill   100% STR
    --   Brainshaker      70 skill   100% STR
    sets.precast.WS['True Strike']    = sets.WS_BASE
    sets.precast.WS['Skullbreaker']   = sets.WS_BASE
    sets.precast.WS['Brainshaker']    = sets.WS_BASE

    ---------------------------------------------------------------------------
    -- Job abilities
    ---------------------------------------------------------------------------

    -- The one place your old relic body earns its keep: Warrior's Lorica cuts
    -- Aggressor's evasion penalty by 10. Aggressor is instant, so this costs
    -- nothing - swapped in for the JA and straight back out on aftercast.
    sets.precast.JA['Aggressor'] = {body="Warrior's Lorica"}

    -- Berserk, Warcry, Defender, Retaliation, Restraint, Blood Rage and
    -- Mighty Strikes have no enhancing gear in your inventory.

    ---------------------------------------------------------------------------
    -- Utsusemi (/NIN)
    ---------------------------------------------------------------------------

    -- NO FAST CAST SET, on purpose. Your two "Fast Cast"+7% pieces (Dread
    -- Jupon, Herculean Helm) are not WAR-equippable, and the only WAR-legal
    -- one is Naji's Loop at 1%. Cheap future pieces: Loquacious Earring,
    -- Rahab / Prolix Ring, Odyssean gear with Fast Cast augments.
    --
    -- Midcast is where the gear counts: spell recast is fixed by the haste
    -- you are wearing when the spell completes. sets.engaged is already
    -- past the 25% gear haste cap (27%) since Pumm. Cuisses +2 went in, so
    -- it IS the Utsusemi set - the old Valorous Hose swap is gone.
    -- Mote maps both Ichi and Ni to 'Utsusemi'.
    sets.midcast.Utsusemi = sets.engaged

    ---------------------------------------------------------------------------
    -- Idle
    ---------------------------------------------------------------------------

    -- Worn over the idle set only while running (see 'gearinfo' in
    -- job_self_command). Standing still keeps the DT legs below.
    sets.Kiting = {legs="Track Pants +1"}   -- Movement speed +8% (2026-10-31)

    -- 2026-10-21 optimizer pass: DT -45% -> -51% (capped), PDT -4%, HP 397 -> 448.
    -- Murky Ring (DT-10%) for Chirich, Pumm. Cuisses +2, Platinum Moogle Belt,
    -- Valorous Greaves, Thrud + Eabani earrings and Amar Cluster.
    sets.idle = {
        ammo="Amar Cluster",
        head="Flam. Zucchetto +2",    -- HP+80
        body="Sakpata's Plate",       -- DT-10%, HP+136
        hands="Sakpata's Gauntlets",  -- DT-8%,  HP+91
        legs="Pumm. Cuisses +2",      -- was Sulev. Cuisses +2
        feet={name="Valorous Greaves", augments={'Weapon skill damage +5%','AGI+2','Accuracy+9','Attack+9'}},
        neck="Elite Royal Collar",    -- DT-5%, VIT+10, Regen+3 if San d'Oria
        waist="Plat. Mog. Belt",
        left_ear="Thrud Earring",
        right_ear="Eabani Earring",
        left_ring="Defending Ring",   -- DT-10%
        right_ring="Murky Ring",      -- DT-10%, was Chirich Ring
        back="Cichol's Mantle",
    }
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

-- POST-precast, not precast. Mote runs job_precast BEFORE it equips
-- sets.precast.WS[...], and GearSwap keeps the last equip() per slot, so a
-- Moonshade equipped in job_precast was overwritten by every WS set's own
-- left_ear. It never actually went on. job_post_precast runs after the WS
-- set, so the earring sticks.
--
-- FENCER. A one-handed weapon with only a shield (or nothing) in the off-hand
-- gets Fencer's +500 TP Bonus, so Naegling + Blurred Shield hits the 3000
-- cap from 2500 TP on its own - Moonshade there only throws away the
-- Ishvara it replaces. Dual wield and two-handed weapons get no Fencer and
-- keep the 2750 cutoff. Add any new one-hander / shield to these lists.
local FENCER_MAINS = S{'Naegling', 'Loxotic Mace +1', 'Mafic Cudgel'}
local SHIELDS      = S{'Blurred Shield'}

local function fencer_active()
    local sub = player.equipment.sub
    return FENCER_MAINS:contains(player.equipment.main)
        and (sub == 'empty' or SHIELDS:contains(sub))
end

-- WSs whose damage TP doesn't raise at all, so Moonshade would only displace a
-- real earring. Fell Cleave: TP widens the area, fTP is a flat 2.75.
local NO_MOONSHADE = S{'Fell Cleave'}

function job_post_precast(spell, action, spellMap, eventArgs)
    -- Moonshade only matters below the TP cap, and only on a weapon skill.
    if spell.type == 'WeaponSkill' and not NO_MOONSHADE:contains(spell.english) then
        local cutoff = fencer_active() and 2500 or 2750
        if player.tp < cutoff then
            equip(sets.MoonshadeWS)
        end
    end
end

-- The DW TP set only when actually dual wielding: a sword in the off-hand
-- AND a subjob that has the trait. Change sub away from DNC/NIN and the game
-- drops the off-hand sword, so Suppanomimi would be doing nothing.
--
-- Checked against the equipped off-hand, NOT WeaponMode: WeaponMode resets
-- to GreatAxe on every reload / job change, which used to leave you dual
-- wielding in the shield TP set until you re-ran //gs c dw.
--
-- `weapons` ({main=, sub=}) overrides the equipped names. A weapon command
-- passes it because player.equipment still shows the old weapons until the
-- swap lands.
local DW_OFFHANDS = S{'Sangarius +1'}
local CLUB_MAINS  = S{'Loxotic Mace +1', 'Mafic Cudgel'}

local function weapon_engaged_set(weapons)
    local main = weapons and weapons.main or player.equipment.main
    local sub  = weapons and weapons.sub  or player.equipment.sub
    -- Club first: it is always single wield, whatever the subjob.
    if CLUB_MAINS:contains(main) then
        return sets.engaged.Club
    elseif DW_OFFHANDS:contains(sub)
            and (player.sub_job == 'DNC' or player.sub_job == 'NIN') then
        return sets.engaged.DW
    -- Same reason: checked against the equipped weapon, not WeaponMode.
    elseif main == 'Lightreaver' or main == 'Router' then
        return sets.engaged.GreatAxe
    elseif main == 'Shining One' then
        return sets.engaged.Polearm
    end
    return sets.engaged
end

-- //gs c dt. Resets to off on reload, like the other modes.
local DT_MODE = false
-- //gs c th. Same. Its slots are disable()d while on, so nothing else has
-- to know about it.
local TH_MODE = false
local TH_SLOTS = {'ammo', 'head', 'hands', 'legs'}

-- A reload or job change with TH on would otherwise leave those slots locked.
function user_unload()
    if TH_MODE then
        enable(TH_SLOTS)
    end
end

local function engaged_set(weapons)
    local set = weapon_engaged_set(weapons)
    if DT_MODE then
        return set_combine(set, sets.DTOverlay)
    end
    return set
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if player.status == 'Engaged' then
        equip(engaged_set())
    end
end

function job_handle_equipping_gear(playerStatus, eventArgs)
    if playerStatus == 'Engaged' then
        equip(engaged_set())
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
    -- The weapon set this command equipped, if any. lockback, unlockback
    -- and a refused //gs c dw leave it nil, so the TP pick below reads the
    -- equipped weapons instead of a possibly stale WeaponMode.
    local swapped

    if cmd == 'ga' or cmd == 'greataxe' or cmd == 'axe' then
        state.WeaponMode:set('GreatAxe')
        swapped = sets.weapons.GreatAxe
        equip(swapped)
        add_to_chat(122, 'GearSwap: Great Axe / Lightreaver')

    elseif cmd == 'sword' then
        state.WeaponMode:set('Sword')
        swapped = sets.weapons.Sword
        equip(swapped)
        add_to_chat(122, 'GearSwap: Sword / Naegling + Blurred Shield')

    elseif cmd == 'blunt' or cmd == 'club' then
        state.WeaponMode:set('Club')
        swapped = sets.weapons.Club
        equip(swapped)
        add_to_chat(122, 'GearSwap: Club / Loxotic Mace +1 + Blurred Shield '
            .. '(Judgment - blunt damage)')
        if player.sub_job ~= 'DRG' then
            add_to_chat(167, 'GearSwap: club set is built for /DRG (you are /'
                .. (player.sub_job or '?') .. ')')
        end

    elseif cmd == 'polearm' or cmd == 'pole' or cmd == 'so' then
        state.WeaponMode:set('Polearm')
        swapped = sets.weapons.Polearm
        equip(swapped)
        add_to_chat(122, 'GearSwap: Polearm / Shining One + Daduchos Grip (Impulse Drive)')

    elseif cmd == 'dw' or cmd == 'dualwield' or cmd == 'dualsword' then
        -- Without the Dual Wield trait the game just refuses the off-hand
        -- sword. Nothing tells you, so say it here.
        if player.sub_job == 'DNC' or player.sub_job == 'NIN' then
            state.WeaponMode:set('DualSword')
            swapped = sets.weapons.DualSword
            equip(swapped)
            add_to_chat(122, 'GearSwap: Dual Wield / Naegling + Sangarius +1')
        else
            add_to_chat(167, 'GearSwap: Dual Wield needs /DNC or /NIN (you are /'
                .. tostring(player.sub_job) .. ') - weapons unchanged')
        end

    elseif cmd == 'dt' then
        -- //gs c dt toggles; //gs c dt on / off sets it.
        local arg = cmdParams[2] and cmdParams[2]:lower()
        if arg == 'on' then
            DT_MODE = true
        elseif arg == 'off' then
            DT_MODE = false
        else
            DT_MODE = not DT_MODE
        end
        add_to_chat(122, DT_MODE and 'GearSwap: DT mode ON (-45% damage taken)'
            or 'GearSwap: DT mode OFF')

    elseif cmd == 'th' then
        TH_MODE = not TH_MODE
        if TH_MODE then
            equip(sets.TH)
            disable(TH_SLOTS)
        else
            enable(TH_SLOTS)
            if player.status ~= 'Engaged' then send_command('gs c update') end
        end
        add_to_chat(122, TH_MODE and 'GearSwap: TH mode ON (+4, ammo/head/hands/legs locked)'
            or 'GearSwap: TH mode OFF')

    elseif cmd == 'lockback' then
        send_command('gs disable back')
        add_to_chat(122, 'GearSwap: BACK SLOT LOCKED')

    elseif cmd == 'unlockback' then
        send_command('gs enable back')
        add_to_chat(122, 'GearSwap: BACK SLOT UNLOCKED')
    end

    -- A weapon swap mid-fight also swaps to that weapon's TP set.
    if player.status == 'Engaged' then
        equip(engaged_set(swapped))
    end
end

---------------------------------------------------------------------------
-- BLOCKED UPGRADES - gear you own that this file cannot use yet
---------------------------------------------------------------------------
--
-- GearSwap can only equip from inventory and wardrobe1-8. Items in satchel,
-- sack, case, storage, locker and safe are invisible to it - a set naming one
-- silently keeps whatever was already in that slot, with no error. These were
-- read from addons/findAll/data/Char1.lua (findAll run 2026-09-15).
--
--   Router            sack      WAR-only great axe, and the best 2H you own:
--                               DMG 295 vs 273, STR+20, Attack+40,
--                               "Quadruple Attack"+4%. The same TP and
--                               Upheaval sets win with either axe. Modelled
--                               gain over Lightreaver: about +11% Upheaval
--                               damage and +15% total damage per second. Move
--                               it to a wardrobe, then change main= in
--                               sets.weapons.GreatAxe (sets.engaged.GreatAxe
--                               already recognises Router).
--
--   Cornelia's Belt   storage   STR+10, Haste+10%, Counter+5. Possible WS
--                               waist over Sailfi Belt +1, whose Haste+9% is
--                               dead weight in a WS set. Depends on whether
--                               your Sailfi Unity Ranking attack bonus is
--                               actually live; check before swapping.
--
--   Warrior's Lorica  locker    ALREADY NAMED in sets.precast.JA['Aggressor'].
--                               The Aggressor swap is a no-op until it is
--                               moved to a wardrobe.
--
-- NO LONGER BLOCKED: Rep. Plat. Medal and Elite Royal Collar are both in
-- wardrobe3 now. The Medal is used in the Great Axe TP, Upheaval and WS_BASE
-- (so Savage Blade / Judgment) sets.
--
-- Cichol's Mantle augments ARE in the gearinfo dump: DEX+20, Accuracy+20
-- Attack+20, "Dbl.Atk."+10, Damage taken-5%. It's a TP cape. The DA+10 still
-- pulls weight in multi-hit WS sets, because multi-attack can proc during a WS.

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
    set_macro_page(1, 4)
    add_to_chat(122, 'GearSwap: macro book 4 page 1 for WAR')
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

-- Running while idle: add sets.Kiting (Track Pants +1) on top of the idle set.
function customize_idle_set(idleSet)
    if gearinfo_moving and sets.Kiting then
        return set_combine(idleSet, sets.Kiting)
    end
    return idleSet
end
