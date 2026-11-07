-- PUP GearSwap (Char1) - Hand-to-Hand master + automaton
--
-- Built 2026-10-08 from the gearinfo dump (addons/gearinfo/data/Char1_data.lua)
-- and findAll's bag list (addons/findAll/data/Char1.lua), following the BG-Wiki
-- Community Puppetmaster Guide. Every item named below is one you own.
--
-- MOVE CHECKLIST (rechecked against the 2026-10-11 export). Denouements,
-- Guignol Earring, Pantin Taj and Oshasha's Treatise are now in inventory.
-- Still out of reach - GearSwap skips the slot until it's moved:
--   Cornelia's Belt     storage  WS waist (STR+10); Haste+10% too
-- No longer in ANY bag (sold / used up?) - the sets that name them just skip:
--   Nibiru Sainti       "Repair" potency +10% (//gs c nibiru does nothing)
--   Automaton oil       none of any grade left - Repair gets no oil bonus and
--                       the ammo slot falls back to Oshasha's / Lucky Egg.
--                       Buy Automat. Oil +3.
--
-- Pet modes (what you're doing while the automaton fights):
--   Master   you are the damage. Full master TP set.
--   Hybrid   both swinging. Master TP set with the pet accuracy pieces in.
--   Tank     the automaton is tanking. Master DT + automaton regen/haste.
--
-- What isn't here, and why. The guide's pet sets lean on gear you don't own
-- yet - nothing you have carries Pet: Attack, Pet: Damage taken or automaton
-- weapon skill damage. The sets below are the best of what you DO own; the
-- comments on each say what the guide would put there instead.
--
-- 2026-10-31: full Mpaca's set (Cap, Doublet, Gloves, Hose, Boots - unranked,
-- wardrobe). The first pet gear Char1 owns: every piece is Pet: Acc/RAcc/
-- MAcc+50, the Gloves add Automaton: WS damage+10% and the Boots Automaton:
-- Lv+1. On the master side: TA+3~4%, Crit+3~7%, PDT-6~10%, Acc/Atk+40 each.
-- Where it went (stat priority + the PUP guide's 2026 sim sets, not the
-- optimizer - the 2026-10-21 figures below describe the sets before Mpaca):
--   Hybrid TP, pet-engaged idle, automaton WS: all five pieces
--   Master TP: Doublet + Hose (Malignance head/hands kept for accuracy)
--   Master WS: Cap everywhere (Hiza. Somen +2 back at 3000 TP); Victory
--     Smite full set; Hose / Doublet on the multi-hit WS
--   Idle: Gloves + Hose
--
-- Commands:
--   //gs c den | claws | ninzas | nibiru   weapon (+ Animator P)
--   //gs c master | hybrid | tank          pet mode
--   //gs c dt          toggle master DT overlay
--   //gs c petws       toggle the automaton weapon skill swap (default ON)
--   //gs c th          toggle Treasure Hunter (hands locked; egg + ammo only when out of oil)

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function user_setup()
    state.PetMode = M{['description']='Pet Mode', 'Master', 'Hybrid', 'Tank'}
    sync_weapon_mode()
end

function job_setup()
    state.WeaponMode = M{['description']='Weapon', 'Denouements', 'Claws', 'Ninzas', 'Nibiru'}
    watch_pet_tp()
    -- Put the animator on straight after a job change, not just on the next
    -- status change.
    send_command('wait 2; gs c update')
end

-- Maneuvers, Activate and Deploy all need an animator in the range slot.
-- Every set GearSwap equips carries it, so it goes on by itself after a job
-- change. GearSwap skips a slot that already holds the item, so this never
-- re-equips it (or touches your TP) once it's on.
ANIMATOR = "Animator P"   -- Automaton: Lv119, all stats +15

-- The ammo slot belongs to the oil. While you have any oil in inventory or a
-- wardrobe, every swap (WS, TH, Repair, idle, engaged) gets the oil forced
-- into ammo - the one already loaded if it's an oil, otherwise the best one
-- you carry. Only once you're out of oil do Oshasha's / the Lucky Egg go in.
OILS = {"Automat. Oil +3", "Automat. Oil +2", "Automat. Oil +1", "Automaton Oil"}
EQUIP_BAGS = {'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
              'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}

function carries(name)
    for _, bag in ipairs(EQUIP_BAGS) do
        local item = player[bag] and player[bag][name]
        if item and (item.count or 0) > 0 then return true end
    end
    return false
end

-- Range + ammo pieces laid over everything GearSwap equips.
function slot_guard()
    local guard = {range=ANIMATOR}
    local ammo = player.equipment and player.equipment.ammo
    for _, oil in ipairs(OILS) do
        if ammo == oil then guard.ammo = oil return guard end
    end
    for _, oil in ipairs(OILS) do
        if carries(oil) then guard.ammo = oil return guard end
    end
    return guard
end

function has_oil()
    return slot_guard().ammo ~= nil
end

-- Weapons this lua knows about, by the name GearSwap reports in main.
WEAPON_BY_MAIN = {
    ['Denouements']   = 'Denouements',
    ['Calved Claws']  = 'Claws',
    ['Ninzas +2']     = 'Ninzas',
    ['Nibiru Sainti'] = 'Nibiru',
}

function sync_weapon_mode()
    local main = player and player.equipment and player.equipment.main
    local mode = WEAPON_BY_MAIN[main or '']
    if mode and state.WeaponMode.value ~= mode then
        state.WeaponMode:set(mode)
    end
end

function init_gear_sets()

    ---------------------------------------------------------------------------
    -- Weapons. The only sets that touch main/range, equipped only by command.
    -- Animator P rides along with every weapon (and every other set, via
    -- slot_guard). Animator Z, Em. Animator and the old Animator are no longer used.
    ---------------------------------------------------------------------------
    sets.weapons = {}
    -- DMG+165 Delay+126, Quadruple Attack+3%, Automaton Regen+4 Refresh+4.
    sets.weapons.Denouements = {main="Denouements", range=ANIMATOR}
    -- DMG+114, Accuracy+20, DEX/INT+12.
    sets.weapons.Claws = {main="Calved Claws", range=ANIMATOR}
    -- DMG+104, no stats. Fallback only - Denouements is in inventory now.
    sets.weapons.Ninzas = {main="Ninzas +2", range=ANIMATOR}
    -- DMG+124, Store TP+4, Repair potency+10% - the guide's tank alternative.
    -- Not in any bag as of the 2026-10-11 export; kept for if you get it back.
    sets.weapons.Nibiru = {main="Nibiru Sainti", range=ANIMATOR}

    ---------------------------------------------------------------------------
    -- Engaged (you are swinging). No main/range, no ammo - the ammo slot is
    -- left alone so a Repair oil stays loaded.
    ---------------------------------------------------------------------------
    sets.engaged = {}

    -- Guide: Herculean TA set, Shulmanu Collar, Cessance, Epona's / Niqmaddu,
    -- Moonbow Belt +1, Visucius's Mantle. Yours:
    --   gear haste: Somen 6 + Vest 4 + Kote 4 + Samnuha 6 + Malig. Boots 3 + Swift 4 = 27% (cap 25)
    --   Triple Attack: Vest 3 (aug) + Samnuha 2 (aug) = 5% (Malignance Boots trade Herculean's TA+2 for STP+9, DT-4%)
    --   Double Attack: Samnuha 3 + Brutal 5 + Telos 1 + Petrov 1 = 10%
    --   Martial Arts+13 from the Somen - faster H2H swings.
    -- 2026-10-21: the original Master gear is kept as MASTER_BASE because
    -- Hybrid and Tank are built from it. sets.engaged.Master takes the
    -- GearSwap-Optimizer upgrade below.
    local MASTER_BASE = {
        head="Hiza. Somen +2",
        body="Herculean Vest",
        hands="Hizamaru Kote +2",
        legs="Samnuha Tights",
        feet="Malignance Boots",      -- 2026-10-18: STP+9, Acc+50, DT-4%, Haste+3% (guide's pick)
        -- Rechecked 2026-10-10: these two ARE your best owned TP neck/waist.
        -- Medal: STR+10 Attack+30 (+ Regain+2 if Bastok citizen); the only
        -- other necks are Peacock Amulet (Acc+10) and DT/pet pieces.
        -- Swift Belt's Haste+4% takes you from 24% to the gear haste cap.
        -- Upgrades to buy: Shulmanu Collar / Lissome Necklace / Combatant's
        -- Torque; Moonbow Belt +1 / Windbuffet Belt +1 / Kentarch Belt +1.
        neck="Rep. Plat. Medal",
        waist="Swift Belt",
        left_ear="Telos Earring",
        right_ear="Brutal Earring",
        left_ring="Chirich Ring",
        right_ring="Petrov Ring",
        back="Dispersal Mantle",
    }

    -- MASTER after the 2026-10-21 optimizer pass: TP 10.55s -> 8.57s, DT
    -- -4% -> -29%, hit rate vs an Apex Toad 61% -> 97%. Malignance Chapeau,
    -- Tabard and Gloves, Elite Royal Collar, Bladeborn + Steelflash. Costs the
    -- Somen's Martial Arts+13. The ammo slot is still left alone (Repair oil).
    -- 2026-10-31: Mpaca's Doublet (TA+4% Crit+7% PDT-10% Counter+10) over the
    -- Tabard and Mpaca's Hose (TA+4% Crit+6% PDT-9% Haste+9%) over Samnuha.
    -- Head and hands stay Malignance: Acc+50 vs +40, and accuracy is what the
    -- optimizer pass showed this set was short of.
    sets.engaged.Master = set_combine(MASTER_BASE, {
        head="Malignance Chapeau",
        body="Mpaca's Doublet",
        hands="Malignance Gloves",
        legs="Mpaca's Hose",
        neck="Elite Royal Collar",
        left_ear="Bladeborn Earring",
        right_ear="Steelflash Earring",
    })

    -- Your only Pet: Accuracy pieces go in. Both keep their slot's haste, so
    -- you stay at 28% gear haste.
    --   Naga Hakama       Pet: Acc/RAcc+20, Haste+6%     (costs Samnuha's DA/TA/STP)
    --   Foire Bab. +1     Automaton: Haste+3%, Haste+4%  (costs Herculean's TA+2)
    --   Murky Ring        Pet: Acc/RAcc/MAcc+15, DT-10%  (costs Petrov)
    -- 2026-10-31: full Mpaca's - Pet: Acc+50 per piece (Naga's was +20) and
    -- master TA/crit at the same time. Gear haste: 6+4+4+9+3 + Swift Belt 4
    -- = 30%, still over the cap. Foire Bab. +1's Automaton Haste+3% is the
    -- one thing given up.
    sets.engaged.Hybrid = set_combine(MASTER_BASE, {
        head="Mpaca's Cap",
        body="Mpaca's Doublet",
        hands="Mpaca's Gloves",
        legs="Mpaca's Hose",
        feet="Mpaca's Boots",
        right_ring="Murky Ring",
    })

    -- Guide's tank set is Rao +1 (Path C), Anwig Salade, Tali'ah Crackows +1,
    -- Handler's Earrings, Isa Belt, Thurandaut / Varar rings - all Pet: DT.
    -- You own no Pet: DT gear at all, so this keeps YOU alive (-37%) and
    -- gives the automaton what you have: haste, accuracy, regen.
    --   DT: Malignance 9 + Elite Royal Collar 5 + Murky 10 + Defending 10 + Plat. Mog 3
    sets.engaged.Tank = set_combine(sets.engaged.Hybrid, {
        head="Pantin Taj",
        body="Malignance Tabard",
        neck="Elite Royal Collar",
        waist="Plat. Mog. Belt",
        left_ring="Defending Ring",
    })

    -- //gs c dt - laid over Master or Hybrid. -34% (Malignance 9, Collar 5,
    -- Defending 10, Murky 10). Malignance keeps the Vest's Haste+4%, so
    -- you're still haste capped.
    sets.DTOverlay = {
        body="Malignance Tabard",
        neck="Elite Royal Collar",
        left_ring="Defending Ring",
        right_ring="Murky Ring",
    }

    -- Worn over the idle set only while running (see 'gearinfo' in
    -- job_self_command). Standing still keeps the DT legs below.
    sets.Kiting = {legs="Track Pants +1"}   -- Movement speed +8% (2026-10-31)

    ---------------------------------------------------------------------------
    -- Idle.
    ---------------------------------------------------------------------------
    -- IDLE_BASE is the pre-2026-10-21 idle; the three pet idle sets below are
    -- still built from it. sets.idle takes the optimizer upgrade.
    local IDLE_BASE = {
        head="Hiza. Somen +2",
        body="Malignance Tabard",
        hands="Mpaca's Gloves",       -- PDT-8% (2026-10-31; was Hizamaru Kote +2)
        legs="Mpaca's Hose",          -- PDT-9% (2026-10-31; was Hiza. Hizayoroi +2)
        feet="Malignance Boots",      -- DT-4%, Magic Evasion+150
        neck="Elite Royal Collar",
        waist="Plat. Mog. Belt",
        left_ear="Telos Earring",
        right_ear="Brutal Earring",
        left_ring="Defending Ring",
        right_ring="Murky Ring",
        back="Dispersal Mantle",
    }

    -- 2026-10-21 optimizer pass: DT -41% -> -48%, PDT -5%. Malignance Chapeau
    -- and Gloves, Herculean Trousers, Battlecast Gaiters, Eabani + Infused.
    -- 2026-10-31: legs are Mpaca's Hose from IDLE_BASE (PDT-9%) instead of
    -- Herculean Trousers (PDT-2%).
    sets.idle = set_combine(IDLE_BASE, {
        head="Malignance Chapeau",
        hands="Malignance Gloves",
        feet="Battlecast Gaiters",
        left_ear="Eabani Earring",
        right_ear="Infused Earring",
    })

    -- Automaton out, not fighting: give it regen while it waits.
    sets.idle.Pet = set_combine(IDLE_BASE, {
        head="Pantin Taj",
    })

    -- You standing, automaton fighting (pet-only play: Deploy, don't engage).
    -- Guide's "PET DD BUILD" is Pitre Tobe +1, Herculean with Pet STP,
    -- Enmerkar / Domes. earrings, Varar Ring +1 x2, Klouskap Sash +1,
    -- Visucius's Mantle (pet). Yours: everything with "Pet:" or "Automaton:"
    -- on it, with your own DT on the rest.
    -- 2026-10-31: full Mpaca's - Pet: Acc/RAcc/MAcc+250 total, and PDT-40%
    -- for you while you stand there.
    sets.idle.PetEngaged = set_combine(IDLE_BASE, {
        head="Mpaca's Cap",
        body="Mpaca's Doublet",
        hands="Mpaca's Gloves",
        legs="Mpaca's Hose",
        feet="Mpaca's Boots",        -- Automaton: Lv.+1
        neck="Adad Amulet",          -- DT-4%, Pet: MAcc+20 MAB+10
    })

    -- Same, while the automaton tanks: regen head on too.
    sets.idle.PetTank = set_combine(sets.idle.PetEngaged, {
        head="Pantin Taj",
    })

    ---------------------------------------------------------------------------
    -- Automaton weapon skill. Laid over whatever you're wearing while the
    -- automaton's TP is about to fire one (see watch_pet_tp below). Keyed by
    -- HEAD, since the head decides the WS. Every head gets the same pieces
    -- for now. 2026-10-31: full Mpaca's - Gloves' Automaton: WS damage+10% is
    -- your first automaton WS damage piece, and every piece is Pet: Acc+50 so
    -- the WS lands. Still no Pet: Attack or Pet TP Bonus gear; when you get it
    -- (guide: Karagoz / Pitre / Taeon with Pet augments; Xiucoatl for
    -- Valoredge, Karagoz Mantle etc.), add sets.PetWS['Valoredge Head'] = {...}.
    ---------------------------------------------------------------------------
    sets.PetWS = {}
    sets.PetWS.default = {
        head="Mpaca's Cap",
        body="Mpaca's Doublet",
        hands="Mpaca's Gloves",       -- Automaton: Weapon skill damage +10%
        legs="Mpaca's Hose",
        feet="Mpaca's Boots",         -- Automaton: Lv.+1
        right_ring="Murky Ring",
    }

    -- Automaton nukes (Spiritreaver / Stormwaker heads). Adad Amulet is your
    -- only pet magic piece.
    sets.PetNuke = {neck="Adad Amulet"}

    ---------------------------------------------------------------------------
    -- Job abilities (laid on in job_post_precast).
    ---------------------------------------------------------------------------
    sets.precast.JA = {}
    -- Repair eats the oil in the ammo slot - no oil, no Repair bonus. The oil
    -- itself comes from slot_guard(), so it's whichever one you're carrying.
    sets.precast.JA.Repair = {
        left_ear="Guignol Earring",  -- Repair potency
        feet="Foire Bab. +1",        -- "Repair"+2
    }
    -- Dispersal Mantle: "Reduces Overload rate". Guide upgrade: Visucius's
    -- Mantle / Karagoz Mantle (Maneuver +), Kara. Guanti +1 (Maneuver +).
    sets.precast.Maneuver = {
        back="Dispersal Mantle",
    }

    ---------------------------------------------------------------------------
    -- Master weapon skills. Moonshade goes on in job_post_precast below 2750
    -- TP; it lands in LEFT ear, so every WS set keeps its best ear on the right.
    ---------------------------------------------------------------------------
    sets.precast.WS = {
        ammo="Oshasha's Treatise",
        head="Mpaca's Cap",          -- "TP Bonus"+200, STR+33 Atk+40 (2026-10-31; Somen at 3000 TP)
        body="Hiza. Haramaki +2",
        hands="Hizamaru Kote +2",
        legs="Hiza. Hizayoroi +2",   -- STR+50, WSD+7%
        feet="Herculean Boots",      -- WSD+5% (aug)
        neck="Rep. Plat. Medal",     -- STR+10 Attack+30
        -- STR+10, no Attack-5 like the Swift Belt. Sits in STORAGE: until it's
        -- moved, GearSwap skips it and the TP set's Swift Belt stays on.
        waist="Cornelia's Belt",
        left_ear="Telos Earring",
        right_ear="Ishvara Earring",
        left_ring="Cornelia's Ring", -- WSD+10%
        right_ring="Karieyh Ring",   -- WSD+3%
        back="Dispersal Mantle",
    }

    -- STR, crit. Guide: Verethragna, Rancor Collar, Abnoba Kaftan, Ryuo Tekko +1.
    -- The Vest is your only crit body (+3%). Light Gorget / Belt: Victory
    -- Smite is a Light skillchain WS, so they fire.
    -- 2026-10-31: the guide's sim set is full Mpaca's - Crit+25% across the
    -- five pieces, replacing the Vest's +3%.
    sets.precast.WS['Victory Smite'] = set_combine(sets.precast.WS, {
        body="Mpaca's Doublet",
        hands="Mpaca's Gloves",
        legs="Mpaca's Hose",
        feet="Mpaca's Boots",
        neck="Light Gorget",
        waist="Light Belt",
    })

    -- DEX, multi-hit. Malignance (DEX+49, Acc+50) over the Haramaki,
    -- Samnuha (DEX, DA/TA) over the Hizayoroi. Fusion skillchain = Light gorget.
    -- 2026-10-31 optimizer pass: Mpaca's Doublet, Malignance Gloves, Mpaca's
    -- Boots. +46.6% unbuffed, +16.8% buffed (some of that came from ear and
    -- Light Gorget/Belt swaps that weren't applied - the optimizer doesn't
    -- model the gorget/belt fTP bonus).
    sets.precast.WS['Shijin Spiral'] = set_combine(sets.precast.WS, {
        body="Mpaca's Doublet",
        hands="Malignance Gloves",
        legs="Mpaca's Hose",         -- 2026-10-31: guide's Shijin legs, TA+4% (was Samnuha)
        feet="Mpaca's Boots",
        neck="Light Gorget",
        waist="Light Belt",
    })

    -- STR/DEX multi-hit; WSD sets above are wrong for these 15%-STR-mod
    -- 8-hit / 5-hit WS - take the TP set's DA/TA instead.
    sets.precast.WS['Raging Fists'] = set_combine(sets.precast.WS, {
        body="Mpaca's Doublet",      -- 2026-10-31: TA+4% Atk+40 (was Herculean Vest)
        legs="Mpaca's Hose",         -- 2026-10-31: TA+4% Atk+40 (was Samnuha)
        right_ear="Brutal Earring",
    })
    -- Asuran Fists (2026-10-31 optimizer pass): Malignance Gloves, Mpaca's
    -- Boots, and Hiza. Hizayoroi +2 back over the Hose. +41.6% unbuffed,
    -- +4.0% buffed. Raging Fists keeps the set above - the same swaps lost
    -- 5.5% buffed there.
    sets.precast.WS['Asuran Fists'] = set_combine(sets.precast.WS['Raging Fists'], {
        hands="Malignance Gloves",
        legs="Hiza. Hizayoroi +2",
        feet="Mpaca's Boots",
    })
    -- Howling Fist is Transfixion/Impaction - Light Gorget/Belt cover
    -- Transfixion, so they fire here too.
    -- 2026-10-31 optimizer pass: Mpaca's Doublet, Gloves and Boots too -
    -- +21.5% unbuffed, +7.7% buffed.
    sets.precast.WS['Howling Fist'] = set_combine(sets.precast.WS, {
        body="Mpaca's Doublet",
        hands="Mpaca's Gloves",
        legs="Mpaca's Hose",         -- 2026-10-31: guide's Howling Fist legs
        feet="Mpaca's Boots",
        neck="Light Gorget",
        waist="Light Belt",
    })

    sets.MoonshadeWS = {left_ear="Moonshade Earring"}

    -- Treasure Hunter +2: Per. Lucky Egg + Volte Bracers. PUP has no native TH.
    sets.TH = {
        ammo="Per. Lucky Egg",
        hands="Volte Bracers",
    }
end

-------------------------------------------------------------------------------
-- State
-------------------------------------------------------------------------------
DT_MODE = false
PET_WS_SWAP = true      -- //gs c petws
PET_WS_UP = false       -- true while the automaton is about to / is weapon skilling
TH_MODE = false
TH_SLOTS = {'ammo', 'hands'}

-- Automaton weapon skills fire at 1000 TP and have no ready time, so a
-- pet_midcast swap lands too late. The automaton's TP comes in packet 0x068
-- (GearSwap reads it from there too). Swap a little early.
PET_WS_TP = 900

AUTOMATON_WS = S{'Chimera Ripper', 'String Clipper', 'Arcuballista', 'Slapstick',
                 'Cannibal Blade', 'Daze', 'Knockout', 'Bone Crusher', 'Armor Piercer',
                 'Magic Mortar', 'String Shredder', 'Armor Shatterer'}

function user_unload()
    if TH_MODE then
        enable(TH_SLOTS)
    end
end

function pet_ws_set()
    return sets.PetWS[pet.head or ''] or sets.PetWS.default
end

-- The set for right now. Everything that equips "normal" gear comes here.
function current_set()
    local set
    if player.status == 'Engaged' then
        set = sets.engaged[state.PetMode.value] or sets.engaged.Master
        if DT_MODE and state.PetMode.value ~= 'Tank' then
            set = set_combine(set, sets.DTOverlay)
        end
    elseif pet.isvalid and pet.status == 'Engaged' then
        set = state.PetMode.value == 'Tank' and sets.idle.PetTank or sets.idle.PetEngaged
    elseif pet.isvalid then
        set = sets.idle.Pet
    else
        set = sets.idle
    end

    if PET_WS_UP and pet.isvalid then
        set = set_combine(set, pet_ws_set())
    end
    if TH_MODE then
        set = set_combine(set, sets.TH)
    end
    -- Running while not engaged: Track Pants +1 (see 'gearinfo' in job_self_command).
    if gearinfo_moving and player.status ~= 'Engaged' then
        set = set_combine(set, sets.Kiting)
    end
    return set_combine(set, slot_guard())
end

function job_handle_equipping_gear(playerStatus, eventArgs)
    sync_weapon_mode()
    equip(current_set())
    eventArgs.handled = true
end

function job_pet_status_change(newStatus, oldStatus, eventArgs)
    if not midaction() then
        handle_equipping_gear(player.status)
    end
end

function job_pet_change(petparam, gain, eventArgs)
    if not gain then
        PET_WS_UP = false
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        -- Every WS set wears Mpaca's Cap; its TP Bonus does nothing at 3000.
        if player.tp >= 3000 then
            equip({head="Hiza. Somen +2"})
        end
        if player.tp < 2750 then
            equip(sets.MoonshadeWS)
        end
    elseif spell.english:endswith(' Maneuver') then
        equip(sets.precast.Maneuver)
    end
    equip(slot_guard())
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    equip(slot_guard())
end

-- Automaton magic: nuke gear while it casts.
function job_pet_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Magic' and spell.skill == 'Elemental Magic' then
        equip(sets.PetNuke)
        eventArgs.handled = true
    elseif AUTOMATON_WS:contains(spell.english) and PET_WS_SWAP then
        PET_WS_UP = true
        equip(current_set())
        eventArgs.handled = true
    end
end

function job_pet_aftercast(spell, action, spellMap, eventArgs)
    if AUTOMATON_WS:contains(spell.english) then
        PET_WS_UP = false
        add_to_chat(158, '[GS] '..(pet.name or 'Automaton')..': '..spell.english)
    end
    -- Don't stomp on your own WS / JA / spell gear if you're mid-action.
    if not midaction() then
        handle_equipping_gear(player.status)
    end
    eventArgs.handled = true
end

-- Watch the automaton's TP from packet 0x068 (owner index at 0x07, TP at
-- 0x11 - same offsets GearSwap's own parser uses). Raw handler, so it costs
-- nothing per packet; it only sends a command when the threshold is crossed,
-- and the command goes through the normal self_command path with fresh
-- globals.
function watch_pet_tp()
    local last_up = false
    windower.raw_register_event('incoming chunk', function(id, data)
        if id ~= 0x068 or not PET_WS_SWAP then return end
        local me = windower.ffxi.get_mob_by_target('me')
        if not me or data:unpack('H', 0x07) ~= me.index then return end
        local up = data:unpack('H', 0x11) >= PET_WS_TP
        if up ~= last_up then
            last_up = up
            windower.send_command('gs c _petws '..(up and 'on' or 'off'))
        end
    end)
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

    local weapon = ({den='Denouements', denouements='Denouements', claws='Claws',
                     ninzas='Ninzas', nibiru='Nibiru'})[cmd]
    if weapon then
        state.WeaponMode:set(weapon)
        equip(sets.weapons[weapon])
        add_to_chat(122, 'GearSwap: Weapon = '..weapon)

    elseif cmd == 'master' or cmd == 'hybrid' or cmd == 'tank' then
        local mode = cmd:sub(1,1):upper()..cmd:sub(2)
        state.PetMode:set(mode)
        handle_equipping_gear(player.status)
        add_to_chat(122, 'GearSwap: Pet mode = '..mode)

    elseif cmd == 'dt' then
        DT_MODE = not DT_MODE
        handle_equipping_gear(player.status)
        add_to_chat(122, 'GearSwap: DT mode '..(DT_MODE and 'ON' or 'OFF'))

    elseif cmd == 'petws' then
        PET_WS_SWAP = not PET_WS_SWAP
        if not PET_WS_SWAP and PET_WS_UP then
            PET_WS_UP = false
            handle_equipping_gear(player.status)
        end
        add_to_chat(122, 'GearSwap: Pet WS swap '..(PET_WS_SWAP and 'ON' or 'OFF'))

    elseif cmd == '_petws' then
        -- Sent by watch_pet_tp. Never interrupt your own cast/WS/JA gear.
        PET_WS_UP = cmdParams[2] == 'on' and PET_WS_SWAP and pet.isvalid
        if not midaction() then
            handle_equipping_gear(player.status)
        end

    elseif cmd == 'th' then
        TH_MODE = not TH_MODE
        if TH_MODE then
            -- With oil on hand the egg stays out: hands only, TH+1.
            TH_SLOTS = has_oil() and {'hands'} or {'ammo', 'hands'}
            equip(set_combine(sets.TH, slot_guard()))
            disable(TH_SLOTS)
        else
            enable(TH_SLOTS)
            handle_equipping_gear(player.status)
        end
        add_to_chat(122, 'GearSwap: TH mode '..(TH_MODE and 'ON ('..table.concat(TH_SLOTS, '/')..' locked)' or 'OFF'))
    end
end

-- Lockstyle - see SAM.lua for why it is re-applied on every job change.
LOCKSTYLE_SET = 39

function select_default_macro_book()
    set_macro_page(1, 9)
    add_to_chat(122, 'GearSwap: macro book 9 page 1 for PUP')
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
