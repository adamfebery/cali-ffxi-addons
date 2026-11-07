-- Sector A (the Abject / leech sector, NW of the ground floor) to Ghatjot.
-- //sn load ghatjot once you are inside Sortie.
--
-- Sources, 2026-09-28:
--   bg-wiki Ghatjot / Ra'Kaznar Shard A / Ra'Kaznar Key A pages
--   "This Idiot's Guide to Sortie" (ffxiah.com/node/469) for the grid squares
--   ffxiah forum "Sortie: A Beginner's Guide To Locating Gems"
--
-- Grid squares are the guides' and match the in-game map, so they're drawn
-- on the map image straight away. Distance / direction in the readout needs
-- the ground floor calibrated (//sn cal); //sn fix at each spot pins it
-- exactly.
--
-- UNVERIFIED - check on your first run:
--   * NPC names. Device steps match on part of the name ('Gate', 'Gadget').
--     If a step doesn't tick when you touch the thing, //sn next and tell me
--     the real name.
--   * Where Diaphanous Gadget #A is. The guides only put Locked Gate #A at
--     (J-5); the gadget is assumed to be past it.
--   * How Shard #A is earned. The guides disagree (see that step).
--
-- No zone set: the route binds to the zone you load it in. Once //sn where
-- has given us the Sortie zone id, add it here.

return {
    name = 'Sector A -> Ghatjot',
    waypoints = {
        {
            id = 'gate_a1',
            name = 'Gate #A-1',
            floor = 'ground',
            grid = 'D-4',
            advance = {type = 'device', name = 'Gate'},
            note = 'Sneak up before the Acuex. You start near (C-7). Opening it -> Key #A chest.',
        },
        {
            id = 'shard_a',
            name = 'Get Shard #A',
            advance = {type = 'item', name = "Shard A"},
            note = 'Guides disagree: 3 magic killing blows -> chest, OR 6 Abject Acuex + Abject Obdella -> Chest #A3.',
        },
        {
            id = 'locked_gate_a',
            name = 'Locked Gate #A',
            floor = 'ground',
            grid = 'J-5',
            advance = {type = 'device', name = 'Gate'},
            note = 'Southern Hecteyes room. Needs Key #A.',
        },
        {
            id = 'gadget_a',
            name = 'Diaphanous Gadget #A',
            floor = 'ground',
            grid = 'J-5',
            advance = {type = 'device', name = 'Gadget'},
            note = 'Buff INSIDE the chamber, not the hallway - the door locks when you engage.',
        },
        {
            id = 'ghatjot',
            name = 'Ghatjot',
            advance = {type = 'defeat', name = 'Ghatjot'},
            note = 'NO water/ice damage or Distortion/Darkness SCs - it absorbs them. Stun works.',
        },
    },
}
