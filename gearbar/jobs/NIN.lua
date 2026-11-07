-- NIN buttons (Char1). Field guide: jobs/WAR.lua.
return {
    {label='KAT', name='Katana - Gokotai + Tauret',     kind='weapon',  cmd='gs c katana',  group='weapon', equip={main='Gokotai'}},
    {label='SWD', name='Sword - Naegling + Gokotai',    kind='weapon',  cmd='gs c sword',   group='weapon', equip={main='Naegling'}},
    {label='HA',  name='TP mode: High Accuracy',        kind='mode',    cmd='gs c highacc', group='tp', on='TP mode = HighAcc', default=true},
    {label='MA',  name='TP mode: Mid Accuracy',         kind='mode',    cmd='gs c midacc',  group='tp', on='TP mode = MidAcc'},
    {label='LA',  name='TP mode: Low Accuracy (capped magic haste)', kind='mode', cmd='gs c lowacc', group='tp', on='TP mode = LowAcc'},
    {label='DT',  name='TP mode: DT (-34%)',            kind='defense', cmd='gs c dt',      group='tp', on='TP mode = DT'},
    {label='CST', name='Ammo: Coiste Bodhar',           kind='utility', cmd='gs c coiste',  group='ammo', on='ammo = Coiste', default=true},
    {label='SHU', name='Ammo: Shuriken',                kind='utility', cmd='gs c shuriken', group='ammo', on={'ammo =', 'Shuriken'}},
    {label='ICHI', name='Utsusemi: Ichi',               kind='utility', cmd='input /ma "Utsusemi: Ichi" <me>'},
    {label='NI',  name='Utsusemi: Ni',                  kind='utility', cmd='input /ma "Utsusemi: Ni" <me>'},
    {label='KU',  name='Blade: Ku',                     kind='ws',      cmd='input /ws "Blade: Ku" <t>',     needs={main='Gokotai'}},
    {label='SB',  name='Savage Blade',                  kind='ws',      cmd='input /ws "Savage Blade" <t>',  needs={main='Naegling'}},
    -- Char3 (COR) on command: Bolter's lights while the roll is on you.
    {label='BOLT', name="Char3: Bolter's Roll - movement speed (lucky 3, unlucky 9)", kind='roll', lucky=3, unlucky=9, section='char3', cmd='send Char3 /ja "Bolter\'s Roll" <me>', buff="Bolter's Roll"},
    {label='DBL', name="Char3: Double-Up his roll", kind='roll', section='char3', cmd='send Char3 /ja "Double-Up" <me>'},
    {label='JIG', name="Char3: Spectral Jig - Sneak + Invisible on himself (needs DNC main or sub)", kind='ability', section='char3', cmd='send Char3 /ja "Spectral Jig" <me>'},
}
