-- COR buttons (Char1). Field guide: jobs/WAR.lua.
return {
    -- Row 3 (top): Phantom Rolls. Gold ring while that roll is on you.
    -- GearSwap's sets.precast.CorsairRoll already brings Compensator, Lanun
    -- Knife and the roll gear. Lucky / unlucky from bg-wiki.
    {label='HUNT', name="Hunter's Roll - Accuracy / Ranged Accuracy (lucky 4, unlucky 8)", kind='roll', lucky=4, unlucky=8, row=3, cmd='input /ja "Hunter\'s Roll" <me>', buff="Hunter's Roll"},
    {label='SAM', name='Samurai Roll - Store TP (lucky 2, unlucky 6)',          kind='roll', lucky=2, unlucky=6, row=3, cmd='input /ja "Samurai Roll" <me>',  buff='Samurai Roll'},
    {label='COR', name="Corsair's Roll - EXP / CP / EP (lucky 5, unlucky 9)",   kind='roll', lucky=5, unlucky=9, row=3, cmd='input /ja "Corsair\'s Roll" <me>', buff="Corsair's Roll"},
    {label='WIZ', name="Wizard's Roll - Magic Attack Bonus (lucky 5, unlucky 9)", kind='roll', lucky=5, unlucky=9, row=3, cmd='input /ja "Wizard\'s Roll" <me>', buff="Wizard's Roll"},
    {label='BOLT', name="Bolter's Roll - Movement speed (lucky 3, unlucky 9)",  kind='roll', lucky=3, unlucky=9, row=3, cmd='input /ja "Bolter\'s Roll" <me>', buff="Bolter's Roll"},

    {label='DBL', name='Double-Up - roll again (glows while you can)',          kind='roll', row=3, section='double', cmd='input /ja "Double-Up" <me>', ready_buff='Double-Up Chance'},

    -- Row 2 (above the main bar): Quick Draw. GearSwap already dresses
    -- these through sets.midcast.CorsairShot (Light / Dark Shot get their
    -- magic-accuracy sets). `debuff` = the effects that shot enhances
    -- (bg-wiki Quick Draw); the button glows cyan while your target has one.
    {label='FIRE', name='Fire Shot - fire damage, boosts Burn',       kind='fire',    row=2, section='qd', charges=2, cmd='input /ja "Fire Shot" <t>', debuff={'Burn'}},
    {label='ICE', name='Ice Shot - boosts Paralyze, Frost',       kind='ice',     row=2, section='qd', charges=2, cmd='input /ja "Ice Shot" <t>', debuff={'Paralyze', 'Frost'}},
    {label='WIND', name='Wind Shot - wind damage, boosts Choke',      kind='wind',    row=2, section='qd', charges=2, cmd='input /ja "Wind Shot" <t>', debuff={'Choke'}},
    {label='EARTH', name='Earth Shot - boosts Slow, Rasp',    kind='earth',   row=2, section='qd', charges=2, cmd='input /ja "Earth Shot" <t>', debuff={'Slow', 'Rasp'}},
    {label='THUN', name='Thunder Shot - thunder damage, boosts Shock', kind='thunder', row=2, section='qd', charges=2, cmd='input /ja "Thunder Shot" <t>', debuff={'Shock'}},
    {label='WATR', name='Water Shot - water damage, boosts Drown',    kind='water',   row=2, section='qd', charges=2, cmd='input /ja "Water Shot" <t>', debuff={'Drown'}},
    {label='LGHT', name='Light Shot - sleep, boosts Dia (Alt+L)',     kind='light',   row=2, section='qd', charges=2, cmd='input /ja "Light Shot" <t>', debuff={'Dia'}},
    {label='DARK', name='Dark Shot - dispel, boosts Bio, Blind (Alt+D)',     kind='dark',    row=2, section='qd', charges=2, cmd='input /ja "Dark Shot" <t>', debuff={'Bio', 'Blind'}},

    -- Row 1: the main bar.
    {label='WPN', name='Weapons - Naegling + your chosen gun (DW on /NIN /DNC)', kind='weapon', cmd='gs c weapons', equip={main='Naegling'}},
    {label='DOOM', name='Gun: Doomsday (Leaden at 2000+ TP, melee DA/STR) - resets TP', kind='weapon', cmd='gs c doomsday', group='gun', equip={range='Doomsday'}},
    {label='ANAR', name='Gun: Anarchy +2 (TP Bonus +1000, Leaden below 2000) - resets TP', kind='weapon', cmd='gs c anarchy', group='gun', equip={range='Anarchy +2'}},
    {label='MEL', name='TP mode: Melee',                kind='mode',    cmd='gs c melee',   group='tp', on='TP mode = Melee', default=true},
    {label='RNG', name='TP mode: Ranged',               kind='mode',    cmd='gs c ranged',  group='tp', on='TP mode = Ranged'},
    -- Weapon skills, in the order you use them.
    {label='SLUG', name='Slug Shot (flat damage; -50 ranged acc below 2000 TP)', kind='ws', cmd='input /ws "Slug Shot" <t>'},
    {label='SB',  name='Savage Blade',                  kind='ws',      cmd='input /ws "Savage Blade" <t>',  needs={main='Naegling'}},
    {label='LEAD', name='Leaden Salute (Anarchy below 2000 TP, Doomsday from 2000)', kind='ws', cmd='input /ws "Leaden Salute" <t>'},
    {label='WILD', name='Wildfire (hold Doomsday; unlock: Kupofried\'s Weapon Skill Moogle Magic)', kind='ws', cmd='input /ws "Wildfire" <t>'},
    {label='LAST', name='Last Stand',                   kind='ws',      cmd='input /ws "Last Stand" <t>'},
}
