# autoring

Keeps a Capacity Point ring buff (**Commitment**) up, and optionally an EXP ring buff
(**Dedication**) too.

When a buff is missing, autoring picks the best ring you own that is **ready**, meaning it has
charges left and is off recast. It reads both from the item's own data. Then it:
1. locks the ring slot in GearSwap
2. equips the ring and waits out the equip delay
3. uses it
4. unlocks the slot, so GearSwap puts your normal ring back

The buff stays after the ring comes off. Only rings in bags `/equip` can reach (inventory and
wardrobes) are used.

By default it only fires while you're **engaged**, so a ring with a 12-hour recast never gets used
standing in town.

**Load:** `//lua load autoring`

## Commands (`//ar` or `//autoring`)

| Command | Does |
|---|---|
| `cp` / `exp` / `both` / `off` | Which buffs to keep up (default `cp`) |
| `idle` | Toggle firing when you're not engaged too |
| `now` | Try once right now, engaged or not |
| `use <ring name>` | Test one specific ring right now |
| `status` | Show the buffs it sees and which rings are ready |

The ring priority list (best first) is at the top of `autoring.lua`.
