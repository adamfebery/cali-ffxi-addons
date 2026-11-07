-- SAM buttons (Char1). Field guide: jobs/WAR.lua.
return {
    -- Row 2 (above the main bar): job abilities. Hasso and Third Eye get the
    -- gold ring while they're up. The jumps only appear on /DRG: Jump (sub
    -- Lv10), High Jump (Lv35) and Super Jump (Lv50 - needs master levels).
    {label='HASSO', name='Hasso - two-handed Haste / STR (Wakido Kote +3 via GearSwap)', kind='ability', row=2, section='sam', cmd='input /ja "Hasso" <me>', buff='Hasso'},
    {label='EYE',  name='Third Eye - anticipate / counter the next attack', kind='ability', row=2, section='sam', cmd='input /ja "Third Eye" <me>', buff='Third Eye'},
    {label='MEDI', name='Meditate - TP over time (Wakido Kabuto +2 + Smertrios via GearSwap)', kind='ability', row=2, section='sam', cmd='input /ja "Meditate" <me>'},
    {label='KONZ', name='Konzen-ittai - your next WS can open a skillchain', kind='ability', row=2, section='sam', cmd='input /ja "Konzen-ittai" <t>'},
    {label='JUMP', name='Jump (/DRG)',                   kind='ability', row=2, section='drg', subjob='DRG', cmd='input /ja "Jump" <t>'},
    {label='HIGH', name='High Jump (/DRG) - also sheds enmity', kind='ability', row=2, section='drg', subjob='DRG', cmd='input /ja "High Jump" <t>'},
    {label='SUPER', name='Super Jump (/DRG) - drops you off the enmity list; needs sub Lv50 (master levels)', kind='ability', row=2, section='drg', subjob='DRG', cmd='input /ja "Super Jump" <t>'},

    -- Row 1: the main bar.
    {label='GKT', name='Great Katana - Masamune',       kind='weapon',  cmd='gs c gkt',     group='weapon', equip={main='Masamune'}},
    {label='POL', name='Polearm - Shining One',         kind='weapon',  cmd='gs c polearm', group='weapon', equip={main='Shining One'}},
    {label='TP',  name='TP mode: Normal',               kind='mode',    cmd='gs c normal',  group='tp', on='TP mode = Normal', default=true},
    {label='DT',  name='TP mode: DT (-50% capped)',     kind='defense', cmd='gs c dt',      group='tp', on='TP mode = DT'},
    {label='TH',  name='Treasure Hunter +4 - locks ammo/head/hands/legs in Lucky Egg, Wh. Rarab Cap +1, Volte Bracers, Valorous Hose (WS too)', kind='utility', cmd='gs c th', on='TH mode ON', off='TH mode OFF'},
    {label='SLP2', name="Char2: Horde Lullaby II on my target", kind='black', section='char2', cmd='send Char2 /ma "Horde Lullaby II" <tid>'},
    {label='FUDO', name='Tachi: Fudo',                  kind='ws',      cmd='input /ws "Tachi: Fudo" <t>',  needs={main='Masamune'}},
    {label='SHOH', name='Tachi: Shoha',                 kind='ws',      cmd='input /ws "Tachi: Shoha" <t>', needs={main='Masamune'}},
    {label='KASH', name='Tachi: Kasha',                 kind='ws',      cmd='input /ws "Tachi: Kasha" <t>', needs={main='Masamune'}},
    {label='ID',  name='Impulse Drive',                 kind='ws',      cmd='input /ws "Impulse Drive" <t>', needs={main='Shining One'}},
    {label='STAR', name='Stardiver',                    kind='ws',      cmd='input /ws "Stardiver" <t>',     needs={main='Shining One'}},
    -- Char3 (COR) on command: Bolter's lights while the roll is on you.
    {label='BOLT', name="Char3: Bolter's Roll - movement speed (lucky 3, unlucky 9)", kind='roll', lucky=3, unlucky=9, section='char3', cmd='send Char3 /ja "Bolter\'s Roll" <me>', buff="Bolter's Roll"},
    {label='DBL', name="Char3: Double-Up his roll", kind='roll', section='char3', cmd='send Char3 /ja "Double-Up" <me>'},
    {label='JIG', name="Char3: Spectral Jig - Sneak + Invisible on himself (needs DNC main or sub)", kind='ability', section='char3', cmd='send Char3 /ja "Spectral Jig" <me>'},
}
