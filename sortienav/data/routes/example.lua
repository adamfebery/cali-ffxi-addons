-- Example route showing every waypoint option. Load with //sn load example.
-- Real Sortie routes go in this folder the same way (phase 4).
--
-- Waypoint fields:
--   id       stable key for //sn fix (defaults to the list position; set it
--            so inserting a step later doesn't orphan saved fixes)
--   name     shown in the readout
--   floor    floor id from data/zones.lua (omit for single-floor zones)
--   grid     guide square like "H-8" (needs the floor calibrated), or
--   pos      exact {x, y, z}
--   radius   arrive distance in yalms (default: settings arrive_radius)
--   advance  'arrive' (default), {type = 'floor', floor = 'basement'},
--            {type = 'zone', zone = <id>}, or
--            {type = 'defeat' | 'item' | 'device', name = '...'} - name is
--            matched as part of the mob / item / NPC name, ignoring case
--   note     extra line under the readout
--
-- No zone field: the route binds to the zone you load it in.

return {
    name = 'Example',
    waypoints = {
        {id = 'start', name = 'Where you stand now', pos = {0, 0, 0}, note = 'Edit pos, or stand there and //sn fix'},
        {id = 'boss', name = 'Some NM', pos = {40, 25, 0}, advance = {type = 'defeat', name = 'Some NM'}},
        {id = 'back', name = 'Back to start', pos = {0, 0, 0}, radius = 4},
    },
}
