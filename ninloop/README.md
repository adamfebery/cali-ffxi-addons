# ninloop

Casts enemy-target ninjutsu on your current target over and over, for Ninjutsu skill-ups. It's a
standalone addon and doesn't need GearSwap.

It only casts spells you know, have a tool for, and have off recast. A tool can be the
tier-specific one (for example Inoshishinofuda for Raiton Ichi/Ni, or Hiraishin for Raiton:
San) or the universal fuda.

**Load:** `//lua load ninloop`

## Commands (`//nl` or `//ninloop`)

| Command | Does |
|---|---|
| `start` / `stop` | Start or stop the loop |
| `tier <all\|ichi\|ni\|san>` | Which tiers to cast |
| `delay <sec>` | Pause between casts |
| `restock` | Toggle opening tool bags when you run out |
| `list` | Show the spells it would cast right now |

The tool tables in `ninloop.lua` (`tool_map`, `universal_tool_map`, `toolbag`) are generated
from GearSwap's `statics.lua` and the item resources. Regenerate them rather than editing them by
hand.
