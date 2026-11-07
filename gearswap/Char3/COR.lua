-- COR GearSwap (Char3) - built 2026-09-29 from Char3's gearinfo
-- parse. Every item named here is one Char3 owns and COR can wear.
--
-- Weapons: Naegling (main, since 2026-10-16 - was Eletta Sword) + Homestead
-- Gun (range); Blurred Sword +1 in the off-hand under /NIN or /DNC. Same conventions as Char1's jobs:
-- main / sub / range / ammo live only in sets.weapons and change only by
-- //gs c command, so nothing resets your TP mid-fight. Overlays go in
-- job_post_precast / job_post_midcast so Mote's base set doesn't undo them.
--
-- BEFORE USING:
--   * Bullets: you have an O. Bull. Pouch and a Trump Card Case (7 each) in
--     your CASE. Take a pouch and a card case into inventory and open them -
--     Orichalc. Bullets to shoot, Trump Cards for Quick Draw.
--   * Lanun Frac is in your SACK - move it to a wardrobe for Leaden Salute,
--     Quick Draw and Random Deal (the sets fall back gracefully without it).
--
-- Commands:
--   //gs c weapons   Naegling + Homestead Gun (+ Blurred Sword +1 on /NIN /DNC)
--   //gs c melee     TP mode: swinging (default)
--   //gs c ranged    TP mode: shooting
--
-- Not owned, for the record: Compensator / Rostam (roll duration or range),
-- Lanun Tricorne / Chasseur's (roll gear), a Moonshade Earring, any WSD
-- piece, a DT neck. Merirosvo Ring (Phantom Roll+3) isn't used: Barataria
-- Ring's +5 is the one that applies - they don't stack.

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()
end

function user_setup()
    state.TPMode = M{['description']='TP Mode', 'Melee', 'Ranged'}
end

-- Dual Wield comes from the subjob.
function dual_wield()
    return player.sub_job == 'NIN' or player.sub_job == 'DNC'
end

