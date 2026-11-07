-- Zones and floors for sortienav, keyed by zone id (//sn where prints it).
--
-- Each floor:
--   id     short name routes refer to (floor = 'ground')
--   label  what the readout shows ("go to Basement")
--   z      optional {min, max} height range for this floor
--   rect   optional {minx, miny, maxx, maxy}
--          Without either, the floor is picked by nearest calibration
--          height, or forced with //sn floor <id>.
--   map    image background:
--     image   file in sortienav/maps/ (tools/extract_maps.py makes them)
--     width, height   image size in pixels (default 512)
--     grid    {u0 =, v0 =, cell =}: pixel of the A-1 grid corner and one
--             cell's size, so guide squares like "H-8" land on the map
--   Calibration (game position <-> pixel) is done in game with //sn cal and
--   saved to data/calibration.lua, keyed by image.

-- The in-game maps of Outer Ra'Kaznar, from ROM/311/108-109.DAT. Their
-- grid lines were measured at 16, 48, 80 ... 496 px: 32-px cells from 16.
local GRID = {u0 = 16, v0 = 16, cell = 32}

local ra_kaznar = {
    name = "Outer Ra'Kaznar",
    floors = {
        {id = 'ground', label = 'Ground floor (A-D)',
         map = {image = '274_01.png', width = 512, height = 512, grid = GRID}},
        {id = 'basement', label = 'Basement (E-H)',
         map = {image = '274_02.png', width = 512, height = 512, grid = GRID}},
    },
}

-- Sortie is Outer Ra'Kaznar split into sectors, in one of the [U] zones.
-- Which id it is hasn't been checked yet (//sn where inside Sortie), so all
-- of them share the same floors. 274 is the normal zone - handy for
-- calibrating and testing outside Sortie.
return {
    [274] = ra_kaznar,   -- Outer Ra'Kaznar
    [275] = ra_kaznar,   -- Outer Ra'Kaznar [U1]
    [133] = ra_kaznar,   -- Outer Ra'Kaznar [U2]
    [189] = ra_kaznar,   -- Outer Ra'Kaznar [U3]
}
