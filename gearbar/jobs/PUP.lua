-- PUP buttons (Char1). Field guide: jobs/WAR.lua.
return {
    -- Row 3: maneuvers, in element colours. Gold while that maneuver is up
    -- (the bar can't show how many stacks). They share one timer.
    {label='FIRE', name='Fire Maneuver - STR (melee damage; Valoredge / Sharpshot)', kind='fire', row=3, cmd='input /pet "Fire Maneuver" <me>', buff='Fire Maneuver'},
    {label='ICE',  name='Ice Maneuver - INT (automaton nukes)', kind='ice', row=3, cmd='input /pet "Ice Maneuver" <me>', buff='Ice Maneuver'},
    {label='WIND', name='Wind Maneuver - AGI (ranged; Sharpshot)', kind='wind', row=3, cmd='input /pet "Wind Maneuver" <me>', buff='Wind Maneuver'},
    {label='EARTH', name='Earth Maneuver - VIT (tanking)', kind='earth', row=3, cmd='input /pet "Earth Maneuver" <me>', buff='Earth Maneuver'},
    {label='THUN', name='Thunder Maneuver - DEX (accuracy, crits)', kind='thunder', row=3, cmd='input /pet "Thunder Maneuver" <me>', buff='Thunder Maneuver'},
    {label='WATER', name='Water Maneuver - MND (automaton healing / enfeebles)', kind='water', row=3, cmd='input /pet "Water Maneuver" <me>', buff='Water Maneuver'},
    {label='LIGHT', name='Light Maneuver - CHR / HP (tank: Fire-Fire-Light)', kind='light', row=3, cmd='input /pet "Light Maneuver" <me>', buff='Light Maneuver'},
    {label='DARK', name='Dark Maneuver - MP (casters)', kind='dark', row=3, cmd='input /pet "Dark Maneuver" <me>', buff='Dark Maneuver'},

    -- Row 2: automaton control | the rarer abilities in a pop-out.
    {label='ACTV', name='Activate - call the automaton', kind='ability', row=2, section='call', cmd='input /ja "Activate" <me>'},
    {label='DEUS', name='Deus Ex Automata - call it back at reduced HP/MP (works on Activate\'s timer)', kind='ability', row=2, section='call', cmd='input /ja "Deus Ex Automata" <me>'},
    {label='DEPLY', name='Deploy - send the automaton at your target', kind='ability', row=2, section='pet', cmd='input /pet "Deploy" <t>'},
    {label='RETR', name='Retrieve - call the automaton back to you', kind='ability', row=2, section='pet', cmd='input /pet "Retrieve" <me>'},
    {label='REPR', name='Repair - needs an oil (GearSwap loads Automat. Oil +3)', kind='white', row=2, section='pet', cmd='input /ja "Repair" <me>'},
    {label='MAINT', name='Maintenance - clears automaton debuffs (uses an oil)', kind='white', row=2, section='pet', cmd='input /ja "Maintenance" <me>'},
    {label='COOL', name='Cooldown - clears Overload / cuts burden (pulses cyan while you are Overloaded)', kind='ability', row=2, section='pet', cmd='input /ja "Cooldown" <me>', ready_buff='Overload'},
    {label='MORE', name='Ventriloquy / Role Reversal / Tactical Switch / Deactivate / SP abilities', kind='utility', row=2, section='menu', opens='more'},

    {label='VENT', name='Ventriloquy - swap enmity between you and the automaton', kind='ability', menu='more', cmd='input /ja "Ventriloquy" <t>'},
    {label='ROLE', name='Role Reversal - swap HP with the automaton', kind='ability', menu='more', cmd='input /ja "Role Reversal" <me>'},
    {label='TSW', name='Tactical Switch - swap TP with the automaton', kind='ability', menu='more', cmd='input /ja "Tactical Switch" <me>'},
    {label='DEACT', name='Deactivate - dismiss the automaton', kind='utility', menu='more', cmd='input /pet "Deactivate" <me>'},
    {label='OVDR', name='Overdrive (SP1) - huge automaton boost', kind='arts', menu='more', cmd='input /ja "Overdrive" <me>', buff='Overdrive'},
    {label='HEADY', name='Heady Artifice (SP2) - head-dependent effect', kind='arts', menu='more', cmd='input /ja "Heady Artifice" <me>'},

    -- Row 1: weapons | pet modes | toggles | weapon skills.
    {label='DEN',  name='Denouements + Em. Animator (move it out of the case first)', kind='weapon', group='weapon', cmd='gs c den', equip={main='Denouements'}},
    {label='CLAW', name='Calved Claws + Em. Animator', kind='weapon', group='weapon', cmd='gs c claws', equip={main='Calved Claws'}},
    {label='NINZ', name='Ninzas +2 + Em. Animator', kind='weapon', group='weapon', cmd='gs c ninzas', equip={main='Ninzas +2'}},
    {label='NIBR', name='Nibiru Sainti + Em. Animator (Repair +10%; in sack)', kind='weapon', group='weapon', cmd='gs c nibiru', equip={main='Nibiru Sainti'}},
    {label='MAST', name='Pet mode: Master - you are the damage', kind='mode', group='pmode', cmd='gs c master', on='Pet mode = Master', default=true},
    {label='HYB',  name='Pet mode: Hybrid - master TP with pet accuracy pieces', kind='mode', group='pmode', cmd='gs c hybrid', on='Pet mode = Hybrid'},
    {label='TANK', name='Pet mode: Tank - automaton tanks; you wear DT + its regen', kind='defense', group='pmode', cmd='gs c tank', on='Pet mode = Tank'},
    {label='DT',   name='Master DT overlay (-34%) on Master / Hybrid', kind='defense', section='toggle', cmd='gs c dt', on='DT mode ON', off='DT mode OFF'},
    {label='PWS',  name='Automaton WS swap - pet gear on as its TP nears 1000', kind='mode', section='toggle', cmd='gs c petws', on='Pet WS swap ON', off='Pet WS swap OFF', default=true},
    {label='TH',   name='Treasure Hunter +2 (Lucky Egg, Volte Bracers; ammo/hands locked)', kind='utility', section='toggle', cmd='gs c th', on='TH mode ON', off='TH mode OFF'},
    {label='VS',   name='Victory Smite (STR, crit)', kind='ws', cmd='input /ws "Victory Smite" <t>'},
    {label='SHIJ', name='Shijin Spiral (DEX)', kind='ws', cmd='input /ws "Shijin Spiral" <t>'},
    {label='ASUR', name='Asuran Fists (8 hits)', kind='ws', cmd='input /ws "Asuran Fists" <t>'},
    {label='RAGE', name='Raging Fists (5 hits)', kind='ws', cmd='input /ws "Raging Fists" <t>'},
    {label='HOWL', name='Howling Fist', kind='ws', cmd='input /ws "Howling Fist" <t>'},
    -- Char3 (COR) on command: Bolter's lights while the roll is on you.
    {label='BOLT', name="Char3: Bolter's Roll - movement speed (lucky 3, unlucky 9)", kind='roll', lucky=3, unlucky=9, section='char3', cmd='send Char3 /ja "Bolter\'s Roll" <me>', buff="Bolter's Roll"},
    {label='DBL', name="Char3: Double-Up his roll", kind='roll', section='char3', cmd='send Char3 /ja "Double-Up" <me>'},
    {label='JIG', name="Char3: Spectral Jig - Sneak + Invisible on himself (needs DNC main or sub)", kind='ability', section='char3', cmd='send Char3 /ja "Spectral Jig" <me>'},
}
