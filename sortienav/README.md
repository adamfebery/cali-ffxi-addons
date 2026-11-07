# sortienav

Route guidance and a minimap for solo Sortie. It walks you through a route one waypoint at a time,
showing distance, floor and zone, and moves to the next waypoint by itself. Design notes and
phase status are in [PLAN.md](PLAN.md).

**Load:** `//lua load sortienav`

## Commands (`//sn` or `//sortienav`)

| Command | Does |
|---|---|
| `routes` | List the routes in `data/routes/` |
| `load <name>` / `unload` | Start or clear a route |
| `next` / `prev` / `goto <n>` | Step through waypoints by hand |
| `map` | Switch between the small and large minimap |
| `show` / `hide` | Show or hide the display |
| `fix` | Move the current waypoint to where you are standing |
| `where` | Print the zone, position, floor and grid |
| `cal` / `cal cancel` / `cal reset` | Calibrate the map image for this floor (stand somewhere easy to pin-point, then Alt+click it on the map) |
| `floor next` / `floor auto` | Choose which floor map to show, or go back to automatic |
| `test` | Run a test route you can use anywhere |

## How a waypoint advances

A waypoint moves on by itself when one of these happens:
- you get within range of it
- you change floor or zone
- the mob it names is defeated
- you obtain the item or key item it names
- you touch the gate or device NPC it names

## Maps

Map images aren't in this repo, because they're Square Enix assets. To build them from your own
install, run `python tools/extract_maps.py`. `tools/dat_list.json` tells it which DAT files to
read. Without map images the minimap shows a plain dot plot.

## Routes

A route is a Lua file in `data/routes/`. Start from `example.lua`.
