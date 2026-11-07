-- NIN GearSwap - Katana (Blade: Ku) / Sword (Savage Blade)
--
-- Katana = Gokotai + Tauret        (Blade: Ku spam - Gokotai +60% on every hit)
-- Sword  = Naegling + Gokotai      (Savage Blade, Naegling +15%)
--
-- Built from Char1's gearinfo export of 2026-09-15 22:29 and findAll's bag
-- list from the same minute. Structure follows SAM.lua / WAR.lua: weapons
-- live ONLY in sets.weapons and are equipped ONLY by an explicit //gs c
-- command, so no TP, WS, magic or idle set can swap your weapons mid-fight.
-- Reference material: Kastra_NIN.lua (accuracy tiers, Utsusemi cancel logic)
-- and Finan's NIN gearset guide on bg-wiki (set list and stat priorities).
-- Almost none of the guide's gear is owned (no Heishi, Nyame, Hattori,
-- Andartia's Mantle), so every set below is Char1's own gear.
--
-- 2026-10-31: full Mpaca's set (Cap, Doublet, Gloves, Hose, Boots - unranked,
-- wardrobe). Placed by stat priority and the NIN guide's sets, NOT by the
-- scratch model or the optimizer, so the old modelled figures in the
-- comments below describe the sets before Mpaca. Where it went:
--   Hose   every TP set except HighAcc's base, all physical WS, DT, idle,
--          Utsusemi (guide: Mpaca's Hose in all five TP columns)
--   Cap    MidAcc / LowAcc / DT TP, every physical WS (Flam. off -> Hiza.
--          Somen +2 back on at 3000 TP, when the TP Bonus+200 is wasted)
--   Doublet MidAcc / LowAcc TP, Ku / Hi Low tier
--   Gloves, Boots  Blade: Ku / Hi (DEX/STR + TA + crit on every hit)
-- HighAcc keeps the Malignance accuracy pieces.
--
-- Commands:
--   //gs c katana     Gokotai + Tauret
--   //gs c sword      Naegling + Gokotai
--   //gs c highacc    TP mode: accuracy first (default)
--   //gs c midacc     TP mode: balanced
--   //gs c lowacc     TP mode: multi-attack, for easy mobs WITH capped haste
--   //gs c dt         TP mode: DT-34% hybrid
--   //gs c tpmode     cycle the four
--   //gs c sange      ammo -> best shuriken found in your bags, for Sange
--   //gs c coiste     ammo -> Coiste Bodhar (default)
--   //gs c ammo       toggle the two
--
-- HOW THE SETS WERE PICKED. Every combination of reachable NIN-legal gear was
-- scored in a scratch model using bg-wiki's formulas:
--   - Dual wield delay: (D1+D2)(1-DW)/2 per hand. NIN's native DW is 35%.
--   - TP per hit comes from bg-wiki's delay table.
--   - Gokotai Regain: 1 TP per tic per point of total Dual Wield.
--   - Hit rate: 75 + (Acc - Eva)/2, clamped between 20 and 95.
--   - Weapon skills get their real hit counts, fTP, modifiers and weapon
--     bonuses.
-- Total damage per second is melee plus the weapon skills that TP buys.
--
-- THE ACCURACY TIERS ARE NOT OPTIONAL. The best set changes completely with
-- enemy evasion. Your accuracy comes out around 1130, and the same gear can
-- be +23% or -60% depending on the mob. Cross-checked, Blade: Ku damage per
-- second (LowAcc is last in each row):
--
--   enemy Eva / magic haste    HighAcc   MidAcc    LowAcc
--   1100 / 30%                 +0%       -6%       -60%
--   1000 / 30%                 +0%       +11%      -14%
--    950 / capped              +0%       +11%      +23%
--   1200 / 30%                 +0%       -20%      -43%
--
-- HighAcc never loses more than ~18% anywhere, so it's the default. Drop a
-- tier when you're clearly hitting almost every swing. LOWACC ALSO ASSUMES
-- CAPPED MAGIC HASTE: it wears no Dual Wield gear, which is only correct when
-- haste has already taken you to the delay cap.
--
-- See BLOCKED UPGRADES at the bottom for NIN gear that's in bags GearSwap
-- cannot reach.

---------------------------------------------------------------------------
-- SANGE / SHURIKEN
---------------------------------------------------------------------------
-- The shuriken is found AT RUNTIME by scanning the bags GearSwap can equip
-- from, picking the highest-damage one you are actually carrying. Nothing is
-- hardcoded, so this follows your real inventory instead of a name written
-- into this file (which is what broke the first version - the gearinfo dump
-- it was built from was out of date and showed no shuriken at all).
--
-- Leave SHURIKEN_OVERRIDE empty unless you want to force one specific
-- shuriken; if set, it wins over the scan.
SHURIKEN_OVERRIDE = ''

-- Sange consumes shuriken on melee hits for its whole 60s duration, so the
-- shuriken has to STAY equipped for the window. That is why this is a mode
-- rather than a precast swap.
--
-- Do NOT lock the ammo slot for this. A lock (//gs disable ammo) also stops
-- GearSwap pulling the next stack when one runs dry, which is the only
-- auto-refill you have. Leaving the slot swappable is what makes refill work:
-- GearSwap equips by NAME, so an empty slot gets the next stack automatically.

-- The bags GearSwap is willing to equip out of (validate.lua:30).
local EQUIPPABLE_BAGS = {'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
                         'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}
local shuriken_cache = nil

-- Highest-damage shuriken currently sitting in a reachable bag, or nil.
function find_shuriken(rescan)
    if SHURIKEN_OVERRIDE ~= '' then return SHURIKEN_OVERRIDE end
    if shuriken_cache and not rescan then return shuriken_cache end

    local items = windower.ffxi.get_items()
    if not items then return nil end

    -- `res` is NOT in GearSwap's job-file environment (refresh.lua:114 lists
    -- the whitelist and res is absent). Mote's own libs reach it through the
    -- `gearswap` handle on the real _G - see Mote-Include.lua:104.
    local resources = gearswap and gearswap.res
    if not resources or not resources.items then return nil end

    local best, best_dmg = nil, -1
    for _, bag in ipairs(EQUIPPABLE_BAGS) do
        local contents = items[bag]
        if type(contents) == 'table' then
            for _, entry in pairs(contents) do
                if type(entry) == 'table' and entry.id and entry.id > 0
                        and (entry.count or 0) > 0 then
                    local info = resources.items[entry.id]
                    local name = info and (info.en or info.english)
                    if name and name:lower():find('shuriken', 1, true) then
                        local dmg = info.damage or 0
                        if dmg > best_dmg then
                            best, best_dmg = name, dmg
                        end
                    end
                end
            end
        end
    end

    shuriken_cache = best
    return best
end

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function user_setup()
    state.WeaponMode = M{['description']='Weapon', 'Katana', 'Sword'}
    -- Accuracy first: M{} defaults to its first entry, and you should have to
    -- ask for the lower-accuracy sets rather than silently miss in them.
    state.TPMode = M{['description']='TP Mode', 'HighAcc', 'MidAcc', 'LowAcc', 'DT'}
    -- Coiste Bodhar is the default: Sange is situational, Coiste's DA+3% and
    -- STP+3 are not. Switch with //gs c sange, back with //gs c coiste.
    state.AmmoMode = M{['description']='Ammo', 'Coiste', 'Shuriken'}
    -- The Trust addon sends "gs c set MagicBurstMode Single" before every
    -- burst. Without this state Mote prints "Set: Unknown field". There's no
    -- NIN-wearable Magic Burst gear, so bursts use sets.midcast.ElementalNinjutsu
    -- as-is; job_aftercast drops Single back to Off after the cast.
    state.MagicBurstMode = M{['description']='Magic Burst', 'Off', 'Single', 'Always'}
    sync_weapon_mode()
end

-- Returns the ammo overlay, or nil when there is nothing to override.
-- Every caller applies this AFTER its own set, so it always wins its slot.
function ammo_overlay()
    if state.AmmoMode.value ~= 'Shuriken' then
        return nil
    end
    local name = find_shuriken()
    if not name then
        return nil
    end
    return {ammo=name}
end

function current_weapon_mode()
    local main = player and player.equipment and player.equipment.main
    if main == 'Naegling' then
        return 'Sword'
    end
    return 'Katana'
end

function sync_weapon_mode()
    local actual = current_weapon_mode()
    if state.WeaponMode.value ~= actual then
        state.WeaponMode:set(actual)
    end
    return actual
end

function init_gear_sets()

    ---------------------------------------------------------------------------
    -- Weapons - the only sets that ever touch main/sub
    ---------------------------------------------------------------------------

    sets.weapons = {}

    -- GOKOTAI MAIN, TAURET OFF. Gokotai has to be main hand for both of its
    -- effects: Blade: Ku access with +60% damage on all five hits, and Regain
    -- of 1 TP per tic per point of Dual Wield (35 native + gear, cap 100).
    -- The off-hand was scored three ways, Blade: Ku damage per second at Eva 1100:
    --   Tauret      DMG 125 Delay 180 Acc+40 Atk+30   358  <- best in every scenario
    --   Naegling    DMG 166 Delay 240 Acc+40 Atk+30   349  (bigger hit, slower swings)
    --   Senkutanto  DMG 100 Delay 185 Acc+27          306
    -- Tauret is in wardrobe3 and Gokotai is in your INVENTORY. Gokotai is
    -- reachable, but move it to a wardrobe before you fill your bag.
    sets.weapons.Katana = {
        main="Gokotai",
        sub="Tauret",
    }

    -- NAEGLING MAIN, GOKOTAI OFF. Naegling is what lets NIN use Savage Blade
    -- at all (+15% damage). Off-hand at Eva 1100: Gokotai 327/s, Tauret 304/s.
    -- Tauret edges ahead only on very low-evasion mobs (within 3%).
    -- Gokotai's Regain is main-hand only, so it's off here.
    sets.weapons.Sword = {
        main="Naegling",
        sub="Gokotai",
    }

    ---------------------------------------------------------------------------
    -- TP. No main/sub. Kept in sets.TP rather than sets.engaged subtables:
    -- a self-referencing set table is a recursion hazard inside GearSwap.
    -- Blade: Ku and Savage Blade scored the same TP sets in every scenario,
    -- so one family serves both weapons.
    ---------------------------------------------------------------------------

    sets.TP = {}

    -- HIGHACC - scored best at Eva 1100 with 30% and 0% magic haste.
    --   Accuracy  269 gear (+40 per weapon) - Hizamaru +2 x4 and Malignance
    --             Tabard are all Acc+42~50 pieces
    --   Haste     36% gear, over the 25% cap
    --   Dual Wield 35 + Sune-Ate +2 8 + Suppanomimi 5 = 48 -> Gokotai Regain 48/tic
    --   Store TP  29  (Tabard 11, Coiste 3, Telos 5, Chirich 5, Rajas 5)
    --   DT        -9% (Tabard) comes along free
    -- Hiza. Hizayoroi +2's WSD+7% is irrelevant here. The legs are here for
    -- Accuracy+45, Haste+9% and STR+50.
    --
    -- 2026-10-21: the original HighAcc gear is kept as HIGHACC_BASE, because
    -- MidAcc, LowAcc and DT are built from it. sets.TP.HighAcc itself now takes
    -- the GearSwap-Optimizer upgrade further down.
    local HIGHACC_BASE = {
        ammo="Coiste Bodhar",         -- DA+3%, STP+3
        head="Hiza. Somen +2",        -- Acc+44 Atk+26, Haste+6%
        body="Malignance Tabard",     -- Acc+50, DEX+49, STP+11, Haste+4%, DT-9%
        hands="Hizamaru Kote +2",     -- Acc+43 Atk+25, DEX+43, Haste+4%
        legs="Hiza. Hizayoroi +2",    -- Acc+45 Atk+27, STR+50, Haste+9%
        feet="Hiza. Sune-Ate +2",     -- Acc+42 Atk+24, "Dual Wield"+8, Haste+3%
        neck="Defiant Collar",        -- Acc+8, TA+1%
        waist="Sailfi Belt +1",       -- Haste+9%, TA+2%
        left_ear="Suppanomimi",       -- "Dual Wield"+5 (= +5 Regain/tic on Gokotai)
        right_ear="Telos Earring",    -- Acc+10 Atk+10, STP+5, DA+1%
        left_ring="Chirich Ring",     -- Acc+7, STP+5
        right_ring="Rajas Ring",      -- STR/DEX+5, STP+5
        back="Grounded Mantle",       -- Acc+20, DEX+7 (Unity)
    }

    -- HIGHACC after the 2026-10-21 optimizer pass. Both versions hit 99% vs an
    -- Apex Toad, so the extra accuracy wasn't buying anything there. TP
    -- 7.32s -> 5.48s, DT -9% -> -20%. Malignance Chapeau and Gloves,
    -- Bladeborn + Steelflash (Suppanomimi out: Gokotai loses 5 Regain/tic),
    -- Rajas + Petrov, Yokaze Mantle, Samnuha Tights. For content harder than
    -- Apex mobs, HIGHACC_BASE is the old set.
    sets.TP.HighAcc = set_combine(HIGHACC_BASE, {
        head="Malignance Chapeau",
        hands="Malignance Gloves",
        legs="Mpaca's Hose",          -- 2026-10-31: was Samnuha Tights. TA+4% Crit+6% Haste+9% PDT-9%
        left_ear="Bladeborn Earring",
        right_ear="Steelflash Earring",
        left_ring="Rajas Ring",
        right_ring="Petrov Ring",
        back="Yokaze Mantle",
    })

    -- MIDACC - scored best at Eva 1000. Trades ~64 accuracy for multi-attack:
    -- DA 4 -> 10%, TA 3 -> 8%, Crit+3%.
    --   body  Tabard -> Herculean Vest (TA+3 aug, Acc+28, Crit+3%)
    --   legs  Hizayoroi +2 -> Samnuha Tights (DA+3 TA+2 augs, STP+7)
    --   back  Grounded -> Yokaze Mantle (DA+2%, Atk+15)
    --   ring  Chirich -> Petrov (DA+1%)
    -- Loses the Tabard's DT-9%.
    -- 2026-10-31: Mpaca's Cap / Doublet / Hose replace the Somen, Vest and
    -- Samnuha (the guide's haste-cap set). Acc 40 each vs 28-44, plus TA,
    -- crit and PDT-26% - the old "loses the Tabard's DT" no longer applies.
    sets.TP.MidAcc = set_combine(HIGHACC_BASE, {
        head="Mpaca's Cap",           -- TA+3% Crit+4% PDT-7%
        body="Mpaca's Doublet",       -- TA+4% Crit+7% PDT-10%
        legs="Mpaca's Hose",          -- TA+4% Crit+6% PDT-9% Haste+9%
        back="Yokaze Mantle",
        left_ring="Petrov Ring",
    })

    -- LOWACC - scored best at Eva 950 with CAPPED magic haste. Drops ALL Dual
    -- Wield gear, which only pays off when haste has reached the delay cap:
    -- 35% native DW with capped haste is already at the 80% cap. Without
    -- capped haste this set is simply slower, so use MidAcc instead.
    --   feet  Sune-Ate +2 -> Malignance Boots (STP+9, Acc+50, DT-4%; replaced
    --         Tatena. Sune. STP+8 on 2026-10-18)
    --   ear   Suppanomimi -> Brutal Earring (DA+5%)
    --   ring  Rajas -> Chirich (the model wanted Chirich + Petrov here)
    -- Totals: DA 15%, TA 8%, STP 37, gear Acc 170.
    --
    -- 2026-10-21 optimizer pass (scored with capped magic haste, as this set
    -- assumes): TP 6.19s -> 5.95s, melee damage +9.5%, DT -4% -> -11%.
    -- Malignance Chapeau and Gloves, Steelflash + Eabani, Rajas + Petrov, and
    -- Hiza. Sune-Ate +2 back over the Malignance Boots.
    -- 2026-10-31: head stays Mpaca's Cap from MidAcc (was Malignance Chapeau).
    sets.TP.LowAcc = set_combine(sets.TP.MidAcc, {
        hands="Malignance Gloves",
        feet="Hiza. Sune-Ate +2",
        left_ear="Steelflash Earring",
        right_ear="Eabani Earring",
        left_ring="Rajas Ring",
        right_ring="Petrov Ring",
    })

    -- DT - HighAcc with three swaps. DT-34%:
    --   Tabard -9, Elite Royal Collar -5, Defending Ring -10, Murky Ring -10.
    -- That's everything NIN-legal and reachable that says "Damage taken". The
    -- only other lines owned are Physical-only: Herculean Trousers/Boots -2 each
    -- and Emet Harness -5 (loses the Tabard's -9 all-damage for it).
    -- Cost at Eva 1100: about -14% damage per second (308 vs 358).
    -- Accuracy barely moves (254 vs 269). Haste stays 36%, DW 48.
    -- 2026-10-18: Malignance Boots -> DT-38%. They take the Sune-Ate +2's
    -- Dual Wield+8, so DW is 40 (Gokotai Regain 40/tic) - still capped with
    -- capped magic haste, a little slower without it.
    -- 2026-10-31: Mpaca's Cap, Malignance Gloves and Mpaca's Hose (the
    -- guide's Katana Full DT set): DT-43%, plus PDT-16% -> physical capped.
    sets.TP.DT = set_combine(HIGHACC_BASE, {
        head="Mpaca's Cap",           -- PDT-7%
        hands="Malignance Gloves",    -- DT-5%
        legs="Mpaca's Hose",          -- PDT-9%
        feet="Malignance Boots",      -- DT-4%, STP+9, Acc+50
        neck="Elite Royal Collar",    -- DT-5%
        left_ring="Defending Ring",   -- DT-10%
        right_ring="Murky Ring",      -- DT-10%
    })

    -- Mote's own fallback if anything reaches it before the mode is read.
    sets.engaged = sets.TP.HighAcc

    ---------------------------------------------------------------------------
    -- Weapon skills. Picked per accuracy group: HighAcc and DT use sets.WS.Acc,
    -- MidAcc and LowAcc use sets.WS.Low. The left ear is Moonshade below 2750
    -- TP (applied AFTER the WS set in job_precast so it can't be overwritten).
    -- The left_ear named in each set is only for the rare 2750+ WS.
    ---------------------------------------------------------------------------

    sets.WS = {Acc = {}, Low = {}}

    -- BLADE: KU - 5 hits, 30% STR / 30% DEX, fTP 1.25 on EVERY hit (fTP
    -- replicating, and multi-attack procs replicate too). Gokotai +60% on all
    -- hits. A 5-hit WS lives or dies on hits 2-5 landing, and only the first
    -- hit gets the built-in +100 WS accuracy. That's why the Acc version keeps
    -- the TP set's accuracy pieces.
    --
    -- THE WSD RINGS, checked properly:
    --   Weapon skill damage is FIRST HIT ONLY. The first hit is ~15% of a Ku
    --   (five hits + off-hand + procs), so Cornelia's WSD+10% is worth ~1.5%.
    --   But gear "Weapon Skill Accuracy" applies to ALL hits of a physical WS
    --   (bg-wiki, dev-confirmed). Cornelia's WS Acc+10 lands on every hit, and
    --   that's the other half of why it earns the slot. The first version of
    --   this set left it out because the model only counted WS Acc on hit one.
    --   Ku damage by ring pair, Acc set at Eva 1100:
    --     Chirich + Rajas       2,944   (old)
    --     Chirich + Cornelia's  3,039   +3.2%  <- this set
    --     Rajas + Cornelia's    3,036   +3.1%  (a tie; better on Eva 1250+)
    --     Cornelia's + Karieyh  3,028   +2.9%
    --   Karieyh never earns a slot: WSD+3% on one hit and WS Acc+5 lose to
    --   Chirich's Acc+7 or Rajas' STR/DEX+5 on all hits.
    -- Rep. Plat. Medal (STR+10 Atk+30) also beats the TP neck on every hit.
    -- 2026-10-31: Mpaca's Cap, Gloves, Hose and Boots replace the Hizamaru
    -- four. Same STR/DEX, about 4 less Acc per slot, but Atk+40 and TA+3~4%
    -- per piece - every Triple Attack proc is another full-fTP Ku hit. The
    -- Tabard stays for its Acc+50 in this tier. (The ring table above was
    -- modelled with the Hizamaru set.)
    sets.WS.Acc['Blade: Ku'] = {
        ammo="Coiste Bodhar",         -- DA+3% - extra Ku hits get the full fTP
        head="Mpaca's Cap",
        body="Malignance Tabard",
        hands="Mpaca's Gloves",
        legs="Mpaca's Hose",          -- STR+49, TA+4% (Hizayoroi's WSD+7% was first hit only)
        feet="Mpaca's Boots",
        neck="Rep. Plat. Medal",      -- STR+10 Atk+30
        waist="Sailfi Belt +1",
        left_ear="Brutal Earring",    -- 2750+ only; Moonshade otherwise
        right_ear="Telos Earring",
        left_ring="Chirich Ring",     -- Acc+7 on all hits
        right_ring="Cornelia's Ring", -- WS Acc+10 on ALL hits, WSD+10% on the first
        back="Grounded Mantle",
    }

    -- Blade: Ku, lower-evasion mobs (scored at Eva 1000 and 950). Once hits
    -- land reliably, Attack and STR take over from accuracy:
    --   body  Tabard -> Hiza. Haramaki +2 (STR+40 Atk+28)
    --   back  Grounded -> Yokaze Mantle (Atk+15, DA+2%)
    --   ears  Brutal (DA+5%) stays; Telos becomes the 2750+ ear
    --   rings Rajas takes Chirich's place next to Cornelia's. Once hits land,
    --         Rajas' STR/DEX+5 on every hit is worth more than Chirich's
    --         Acc+7: 3,417 vs 3,359. Cornelia's stays, for the same all-hits
    --         WS Acc reason as above.
    -- Modelled 3,417 per Ku at Eva 1000.
    -- 2026-10-31: body is Mpaca's Doublet (STR+39 Atk+40 TA+4% Crit+7%) over
    -- the Haramaki (STR+40 Atk+28).
    -- 2026-10-31 optimizer pass: Cornelia's + Petrov and Amemet Mantle +1 -
    -- +3.6% unbuffed, +3.2% buffed. It kept all the Mpaca's pieces.
    sets.WS.Low['Blade: Ku'] = set_combine(sets.WS.Acc['Blade: Ku'], {
        body="Mpaca's Doublet",
        back="Amemet Mantle +1",
        left_ear="Telos Earring",
        right_ear="Brutal Earring",
        left_ring="Cornelia's Ring",
        right_ring="Petrov Ring",
    })

    -- SAVAGE BLADE - 2 hits + off-hand, 50% STR / 50% MND, fTP 4.0 / 10.25 /
    -- 13.75 on the FIRST hit only, Naegling +15%. Roughly three quarters of
    -- the weapon skill is hit one, so gear "Weapon skill damage" - which is
    -- FIRST HIT ONLY - is close to a straight multiplier here. That is the
    -- opposite of Blade: Ku, where the same gear buys about a third as much.
    -- This set stacks every reachable WSD piece:
    --   Cornelia's Ring +10%, Hiza. Hizayoroi +2 +7%, Oshasha's Treatise +3%,
    --   Karieyh Ring +3%, Ishvara Earring +2%          = 25%
    -- and the Low set below adds Herculean Boots for 30%.
    -- No NIN gear you own carries MND worth chasing; the Hizamaru STR does it.
    -- (The old "modelled 3,334 at Eva 1100" figure predates the 20% -> 25%
    -- WSD change and is no longer accurate; it was not re-run.)
    sets.WS.Acc['Savage Blade'] = {
        -- WSD+3%, Acc+5, Atk+5. Coiste Bodhar's DA+3% does little for a WS
        -- whose extra hits do NOT replicate fTP, so this is a clear win.
        -- NOTE: this lives in your SATCHEL. If GearSwap cannot reach it the
        -- slot silently keeps the TP set's Coiste Bodhar - the correct
        -- fallback - so this is safe to leave in place. Move it to a wardrobe.
        ammo="Oshasha's Treatise",
        -- 2026-10-31: "TP Bonus"+200 raises Savage Blade's first-hit fTP, the
        -- part that matters. STR+33 Atk+40. Somen +2 back on at 3000 TP.
        head="Mpaca's Cap",
        -- 2026-10-31 optimizer pass: Mpaca's Doublet over the Haramaki and
        -- Malignance Gloves over the Kote - +12.5% unbuffed, +13.0% buffed.
        body="Mpaca's Doublet",
        hands="Malignance Gloves",
        legs="Hiza. Hizayoroi +2",    -- STR+50, WSD+7%
        feet="Hiza. Sune-Ate +2",
        neck="Rep. Plat. Medal",
        -- Ishvara over Brutal here. Savage Blade does not replicate fTP, so a
        -- Double Attack proc only adds a small fTP-1.0 hit, while WSD+2% lands
        -- on the big one. 2750+ only; Moonshade overwrites this slot below it.
        left_ear="Ishvara Earring",
        right_ear="Telos Earring",    -- Acc+10 helps BOTH hits land
        left_ring="Cornelia's Ring",  -- WSD+10%, WS Acc+10
        right_ring="Karieyh Ring",    -- WSD+3%
        back="Yokaze Mantle",
    }

    -- Savage Blade, lower-evasion mobs (Eva 1000): Herculean Boots' WSD+5%
    -- augment and Attack+22 beat the Sune-Ate +2's accuracy (-42 Acc). Takes
    -- total WSD to 30%. Inherits the Oshasha's ammo and Ishvara ear above.
    sets.WS.Low['Savage Blade'] = set_combine(sets.WS.Acc['Savage Blade'], {
        feet="Herculean Boots",
    })

    -- BLADE: SHUN - 5 hits, DEX 73~85% (merits), fTP 1.0 replicating on every
    -- hit, and ATTACK scales with TP instead of fTP. Fusion / Impaction - the
    -- opener or Fusion step of NIN/DNC/COR Light chains.
    -- Built off the Ku set (same 5-hit shape: accuracy on hits 2-5 matters,
    -- multi-attack procs get full fTP, WSD is first hit only) with two changes:
    --   neck  Rep. Plat. Medal -> Light Gorget  } Fusion has a Light element,
    --   waist Sailfi Belt +1  -> Light Belt     } so both activate: Acc+10 and
    --                                             fTP+0.1 each, 1.0 -> 1.2 per
    --                                             hit. Worth far more than the
    --                                             medal's STR (not a Shun stat)
    --                                             or the Sailfi's TA+2%.
    -- Moonshade still applies below 2750 - TP Bonus raises Shun's attack bonus.
    -- Both elemental pieces sit in wardrobe2. NOT MODELLED like Ku/Savage -
    -- these are stat-priority picks, not scratch-model scores.
    sets.WS.Acc['Blade: Shun'] = set_combine(sets.WS.Acc['Blade: Ku'], {
        neck="Light Gorget",
        waist="Light Belt",
    })

    -- Blade: Shun, lower-evasion mobs. Unlike the Ku Low set, the Tabard stays
    -- (DEX+49 beats the Haramaki's DEX+36 on a DEX WS) and Grounded stays
    -- (DEX+7). Accuracy is traded for DEX and multi-attack instead:
    --   legs  Hizayoroi +2 (DEX 0, Acc+45) -> Samnuha Tights (DEX+15, DA+3 TA+2)
    --   feet  Sune-Ate +2 -> Herculean Boots (DEX+32, TA+2%, WSD+5% aug)
    --   rings Rajas (DEX+5) replaces Chirich next to Cornelia's
    --
    -- 2026-10-21 GearSwap-Optimizer pass: Malignance Gloves, Cornelia's +
    -- Petrov, Yokaze Mantle, and Steelflash left / Bladeborn right (Moonshade
    -- still takes the left below 2750). +6.4% unbuffed, +9.7% buffed. The
    -- optimizer also wanted the Light Gorget and Light Belt out, but it gives
    -- them no stats at all (it doesn't model their fTP+), so they stay.
    -- 2026-10-31: legs and feet stay Mpaca's from the Ku set (DEX+32 TA+3%
    -- Boots over Herculean's DEX+32 TA+2%; Hose is the guide's Shun legs).
    sets.WS.Low['Blade: Shun'] = set_combine(sets.WS.Acc['Blade: Shun'], {
        hands="Malignance Gloves",
        back="Yokaze Mantle",
        left_ear="Steelflash Earring",
        right_ear="Bladeborn Earring",
        left_ring="Cornelia's Ring",
        right_ring="Petrov Ring",
    })

    -- NOT MODELLED - sensible homes only. Other physical katana WS (Blade: Jin
    -- crit, Blade: Ten STR) take the Ku sets. Magical
    -- WS (Blade: Chi / Teki / To / Ei / Yu, Aeolian Edge) take the Ninjutsu
    -- nuke set with the WSD rings.
    for _, tier in ipairs({'Acc', 'Low'}) do
        for _, ws in ipairs({'Blade: Jin', 'Blade: Ten', 'Blade: Retsu',
                             'Blade: Kamu', 'Blade: Hi', 'Blade: Metsu'}) do
            sets.WS[tier][ws] = sets.WS[tier]['Blade: Ku']
        end
        for _, ws in ipairs({'Fast Blade', 'Burning Blade', 'Vorpal Blade', 'Circle Blade'}) do
            sets.WS[tier][ws] = sets.WS[tier]['Savage Blade']
        end
    end

    -- Blade: Hi, lower-evasion mobs - its own set since the 2026-10-21
    -- optimizer pass (it used to share the Ku Low set). Herculean Vest and
    -- Boots, Malignance Gloves, Cornelia's + Karieyh, Steelflash left /
    -- Bladeborn right: +12.7% unbuffed, +16.6% buffed. The Acc tier keeps Ku's.
    -- 2026-10-31: Blade: Hi is a crit WS, so it keeps the Ku set's Mpaca's
    -- Doublet (Crit+7%), Gloves (+5%) and Boots (+3%) instead of the
    -- Herculean Vest (+3%), Malignance Gloves and Herculean Boots.
    sets.WS.Low['Blade: Hi'] = set_combine(sets.WS.Low['Blade: Ku'], {
        back="Yokaze Mantle",         -- as scored; Ku's Amemet change wasn't tested on Hi
        left_ear="Steelflash Earring",
        right_ear="Bladeborn Earring",
        left_ring="Cornelia's Ring",
        right_ring="Karieyh Ring",
    })

    ---------------------------------------------------------------------------
    -- Ninjutsu
    ---------------------------------------------------------------------------

    -- Fast Cast. Herculean Helm's "Fast Cast"+7% is the only FC piece in a bag
    -- GearSwap can reach. Dread Jupon (FC+7%) is in the satchel, Magoraga
    -- Beads (Utsusemi casting time -10%) in the sack, Naji's Loop (FC+1%) in
    -- the safe. See BLOCKED UPGRADES.
    -- 2026-10-21 optimizer pass: Naji's Loop is in a wardrobe now (FC 7 -> 8%),
    -- and the empty slots take DT pieces that cost no fast cast: DT-36%.
    sets.precast.FC = {
        head="Herculean Helm",        -- "Fast Cast"+7%, Haste+8%
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Volte Tights",
        feet="Malignance Boots",
        neck="Elite Royal Collar",
        waist="Plat. Mog. Belt",
        back="Yokaze Mantle",
        left_ring="Murky Ring",
        right_ring="Naji's Loop",     -- "Fast Cast"+1%
    }
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})

    -- Utsusemi midcast: you own no "Utsusemi +" or spell-interruption gear, so
    -- the cast is spent in DT gear. Shadows come up with you still at -34%.
    -- 2026-10-31: Mpaca's Cap / Gloves / Hose add PDT-24% (physical capped).
    sets.midcast.Utsusemi = {
        ammo="Coiste Bodhar",
        head="Mpaca's Cap",           -- PDT-7%
        body="Malignance Tabard",     -- DT-9%
        hands="Mpaca's Gloves",       -- PDT-8%
        legs="Mpaca's Hose",          -- PDT-9%
        feet="Malignance Boots",      -- DT-4%
        neck="Elite Royal Collar",    -- DT-5%
        waist="Sailfi Belt +1",
        left_ring="Defending Ring",   -- DT-10%
        right_ring="Murky Ring",      -- DT-10%, Spell interruption rate down 3%
        back="Yokaze Mantle",
    }

    -- Enfeebling / utility Ninjutsu (Kurayami, Hojo, Jubaku, Aisha, Yurin,
    -- Dokumori) - magic accuracy. No Ninjutsu skill gear is owned, so this is
    -- every Magic Accuracy line you can reach: Tabard 50, Herculean Trousers
    -- 36 (augs), Herculean Boots 24, Yokaze Mantle 15, Hydrocera 6. Gokotai
    -- adds MAcc+40 on top when it's the main hand.
    sets.midcast.Ninjutsu = {
        ammo="Hydrocera",             -- Magic Accuracy+6
        head="Herculean Helm",        -- "Magic Atk. Bonus"+19 (base+aug), INT+20
        body="Malignance Tabard",     -- Magic Accuracy+50, INT+19
        hands="Hizamaru Kote +2",     -- INT+7
        legs="Herculean Trousers",    -- Mag. Acc.+36, "Mag.Atk.Bns."+15 (augs), INT+29
        feet="Herculean Boots",       -- Mag. Acc.+24, "Mag.Atk.Bns."+24 (base+aug)
        neck="Sibyl Scarf",           -- INT+10, "Magic Atk. Bonus"+10
        waist="Sailfi Belt +1",
        left_ring="Acumen Ring",      -- INT+2, "Magic Atk. Bonus"+4
        right_ring="Murky Ring",      -- DT-10% - no second MAB/MAcc ring reachable
        back="Yokaze Mantle",         -- Magic Accuracy+15
    }

    -- Elemental Ninjutsu (Katon / Suiton / Raiton / Doton / Huton / Hyoton).
    -- Every magic-attack line you own is already in the set above:
    --   - Herculean head, legs and feet: MAB+58 total.
    --   - Sibyl Scarf and Acumen Ring.
    -- So it's the same gear under its own name, ready for a Friomisi or
    -- Moldavite Earring. Moldavite ("Magic Atk. Bonus"+5) is in your locker.
    -- 2026-10-18: Ghastly Tathlum +1 (Magic Damage+11) for the nukes; the
    -- enfeebling set above keeps Hydrocera's MAcc+6.
    sets.midcast.ElementalNinjutsu = set_combine(sets.midcast.Ninjutsu, {
        ammo="Ghastly Tathlum +1",
    })

    -- Magical weapon skills, not modelled: the nuke gear plus WSD rings.
    sets.WS.Magic = set_combine(sets.midcast.Ninjutsu, {
        left_ring="Cornelia's Ring",
        right_ring="Karieyh Ring",
    })
    for _, tier in ipairs({'Acc', 'Low'}) do
        for _, ws in ipairs({'Blade: Chi', 'Blade: Teki', 'Blade: To', 'Blade: Ei',
                             'Blade: Yu', 'Aeolian Edge'}) do
            sets.WS[tier][ws] = sets.WS.Magic
        end
    end

    -- Blade: Chi (2026-10-21 optimizer pass): +6.5%. Ghastly Tathlum +1,
    -- Ishvara in the empty right ear, Malignance Gloves, Eschan Stone, and
    -- Hiza. Hizayoroi +2's WSD+7% over the Herculean Trousers. Both tiers - a
    -- magical WS doesn't care about the accuracy split.
    sets.WS.Chi = set_combine(sets.WS.Magic, {
        ammo="Ghastly Tathlum +1",
        hands="Malignance Gloves",
        legs="Hiza. Hizayoroi +2",
        waist="Eschan Stone",
        right_ear="Ishvara Earring",
    })
    sets.WS.Acc['Blade: Chi'] = sets.WS.Chi
    sets.WS.Low['Blade: Chi'] = sets.WS.Chi

    -- Blade: Ten, lower-evasion mobs (2026-10-31 optimizer pass) - its own set
    -- now, off the Ku Low set. A single-hit STR WS, so WSD wins back the legs
    -- and feet: Hiza. Hizayoroi +2 (WSD+7%), Herculean Boots (WSD+5%),
    -- Cornelia's + Karieyh, Ishvara, Amar Cluster. +6.0% unbuffed, +10.0%
    -- buffed. The Acc tier still uses the Ku set.
    sets.WS.Low['Blade: Ten'] = set_combine(sets.WS.Low['Blade: Ku'], {
        ammo="Amar Cluster",
        legs="Hiza. Hizayoroi +2",
        feet="Herculean Boots",
        right_ear="Ishvara Earring",
        left_ring="Cornelia's Ring",
        right_ring="Karieyh Ring",
    })

    ---------------------------------------------------------------------------
    -- Idle. No main/sub - idling must never change the weapons you're holding.
    ---------------------------------------------------------------------------

    -- Worn over the idle set only while running (see 'gearinfo' in
    -- job_self_command). Standing still keeps the DT legs below.
    sets.Kiting = {legs="Track Pants +1"}   -- Movement speed +8% (2026-10-31)

    -- DT-34%, plus Physical DT-4% from the Herculean legs and feet. Same four
    -- all-damage pieces as sets.TP.DT; there's nothing else to add.
    -- Malignance Tabard over Hiza. Haramaki +2's "Regen"+12: the DT-9% matters
    -- more when something is actually hitting you. Swap the body if you idle
    -- somewhere safe.
    -- No movement speed gear is reachable (Councilor's Garb only works in
    -- Adoulin, and it's in the satchel).
    -- 2026-10-21 optimizer pass: DT -38% -> -52% (capped), HP 290 -> 347.
    -- Malignance Chapeau and Gloves, Platinum Moogle Belt, Eabani + Infused
    -- earrings, Amar Cluster.
    sets.idle = {
        ammo="Amar Cluster",
        head="Malignance Chapeau",    -- DT-6%, was Hiza. Somen +2
        body="Malignance Tabard",     -- DT-9%
        hands="Malignance Gloves",    -- DT-5%, was Hizamaru Kote +2
        legs="Mpaca's Hose",          -- PDT-9%, HP+72 (2026-10-31; was Herculean Trousers PDT-2% HP+38)
        feet="Malignance Boots",      -- DT-4%, Magic Evasion+150 (2026-10-18)
        neck="Elite Royal Collar",    -- DT-5%, Regen+3 if San d'Oria
        waist="Plat. Mog. Belt",      -- DT-3%, HP+10%
        left_ear="Eabani Earring",
        right_ear="Infused Earring",
        left_ring="Defending Ring",   -- DT-10%
        right_ring="Murky Ring",      -- DT-10%
        back="Yokaze Mantle",         -- HP+50
    }

    -- Low-TP overlay: TP Bonus +250 is wasted at the 3000 TP cap.
    sets.MoonshadeWS = {left_ear="Moonshade Earring"}
end

function job_setup()
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

-- MidAcc and LowAcc are for mobs you already hit reliably, so their WS
-- choice follows them into the lower-evasion WS sets.
local function ws_tier()
    if state.TPMode.value == 'MidAcc' or state.TPMode.value == 'LowAcc' then
        return 'Low'
    end
    return 'Acc'
end

local function tp_set()
    return sets.TP[state.TPMode.value] or sets.TP.HighAcc
end

-- Utsusemi tiers by name. A lower tier cannot overwrite a higher tier's
-- shadows. Casting Ichi over Ni's shadows just fails, and you've spent the
-- tools and the recast for nothing. Same rule the Trust addon's NIN code uses.
local UTSUSEMI_TIER = {['Utsusemi: Ichi']=1, ['Utsusemi: Ni']=2, ['Utsusemi: San']=3}
local COPY_IMAGE_BUFFS = {66, 444, 445, 446}   -- Copy Image, (2), (3), (4+)
local shadow_tier = nil                          -- tier of the shadows currently up

local function shadows_up()
    for _, id in ipairs(COPY_IMAGE_BUFFS) do
        if buffactive[id] then return true end
    end
    return false
end

function job_precast(spell, action, spellMap, eventArgs)
    if spell.type ~= 'WeaponSkill' then
        return      -- magic and abilities: Mote picks sets.precast.FC etc. by name
    end

    local tier = ws_tier()
    local ws_set = sets.WS[tier][spell.english]
    if not ws_set then
        return      -- unlisted WS: let Mote fall back to sets.precast.WS
    end

    -- The WS set first, THEN Moonshade. GearSwap keeps the last equip() per
    -- slot, so the order is what makes the TP Bonus earring actually stick.
    equip(ws_set)
    -- Mpaca's Cap's TP Bonus does nothing at the 3000 cap.
    if player.tp >= 3000 and ws_set.head == "Mpaca's Cap" then
        equip({head="Hiza. Somen +2"})
    end
    if player.tp < 2750 then
        equip(sets.MoonshadeWS)
    end
    add_to_chat(167, '[GS] '..spell.english..' >> WS '..tier..
        (player.tp < 2750 and ' / Moonshade' or '')..' @ '..player.tp..' TP')
    eventArgs.handled = true
end

function job_midcast(spell, action, spellMap, eventArgs)
    local tier = UTSUSEMI_TIER[spell.english]
    if not tier then
        return
    end
    -- Shadows expired or were stripped since the last cast: nothing to guard.
    if not shadows_up() then
        shadow_tier = nil
        return
    end
    -- Only cancel when the new cast is LOWER than what's up. Ni over Ichi, or
    -- San over anything, overwrites on its own. Cancelling there would just
    -- throw away shadows for the length of the cast.
    if shadow_tier and tier < shadow_tier then
        for _, id in ipairs(COPY_IMAGE_BUFFS) do
            if buffactive[id] then
                windower.ffxi.cancel_buff(id)
            end
        end
        add_to_chat(122, '[GS] '..spell.english..': cancelled higher-tier shadows so it can land')
    end
end

-- Mote runs job_post_precast even when job_precast set eventArgs.handled
-- (Mote-Include.lua:273 gates the post hooks on `cancel` only, never on
-- `handled`), so this is the one place an overlay is guaranteed not to be
-- overwritten - including by the Moonshade overlay in job_precast above.
function job_post_precast(spell, action, spellMap, eventArgs)
    local overlay = ammo_overlay()
    if overlay then
        equip(overlay)
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    local tier = UTSUSEMI_TIER[spell.english]
    if tier and not spell.interrupted then
        shadow_tier = tier
    end
    if spell.action_type == 'Magic' and state.MagicBurstMode.value == 'Single' then
        state.MagicBurstMode:set('Off')
    end
    if player.status == 'Engaged' then
        equip(tp_set())
        local overlay = ammo_overlay()
        if overlay then equip(overlay) end
    end
end

function job_handle_equipping_gear(playerStatus, eventArgs)
    sync_weapon_mode()
    if playerStatus == 'Engaged' then
        equip(tp_set())
        local overlay = ammo_overlay()
        if overlay then equip(overlay) end
        eventArgs.handled = true
    end
end

-- Idle is NOT claimed above, so Mote builds it itself and this is where the
-- overlay has to go for the idle set. Keeps the shuriken on between pulls so
-- a stack that ran dry gets replaced before you re-engage.
function customize_idle_set(idleSet)
    -- Running: Track Pants +1 (see 'gearinfo' in job_self_command).
    if gearinfo_moving and sets.Kiting then
        idleSet = set_combine(idleSet, sets.Kiting)
    end
    local overlay = ammo_overlay()
    if overlay then
        return set_combine(idleSet, overlay)
    end
    return idleSet
end

-- Always rescans when switching to Shuriken, so it picks up stock you have
-- acquired since the last swap and re-picks if you burned through a type.
local function set_ammo_mode(mode)
    state.AmmoMode:set(mode)

    local label = 'Coiste Bodhar'
    if mode == 'Shuriken' then
        local name = find_shuriken(true)
        if not name then
            add_to_chat(123, 'GearSwap: no shuriken found in inventory or wardrobes 1-8. '
                .. 'Move a stack into one of those bags, or set SHURIKEN_OVERRIDE at the top of NIN.lua.')
            return
        end
        label = name
    end

    -- A locked ammo slot is the single most likely reason nothing visibly
    -- changes: GearSwap silently refuses to touch a disabled slot, so the
    -- overlay is staged and then dropped with no error. disable_table is
    -- keyed by slot id and ammo is 3 (statics.lua:154); reach it through the
    -- `gearswap` handle because disable_table is not in the job-file env.
    local dt = gearswap and gearswap.disable_table
    if dt and dt[3] then
        add_to_chat(123, 'GearSwap: AMMO SLOT IS LOCKED - nothing will equip there. '
            .. 'Run //gs enable ammo, then this command again.')
        return
    end

    if player.status == 'Engaged' then
        equip(tp_set())
        local overlay = ammo_overlay()
        if overlay then equip(overlay) end
    end
    add_to_chat(122, 'GearSwap: ammo = ' .. label
        .. (player.status == 'Engaged' and '' or '  (not engaged - applies on your next set swap)'))
end

local function set_tp_mode(mode, note)
    state.TPMode:set(mode)
    if player.status == 'Engaged' then equip(tp_set()) end
    add_to_chat(122, 'GearSwap: TP mode = '..mode..(note and (' ('..note..')') or ''))
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

    if cmd == 'katana' or cmd == 'ku' then
        state.WeaponMode:set('Katana')
        equip(sets.weapons.Katana)
        add_to_chat(122, 'GearSwap: Katana / Gokotai + Tauret (Blade: Ku)')

    elseif cmd == 'sword' or cmd == 'savage' then
        state.WeaponMode:set('Sword')
        equip(sets.weapons.Sword)
        add_to_chat(122, 'GearSwap: Sword / Naegling + Gokotai (Savage Blade)')

    elseif cmd == 'highacc' then
        set_tp_mode('HighAcc')
    elseif cmd == 'midacc' then
        set_tp_mode('MidAcc')
    elseif cmd == 'lowacc' then
        set_tp_mode('LowAcc', 'needs capped magic haste')
    elseif cmd == 'dt' then
        set_tp_mode('DT', 'DT-34%')
    elseif cmd == 'normal' or cmd == 'tp' then
        set_tp_mode('HighAcc')
    elseif cmd == 'tpmode' then
        state.TPMode:cycle()
        set_tp_mode(state.TPMode.value)

    elseif cmd == 'sange' or cmd == 'shuriken' then
        set_ammo_mode('Shuriken')
    elseif cmd == 'coiste' then
        set_ammo_mode('Coiste')
    elseif cmd == 'ammo' then
        state.AmmoMode:cycle()
        set_ammo_mode(state.AmmoMode.value)
    end
end

---------------------------------------------------------------------------
-- BLOCKED UPGRADES - NIN gear you own that this file cannot use yet
---------------------------------------------------------------------------
--
-- GearSwap only equips from inventory and wardrobes 1-8. A set naming an item
-- in any other bag silently keeps whatever was in that slot. Bags are from
-- addons/findAll/data/Char1.lua (2026-09-15 22:29).
--
--   Magoraga Beads     sack     "Utsusemi" spellcasting time -10%. Goes in
--                               sets.precast.FC.Utsusemi as neck.
--   Dread Jupon        satchel  "Fast Cast"+7%, Haste+4%, DA+2%. Doubles
--                               your Fast Cast with the Herculean Helm.
--   Raimitsukane       sack     NIN katana, DMG 122 / Delay 227, DEX+12 Acc+15.
--                               Not better than Tauret off-hand, but a real
--                               second katana if you want Blade WS off both hands.
--   Oshasha's Treatise satchel  Acc+5 Atk+5, WSD+3%. NOW REFERENCED by the
--                               Savage Blade sets (not by Ku, which wants
--                               Coiste's Double Attack - Ku replicates fTP on
--                               multi-attack procs, Savage Blade does not).
--                               Until you move it to a wardrobe the slot just
--                               keeps Coiste Bodhar, so nothing breaks.
--   Moldavite Earring  locker   "Magic Atk. Bonus"+5 for elemental Ninjutsu.
--   Koga Tekko         locker   Nighttime STR+12 Haste+4% - old relic hands,
--                               loses to Hizamaru Kote +2 in every set here.
--   Mouflon Ring       case     Acc+6, STP+2 - no better than Chirich.
--   Iximulew Cape      case     Physical DT-4%, for sets.TP.DT / idle back.
--
-- Nothing here is Ninja-JSE: no Andartia's Mantle, no Hachiya/Mochizuki/
-- Hattori pieces and no Ninja Nodowa. An Andartia's Mantle (DEX/Acc/DA) would
-- be the single biggest upgrade to every TP set.
--
-- RULED OUT - do not re-suggest these:
--   Ygnas's Resolve +1   case   Reads "Weapon skill damage +25%", which would
--                               otherwise be the best WS neck here by a mile.
--                               CONFIRMED IN-GAME 2026-09-16: the WSD, like
--                               the Regain+30 beside it, is Reives-only. Dead
--                               outside Escha-Zi'Tah reives. Rep. Plat. Medal
--                               stays the WS neck.
--
-- WEAPON SKILL DAMAGE, where you actually stand. Gear WSD is FIRST HIT ONLY,
-- so it is a Savage Blade stat, not a Blade: Ku stat. NIN-legal WSD you own:
--   Cornelia's Ring +10%  Hiza. Hizayoroi +2 +7%  Herculean Boots +5% (aug)
--   Oshasha's Treatise +3%  Karieyh Ring +3%  Ishvara Earring +2%
-- All six are in the Savage Blade sets above: 25% base, 30% in the Low tier.
-- That is close to the reachable ceiling. The remaining WSD gear in your bags
-- (Knobkierrie, Smertrios's Mantle, Wakido Haidate +3, Meg. Gloves +2, Thrud
-- Earring and others) is not NIN-equippable - it belongs to SAM/WAR/COR.
--
-- So WSD is NOT your bottleneck. ATTACK is: on Apex-tier mobs your cRatio sits
-- under 1.0 and pDIF is at the floor, which divides the whole weapon skill,
-- WSD included. /WAR Berserk + Aggressor and an attack food (Grape Daifuku,
-- Red Curry Bun) are each worth more than every gear swap in this file.

-- Lockstyle. The game clears style lock every time you change jobs, so it has
-- to be re-applied - Mote calls select_default_macro_book() on load and on job
-- change, which is the right place for it.
--
-- SET THIS to your in-game equipset number. 39 is the value the other job
-- files use. A number with no matching equipset fails silently.
LOCKSTYLE_SET = 39

-- SET THIS too: macro book 6 is a placeholder. WAR uses 4, SAM 2 and COR 5.
function select_default_macro_book()
    set_macro_page(1, 6)
    add_to_chat(122, 'GearSwap: macro book 6 page 1 for NIN')
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
