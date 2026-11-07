-- WAR buttons (Char1). One button per line - tools/make_art.py reads the
-- label and kind from each line to draw its face.
--
--   label   2-5 characters drawn on the button
--   name    tooltip title
--   kind    weapon | ws | defense | mode | utility  (sets the colour)
--   cmd     Windower command sent on click
--   group   buttons sharing a group light up one at a time
--   equip   lit while these are equipped, e.g. {main='Naegling'}
--   on/off  lit / unlit when a chat line contains this text (or all of a
--           list of texts) - GearSwap's own "GearSwap: ..." messages
--   default lit until a chat line says otherwise (GearSwap's default mode)
--   needs   dimmed unless these are equipped (the weapon a WS needs)
--   subjob  only shown on these subjobs, e.g. 'NIN DNC'
--   row     1 = main bar (default); 2, 3 ... stack above it
--   section buttons with different sections get a gap between them
--           (defaults to kind)
--   buff    lit while you have this buff, e.g. "Samurai Roll"
--   buff_any / buff_all  lit while ANY / ALL of these buffs are on you
--   opens / menu  pop-out menus: `opens='x'` shows the `menu='x'` buttons
--   needs_buff  dimmed unless you have ANY of these, e.g.
--           {'Light Arts', 'Addendum: White'}
--   ready_buff  glows cyan (pulsing) while you have this buff, e.g.
--           'Double-Up Chance' - "press this now"
--   lucky / unlucky   numbers drawn as green / red badges on the face
--           (Phantom Rolls); re-run tools/make_art.py after changing them
--   debuff  glows cyan (pulsing) while your target has one of these,
--           e.g. {'Dia'} - status names from res/buffs.lua; Paralyze and
--           Blind are accepted for paralysis / blindness
return {
    {label='GA',  name='Great Axe - Lightreaver',       kind='weapon',  cmd='gs c ga',      group='weapon', equip={main='Lightreaver'}},
    {label='SWD', name='Sword - Naegling + Blurred Shield', kind='weapon', cmd='gs c sword', group='weapon', equip={main='Naegling', sub='Blurred Shield'}},
    {label='DW',  name='Dual Wield - Naegling + Sangarius +1', kind='weapon', cmd='gs c dw', group='weapon', equip={main='Naegling', sub='Sangarius +1'}, subjob='NIN DNC'},
    {label='CLB', name='Club - Mafic Cudgel',           kind='weapon',  cmd='gs c club',    group='weapon', equip={main='Mafic Cudgel'}},
    {label='POL', name='Polearm - Shining One',         kind='weapon',  cmd='gs c polearm', group='weapon', equip={main='Shining One'}},
    {label='DT',  name='DT mode (-32%)',                kind='defense', cmd='gs c dt',      on='DT mode ON', off='DT mode OFF'},
    {label='TH',  name='Treasure Hunter +3 (Lucky Egg, Volte Bracers, Valorous Hose; ammo/hands/legs locked)', kind='utility', section='toggle', cmd='gs c th', on='TH mode ON', off='TH mode OFF'},
    {label='SLP2', name="Char2: Horde Lullaby II on my target", kind='black', section='char2', cmd='send Char2 /ma "Horde Lullaby II" <tid>'},
    {label='UPH', name='Upheaval',                      kind='ws',      cmd='input /ws "Upheaval" <t>',      needs={main='Lightreaver'}},
    {label='SB',  name='Savage Blade',                  kind='ws',      cmd='input /ws "Savage Blade" <t>',  needs={main='Naegling'}},
    {label='JDG', name='Judgment',                      kind='ws',      cmd='input /ws "Judgment" <t>',      needs={main='Mafic Cudgel'}},
    {label='ID',  name='Impulse Drive',                 kind='ws',      cmd='input /ws "Impulse Drive" <t>', needs={main='Shining One'}},
    -- Char3 (COR) on command: Bolter's lights while the roll is on you.
    {label='BOLT', name="Char3: Bolter's Roll - movement speed (lucky 3, unlucky 9)", kind='roll', lucky=3, unlucky=9, section='char3', cmd='send Char3 /ja "Bolter\'s Roll" <me>', buff="Bolter's Roll"},
    {label='DBL', name="Char3: Double-Up his roll", kind='roll', section='char3', cmd='send Char3 /ja "Double-Up" <me>'},
    {label='JIG', name="Char3: Spectral Jig - Sneak + Invisible on himself (needs DNC main or sub)", kind='ability', section='char3', cmd='send Char3 /ja "Spectral Jig" <me>'},
}
