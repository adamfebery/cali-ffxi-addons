-- BRD buttons (Char2). Field guide: jobs/WAR.lua.
return {
    {label='MEL', name='Melee - Naegling (Fusetto +2 when dual wielding)', kind='weapon', cmd='gs c weapons', group='weapon', equip={main='Naegling'}},
    {label='SONG', name='Songs - Kali',                 kind='weapon',  cmd='gs c songs',   group='weapon', equip={main='Kali'}},
    {label='DT',  name='DT mode (-43%)',                kind='defense', cmd='gs c dt',      on='DT mode ON', off='DT mode OFF'},
    {label='SB',  name='Savage Blade',                  kind='ws',      cmd='input /ws "Savage Blade" <t>',  needs={main='Naegling'}},
}
