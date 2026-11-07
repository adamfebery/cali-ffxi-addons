# GearSwap job files

GearSwap luas sorted by character. This branch (`gearswap`) is for gear updates; `main` holds the addons.

| Folder | Jobs |
|---|---|
| `Char1/` | BLU, COR, NIN, PUP, SAM, SCH, WAR, skillup |
| `Char2/` | BRD (plus `bard.lua`), DNC, RDM, THF, skillup |
| `Char3/` | COR, RUN, WHM, skillup |

To use one, copy it to `Windower/addons/GearSwap/data/<YourCharacterName>/` (or `data/` to share it across characters).

Most files use Mote's libraries (`include('Mote-Include.lua')`), which ship with GearSwap. The `skillup.lua` files expect `Saves/skillup_data.lua`.

Character names are replaced with Char1–Char3. Backups, gearinfo stat dumps and optimizer exports aren't included.