function init_gear_sets()

    ---------------------------------------------------------------------------
    -- Weapons (only equipped by command)
    ---------------------------------------------------------------------------

    sets.weapons = {
        main="Naegling",              -- DMG 166, Acc+40 Atk+30, Savage Blade damage +15% (main hand only)
        sub=empty,                    -- no COR-legal shield owned
        range="Homestead Gun",        -- iL119, Marksmanship +242
        ammo="Orichalc. Bullet",      -- from the O. Bull. Pouch in your case
    }
    sets.weaponsDW = set_combine(sets.weapons, {
        sub="Blurred Sword +1",       -- DMG 115, Acc+20, occasionally attacks twice
    })

    ---------------------------------------------------------------------------
    -- Phantom Roll / job abilities
    ---------------------------------------------------------------------------

    sets.precast.CorsairRoll = {
        back="Camulus's Mantle",      -- "Phantom Roll" effect duration +30
        left_ring="Barataria Ring",   -- Phantom Roll+5
    }
    sets.precast.JA['Double-Up'] = {left_ring="Barataria Ring"}
    sets.precast.JA['Wild Card'] = {feet="Lanun Bottes +1"}      -- Enhances "Wild Card"
    sets.precast.JA['Random Deal'] = {body="Lanun Frac"}         -- "Random Deal" effect +50 (sack)

    ---------------------------------------------------------------------------
    -- Ranged attacks
    ---------------------------------------------------------------------------

    sets.precast.RA = {
        head="Aurore Beret",          -- Enhances "Snapshot"
    }

    -- Shots: Ranged Accuracy and AGI first, Store TP where it's free.
    sets.midcast.RA = {
        head="Mummu Bonnet +1",       -- RAcc+38 AGI+30
        body="Adhemar Jacket +1",     -- RAcc+35 RAtt+35 AGI+29
        hands="Mummu Wrists +1",      -- RAcc+37
        legs="Mummu Kecks +1",        -- RAcc+39 AGI+41
        feet="Herculean Boots",       -- RAcc/RAtt+28 AGI+43 Store TP+5
        waist="Windbuffet Belt +1",
        left_ear="Mache Earring +1",
        right_ear="Eabani Earring",
        left_ring="Petrov Ring",      -- Store TP+5
        right_ring="Rajas Ring",      -- Store TP+5
        back="Camulus's Mantle",      -- AGI+20
    }

    ---------------------------------------------------------------------------
    -- Quick Draw
    ---------------------------------------------------------------------------

    -- Damage shots: AGI and MAB, same shell as Leaden Salute below.
    sets.midcast.CorsairShot = {
        head="Mummu Bonnet +1",       -- AGI+30 MAcc+38 (no MAB head owned)
        body="Lanun Frac",            -- MAB+15 AGI+22 (sack)
        hands="Mummu Wrists +1",      -- MAcc+37
        legs="Herculean Trousers",    -- MAB+19 MAcc+19 AGI+32 (augments)
        feet="Herculean Boots",       -- MAB+14 MAcc+14 AGI+43
        waist="Salire Belt",          -- MAB+4 MAcc+4
        left_ear="Friomisi Earring",  -- MAB+10
        right_ear="Hecate's Earring", -- MAB+6
        back="Camulus's Mantle",      -- AGI+20, MAcc/Magic Damage+5, MAB+1
    }

    -- Light / Dark Shot land debuffs, so magic accuracy: the Mummu +1 set.
    sets.midcast.CorsairShot['Light Shot'] = set_combine(sets.midcast.CorsairShot, {
        head="Mummu Bonnet +1",       -- MAcc+38
        hands="Mummu Wrists +1",      -- MAcc+37
        legs="Mummu Kecks +1",        -- MAcc+39
        feet="Mummu Gamash. +1",      -- MAcc+36
    })
    sets.midcast.CorsairShot['Dark Shot'] = sets.midcast.CorsairShot['Light Shot']

    ---------------------------------------------------------------------------
    -- Weapon skills
    ---------------------------------------------------------------------------

    -- Physical sword WS (Savage Blade if unlocked, Vorpal Blade ...):
    -- STR / Attack. You own no Weapon Skill Damage pieces, so Adhemar's
    -- augmented STR+12 / Attack+20 carries it.
    sets.precast.WS = {
        head="Adhemar Bonnet +1",     -- STR+31 Attack+56
        body="Adhemar Jacket +1",     -- STR+38 Attack+55
        hands="Adhemar Wrist. +1",    -- STR+27 Attack+20 Acc+32
        legs="Herculean Trousers",    -- STR+33 Attack+28
        feet="Herculean Boots",       -- Acc/Atk+28
        waist="Windbuffet Belt +1",
        left_ear="Mache Earring +1",  -- Acc+10
        right_ear="Eabani Earring",
        left_ring="Rajas Ring",       -- STR+5
        right_ring="Petrov Ring",     -- STR+3
        back="Camulus's Mantle",
    }

    -- SAVAGE BLADE (2026-10-16) - 2 hits, 50% STR + 50% MND, fTP 4.0 /
    -- 10.25 / 13.75 at 1000 / 2000 / 3000 TP, so Attack scales it hard.
    -- Naegling (main hand) adds +15% Savage Blade damage on its own.
    -- You own no Weapon Skill Damage gear, no Moonshade, no STR/MND neck
    -- or earrings, so this is the Adhemar +1 shell with each piece checked
    -- against the alternatives for STR + MND + Attack:
    --   head  Adhemar +1   STR 31 MND 14 Att 56  (Shned. Chapeau +1: 22/22, no Att)
    --   body  Adhemar +1   STR 38 MND 20 Att 55  (Shned. Tabard +1: 29/28, no Att)
    --   hands Adhemar +1   STR 27 MND 30 Att 20 Acc 32
    --   legs  Herculean    STR 33 MND 15 Att 28  (Pursuer's 35/20 but ranged Att only)
    --   feet  Herculean    STR 16 MND 11 Att 28 Acc 28
    --   rings Rajas STR+5, Petrov STR+3; Mache +1 for Acc+10 / DA+2%;
    --   Windbuffet +1 for TA/QA procs on the first hit.
    -- Ammo stays on bullets so the gun never loses its ammo.
    sets.precast.WS['Savage Blade'] = {
        head="Adhemar Bonnet +1",     -- STR+31 MND+14 Attack+56
        body="Adhemar Jacket +1",     -- STR+38 MND+20 Attack+55 Acc+35
        hands="Adhemar Wrist. +1",    -- STR+27 MND+30 Attack+20 Acc+32
        legs="Herculean Trousers",    -- STR+33 MND+15 Attack+28 Acc+13
        feet="Herculean Boots",       -- STR+16 MND+11 Acc/Atk+28
        waist="Windbuffet Belt +1",   -- TA+2% QA+2%
        left_ear="Mache Earring +1",  -- Acc+10 DA+2%
        right_ear="Eabani Earring",
        left_ring="Rajas Ring",       -- STR+5
        right_ring="Petrov Ring",     -- STR+3 DA+1%
        back="Camulus's Mantle",
    }

    -- Last Stand: ranged physical, AGI. The shooting set with Adhemar's
    -- Ranged Attack+36 on the head.
    sets.precast.WS['Last Stand'] = set_combine(sets.midcast.RA, {
        head="Adhemar Bonnet +1",     -- RAtt+36
    })

    -- SPLIT SHOT - single hit, 70% AGI, fTP 1.0 at every TP; TP only raises
    -- how much of the mob's defense it ignores (0 / 35 / 50%). Added
    -- 2026-10-03: before this it had no set and fell through to
    -- sets.precast.WS above - the MELEE STR / Attack set, with only 77
    -- Ranged Accuracy in it. That is why it kept missing.
    -- A one-hit WS that misses does nothing (and breaks the skillchain), so
    -- this is Ranged Accuracy first, AGI second:
    --   Ranged Accuracy 185 (was 77): Mummu Bonnet +1 38, Adhemar Jacket +1
    --   35, Mummu Wrists +1 37, Mummu Kecks +1 39, Mummu Gamash. +1 36.
    --   AGI 194: those plus Camulus's Mantle 20 and Petrov Ring 3.
    -- Nothing else you own adds ranged accuracy: Thurandaut Ring and Murky
    -- Ring read "Ranged Accuracy" but it's their PET line, and no earring,
    -- neck or belt has any. Those slots keep the shooting set's pieces.
    sets.precast.WS['Split Shot'] = set_combine(sets.midcast.RA, {
        head="Mummu Bonnet +1",       -- RAcc+38 AGI+30
        body="Adhemar Jacket +1",     -- RAcc+35 RAtt+35 AGI+29
        hands="Mummu Wrists +1",      -- RAcc+37 AGI+18
        legs="Mummu Kecks +1",        -- RAcc+39 AGI+41
        feet="Mummu Gamash. +1",      -- RAcc+36 AGI+53 (over Herculean Boots' RAcc+10)
        left_ring="Petrov Ring",      -- AGI+3
        back="Camulus's Mantle",      -- AGI+20
    })

    -- SNIPER SHOT (2026-10-09) - kept missing for exactly the Split Shot
    -- reason above: no set of its own, so it fell through to the melee STR /
    -- Attack set. It's the opener of the COR > PUP > RDM Light chain (Sniper
    -- Shot > Raging Fists > Savage Blade), so a miss breaks the whole chain.
    -- Same Ranged Accuracy set. Every other physical gun WS without a set of
    -- its own takes it too, so none of them can fall through to the melee set.
    sets.precast.WS['Sniper Shot']  = sets.precast.WS['Split Shot']
    sets.precast.WS['Hot Shot']     = sets.precast.WS['Split Shot']
    sets.precast.WS['Slug Shot']    = sets.precast.WS['Split Shot']
    sets.precast.WS['Blast Shot']   = sets.precast.WS['Split Shot']
    sets.precast.WS['Heavy Shot']   = sets.precast.WS['Split Shot']
    sets.precast.WS['Detonator']    = sets.precast.WS['Split Shot']
    sets.precast.WS['Numbing Shot'] = sets.precast.WS['Split Shot']

    -- Leaden Salute: magical dark, 100% AGI. Damage comes from the gun's
    -- LEVEL (Homestead Gun is iL119), then AGI and MAB.
    sets.precast.WS['Leaden Salute'] = set_combine(sets.midcast.CorsairShot, {})
    sets.precast.WS['Wildfire'] = sets.precast.WS['Leaden Salute']

    ---------------------------------------------------------------------------
    -- Melee / idle
    ---------------------------------------------------------------------------

    -- Melee TP: Adhemar +1 (Triple Attack+4% each, set: crit rate), Windbuffet
    -- (TA/QA), Store TP rings.
    sets.TP = {}
    sets.TP.Melee = {
        head="Adhemar Bonnet +1",     -- TA+4% Haste+8%
        body="Adhemar Jacket +1",     -- TA+4% Dual Wield+6
        hands="Adhemar Wrist. +1",    -- TA+4% Store TP+7
        legs="Mummu Kecks +1",        -- Acc+39 Crit+6% DT-4%
        feet="Herculean Boots",       -- TA+2 Store TP+5 Acc+28
        waist="Windbuffet Belt +1",   -- TA+2% QA+2%
        left_ear="Mache Earring +1",  -- DA+2% Acc+10
        right_ear="Eabani Earring",
        left_ring="Petrov Ring",      -- STP+5 DA+1%
        right_ring="Rajas Ring",      -- STP+5
        back="Camulus's Mantle",
    }
    -- Under /NIN or /DNC: both Dual Wield earrings (Suppanomimi +5, Eabani +4).
    sets.TP.MeleeDW = set_combine(sets.TP.Melee, {
        left_ear="Suppanomimi",
        right_ear="Eabani Earring",
    })
    -- Shooting between shots: stay in the ranged gear.
    sets.TP.Ranged = sets.midcast.RA
    sets.engaged = sets.TP.Melee

    -- Worn over the idle set only while running (see 'gearinfo' in
    -- job_self_command). Standing still keeps the DT legs.
    sets.Kiting = {legs="Track Pants +1"}   -- Movement speed +8% (2026-10-31)

    -- Idle: DT - Murky Ring -10, Mummu Kecks -4, Lanun Bottes +1 PDT-4,
    -- Flume Belt +1 PDT-4, Staunch Tathlum is ammo so it's left alone.
    sets.idle = {
        head="Mummu Bonnet +1",
        body="Adhemar Jacket +1",
        hands="Mummu Wrists +1",
        legs="Mummu Kecks +1",        -- DT-4%
        feet="Lanun Bottes +1",       -- PDT-4%
        waist="Flume Belt +1",        -- PDT-4%
        left_ring="Murky Ring",       -- DT-10%
        right_ring="Petrov Ring",
        back="Camulus's Mantle",
    }
end

---------------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------------

local function current_tp_set()
    if state.TPMode.value == 'Ranged' then
        return sets.TP.Ranged
    end
    return dual_wield() and sets.TP.MeleeDW or sets.TP.Melee
end

-- Refill an EMPTY ammo slot with Orichalc. Bullet, else Bullet, from
-- inventory or any wardrobe - never anything else, so a rare bullet is
-- never shot by accident. Same as Char1's COR.lua.
AMMO_PRIORITY = {'Orichalc. Bullet', 'Bullet'}
local AMMO_BAGS = {'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
                   'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}

local function find_ammo()
    local items = windower.ffxi.get_items()
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

local function refill_ammo()
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

    if cmd == 'weapons' then
        if dual_wield() then
            equip(sets.weaponsDW)
            add_to_chat(122, 'GearSwap: Naegling / Blurred Sword +1 / Homestead Gun'
                .. ' (Dual Wield from /' .. player.sub_job .. ')')
        else
            equip(sets.weapons)
            add_to_chat(122, 'GearSwap: Naegling / Homestead Gun')
        end

    elseif cmd == 'ranged' or cmd == 'gun' then
        state.TPMode:set('Ranged')
        if player.status == 'Engaged' then equip(current_tp_set()) end
        add_to_chat(122, 'GearSwap: TP mode = Ranged')

    elseif cmd == 'melee' then
        state.TPMode:set('Melee')
        if player.status == 'Engaged' then equip(current_tp_set()) end
        add_to_chat(122, 'GearSwap: TP mode = Melee')
    end
end

-- Lockstyle: 0 = lock to whatever you're wearing, same as Char3's RUN.
-- Macro book 2 is a guess (RUN uses book 1) - set it to your COR book.
LOCKSTYLE_SET = 0

function select_default_macro_book()
    set_macro_page(1, 2)
    add_to_chat(122, 'GearSwap: macro book 2 page 1 for COR')
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
