# bluesets

Sets all your Blue Mage spells in one command, from a **priority list**.

Each set is a list, not a fixed loadout. bluesets goes down it from the top and takes every spell
you actually **know** that still fits in your 20 slots and your set points. When you learn
something new, it slots in by itself and you don't have to edit anything. An `{all = {...}}` entry
is all-or-nothing; for example, the Triple Attack trio only counts when all three fit.

**Load:** `//lua load bluesets`

## Commands (`//bs` or `//bluesets`)

| Command | Does |
|---|---|
| `//bs [set]` | Set the spells (default set: `melee`). You can't use it while engaged |
| `preview [set]` | Show what it *would* set, without changing anything |
| `max <n>` | Your blue magic set point limit (default 55) |
| `list` | List the sets |
| `announce` | Tell [gearbar](../gearbar/) which set is on, so it shows above the BLU plate. This is also sent by itself on any change |

## Set points

You get 55 at level 99, +1 per Assimilation merit (up to +5), and +1 per tier of the "Blue Magic
Point Bonus" job point category (up to +20). The game doesn't expose your total to addons, so set
it with `//bs max <n>`. You can read the number off the in-game Set Spells screen.

## Editing the sets

The sets are at the top of `bluesets.lua`:

| Set | What it's for |
|---|---|
| `melee` | Savage Blade, with Dual Wield III and Triple Attack traits |
| `nuke` | Single-target magic |
| `aoe` | AoE nukes, which pull extra mobs, so use them on purpose |
| `omenaoe` | AoE for Omen |
| `tank`, `tankdw` | Tanking, without and with Dual Wield |

The comments in the file explain why each spell is placed where it is.
