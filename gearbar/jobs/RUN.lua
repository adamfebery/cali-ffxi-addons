-- RUN buttons (Char3). Field guide: jobs/WAR.lua.
return {
    {label='AET', name='Aettir + Mensch Strap +1 (tank)', kind='weapon', cmd='gs c aettir',  group='weapon', equip={main='Aettir'}},
    {label='GS',  name='Great Sword - Beryllium Sword', kind='weapon',  cmd='gs c gs',      group='weapon', equip={main='Beryllium Sword'}},
    {label='GA',  name='Great Axe - Hepatizon Axe +1',  kind='weapon',  cmd='gs c ga',      group='weapon', equip={main='Hepatizon Axe +1'}},
    {label='ELT', name='Eletta Sword (Lunge / Swipe)',  kind='weapon',  cmd='gs c eletta',  group='weapon', equip={main='Eletta Sword'}},
    {label='PDT', name='Defense: PDT (max physical)',   kind='defense', cmd='gs c pdt',     group='def', on='DEFENSE = PDT'},
    {label='MDT', name='Defense: MDT (max magic evasion)', kind='defense', cmd='gs c mdt',  group='def', on='DEFENSE = MDT'},
    {label='DT',  name='Defense: DT (hybrid)',          kind='defense', cmd='gs c dt',      group='def', on='DEFENSE = DT'},
    {label='OFF', name='Defense off',                   kind='mode',    cmd='gs c off',     group='def', on='DEFENSE OFF', default=true},
    {label='PXR', name='Phalanx received +4 (Futhark Bandeau)', kind='utility', cmd='gs c pxr'},
    {label='DIM', name='Dimidiation',                   kind='ws',      cmd='input /ws "Dimidiation" <t>', needs={main='Aettir'}},
    {label='RES', name='Resolution',                    kind='ws',      cmd='input /ws "Resolution" <t>',  needs={main='Beryllium Sword'}},
}
