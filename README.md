# ScanZone

Find any NPC or mob in your current zone, ask the server where it is, and see
it on the zone map, even when it's far outside your draw range.

```
//lua load scanzone
//sz
```

## The window

`//sz` opens a window in the style of [Chronicle](#credits):

- **Search box**: filters every entity listed in the zone's DAT as you type.
  Enter finishes typing and Esc clears it.
- **Results list**: name, target index and server ID. After a scan it also
  shows HP% and distance. The dot on the left shows its state:

  | Dot | Meaning |
  | --- | --- |
  | grey | not scanned yet |
  | amber | waiting for the server's reply |
  | cyan | the server says it's up |
  | orange | despawned, or no reply within 3 s |

- **Click a row** to scan it. If the game already has the entity loaded (it's
  near you), its info shows straight away.
- **Scan all** scans every row in the current results, one every 0.3 s, up to
  50. For example, search `???` and click Scan all to see which ones are up.
- **Scan result**: HP, status, position, grid square, distance and when it
  last updated, with **Rescan** and **Copy index** buttons.
- **Map pane** (right side): the zone map with markers for the selected entity
  (amber, labelled), you (white) and everything else in the search that's up
  (cyan).

You can drag the window by its title bar, and collapse or close it. It
remembers its position for each character.

## Commands

| Command | What it does |
| --- | --- |
| `//sz` | Show or hide the window |
| `//sz show` / `hide` | Show or hide the window |
| `//sz find <name>` | Search the zone DAT. Prints the results to chat and fills in the search box |
| `//sz scan <hex index>` | Ask the server about a target index, e.g. `//sz scan 1A3` |
| `//sz map` | Turn the map pane on or off |
| `//sz mapsize <px>` | Map pane size, 150 to 800 (default 330) |
| `//sz reset` | Move the window back to its default position |
| `//sz autoshow` | Open the window when the addon loads |
| `//sz help` | List the commands |

## How it works

**Finding entities.** `datmap.lua` maps each zone ID to its entity DAT file(s)
under the FFXI install. Each record in the file is 32 bytes: a 28-byte
null-padded name, then a 4-byte little-endian server ID. The target index is
`id & 0xFFF`. This only reads files on disk, so it lists everything defined for
the zone, whether it's spawned or not.

**Scanning.** ScanZone sends outgoing packet `0x016` (entity update request)
for the target index. The server answers with incoming `0x00E`, which carries
position, HP%, status and a despawn bit. ScanZone only reads that packet. The
game still handles it as normal. Any `0x00E` the server sends for an entity in
the zone's list updates its row, so the list keeps itself up to date while
you're in the zone.

**The map.** The map images are the ones extracted from the game DATs by the
[sortienav](#requirements) addon. Lining a map up needs no clicking:
`windower.ffxi.get_position(x, y, z)` returns the grid square (e.g. `(H-8)`)
for *any* position. FFXI maps are 512 px, with a 15x15 grid of 32 px cells
starting at pixel 16. ScanZone walks along each axis and bisects to find where
the grid letter (or number) changes. Two grid lines on an axis give that axis's
scale and offset. Each map is lined up the first time it's shown, and the
result is cached until you zone. `windower.ffxi.get_map_data` picks which floor
image to use.

## Requirements

- Windower 4.
- The map pane uses `addons/sortienav/maps/*.png` and
  `addons/sortienav/data/zone_maps.lua`, made by sortienav's
  `tools/extract_maps.py --all`. Without them everything else still works, and
  the map pane says it can't find the images.

## Settings

`data/settings.xml` is created on the first save:

| Setting | Default | Meaning |
| --- | --- | --- |
| `scan_timeout` | 3 | Seconds to wait for a reply before marking an entity as not up |
| `scan_all_delay` | 0.3 | Seconds between requests in Scan all |
| `scan_all_max` | 50 | Most entities Scan all will request |
| `show_map` | true | Show the map pane |
| `map_size` | 330 | Map pane size in pixels |
| `visible_on_load` | false | Open the window when the addon loads |

## Credits

- Original ScanZone (DAT lookup, `find` and `scan` commands, `datmap.lua`):
  **Project Tako**.
- `ui/widgets.lua`, `ui/theme.lua` and the icons in `assets/` are unmodified
  copies from **Chronicle** by Jintawk, used under its BSD-style licence (see
  `ui/LICENSE-chronicle.txt`).
