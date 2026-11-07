-- SCH buttons (Char1). Field guide: jobs/WAR.lua.
--
-- Two rows. The top row's STRAT / HELIX / STORM / HEAL / ENF / DRAIN buttons
-- are pop-out menus: click one and its buttons replace the bar (with BACK);
-- pick one, press BACK, or leave it alone a few seconds and the bar returns.
--
-- Stratagems (and both Addendums) share one charge timer; `charges=5` is the
-- level-99 count. Light stratagems grey out unless Light Arts / Addendum:
-- White is up, dark ones unless Dark Arts / Addendum: Black.
-- Party-target spells use <stpt>: click, then pick who in the game's selector.
-- Helix II / Storm II are job-point spells; swap the names in if you have them.
local LIGHT = {'Light Arts', 'Addendum: White'}
local DARK = {'Dark Arts', 'Addendum: Black'}
local STORMS = {'Firestorm', 'Hailstorm', 'Windstorm', 'Sandstorm', 'Thunderstorm',
                'Rainstorm', 'Aurorastorm', 'Voidstorm'}

return {
    -- Row 2: Arts + Sublimation | the pop-out menus.
    {label='LA', name='Light Arts', kind='arts', row=2, section='arts', cmd='input /ja "Light Arts" <me>', buff='Light Arts'},
    {label='DA', name='Dark Arts', kind='arts', row=2, section='arts', cmd='input /ja "Dark Arts" <me>', buff='Dark Arts'},
    {label='ADDW', name='Addendum: White (uses a stratagem charge)', kind='arts', row=2, section='arts', cmd='input /ja "Addendum: White" <me>', buff='Addendum: White', needs_buff={'Light Arts'}, charges=5},
    {label='ADDB', name='Addendum: Black (uses a stratagem charge)', kind='arts', row=2, section='arts', cmd='input /ja "Addendum: Black" <me>', buff='Addendum: Black', needs_buff={'Dark Arts'}, charges=5},
    {label='SUBL', name='Sublimation - gold while charging, pulses cyan when complete', kind='arts', row=2, section='arts', cmd='input /ja "Sublimation" <me>', buff='Sublimation: Activated', ready_buff='Sublimation: Complete'},
    {label='STRAT', name='Light stratagems', kind='light', row=2, section='menus', opens='lstrat', needs_buff=LIGHT, buff_any={'Penury', 'Celerity', 'Accession', 'Rapture', 'Perpetuance'}},
    {label='STRAT', name='Dark stratagems', kind='dark', row=2, section='menus', opens='dstrat', needs_buff=DARK, buff_any={'Parsimony', 'Alacrity', 'Manifestation', 'Ebullience', 'Immanence'}},
    {label='HELIX', name='Helixes', kind='black', row=2, section='menus', opens='helix'},
    {label='STORM', name='Storms (gold while one is on you)', kind='white', row=2, section='menus', opens='storm', buff_any=STORMS},
    {label='HEAL', name='Cures and support', kind='white', row=2, section='menus', opens='heal'},
    {label='PRE', name='Party prebuff: Reraise > Accession Protect > Accession Shell > Accession + Perpetuance Regen (best tiers you know; click again to cancel)', kind='white', row=2, section='menus', cmd='gs c prebuff', on='prebuff running', off='prebuff stopped'},
    {label='BUFF', name='Regen IV / Protect V / Shell V (gold while all three are on you)', kind='white', row=2, section='menus', opens='buff', buff_all={'Regen', 'Protect', 'Shell'}},
    {label='ENF', name='Enfeebles', kind='black', row=2, section='menus', opens='enf'},
    {label='DRAIN', name='Drain / Aspir / Kaustra / Klimaform', kind='black', row=2, section='menus', opens='dark', buff_any={'Klimaform'}},

    -- Row 1: the main bar - weapons | modes | weapon skills.
    {label='STF', name='Venabulum + Tzacab Grip (nuke / melee staff)', kind='weapon', group='weapon', cmd='gs c staff', equip={main='Venabulum'}},
    {label='MARN', name='Marin Staff + Tzacab Grip (Fast Cast, wind MAB)', kind='weapon', group='weapon', cmd='gs c marin', equip={main='Marin Staff'}},
    {label='CLUB', name="Cagliostro's Rod + Culminus", kind='weapon', group='weapon', cmd='gs c club', equip={main="Cagliostro's Rod"}},
    {label='POLE', name='Malignance Pole + Tzacab Grip (DT-20%, survival)', kind='weapon', group='weapon', cmd='gs c pole', equip={main='Malignance Pole'}},
    {label='MELEE', name='Melee mode: TP set while engaged', kind='mode', section='modes', cmd='gs c melee', on='Melee mode ON', off='Melee mode OFF'},
    {label='MB', name='Magic Burst mode (Acad. Gown +3 on nukes: MB 17%)', kind='mode', section='modes', cmd='gs c mb', on='Magic Burst mode ON', off='Magic Burst mode OFF'},
    {label='ACC', name='Nuke accuracy mode (full Academic: MAcc over MAB)', kind='mode', section='modes', cmd='gs c acc', on='Nuke mode = Accuracy', off='Nuke mode = Normal'},
    {label='CATA', name='Cataclysm (magical dark) - needs /WHM /WAR /MNK /PLD /GEO', kind='ws', cmd='input /ws "Cataclysm" <t>', subjob='WHM WAR MNK PLD GEO'},
    {label='SHAT', name='Shattersoul (merit weapon skill)', kind='ws', cmd='input /ws "Shattersoul" <t>'},
    {label='SPRT', name='Spirit Taker - turns damage into MP', kind='ws', cmd='input /ws "Spirit Taker" <t>'},

    -- Menu: light stratagems.
    {label='PENU', name='Penury - next white spell costs half MP', kind='arts', menu='lstrat', cmd='input /ja "Penury" <me>', buff='Penury', needs_buff=LIGHT, charges=5},
    {label='CELE', name='Celerity - next white spell casts faster', kind='arts', menu='lstrat', cmd='input /ja "Celerity" <me>', buff='Celerity', needs_buff=LIGHT, charges=5},
    {label='ACCE', name='Accession - next white spell hits the party', kind='arts', menu='lstrat', cmd='input /ja "Accession" <me>', buff='Accession', needs_buff=LIGHT, charges=5},
    {label='RAPT', name='Rapture - next white spell more potent', kind='arts', menu='lstrat', cmd='input /ja "Rapture" <me>', buff='Rapture', needs_buff=LIGHT, charges=5},
    {label='PERP', name='Perpetuance - next enhancing spell lasts longer', kind='arts', menu='lstrat', cmd='input /ja "Perpetuance" <me>', buff='Perpetuance', needs_buff=LIGHT, charges=5},

    -- Menu: dark stratagems.
    {label='PARS', name='Parsimony - next black spell costs half MP', kind='arts', menu='dstrat', cmd='input /ja "Parsimony" <me>', buff='Parsimony', needs_buff=DARK, charges=5},
    {label='ALAC', name='Alacrity - next black spell casts faster', kind='arts', menu='dstrat', cmd='input /ja "Alacrity" <me>', buff='Alacrity', needs_buff=DARK, charges=5},
    {label='MANI', name='Manifestation - next black spell hits an area', kind='arts', menu='dstrat', cmd='input /ja "Manifestation" <me>', buff='Manifestation', needs_buff=DARK, charges=5},
    {label='EBUL', name='Ebullience - next black spell more potent', kind='arts', menu='dstrat', cmd='input /ja "Ebullience" <me>', buff='Ebullience', needs_buff=DARK, charges=5},
    {label='IMMA', name='Immanence - next elemental spell can skillchain', kind='arts', menu='dstrat', cmd='input /ja "Immanence" <me>', buff='Immanence', needs_buff=DARK, charges=5},

    -- Menu: helixes (on your target).
    {label='HELIX', name='Pyrohelix (fire)', kind='fire', menu='helix', cmd='input /ma "Pyrohelix" <t>'},
    {label='HELIX', name='Cryohelix (ice)', kind='ice', menu='helix', cmd='input /ma "Cryohelix" <t>'},
    {label='HELIX', name='Anemohelix (wind)', kind='wind', menu='helix', cmd='input /ma "Anemohelix" <t>'},
    {label='HELIX', name='Geohelix (earth)', kind='earth', menu='helix', cmd='input /ma "Geohelix" <t>'},
    {label='HELIX', name='Ionohelix (thunder)', kind='thunder', menu='helix', cmd='input /ma "Ionohelix" <t>'},
    {label='HELIX', name='Hydrohelix (water)', kind='water', menu='helix', cmd='input /ma "Hydrohelix" <t>'},
    {label='HELIX', name='Luminohelix (light)', kind='light', menu='helix', cmd='input /ma "Luminohelix" <t>'},
    {label='HELIX', name='Noctohelix (dark - Archon Ring via GearSwap)', kind='dark', menu='helix', cmd='input /ma "Noctohelix" <t>'},

    -- Menu: storms (on you).
    {label='STORM', name='Firestorm', kind='fire', menu='storm', cmd='input /ma "Firestorm" <me>', buff='Firestorm'},
    {label='STORM', name='Hailstorm', kind='ice', menu='storm', cmd='input /ma "Hailstorm" <me>', buff='Hailstorm'},
    {label='STORM', name='Windstorm', kind='wind', menu='storm', cmd='input /ma "Windstorm" <me>', buff='Windstorm'},
    {label='STORM', name='Sandstorm', kind='earth', menu='storm', cmd='input /ma "Sandstorm" <me>', buff='Sandstorm'},
    {label='STORM', name='Thunderstorm', kind='thunder', menu='storm', cmd='input /ma "Thunderstorm" <me>', buff='Thunderstorm'},
    {label='STORM', name='Rainstorm', kind='water', menu='storm', cmd='input /ma "Rainstorm" <me>', buff='Rainstorm'},
    {label='STORM', name='Aurorastorm', kind='light', menu='storm', cmd='input /ma "Aurorastorm" <me>', buff='Aurorastorm'},
    {label='STORM', name='Voidstorm', kind='dark', menu='storm', cmd='input /ma "Voidstorm" <me>', buff='Voidstorm'},

    -- Menu: cures and support.
    {label='CURE', name='Cure IV', kind='white', menu='heal', cmd='input /ma "Cure IV" <stpt>'},
    {label='REGN', name='Regen V (Lugh\'s Cape: Regen duration +15)', kind='white', menu='heal', cmd='input /ma "Regen V" <stpt>'},
    {label='ADLO', name='Adloquium', kind='white', menu='heal', cmd='input /ma "Adloquium" <stpt>'},
    {label='ERAS', name='Erase', kind='white', menu='heal', cmd='input /ma "Erase" <stpt>'},
    {label='SKIN', name='Stoneskin', kind='white', menu='heal', cmd='input /ma "Stoneskin" <me>'},

    -- Menu: buffs. Each lights gold while it's on you. Accession first makes
    -- Protect / Shell / Regen hit the whole party.
    {label='SELF', name='Self buffs: Stoneskin > Blink > Aquaveil', kind='white', menu='buff', cmd='gs c selfbuff'},
    {label='RGN4', name='Regen IV (Lugh\'s Cape: Regen duration +15)', kind='white', menu='buff', cmd='input /ma "Regen IV" <stpt>', buff='Regen'},
    {label='PRO5', name='Protect V (buy from Brave Ox, Rabao F-7)', kind='white', menu='buff', cmd='input /ma "Protect V" <stpt>', buff='Protect'},
    {label='SHL5', name='Shell V (buy from Brave Ox, Rabao F-7)', kind='white', menu='buff', cmd='input /ma "Shell V" <stpt>', buff='Shell'},

    -- Menu: enfeebles.
    {label='SLP2', name='Sleep II', kind='black', menu='enf', cmd='input /ma "Sleep II" <t>'},
    {label='DISP', name='Dispel', kind='black', menu='enf', cmd='input /ma "Dispel" <t>'},
    {label='BRK', name='Break', kind='black', menu='enf', cmd='input /ma "Break" <t>'},

    -- Menu: dark magic.
    {label='DRN', name='Drain', kind='black', menu='dark', cmd='input /ma "Drain" <t>'},
    {label='ASP2', name='Aspir II', kind='black', menu='dark', cmd='input /ma "Aspir II" <t>'},
    {label='KAUS', name='Kaustra (dark - Archon Ring via GearSwap)', kind='black', menu='dark', cmd='input /ma "Kaustra" <t>'},
    {label='KLIM', name='Klimaform', kind='black', menu='dark', cmd='input /ma "Klimaform" <me>', buff='Klimaform'},
    -- Char3 (COR) on command: Bolter's lights while the roll is on you.
    {label='BOLT', name="Char3: Bolter's Roll - movement speed (lucky 3, unlucky 9)", kind='roll', lucky=3, unlucky=9, section='char3', cmd='send Char3 /ja "Bolter\'s Roll" <me>', buff="Bolter's Roll"},
    {label='DBL', name="Char3: Double-Up his roll", kind='roll', section='char3', cmd='send Char3 /ja "Double-Up" <me>'},
    {label='JIG', name="Char3: Spectral Jig - Sneak + Invisible on himself (needs DNC main or sub)", kind='ability', section='char3', cmd='send Char3 /ja "Spectral Jig" <me>'},
}
