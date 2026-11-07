# sortienav (`//sn`) - plan

Solo Sortie companion for Char1 (+ Trust addon, which stays independent).
Goal: a toggleable minimap on an extracted game-map image, plus fixed,
step-by-step routes that advance themselves.

## Decisions (2026-09-28)

| Topic | Choice |
|---|---|
| Help wanted | Minimap overlay + route guidance |
| Content | Anything reasonably soloable, incl. basement sector bosses |
| Party | Char1 + Trust addon; no Trust integration |
| Data source | Hand-typed from guides (bg-wiki etc.) |
| Precision | Guide grid squares ("H-8") first; `//sn fix` overwrites a waypoint with the exact spot you are standing on |
| Map images | Extracted from the FFXI DATs, drawn under the dots |
| Advancing | Arrive-by-distance + boss/NM defeated + item/KI obtained + floor/zone change + door/device used |
| UI | Small minimap normally, key/command toggles a large full-floor view, plus a one-line "Next:" readout |
| Routes | Fixed ordered run scripts (pathfinding maybe much later) |

## How the pieces fit

- **data/zones.lua** - per zone id: floors, each with how to detect it
  (z range / rectangle), its map image, two calibration points
  (game x,y <-> image pixel u,v) and the grid origin/cell size in pixels.
- **Calibration** - FFXI maps are axis-aligned, so two points give a
  per-axis scale + offset. The same transform turns a guide grid square
  into game coordinates (cell centre), which is why guide data works
  before anyone has stood on the spot.
- **data/routes/<name>.lua** - ordered waypoints: name, floor, `grid` or
  `pos`, arrive radius, optional `advance` rule (defeat / item / device).
- **data/fixes.lua** - written by `//sn fix`; exact positions that override
  a waypoint's guide grid. Kept separate so the hand-typed routes stay clean.
- No image or calibration yet -> the map falls back to a plain dot plot
  auto-scaled to the route, so everything is usable before maps exist.

## Phases

1. **Core engine** (this build): settings, zone/floor detection, route
   loading, distance auto-advance, next/prev/goto, the readout, small/large
   minimap (image if present, dots otherwise), `fix`, `where`, `cal`, and a
   `test` route you can run in town.
2. **Event hooks**: defeat (action message 6 etc.), item/KI obtained
   (add item event + "Obtained key item" chat), device/door (outgoing 0x01A
   talk to a named NPC), each opt-in per waypoint via `advance`.
3. **Map extraction**: pull the Sortie floor maps out of the DATs with an
   external tool (e.g. an Altana-Viewer-style exporter) to PNG, then
   calibrate each floor with `//sn cal`.
4. **Data**: find the Sortie zone id(s) and floor z-ranges in game with
   `//sn where`, then type routes from bg-wiki guide grid squares; refine
   with `//sn fix` during runs.

## Status (2026-09-28)

- Phase 1 and 2 built, not yet run in game.
- First real route: `data/routes/ghatjot.lua` (Sector A -> Ghatjot), typed
  from guides; NPC names, gadget position and the Shard #A condition are
  unverified and flagged in the file.
- Sortie zone is one of Outer Ra'Kaznar [U1] 275 / [U2] 133 / [U3] 189 -
  confirm with `//sn where`.

- Phase 3 done: `tools/extract_maps.py` decodes map DATs (DXT3) to PNG.
  `274_01.png` (ground) and `274_02.png` (basement) are the full Outer
  Ra'Kaznar floors; 275_01..16 are small segment maps (possibly Sortie's
  per-sector maps). Grid measured: 32-px cells from pixel 16. In-game
  calibration is Alt+click via `//sn cal`, saved to data/calibration.lua.
- `extract_maps.py --all` extracts every zone listed in Remapster's
  `tools/dat_list.json` that exists in this install: 646 maps / 231 zones,
  51 MB, 256-colour PNG. It also generates `data/zone_maps.lua`, the
  fallback for any zone that data/zones.lua doesn't define. Two image
  formats: 0xA1 DXT3 and 0xB1 8-bit palette (stored bottom-up).
- DOUBT: the guide squares for Sector A (Device I-5, Locked Gate J-5) land
  north-centre/east on the full map, not in the NW. The guides may be
  reading Sortie's own sector map. Check in Sortie which map the game shows.

## Open questions / risks

- "Dahak" was Ghatjot (Sector A major NM).
- Sortie zone ids and floor z-ranges are unknown until measured in game.
- Windower prims can't draw lines or rotate, so the route is drawn as a
  dotted trail and the player as a dot (facing tick later if wanted).
- Map DAT extraction depends on an outside tool; if that stalls, in-game
  screenshots work with the same calibration.
