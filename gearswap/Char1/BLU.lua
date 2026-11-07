-- BLU GearSwap (Char1) - Naegling / Savage Blade melee, plus a midcast set
-- for every kind of blue magic.
--
-- Built 2026-10-02 from Char1's gearinfo dump + findAll bag list, checked
-- against Prothescar's "The Beast Within" BLU guide (ffxiah node 25, last
-- updated 2024-03) and the 2026 pages of its forum thread. Every item named
-- here is one Char1 owns and BLU can wear.
--
-- MOVE THESE INTO A WARDROBE FIRST. GearSwap can only equip from inventory
-- and wardrobes; a set naming an item in another bag just leaves that slot
-- as it was, with no error. (Nibiru Blade is out of the sack now - good.)
--   case     Cornflower Cape    Blue magic skill+5, MAB+15, MAcc+15 - your
--                               only BLU cape; used by nuke / macc / skill
--   case     Oshasha's Treatise WSD+3% ammo for Savage Blade
--   case     Peacock Amulet     Acc+10 neck for the Acc TP / Savage sets
--
-- Same conventions as WAR / SAM / NIN / COR:
--   * weapons live ONLY in sets.weapons and change only by //gs c command,
--     so casting and weapon skills never swap Naegling and never reset TP;
--   * Sortie / Hashishin earrings go in the RIGHT ear only;
--   * overlays (Moonshade, Archon Ring) go in job_post_* hooks so they stick.
--
-- Commands:
--   //gs c savage    Naegling + Machaera +2 (TP Bonus +1000)
--   //gs c nibiru    Naegling + Nibiru Blade (old pair, better off-hand swings)
--   //gs c nuke      Kaja Rod + Culminus (nuking; costs your TP like any swap)
--   //gs c normal    TP mode: full offence (default)
--   //gs c dt        TP mode: DT-34% hybrid
--   //gs c acc       TP mode: max accuracy, and Savage Blade in its max
--                    accuracy set (sets.TP.Acc / sets.SavageAcc)
--   //gs c eva       TP mode: evasion (sets.Evasion) - worn engaged AND
--                    idle, so it's on while you run around pulling
--   //gs c learn     toggle Magus Bazubands (better chance to learn blue
--                    magic) on hands while engaged / idle. Turn it on for
--                    spell hunts (Meebles for Thrashing Assault): the
--                    gloves must be ON when the mob dies.
--   //gs c th        toggle Treasure Hunter +3 (sets.TH) on the tag spells
--                    ONLY - Dream Flower and Sheep Song: AoE sleeps that do
--                    no damage, so one cast tags the whole pack without
--                    killing anything. Idle / engaged / nukes are untouched
--                    (2026-10-17: TH over idle ate the Evasion set's Herc
--                    Helm on the pull - Rarab Cap is DEF 2).
--   //gs c bonk      toggle the same TH+3 set over your TP set while
--                    ENGAGED, to tag with a melee hit. Costs DPS - turn it
--                    off once the mob's tagged. With learn mode on, the
--                    Magus Bazubands keep hands (TH+2 then).
--
-- BLUE MAGIC SPELL SET - the guide's "Advanced DD" melee set (70 points;
-- needs the 100 JP gift, drop a 4-point spell or two if you don't have it):
--   Quad. Continuum, Delta Thrust, Barbed Crescent, Empty Thrash, Heavy
--   Strike, Thrashing Assault, Sudden Lunge, Glutinous Dart, Sinker Drill,
--   Sweeping Gouge (or Tenebral Crush), Paralyzing Triad, Nat. Meditation,
--   Erratic Flutter, Diffusion Ray, Molting Plumage, Blazing Bound, Fantod,
--   + one flex (Magic Fruit / Barrier Tusk / Occultation / Cocoon).
--   Traits: Dual Wield IV, Triple Attack, Store TP III, Accuracy Bonus II,
--   Critical Attack Bonus II, Skillchain Bonus II.
-- The TP set below assumes Dual Wield trait III or better from spells -
-- your only DW gear is Suppanomimi (+5), so the DW has to come from spells.
--
-- UPDATED 2026-10-03 from a new gearinfo parse: Rosmerta's Cape (DEX/Acc/
-- Att, DA+1 so far), Assim. Jubbah +2, Hashishin Kavuk and Luhlaza Shalwar
-- +1 are now owned and used below (the Shalwar +1 has no slot it wins yet).
--
-- vs THE GUIDE - what it builds around that you don't own yet, biggest first:
--   Thibron off-hand (Machaera +2 fills the TP Bonus role), a STR / WSD Rosmerta's Cape for weapon
--   skills (STR / WSD), Jubbah +3 / Luhlaza Shalwar +3 / Hashishin Kavuk +3
--   (WSD), Hashishin Mintan (refresh body, blue magic cast time), Adhemar,
--   Gleti's, Nyame, Malignance (beyond the Tabard), Epona's Ring, Mirage Stole.
-- Your Rosmerta's Cape is the TP one, part-way augmented: its Double Attack
-- line is at +1 and goes up to +10 with more Abdhaljs dye.
--
-- UPDATED 2026-10-04 from a new gearinfo parse + spell export:
--   * Hashishin Kavuk is now +1 (Chain Affinity+24, Acc+20, Sword skill+20).
--     The old name in the Chain Affinity overlay no longer matched anything,
--     so that overlay was silently doing nothing - fixed. It also takes the
--     TP head (see sets.TP.Normal).
--   * Hashishin Mintan +1 (Blue magic casting time -14%) is the body for
--     blue magic precast.
--   * Magus Bazubands -> //gs c learn.
--   * Spells: Glutinous Dart, Paralyzing Triad, Sweeping Gouge learned.
--     Later the same day: Thrashing Assault and Diffusion Ray too - the
--     full Advanced DD spec is learned. //bs melee sets it.
--   Not used: Cornelia's Belt (STORAGE; Sailfi's TA+2 beats its Counter),
--   Emet Harness (Enmity+9), Herculean Vest TA+3 (Tabard keeps DT-9% and
--   Acc+50 against high-level mobs).
--
-- UPDATED 2026-10-09 from a new gearinfo export:
--   * Machaera +2 (TP Bonus +1000) is the off-hand in sets.weapons.Savage;
--     Moonshade now only goes on below 1750 TP.
--   * A second Rosmerta's Cape (INT+8, Magic Damage+1 so far). Both capes
--     are named by augment (ROSMERTA_TP / ROSMERTA_INT) so GearSwap can
--     tell them apart; the INT one is on Sanguine Blade.
--   * Oshasha's Treatise and Hashishin Earring are in inventory now.
--
-- UPDATED 2026-10-13: sets.Evasion + //gs c eva for Omen-style pulling.
-- Built from the 2026-10-11 gearinfo dump - see the set for what's missing.
--
-- UPDATED 2026-10-16 from a new gearinfo export:
--   * //gs c nuke - Kaja Rod + Culminus for nuking (MAB+38, Magic Damage
--     +307 between them, vs Naegling + Machaera's MAB+16 / +217).
--   * Eschan Stone (MAB+7 MAcc+7 Acc/Att+15) takes the empty waist in the
--     nuke, Sanguine Blade and magic accuracy sets, the physical-spell
--     waist, and Swift Belt's place in the Savage Blade accuracy set.
--   * Sveltesse Gouriz (Eva+8 AGI+7) is the evasion waist.
--   * Hashishin Earring's Acc+6 / MAcc+6 augment -> magic accuracy set.
--   * Solemn Ring (MND+5) -> healing set.
--   * Cornflower Cape is STILL in the case. Nuke sets now fall back to the
--     INT Rosmerta's Cape until it's in a wardrobe (job_post_midcast).
--   Checked and not used: Herculean Helm / Trousers' new MAB augments (Jhakri
--   still wins both slots), Taeon Gloves, Quiahuiz Trousers, Satlada Necklace
--   (storage; Sibyl Scarf is better), Aurore Gaiters +1.
--
-- UPDATED 2026-10-17 from a new gearinfo export:
--   * Battlecast Gaiters (Physical DT-3%, STP+5, Haste+4%) -> feet in the DT
--     and idle sets. Herculean Boots keep TP (TA+2% beats STP+5), evasion
--     (Eva 80 vs 72) and the WS / Savage sets (WSD+5% augment).
--   * Dread Jupon is no longer in any bag - dropped from sets.precast.FC.
--   * MOVE FROM THE CASE: Oshasha's Treatise (Savage Blade ammo, Acc TP
--     ammo) and Peacock Amulet (Acc TP / SavageAcc neck) are in the CASE,
--     not inventory, so those slots haven't been swapping. Cornflower Cape
--     is still there too.
--   Checked and not used: Famine Sash (Acc/Att+10 - Eschan Stone's +15 and
--   MAB/MAcc beat it everywhere, Sailfi keeps the TP waist for haste).

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()
end

