-- BLU buttons (Char1). Field guide: jobs/WAR.lua.
--
-- Two rows. Row 2: BLU job abilities, then pop-out spell menus (BUFF / PHYS /
-- NUKE / HEAL) - click one and its spells replace the bar (with BACK); pick
-- one, press BACK, or leave it a few seconds and the bar comes back.
-- Spells you haven't set just fail with the game's own message; swap names
-- in here to match your spell set.
local UL = {'Unbridled Learning', 'Unbridled Wisdom'}

return {
    -- bluesets tells gearbar which spell set is on; shown above the plate.
    plate_query = 'bs announce',

    -- Row 2: job abilities (gold while their buff is up) | menus.
    {label='CHAIN', name='Chain Affinity - next physical spell can skillchain', kind='ability', row=2, section='ja', cmd='input /ja "Chain Affinity" <me>', buff='Chain Affinity'},
    {label='BURST', name='Burst Affinity - next magical spell can magic burst', kind='ability', row=2, section='ja', cmd='input /ja "Burst Affinity" <me>', buff='Burst Affinity'},
    {label='EFFLX', name='Efflux - next physical spell gets a TP bonus', kind='ability', row=2, section='ja', cmd='input /ja "Efflux" <me>', buff='Efflux'},
    {label='DIFF', name='Diffusion - next buff spell hits the party', kind='ability', row=2, section='ja', cmd='input /ja "Diffusion" <me>', buff='Diffusion'},
    {label='UL', name='Unbridled Learning - lets you cast Mighty Guard and other UL spells', kind='ability', row=2, section='ja', cmd='input /ja "Unbridled Learning" <me>', buff_any=UL},
    {label='BUFF', name='Self buffs (gold while Haste + Attack Boost + Defense Boost are up)', kind='white', row=2, section='menus', opens='buff', buff_all={'Haste', 'Attack Boost', 'Defense Boost'}},
    {label='PHYS', name='Physical spells', kind='earth', row=2, section='menus', opens='phys'},
    {label='NUKE', name='Magical spells', kind='black', row=2, section='menus', opens='nuke'},
    {label='HEAL', name='Healing spells', kind='white', row=2, section='menus', opens='heal'},
    {label='SETS', name='Blue spell sets (via bluesets) - the set on now shows above the BLU plate', kind='mode', row=2, section='menus', opens='sets'},
    {label='OMEN', name='Omen AoE rotation - lit while the omenaoe spell set is on. Stays open while you cast down it', kind='black', row=2, section='menus', opens='omen', label_on='omenaoe', menu_timeout=30},
    {label='AOE', name='Pure AoE nuking - lit while the aoe spell set is on. PRE buffs you, then the nukes', kind='black', row=2, section='menus', opens='aoe', label_on='aoe', menu_timeout=30},
    {label='ODYS', name='Odyssey Sheol C Cruel Joke strat - lit while the odyssey spell set is on. Stays open while you work down it', kind='dark', row=2, section='menus', opens='odys', label_on='odyssey', menu_timeout=30},

    -- Row 1: the main bar - weapons | modes | weapon skills.
    {label='SAV', name='Naegling + Nibiru Blade', kind='weapon', group='weapon', cmd='gs c savage', equip={main='Naegling'}},
    {label='TP',  name='TP mode: Normal', kind='mode', cmd='gs c normal', group='tp', on='TP mode = Normal', default=true},
    {label='DT',  name='TP mode: DT (-34%)', kind='defense', cmd='gs c dt', group='tp', on='TP mode = DT'},
    {label='TH',  name='Treasure Hunter +3 (Lucky Egg, Rarab Cap, Volte Bracers) - worn only for Dream Flower / Sheep Song', kind='utility', section='toggle', cmd='gs c th', on='TH mode ON', off='TH mode OFF'},    {label='SB',  name='Savage Blade', kind='ws', cmd='input /ws "Savage Blade" <t>', needs={main='Naegling'}},
    {label='SANG', name='Sanguine Blade - magical dark WS, drains HP', kind='ws', cmd='input /ws "Sanguine Blade" <t>', needs={main='Naegling'}},
    {label='SLP2', name="Char2: Horde Lullaby II on my target", kind='black', section='char2', cmd='send Char2 /ma "Horde Lullaby II" <tid>'},

    -- Menu: spell sets (//bs <set>). Lit = the set that's on. Idle only -
    -- the game won't change spells while engaged.
    {label='MELEE', name='Spell set: melee (Savage Blade, DW III + Triple Attack)', kind='mode', menu='sets', cmd='bs melee', label_on='melee'},
    {label='OMEN', name='Spell set: Omen AoE (melee core + AoE nukes / sleeps)', kind='mode', menu='sets', cmd='bs omenaoe', label_on='omenaoe'},
    {label='NUKE', name='Spell set: nuke / burst', kind='mode', menu='sets', cmd='bs nuke', label_on='nuke'},
    {label='AOE', name='Spell set: pure AoE nukes + pre-pull buffs', kind='mode', menu='sets', cmd='bs aoe', label_on='aoe'},
    {label='ODYS', name='Spell set: Odyssey Cruel Joke (evasion tank + sleeps)', kind='mode', menu='sets', cmd='bs odyssey', label_on='odyssey'},

    -- Menu: Odyssey Sheol C Cruel Joke (needs //bs odyssey and Cruel Joke
    -- learned - from Palloritus, Vagary). Per the SE forum / FFXIAH guide:
    -- buff, pull pack 1, sleep it, pull pack 2 onto it, Cruel Joke both.
    -- Doom kills in 60 s; sleep/bind don't break it, walking 10'+ away does,
    -- and damage wakes them - so DDs leave CJ'd packs alone. Random Deal
    -- (Char3, COR main) can reset Unbridled Learning for another CJ.
    -- Immune families (Bats, Funguar, Imps, Tigers, Worms ...): sleep +
    -- Actinic Burst and let the DDs kill. //oddyweak's data has the list.
    {label='EVA', name='Pre-pull: TP mode Evasion (worn engaged and idle) - you are the tank', kind='defense', menu='odys', cmd='gs c eva', group='tp', on='TP mode = Eva', stay=true},
    {label='OCCU', name='Pre-pull: Occultation - shadows', kind='white', menu='odys', cmd='input /ma "Occultation" <me>', buff='Blink', stay=true},
    {label='COCO', name='Pre-pull: Cocoon - Defense Boost', kind='white', menu='odys', cmd='input /ma "Cocoon" <me>', buff='Defense Boost', stay=true},
    {label='1DRM', name='1. Dream Flower - AoE sleep (dark). Then pull the next pack onto them', kind='dark', menu='odys', cmd='input /ma "Dream Flower" <t>', stay=true},
    {label='SHEEP', name='Sheep Song - AoE sleep (LIGHT): use on Apkallu, or while Dream Flower recasts', kind='light', menu='odys', cmd='input /ma "Sheep Song" <t>', stay=true},
    {label='2CJ', name='2. Unbridled Learning + Cruel Joke - AoE doom, kills in 60 s. Stay within 10 yalms!', kind='dark', menu='odys', cmd='input /ja "Unbridled Learning" <me>; wait 1.5; input /ma "Cruel Joke" <t>', stay=true},
    {label='RDEAL', name="Char3: Random Deal - chance to reset your Unbridled Learning (COR main only)", kind='roll', menu='odys', cmd='send Char3 /ja "Random Deal" <me>', stay=true},
    {label='SLP2', name="Char2: Horde Lullaby II on my target - backup AoE sleep", kind='black', menu='odys', cmd='send Char2 /ma "Horde Lullaby II" <tid>', stay=true},
    {label='FLASH', name='Actinic Burst - AoE flash + enmity (not learned yet on 2026-10-25). For CJ-immune packs', kind='light', menu='odys', cmd='input /ma "Actinic Burst" <t>', stay=true},
    {label='GEIST', name='Geist Wall - AoE dispel + enmity', kind='dark', menu='odys', cmd='input /ma "Geist Wall" <t>', stay=true},
    {label='FRUIT', name='Magic Fruit - big self heal', kind='white', menu='odys', cmd='input /ma "Magic Fruit" <me>', stay=true},
    {label='RESTO', name='Restoral - self heal', kind='white', menu='odys', cmd='input /ma "Restoral" <me>', stay=true},

    -- Menu: pure AoE (needs //bs aoe). PRE is the pre-pull macro: nuke
    -- weapons, then the /RDM 49 buffs longest-lasting first (Protect III,
    -- Shell II, Aquaveil, Stoneskin, Phalanx, Haste, Refresh - no Blink, it
    -- shares Occultation's shadow slot), then Occultation -> Cocoon ->
    -- Memento Mori (last, so the MAB buff is freshest when you open). About
    -- 50 s in all. The waits cover cast + recovery; if one gets interrupted
    -- the rest still go, so check the button lights (gold = every buff up).
    -- Not /RDM: the RDM spells just fail and the BLU ones still go.
    -- Then pull with any nuke - every one is AoE on the pack around <t>.
    {label='PRE', name='Pre-pull: Kaja Rod, /RDM Protect III Shell II Aquaveil Stoneskin Phalanx Haste Refresh, then Occultation Cocoon Memento Mori (~50 s; gold while all are up)', kind='white', menu='aoe', stay=true,
        cmd='gs c nuke; wait 1; '
            .. 'input /ma "Protect III" <me>; wait 4.5; input /ma "Shell II" <me>; wait 4.5; '
            .. 'input /ma "Aquaveil" <me>; wait 8; input /ma "Stoneskin" <me>; wait 10; '
            .. 'input /ma "Phalanx" <me>; wait 6; input /ma "Haste" <me>; wait 6; '
            .. 'input /ma "Refresh" <me>; wait 8; '
            .. 'input /ma "Occultation" <me>; wait 4.5; input /ma "Cocoon" <me>; wait 4.5; input /ma "Memento Mori" <me>',
        buff_all={'Protect', 'Shell', 'Aquaveil', 'Stoneskin', 'Phalanx', 'Haste', 'Refresh',
                  'Blink', 'Defense Boost', 'Magic Atk. Boost'}},
    {label='BURST', name='Burst Affinity - next nuke can magic burst', kind='ability', menu='aoe', stay=true, cmd='input /ja "Burst Affinity" <me>', buff='Burst Affinity'},
    {label='TENEB', name='Tenebral Crush - AoE dark, Defense Down', kind='dark', menu='aoe', stay=true, cmd='input /ma "Tenebral Crush" <t>'},
    {label='FLOE', name='Spectral Floe - AoE ice, Terror', kind='ice', menu='aoe', stay=true, cmd='input /ma "Spectral Floe" <t>'},
    {label='ENTMB', name='Entomb - AoE earth, Petrify', kind='earth', menu='aoe', stay=true, cmd='input /ma "Entomb" <t>'},
    {label='SEAR', name='Searing Tempest - AoE fire, Burn', kind='fire', menu='aoe', stay=true, cmd='input /ma "Searing Tempest" <t>'},
    {label='STORM', name='Silent Storm - AoE wind, Silence', kind='wind', menu='aoe', stay=true, cmd='input /ma "Silent Storm" <t>'},
    {label='SPATE', name='Scouring Spate - AoE water, Attack Down', kind='water', menu='aoe', stay=true, cmd='input /ma "Scouring Spate" <t>'},
    {label='CURSE', name='Cursed Sphere - AoE water', kind='water', menu='aoe', stay=true, cmd='input /ma "Cursed Sphere" <t>'},
    {label='WWIND', name='White Wind - AoE heal', kind='white', menu='aoe', stay=true, cmd='input /ma "White Wind" <me>'},
    {label='FRUIT', name='Magic Fruit - big self heal', kind='white', menu='aoe', stay=true, cmd='input /ma "Magic Fruit" <me>'},
    {label='UPHV', name='Tem. Upheaval - AoE wind, fast recast: spam to finish', kind='wind', menu='aoe', stay=true, cmd='input /ma "Tem. Upheaval" <t>'},

    -- Menu: Omen AoE, in casting order (needs //bs omenaoe). From the Omen
    -- AoE set in Prothescar's BLU guide (ffxiah thread 30626) and the
    -- thread's advice: Dream Flower if the pack is on you, then Entomb, then
    -- Spectral Floe - "kills most mobs". Petrify and Terror keep them off
    -- you once the damage wakes them. Silent Storm silences casters; Tem.
    -- Upheaval (0.5 s cast, 12 s recast) is the filler to finish. All
    -- target <t>; they hit the pack around it. `stay` keeps the menu up.
    -- BEFORE the pull: shadows + Defense Boost (the guide's Omen notes say
    -- keep Occultation up), EVA set, TH on. TH only swaps gear for Dream
    -- Flower / Sheep Song itself, so it no longer weakens the pull gear.
    {label='OCCU', name='Pre-pull: Occultation - shadows. Keep it up', kind='white', menu='omen', cmd='input /ma "Occultation" <me>', buff='Blink', stay=true},
    {label='COCO', name='Pre-pull: Cocoon - Defense Boost', kind='white', menu='omen', cmd='input /ma "Cocoon" <me>', buff='Defense Boost', stay=true},
    {label='TH', name='Treasure Hunter for Dream Flower / Sheep Song (gear swaps only for those casts)', kind='utility', menu='omen', cmd='gs c th', on='TH mode ON', off='TH mode OFF', stay=true},
    {label='EVA', name='TP mode: Evasion (worn engaged and idle) - for pulling', kind='defense', menu='omen', cmd='gs c eva', group='tp', on='TP mode = Eva', stay=true},
    {label='1DRM', name='1. Dream Flower - AoE sleep, no damage: tags the pack with TH (TH on). Damage wakes them', kind='dark', menu='omen', cmd='input /ma "Dream Flower" <t>', stay=true},
    {label='2ENT', name='2. Entomb - AoE earth + Petrify', kind='earth', menu='omen', cmd='input /ma "Entomb" <t>', stay=true},
    {label='3FLOE', name='3. Spectral Floe - AoE ice + Terror', kind='ice', menu='omen', cmd='input /ma "Spectral Floe" <t>', stay=true},
    {label='4STRM', name='4. Silent Storm - AoE wind + Silence (casters)', kind='wind', menu='omen', cmd='input /ma "Silent Storm" <t>', stay=true},
    {label='5UPH', name='5. Tem. Upheaval - AoE wind, 12 s recast: spam to finish', kind='wind', menu='omen', cmd='input /ma "Tem. Upheaval" <t>', stay=true},
    {label='SHEEP', name='Sheep Song - backup AoE sleep while Dream Flower recasts (4 yalms)', kind='light', menu='omen', cmd='input /ma "Sheep Song" <t>', stay=true},
    -- Emergency: the pack is on you and you can't finish a cast. Char2
    -- sleeps it; you aren't casting, so nothing to interrupt. Note: mobs
    -- already asleep won't take Dream Flower, so they can't be TH-tagged
    -- by it afterwards - tag first if you can.
    {label='SLP2', name="EMERGENCY: Char2 sings Horde Lullaby II on my target (AoE sleep) - then step back", kind='black', menu='omen', cmd='send Char2 /ma "Horde Lullaby II" <tid>', stay=true},

    -- Menu: self buffs.
    {label='FLUT', name='Erratic Flutter - Haste (gold while Haste is on you)', kind='white', menu='buff', cmd='input /ma "Erratic Flutter" <me>', buff='Haste'},
    {label='MEDI', name='Nat. Meditation - Attack Boost', kind='white', menu='buff', cmd='input /ma "Nat. Meditation" <me>', buff='Attack Boost'},
    {label='COCO', name='Cocoon - Defense Boost', kind='white', menu='buff', cmd='input /ma "Cocoon" <me>', buff='Defense Boost'},
    {label='TUSK', name='Barrier Tusk - Phalanx', kind='white', menu='buff', cmd='input /ma "Barrier Tusk" <me>', buff='Phalanx'},
    {label='OCCU', name='Occultation - shadows (Blink), scales with blue magic skill', kind='white', menu='buff', cmd='input /ma "Occultation" <me>', buff='Blink'},
    {label='MGRD', name='Mighty Guard - needs Unbridled Learning first', kind='white', menu='buff', cmd='input /ma "Mighty Guard" <me>', buff='Mighty Guard', needs_buff=UL},

    -- Menu: physical spells (on your target).
    {label='SINK', name='Sinker Drill (STR/VIT, crit damage)', kind='earth', menu='phys', cmd='input /ma "Sinker Drill" <t>'},
    {label='HEAVY', name='Heavy Strike (STR)', kind='earth', menu='phys', cmd='input /ma "Heavy Strike" <t>'},
    {label='THRSH', name='Thrashing Assault (STR/DEX)', kind='earth', menu='phys', cmd='input /ma "Thrashing Assault" <t>'},
    {label='LUNGE', name='Sudden Lunge - stun', kind='earth', menu='phys', cmd='input /ma "Sudden Lunge" <t>'},
    {label='TRIAD', name='Paralyzing Triad - paralyze', kind='earth', menu='phys', cmd='input /ma "Paralyzing Triad" <t>'},

    -- Menu: magical spells (on your target).
    {label='TENEB', name='Tenebral Crush (dark, Defense Down)', kind='dark', menu='nuke', cmd='input /ma "Tenebral Crush" <t>'},
    {label='ANVIL', name='Anvil Lightning (thunder)', kind='thunder', menu='nuke', cmd='input /ma "Anvil Lightning" <t>'},
    {label='SEAR', name='Searing Tempest (fire, burn)', kind='fire', menu='nuke', cmd='input /ma "Searing Tempest" <t>'},
    {label='DIFRY', name='Diffusion Ray (light, MND)', kind='light', menu='nuke', cmd='input /ma "Diffusion Ray" <t>'},
    {label='SUBD', name='Subduction (wind)', kind='wind', menu='nuke', cmd='input /ma "Subduction" <t>'},
    {label='ENTMB', name='Entomb (earth, VIT)', kind='earth', menu='nuke', cmd='input /ma "Entomb" <t>'},

    -- Menu: healing. Party targets use <stpt>: click, then pick who.
    {label='FRUIT', name='Magic Fruit (party target)', kind='white', menu='heal', cmd='input /ma "Magic Fruit" <stpt>'},
    {label='CARR', name='Wild Carrot (party target)', kind='white', menu='heal', cmd='input /ma "Wild Carrot" <stpt>'},
    {label='PLEN', name='Plenilune Embrace (party target)', kind='white', menu='heal', cmd='input /ma "Plenilune Embrace" <stpt>'},
    {label='WIND', name='White Wind - party AoE heal, scales with your HP', kind='white', menu='heal', cmd='input /ma "White Wind" <me>'},
    -- Char3 (COR) on command: Bolter's lights while the roll is on you.
    {label='BOLT', name="Char3: Bolter's Roll - movement speed (lucky 3, unlucky 9)", kind='roll', lucky=3, unlucky=9, section='char3', cmd='send Char3 /ja "Bolter\'s Roll" <me>', buff="Bolter's Roll"},
    {label='DBL', name="Char3: Double-Up his roll", kind='roll', section='char3', cmd='send Char3 /ja "Double-Up" <me>'},
    {label='JIG', name="Char3: Spectral Jig - Sneak + Invisible on himself (needs DNC main or sub)", kind='ability', section='char3', cmd='send Char3 /ja "Spectral Jig" <me>'},
}