function user_setup()
    -- Offence first: you have to ask for the DT set.
    state.TPMode = M{['description']='TP Mode', 'Normal', 'DT', 'Acc', 'Eva'}
    -- Set by the Trust addon ("gs c set MagicBurstMode Single") right before
    -- each Burst Affinity burst, same as on SCH. Without this state Mote
    -- printed an error for every burst. It changes no gear: the Magical set
    -- already wears your only burst pieces (Jhakri Pigaches +1 MB+5, Jhakri
    -- Ring MB+2). job_aftercast turns it back Off after the nuke.
    state.MagicBurstMode = M{['description']='Magic Burst', 'Off', 'Single', 'Always'}
    state.LearnMode = M(false, 'Learn Blue Magic')
    state.THMode = M(false, 'Treasure Hunter')
    state.BonkMode = M(false, 'Treasure Hunter (melee)')
end

-- Spells that tag with TH without damage (//gs c th puts sets.TH on them).
TH_TAG_SPELLS = S{'Dream Flower', 'Sheep Song'}

---------------------------------------------------------------------------
-- Blue magic categories. Mote looks up sets.midcast['Blue Magic'][<map>],
-- where <map> comes from job_get_spell_map below. Names are the exact
-- in-game spellings from res/spells.lua (note the abbreviations).
-- Anything not listed falls back to sets.midcast['Blue Magic'] itself, the
-- magic accuracy set - right for most odd debuffs.
---------------------------------------------------------------------------

local BLUE_MAPS = {
    Physical = S{
        'Foot Kick', 'Power Attack', 'Sprout Smack', 'Wild Oats', 'Queasyshroom',
        'Battle Dance', 'Head Butt', 'Feather Storm', 'Helldive', 'Bludgeon',
        'Claw Cyclone', 'Screwdriver', 'Grand Slam', 'Smite of Rage', 'Pinecone Bomb',
        'Jet Stream', 'Uppercut', 'Terror Touch', 'Mandibular Bite', 'Sickle Slash',
        'Death Scissors', 'Dimensional Death', 'Spiral Spin', 'Seedspray', 'Body Slam',
        'Spinal Cleave', 'Frenetic Rip', 'Frypan', 'Hydro Shot', 'Tail Slap',
        'Hysteric Barrage', 'Asuran Claws', 'Cannonball', 'Disseverment',
        'Sub-zero Smash', 'Ram Charge', 'Vertical Cleave', 'Final Sting', 'Goblin Rush',
        'Vanity Dive', 'Benthic Typhoon', 'Whirl of Rage', 'Quad. Continuum',
        'Empty Thrash', 'Delta Thrust', 'Heavy Strike', 'Sudden Lunge', 'Quadrastrike',
        'Tourbillion', 'Amorphic Spikes', 'Barbed Crescent', 'Bilgestorm', 'Bloodrake',
        'Paralyzing Triad', 'Glutinous Dart', 'Thrashing Assault', 'Sinker Drill',
        'Sweeping Gouge', 'Saurian Slide',
    },
    Magical = S{
        'Sandspin', 'Cursed Sphere', 'Blastbomb', 'Bomb Toss', 'Death Ray',
        'Mysterious Light', 'Blitzstrahl', 'Ice Break', 'Maelstrom', 'Eyes On Me',
        'Corrosive Ooze', 'Firespit', 'Regurgitation', 'Mind Blast', 'Magic Hammer',
        'Acrid Stream', 'Leafstorm', 'Blazing Bound', 'Thermal Pulse', 'Charged Whisker',
        'Evryone. Grudge', 'Water Bomb', 'Dark Orb', 'Thunderbolt', 'Gates of Hades',
        'Droning Whirlwind', 'Tem. Upheaval', 'Rending Deluge', 'Embalming Earth',
        'Foul Waters', 'Retinal Glare', 'Subduction', 'Rail Cannon', 'Diffusion Ray',
        'Uproot', 'Crashing Thunder', 'Polar Roar', 'Molting Plumage',
        'Nectarous Deluge', 'Searing Tempest', 'Blinding Fulgor', 'Spectral Floe',
        'Scouring Spate', 'Anvil Lightning', 'Silent Storm', 'Entomb', 'Tenebral Crush',
        'Palling Salvo', 'Cesspool', 'Tearing Gust',
    },
    MagicAcc = S{
        'Filamented Hold', 'Cimicine Discharge', 'Demoralizing Roar', 'Venom Shell',
        'Light of Penance', 'Sandspray', 'Auroral Drape', 'Frightful Roar', 'Enervation',
        'Infrasonics', 'Lowing', 'Cold Wave', 'Awful Eye', 'Sheep Song', 'Soporific',
        'Yawn', 'Dream Flower', 'Chaotic Eye', 'Sound Blast', 'Blank Gaze', 'Stinking Gas',
        'Geist Wall', 'Jettatura', 'Feather Tickle', 'Temporal Shift', 'Actinic Burst',
        'Reaving Wind', 'Mortal Ray', 'Absolute Terror', 'Blistering Roar', 'Cruel Joke',
    },
    Healing = S{
        'Pollen', 'Healing Breeze', 'Wild Carrot', 'Magic Fruit', 'Plenilune Embrace',
        'Restoral', 'Exuviation',
    },
    -- Potency scales with blue magic skill. Drains are skill-based too.
    Skill = S{
        'Metallic Body', 'Diamondhide', 'Occultation', 'Magic Barrier',
        'Blood Drain', 'Digest', 'MP Drainkiss', 'Blood Saber', 'Osmosis', 'Atra. Libations',
    },
    -- Damage / healing scales with YOUR max HP.
    Breath = S{
        'Poison Breath', 'Magnetite Cloud', 'Hecatomb Wave', 'Radiant Breath',
        'Flying Hip Press', 'Bad Breath', 'Frost Breath', 'Heat Breath', 'Vapor Spray',
        'Thunder Breath', 'Wind Breath', 'White Wind',
    },
    -- Flat buffs: no gear changes their effect, so these cast in DT gear.
    Buff = S{
        'Cocoon', 'Refueling', 'Feather Barrier', 'Memento Mori', 'Voracious Trunk',
        'Zephyr Mantle', 'Warm-Up', 'Amplification', 'Triumphant Roar', 'Saline Coat',
        'Reactor Cool', 'Plasma Charge', 'Regeneration', 'Animating Wail',
        'Battery Charge', 'Fantod', 'Winds of Promy.', 'Barrier Tusk',
        'O. Counterstance', 'Harden Shell', 'Pyric Bulwark', 'Nat. Meditation',
        'Carcharian Verve', 'Erratic Flutter', 'Mighty Guard',
    },
}

function job_get_spell_map(spell, default_spell_map)
    if spell.skill == 'Blue Magic' then
        for map, names in pairs(BLUE_MAPS) do
            if names:contains(spell.english) then
                return map
            end
        end
    end
end

function init_gear_sets()

    ---------------------------------------------------------------------------
    -- Weapons - the only sets that ever touch main/sub
    ---------------------------------------------------------------------------

    -- Two Rosmerta's Capes now, so GearSwap needs the augments to pick one.
    ROSMERTA_TP  = {name="Rosmerta's Cape", augments={'DEX+20', 'Accuracy+20 Attack+20'}}
    ROSMERTA_INT = {name="Rosmerta's Cape", augments={'INT+8'}}   -- INT+8, Magic Damage+2 so far

    sets.weapons = {}

    -- Naegling is the whole build: Savage Blade +15%, and its MAB+16 /
    -- Magic Damage+217 also make it a decent nuking sword.
    -- Machaera +2 is the off-hand: TP Bonus +1000 (augment), the guide's
    -- Thibron role. Savage Blade's fTP is 4.0 / 10.25 / 13.75 at 1000 / 2000
    -- / 3000 TP, so a 1000 TP Savage Blade fires at 2000 - about 2.5x the
    -- damage - and anything from 2000 TP up fires at the 3000 cap.
    -- The price is off-hand swings: Machaera is a Lv99 sword with DMG 51 and
    -- no Sword skill bonus, against Nibiru Blade's DMG 133, Sword skill +242
    -- and DA+2%, so off-hand hits land less often and for less. The WS gain
    -- is far bigger. //gs c nibiru puts the old pair back.
    sets.weapons.Savage = {
        main="Naegling",
        sub="Machaera +2",
    }
    sets.weapons.Nibiru = {
        main="Naegling",
        sub="Nibiru Blade",
    }
    -- Nuking pair. Kaja Rod: MAB+18, Magic Damage+232, MAcc+35. Culminus:
    -- MAB+20, Magic Damage+75. Weapon Magic Damage adds straight onto every
    -- nuke's base, so this is the biggest single nuke upgrade you own.
    sets.weapons.Nuke = {
        main="Kaja Rod",              -- wardrobe 2
        sub="Culminus",               -- wardrobe
    }

    ---------------------------------------------------------------------------
    -- TP. No main/sub. sets.TP rather than sets.engaged subtables, same as
    -- SAM: a self-referencing set table is a recursion hazard in GearSwap.
    ---------------------------------------------------------------------------

    sets.TP = {}

    -- Gear haste 31% (cap needs 26%): Kavuk +1 8, Tabard 4, Samnuha 6,
    -- Herculean Boots 4, Sailfi 9. Head: Hashishin Kavuk +1 over Herculean
    -- Helm - same Haste+8%, and Acc+20 + Sword skill+20 + DEX18 is roughly
    -- +30 more accuracy than the Helm's DEX28, for ~44 less attack (Att+16,
    -- STR+37). Accuracy wins against level 119+ mobs like the Temenos
    -- Meebles. On easy targets the Helm is a little more damage.
    -- Hands: Malignance Gloves (2026-10-18) over Jhakri Cuffs +2 - Acc+50
    -- vs 43, DEX+56 vs 41, Store TP+12 and DT-5% for the Cuffs' Att+43.
    -- Multi-attack: Samnuha DA+3 TA+2, Herculean Boots TA+2, Sailfi TA+2,
    -- Defiant TA+1, Telos DA+1, Petrov DA+1, Coiste DA+3.
    -- Rosmerta's Cape replaces Grounded Mantle: same Acc+20, but DEX+20 (vs
    -- up to 7), Attack+20 and DA+1%, for the Mantle's Haste+1% - still capped.
    -- Guide's TP set for comparison: Adhemar / Malignance, Mirage Stole,
    -- Epona's Ring - Malignance Gloves owned now, the rest not.
    --
    -- 2026-10-21 GearSwap-Optimizer pass: Amar Cluster, Malignance Chapeau over
    -- the Kavuk, and Telos + Steelflash in place of Suppanomimi + Telos. TP
    -- 5.99s -> 5.63s, melee damage +5%, DT -18% -> -24%, still 99% hit rate vs
    -- an Apex Toad. TP.DT inherits these (the Chapeau adds DT-6% there too).
    sets.TP.Normal = {
        ammo="Amar Cluster",          -- Acc+10, STR+2 (was Coiste Bodhar)
        head="Malignance Chapeau",    -- was Hashishin Kavuk +1
        body="Malignance Tabard",     -- Acc+50, DEX+49, STP+11, DT-9%
        hands="Malignance Gloves",    -- Acc+50, DEX+56, STP+12, DT-5%, Haste+4%
        legs="Samnuha Tights",        -- DA+3 TA+2 (augments), STP+7, Haste+6%
        feet="Malignance Boots",      -- Acc+50, DEX+40, STP+9, DT-4%, Haste+3%
                                      -- (2026-10-18; was Herculean Boots TA+2%)
        neck="Defiant Collar",        -- Acc+8, TA+1%
        waist="Sailfi Belt +1",       -- Haste+9%, TA+2%
        left_ear="Telos Earring",     -- Acc/Att+10, STP+5, DA+1%
        right_ear="Steelflash Earring", -- was Suppanomimi
        left_ring="Chirich Ring",     -- Acc+7, STP+5
        right_ring="Petrov Ring",     -- DA+1%, STP+5
        back=ROSMERTA_TP,             -- DEX+20, Acc/Att+20, DA+1%
    }

    -- DT-43%: Tabard -9, Malignance Gloves -5, Malignance Boots -4 (from
    -- TP.Normal), Elite Royal Collar -5, Defending Ring -10, Murky Ring -10.
    -- Plat. Mog. Belt
    -- would cost Sailfi's Haste+9% and drop you under the gear haste cap -
    -- don't make that trade.
    sets.TP.DT = set_combine(sets.TP.Normal, {
        neck="Elite Royal Collar",    -- DT-5%
        left_ring="Defending Ring",   -- DT-10%
        right_ring="Murky Ring",      -- DT-10%
    })

    -- MAX ACCURACY (//gs c acc) - for mobs you keep missing. Every slot goes
    -- to Accuracy (+DEX, ~0.75 Acc a point); multi-attack is given up.
    -- Coronal +1 Acc38 DEX24 over Kavuk +1 (Acc20 + Sword skill20, DEX18).
    -- Volte Tights over Jhakri Slops +1: Acc38 vs 39, but Haste+9 vs +2 is
    -- what keeps gear haste at the 25% cap (Coronal 3, Tabard 4, Volte 9,
    -- Sailfi 9). Peacock Amulet Acc+10 over Defiant Collar Acc+8. Steelflash
    -- Acc+8 replaces Suppanomimi, so Dual Wield is from spells only here.
    sets.TP.Acc = {
        ammo="Oshasha's Treatise",    -- Acc+5
        head="Jhakri Coronal +1",     -- Acc+38, DEX+24
        body="Malignance Tabard",     -- Acc+50, DEX+49
        hands="Malignance Gloves",    -- Acc+50, DEX+56
        legs="Volte Tights",          -- Acc+38, Haste+9%
        feet="Malignance Boots",      -- Acc+50, DEX+40, Haste+3%
        neck="Peacock Amulet",        -- Acc+10
        waist="Sailfi Belt +1",       -- Haste+9% (Swift Belt's Acc+3 would cost 5% haste)
        left_ear="Steelflash Earring",-- Acc+8
        right_ear="Telos Earring",    -- Acc+10
        left_ring="Chirich Ring",     -- Acc+7
        right_ring="Jhakri Ring",     -- Acc+6
        back=ROSMERTA_TP,             -- Acc+20, DEX+20
    }

    -- EVASION (//gs c eva) - pulling packs Omen-style. Pair it with the
    -- omenaoe spell set (//bs omenaoe = Evasion Bonus III). Your best
    -- evasion piece in every slot that has one:
    --   Evasion 431: Herc Helm 55, Tabard 102, Volte Bracers 85, Volte
    --   Tights 74, Herc Boots 80, Eabani 15, Infused 10, Amar Cluster 10
    --   (the DT set has 274). AGI 184 (DT set 137).
    --   DT-32% (+2% physical from the Boots): Tabard 9, Plat. Mog. Belt 3,
    --   Defending 10, Murky 10 - not capped.
    --   Gear haste 30% (cap 26%) without Sailfi: Helm 8, Tabard 4, Bracers 5,
    --   Tights 9, Boots 4.
    -- Eabani, Infused, Amar Cluster and Bathy Choker +1 added 2026-10-14 (all
    -- in INVENTORY). 2026-10-16: Sveltesse Gouriz (Eva+8 AGI+7) replaces Plat.
    -- Mog. Belt - Evasion 439, AGI 191, DT-29% (+2% physical).
    -- 2026-10-18: Malignance Gloves replace Volte Bracers - Eva-5 for DT-5%
    -- (Evasion 434, DT-34%), haste 29% still over the cap. You own no
    -- evasion ring or cape, so those slots keep DT / TP pieces.
    -- 2026-10-18: Malignance Boots replace Herculean Boots - Eva+39, DT-4%.
    -- Missing, best first: Malignance Chapeau (91) /
    -- Tights (85), a Rosmerta's Cape with AGI+20 Eva+20 PDT-10%, Vengeful
    -- Ring, Sveltesse Gouriz +1; augment the Bathy Choker (Eva+15).
    sets.Evasion = {
        ammo="Amar Cluster",          -- Eva+10, Acc+10
        head="Herculean Helm",        -- Eva+55, AGI+25, Haste+8%
        body="Malignance Tabard",     -- Eva+102, AGI+42, DT-9%
        hands="Malignance Gloves",    -- Eva+80, AGI+24, DT-5%, Haste+4%
        legs="Volte Tights",          -- Eva+74, AGI+47, Haste+9%
        feet="Malignance Boots",      -- Eva+119, AGI+49, DT-4%, Haste+3%
        neck="Bathy Choker +1",       -- Eva+5~15 (Unity rank), Regen+3
        waist="Sveltesse Gouriz",     -- Eva+8, AGI+7
        left_ear="Eabani Earring",    -- Eva+15, Dual Wield+4
        right_ear="Infused Earring",  -- Eva+10, AGI+4
        left_ring="Defending Ring",   -- DT-10%
        right_ring="Murky Ring",      -- DT-10%
        back=ROSMERTA_TP,             -- no evasion cape owned
    }
    sets.TP.Eva = sets.Evasion

    sets.engaged = sets.TP.Normal

    ---------------------------------------------------------------------------
    -- Weapon skills
    ---------------------------------------------------------------------------

    -- SAVAGE BLADE - 50% STR / 50% MND, fTP on the FIRST hit, so Weapon
    -- skill damage is close to a straight multiplier (same as on your NIN).
    -- WSD: Cornelia's 10, Jhakri Cuffs +2 7, Assim. Jubbah +2 5, Herculean
    -- Boots 5 (aug), Oshasha's 3, Karieyh 3, Ishvara 2 = 35%.
    -- STR+MND by slot: Jhakri Coronal +1 49 (+Att38) beats Herculean Helm
    -- 53 (+Att16); Jhakri Slops +1 70 (+Att39) beats Herculean Trousers and
    -- Luhlaza Shalwar +1 (48, no WSD - that arrives at +2/+3).
    -- Assim. Jubbah +2 over Herculean Vest: STR+MND 62 vs 50, Acc+40 vs 28,
    -- and WSD+5% on top.
    -- Rosmerta's Cape over Amemet Mantle +1: Att+20 Acc+20 vs Att+15 STR+2.
    -- It's a TP cape (DEX, not STR) - a second Rosmerta's made STR/WSD is
    -- the guide's real Savage Blade cape.
    -- Guide's set for comparison: Hashishin Kavuk +3, Assim. Jubbah +3 /
    -- Gleti's, Nyame, Epaminondas's Ring.
    sets.precast.WS['Savage Blade'] = {
        ammo="Oshasha's Treatise",    -- WSD+3%
        head="Jhakri Coronal +1",     -- STR+28 MND+21, Att+38
        body="Assim. Jubbah +2",      -- WSD+5%, STR+34 MND+28, Acc+40
        hands="Jhakri Cuffs +2",      -- WSD+7%, MND+35, Att+43
        legs="Jhakri Slops +1",       -- STR+44 MND+26, Att+39
        feet="Herculean Boots",       -- WSD+5% (aug), Att+22
        neck="Rep. Plat. Medal",      -- STR+10, Att+30
        waist="Sailfi Belt +1",       -- Att+10~15 (Unity)
        left_ear="Telos Earring",     -- Moonshade below 1750 TP (Machaera)
        right_ear="Ishvara Earring",  -- WSD+2%
        left_ring="Cornelia's Ring",  -- WSD+10%, WS Acc+10
        right_ring="Karieyh Ring",    -- WSD+3%, WS Acc+5
        back=ROSMERTA_TP,             -- Acc/Att+20
    }

    -- SAVAGE BLADE, MAX ACCURACY - worn instead of the set above while TP
    -- mode is Acc (job_post_precast). Trades WSD for Accuracy: Tabard Acc+50
    -- over Jubbah +2 (Acc+40, WSD+5%), Chirich over Karieyh, Swift Belt over
    -- Sailfi, Peacock Amulet over the Medal. No Moonshade in this mode.
    -- Eschan Stone (Acc+15) replaced Swift Belt (Acc+3) on 2026-10-16.
    -- Cornelia's Ring stays: Weapon skill Accuracy+10 AND WSD+10%.
    sets.SavageAcc = {
        ammo="Oshasha's Treatise",    -- Acc+5, WSD+3%
        head="Jhakri Coronal +1",     -- Acc+38, STR+28 MND+21
        body="Malignance Tabard",     -- Acc+50
        hands="Jhakri Cuffs +2",      -- Acc+43, WSD+7%
        legs="Jhakri Slops +1",       -- Acc+39, STR+44 MND+26
        feet="Jhakri Pigaches +1",    -- Acc+36
        neck="Peacock Amulet",        -- Acc+10
        waist="Eschan Stone",         -- Acc+15, Att+15
        left_ear="Steelflash Earring",-- Acc+8
        right_ear="Telos Earring",    -- Acc+10
        left_ring="Cornelia's Ring",  -- WS Acc+10, WSD+10%
        right_ring="Chirich Ring",    -- Acc+7
        back=ROSMERTA_TP,             -- Acc+20
    }

    -- SANGUINE BLADE - magical dark WS (MND 50 / STR 30), drains HP. Uses
    -- Naegling's MAB+16 / Magic Damage+217. TP only changes how much HP is
    -- drained, not damage, so Moonshade (MAB+4 here) is just filler.
    sets.precast.WS['Sanguine Blade'] = {
        ammo="Hydrocera",             -- MND+3, MAcc+6
        head="Jhakri Coronal +1",     -- MAB+38
        body="Psycloth Vest",         -- MAB+25, INT+32 MND+29
        hands="Jhakri Cuffs +2",      -- MAB+40, WSD+7%
        legs="Jhakri Slops +1",       -- MAB+39
        feet="Jhakri Pigaches +1",    -- MAB+36
        neck="Sibyl Scarf",           -- MAB+10, INT+10
        waist="Eschan Stone",         -- MAB+7, MAcc+7
        left_ear="Moonshade Earring", -- MAB+4 (augment)
        right_ear="Moldavite Earring",-- MAB+5
        left_ring="Archon Ring",      -- dark MAB+5
        right_ring="Cornelia's Ring", -- WSD+10%
        back=ROSMERTA_INT,            -- INT+8, Magic Damage+2. Cornflower Cape
                                      -- (MAB+15) is better but it's in the CASE
    }

    -- Low-TP overlay: TP Bonus +250 (wasted at the 3000 cap). Goes on only
    -- when TP + the off-hand's TP Bonus is under 2750 - with Machaera +2
    -- that means under 1750 TP (see job_post_precast).
    sets.MoonshadeWS = {left_ear="Moonshade Earring"}

    ---------------------------------------------------------------------------
    -- Precast. Fast Cast is thin: Herculean Helm 7, Naji's Loop 1 = 8%
    -- (Dread Jupon's 7% left the bags by 2026-10-17). Erratic Flutter's
    -- Fast Cast trait adds to it. The guide caps at 80% with Carmine,
    -- Luhlaza Jubbah, Leyline Gloves, Rosmerta's (FC) - none owned.
    ---------------------------------------------------------------------------

    -- 2026-10-21 optimizer pass: the other slots were empty. Filled with DT
    -- pieces that cost no fast cast: still 8%, now DT-36% while casting.
    sets.precast.FC = {
        head="Herculean Helm",        -- Fast Cast+7%
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Volte Tights",
        feet="Malignance Boots",
        neck="Elite Royal Collar",
        waist="Plat. Mog. Belt",
        back="Grounded Mantle",
        left_ring="Murky Ring",
        right_ring="Naji's Loop",     -- Fast Cast+1%
    }

    -- Blue magic: Hashishin Mintan +1's Blue magic casting time -14%.
    sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, {
        body="Hashishin Mintan +1",
    })

    ---------------------------------------------------------------------------
    -- Blue magic midcast
    ---------------------------------------------------------------------------

    -- Default for anything unmapped: magic accuracy (debuffs).
    -- MAcc: Tabard 50, Malignance Gloves 50, Slops +1 39, Coronal +1 38,
    -- Pigaches +1 36, Erra Pendant 17, Cornflower 15, Eschan Stone 7,
    -- Jhakri Ring 6, Hydrocera 6, Hashishin Earring 6 (augment), Vertigo
    -- Ring 5 - plus Naegling's MAcc+40.
    sets.midcast['Blue Magic'] = {
        ammo="Hydrocera",
        head="Jhakri Coronal +1",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Jhakri Slops +1",
        feet="Jhakri Pigaches +1",
        neck="Erra Pendant",
        waist="Eschan Stone",         -- MAcc+7
        right_ear="Hashishin Earring",-- MAcc+6 (augment), RIGHT EAR ONLY
        left_ring="Jhakri Ring",
        right_ring="Vertigo Ring",
        back="Cornflower Cape",       -- CASE - until moved, slot unchanged
    }
    -- No .MagicAcc subtable on purpose: Mote falls back to this base set when
    -- the map has no table, and pointing a subtable back at its own parent
    -- would make the set contain itself.

    -- PHYSICAL spells. Mostly STR (Heavy Strike, Empty Thrash, Vertical
    -- Cleave 50%), STR/VIT (Sinker Drill, Delta Thrust, Quad. Continuum), or
    -- DEX (Barbed Crescent, Vanity Dive, Sickle Slash) - plus accuracy and
    -- attack to land and hit hard. Jhakri covers STR, DEX, Acc and Att at
    -- once, so one set serves all of them.
    -- Waist: Eschan Stone (Acc/Att+15) over Sailfi - physical spells can't
    -- proc multi-attacks, so Sailfi's Triple Attack does nothing here.
    -- Guide's set: Luhlaza +3, Ifrit Ring +1, Shukuyu Ring, Prosilio Belt +1.
    sets.midcast['Blue Magic'].Physical = {
        ammo="Coiste Bodhar",
        head="Jhakri Coronal +1",     -- STR+28 DEX+24, Acc/Att+38
        body="Assim. Jubbah +2",      -- STR+34 DEX+39, Acc+40, Blue magic skill+22
        hands="Jhakri Cuffs +2",      -- STR+18 DEX+41, Acc/Att+43
        legs="Jhakri Slops +1",       -- STR+44, Acc/Att+39
        feet="Jhakri Pigaches +1",    -- STR+22 DEX+25, Acc/Att+36
        neck="Rep. Plat. Medal",      -- STR+10, Att+30
        waist="Eschan Stone",         -- Acc/Att+15
        left_ear="Telos Earring",     -- Acc/Att+10
        right_ear="Bladeborn Earring",-- Att+8
        left_ring="Rajas Ring",       -- STR/DEX+5
        right_ring="Petrov Ring",     -- STR/DEX+3
        back=ROSMERTA_TP,             -- DEX+20, Acc/Att+20
    }

    -- Chain Affinity overlay (job_post_midcast): Hashishin Kavuk +1's
    -- "Chain Affinity"+24 raises the physical spell's damage, and like all
    -- the BLU JSE ability pieces it counts when it's ON for the spell, not
    -- for the ability itself.
    sets.ChainAffinity = {head="Hashishin Kavuk +1"}

    -- //gs c learn: raises the chance to learn a spell when the mob dies.
    sets.Learn = {hands="Magus Bazubands"}

    -- //gs c th: Treasure Hunter +3, everything BLU can wear that has it.
    -- (Valorous Hose's TH+1 is WAR/PLD/DRK/BST/SAM/DRG only.) On Dream
    -- Flower it costs about 44 magic accuracy (Coronal head, Cuffs' extra 6,
    -- Hydrocera) - if the sleep gets resisted, that mob isn't tagged; recast.
    sets.TH = {
        ammo="Per. Lucky Egg",        -- TH+1, wardrobe
        head="Wh. Rarab Cap +1",      -- TH+1, wardrobe 2
        hands="Volte Bracers",        -- TH+1, wardrobe 3
    }

    -- MAGICAL nukes. INT for most; MND for Diffusion Ray, Rail Cannon,
    -- Scouring Spate, Evryone. Grudge - Jhakri carries both. The guide warns
    -- Jhakri is weak for this vs Hashishin / Amalric, but it's what you own
    -- and it beats everything else in your bags by a wide margin.
    -- Pair it with //gs c nuke (Kaja Rod + Culminus) for real damage.
    sets.midcast['Blue Magic'].Magical = {
        ammo="Ghastly Tathlum +1",    -- Magic Damage+11 (2026-10-18)
        head="Jhakri Coronal +1",     -- MAB+38, INT+33
        body="Psycloth Vest",         -- MAB+25, INT+32
        hands="Jhakri Cuffs +2",      -- MAB+40, INT+36
        legs="Jhakri Slops +1",       -- MAB+39, INT+49
        feet="Jhakri Pigaches +1",    -- MAB+36, INT+30
        neck="Sibyl Scarf",           -- MAB+10, INT+10
        waist="Eschan Stone",         -- MAB+7, MAcc+7
        left_ear="Moonshade Earring", -- MAB+4 (augment)
        right_ear="Moldavite Earring",-- MAB+5
        left_ring="Acumen Ring",      -- MAB+4, INT+2
        right_ring="Jhakri Ring",     -- MAB+3
        back="Cornflower Cape",       -- MAB+15. CASE - INT Rosmerta's until moved
    }

    -- HEALING (Magic Fruit, Wild Carrot, Plenilune Embrace). MND first,
    -- VIT second, then cure potency - you own almost none of the last.
    sets.midcast['Blue Magic'].Healing = {
        ammo="Hydrocera",             -- MND+3
        head="Jhakri Coronal +1",     -- MND+21
        body="Psycloth Vest",         -- MND+29
        hands="Malignance Gloves",    -- MND+42
        legs="Jhakri Slops +1",       -- MND+26
        feet="Jhakri Pigaches +1",    -- MND+21
        left_ring="Solemn Ring",      -- MND+5 (beats Naji's Loop's Cure potency+1%)
        right_ring="Vertigo Ring",    -- MND+5
        back="Pahtli Cape",           -- MND+8
    }

    -- BLUE MAGIC SKILL (Occultation shadows, Magic Barrier, Diamondhide,
    -- Metallic Body, drains). Three skill pieces, two of them packed away.
    sets.midcast['Blue Magic'].Skill = {
        body="Assim. Jubbah +2",      -- Blue magic skill+22 (beats Magus Jubbah's +15)
        right_ear="Hashishin Earring",-- skill+10, RIGHT EAR ONLY
        back="Cornflower Cape",       -- skill+5. CASE - move it
    }

    -- BREATH (and White Wind): damage / healing from YOUR max HP.
    sets.midcast['Blue Magic'].Breath = {
        body="Malignance Tabard",     -- HP+68
        hands="Malignance Gloves",    -- HP+57, same as Volte, plus DT-5%
        legs="Volte Tights",          -- HP+118
        waist="Plat. Mog. Belt",      -- HP+10%
    }

    -- Flat buffs (Cocoon, Erratic Flutter, Nat. Meditation, Barrier Tusk,
    -- Mighty Guard ...): no gear changes them, so take hits in DT gear.
    sets.midcast['Blue Magic'].Buff = sets.TP.DT

    ---------------------------------------------------------------------------
    -- Idle. Assim. Jubbah +2's Refresh+2 is your only refresh, and BLU
    -- burns MP fast, so it takes the body from Malignance Tabard (DT-9%).
    -- DT-33%: Malignance Gloves -5, Elite Royal Collar -5, Defending -10, Murky -10, Plat. Mog.
    -- Belt -3 (plus Battlecast Gaiters' Physical DT-3%). -50% isn't reachable
    -- with what you own either way (the Tabard only made it -37%). If you're
    -- idling somewhere dangerous, put the Tabard back on this body line.
    -- Crimson Cuisses for movement speed.
    ---------------------------------------------------------------------------

    -- 2026-10-21 optimizer pass: Malignance Chapeau (DT-6%) for the Herculean
    -- Helm takes DT -37% -> -43%. The optimizer's full pick (-48%) also took
    -- the Jubbah and Crimson Cuisses off - refresh and movement speed it
    -- doesn't value - so only the head went in.
    sets.idle = {
        ammo="Coiste Bodhar",
        head="Malignance Chapeau",    -- DT-6%, was Herculean Helm
        body="Assim. Jubbah +2",      -- Refresh+2
        hands="Malignance Gloves",    -- DT-5%, HP+57
        legs="Crimson Cuisses",       -- Movement speed+12%
        feet="Malignance Boots",      -- DT-4%, Magic Evasion+150 (was Battlecast PDT-3%)
        neck="Elite Royal Collar",    -- DT-5%
        waist="Plat. Mog. Belt",      -- DT-3%, HP+10%
        left_ear="Suppanomimi",
        right_ear="Telos Earring",
        left_ring="Defending Ring",   -- DT-10%
        right_ring="Murky Ring",      -- DT-10%
        back=ROSMERTA_TP,
    }
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

local function tp_set()
    local set = sets.TP[state.TPMode.value] or sets.TP.Normal
    if state.BonkMode.value then
        set = set_combine(set, sets.TH)
    end
    if state.LearnMode.value then
        set = set_combine(set, sets.Learn)
    end
    return set
end

function customize_idle_set(idleSet)
    -- Pulling happens unengaged, so Eva mode also takes over idle.
    if state.TPMode.value == 'Eva' then
        idleSet = set_combine(idleSet, sets.Evasion)
    end
    if state.LearnMode.value then
        idleSet = set_combine(idleSet, sets.Learn)
    end
    return idleSet
end

-- TP Bonus on the weapons, by the name GearSwap reports in main/sub.
WEAPON_TP_BONUS = {['Machaera +2'] = 1000}

local function weapon_tp_bonus()
    local eq = player.equipment
    return (WEAPON_TP_BONUS[eq.main] or 0) + (WEAPON_TP_BONUS[eq.sub] or 0)
end

function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.english == 'Savage Blade' and state.TPMode.value == 'Acc' then
        equip(sets.SavageAcc)
    elseif spell.type == 'WeaponSkill' and player.tp + weapon_tp_bonus() < 2750 then
        equip(sets.MoonshadeWS)
    end
end

-- True if GearSwap can equip the item right now (inventory or a wardrobe).
local EQUIP_BAGS = {'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
                    'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}
local function equippable(name)
    for _, bag in ipairs(EQUIP_BAGS) do
        if player[bag] and player[bag][name] then
            return true
        end
    end
    return false
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Dark nukes (Tenebral Crush, Dark Orb, Evryone. Grudge): Archon Ring.
    if spellMap == 'Magical' and spell.element == 'Dark' then
        equip({left_ring="Archon Ring"})
    end
    -- Cornflower Cape still in the case: nukes take the INT Rosmerta's
    -- instead of keeping whatever cape was on.
    if spellMap == 'Magical' and not equippable('Cornflower Cape') then
        equip({back=ROSMERTA_INT})
    end
    -- Physical spell cast under Chain Affinity: Hashishin Kavuk.
    if spellMap == 'Physical' and buffactive['Chain Affinity'] then
        equip(sets.ChainAffinity)
    end
    -- TH mode: tag the pack with a no-damage AoE sleep.
    if state.THMode.value and TH_TAG_SPELLS:contains(spell.english) then
        equip(sets.TH)
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spellMap == 'Magical' and state.MagicBurstMode.value == 'Single' then
        state.MagicBurstMode:set('Off')
    end
end

function job_handle_equipping_gear(playerStatus, eventArgs)
    if playerStatus == 'Engaged' then
        equip(tp_set())
        eventArgs.handled = true
    end
end

function job_self_command(cmdParams, eventArgs)
    local cmd = cmdParams[1] and cmdParams[1]:lower() or ''

    if cmd == 'savage' or cmd == 'sword' then
        equip(sets.weapons.Savage)
        add_to_chat(122, 'GearSwap: Naegling + Machaera +2 (TP Bonus +1000)')

    elseif cmd == 'nibiru' then
        equip(sets.weapons.Nibiru)
        add_to_chat(122, 'GearSwap: Naegling + Nibiru Blade')

    elseif cmd == 'nuke' then
        equip(sets.weapons.Nuke)
        add_to_chat(122, 'GearSwap: Kaja Rod + Culminus (nuke) - //gs c savage to go back')

    elseif cmd == 'dt' then
        state.TPMode:set('DT')
        if player.status == 'Engaged' then equip(tp_set()) end
        add_to_chat(122, 'GearSwap: TP mode = DT (-34%)')

    elseif cmd == 'acc' then
        state.TPMode:set('Acc')
        if player.status == 'Engaged' then equip(tp_set()) end
        add_to_chat(122, 'GearSwap: TP mode = Acc (max accuracy TP + Savage Blade)')

    elseif cmd == 'eva' then
        state.TPMode:set('Eva')
        if player.status == 'Engaged' then equip(tp_set()) else send_command('gs c update') end
        add_to_chat(122, 'GearSwap: TP mode = Eva (evasion set engaged + idle)')

    elseif cmd == 'learn' then
        state.LearnMode:toggle()
        if player.status == 'Engaged' then equip(tp_set()) else send_command('gs c update') end
        add_to_chat(122, 'GearSwap: learn mode (Magus Bazubands) = '
            .. (state.LearnMode.value and 'ON' or 'OFF'))

    elseif cmd == 'th' then
        state.THMode:toggle()
        add_to_chat(122, 'GearSwap: TH mode ' .. (state.THMode.value and 'ON' or 'OFF')
            .. (state.THMode.value and ' (TH+3; Dream Flower / Sheep Song tag the pack)' or ''))

    elseif cmd == 'bonk' then
        state.BonkMode:toggle()
        if player.status == 'Engaged' then equip(tp_set()) end
        add_to_chat(122, 'GearSwap: bonk TH mode ' .. (state.BonkMode.value and 'ON' or 'OFF')
            .. (state.BonkMode.value and ' (TH+3 over TP set while engaged)' or ''))

    elseif cmd == 'normal' or cmd == 'tp' then
        state.TPMode:set('Normal')
        if player.status == 'Engaged' then equip(tp_set()) end
        add_to_chat(122, 'GearSwap: TP mode = Normal')
    end
end

-- Lockstyle, same as your other jobs. Macro book 8 is a guess - set it to
-- your BLU book.
LOCKSTYLE_SET = 39

function select_default_macro_book()
    set_macro_page(1, 8)
    add_to_chat(122, 'GearSwap: macro book 8 page 1 for BLU')
    if LOCKSTYLE_SET and LOCKSTYLE_SET > 0 then
        add_to_chat(122, 'GearSwap: applying lockstyleset ' .. LOCKSTYLE_SET
            .. ' for ' .. (player and player.main_job or '?') .. ' (5s delay)')
        send_command('wait 5; input /lockstyleset ' .. LOCKSTYLE_SET
            .. '; wait 2; input /echo GearSwap: lockstyleset ' .. LOCKSTYLE_SET .. ' sent.')
    end
end
