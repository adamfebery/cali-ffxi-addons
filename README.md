# cali-ffxi-addons

Windower 4 addons for Final Fantasy XI, plus local patches to a few third-party addons.

Install: copy an addon's folder into `Windower/addons/`, then `//lua load <name>`.

Character names in configs and comments have been replaced with `Char1`, `Char2`, and so on.
Put your own names back before you use any per-character settings (`charload`, `trustpanel`,
`autows`).

## Addons

| Addon | What it does |
|---|---|
| [scanzone](scanzone/) | Finds any NPC or mob in the zone, scans it, and shows it on a zone map decoded from the game DATs |
| [sortienav](sortienav/) | Navigation help for solo Sortie. See `PLAN.md`. Maps are extracted locally with `tools/extract_maps.py` |
| [gearbar](gearbar/) | FFXIV-style button bars that send GearSwap commands and weapon skills. It rebuilds on every job change |
| [trustpanel](trustpanel/) | One on-screen button that switches the other characters between buff-only and engage + Savage Blade (Trust addon) |
| [deadlead](deadlead/) | `//dl <name>` passes party leader while you are KO'd |
| [oddyweak](oddyweak/) | In Odyssey Sheol, shows the targeted mob's slash/pierce/blunt and element weaknesses and the weapons to use |
| [ninloop](ninloop/) | Loops enemy-target ninjutsu for skill-ups and restocks tools |
| [manloop](manloop/) | Keeps a set mix of PUP maneuvers up (default 2 Wind + 1 Water) |
| [aoewatch](aoewatch/) | Names any party member (or pet) whose action hits more than one monster |
| [whyfail](whyfail/) | When the game says "cannot perform that action", prints the last commands sent |
| [jpstop](jpstop/) | Job point helper. It knows when you are engaged or a party-claimed mob is still alive nearby |
| [autows](autows/) | Automatic weapon skills per character, job and weapon, with HP% and TP conditions |
| [autoring](autoring/) | Keeps a Capacity Point or EXP ring buff up |
| [autosilc](autosilc/) | Skillchain helper (moved here from its own repo) |
| [banishspam](banishspam/) | Casts Banish on your current target on a timer (`//bspam`) |
| [bluelearn](bluelearn/), [bluesets](bluesets/), [bluexport](bluexport/) | Blue Mage: track learned spells, save and load spell sets, and export known spells, the current set and traits to a text file |
| [warpmenu](warpmenu/) | Warp menu |
| [charload](charload/) | Loads addons only on specific characters and unloads them on logout |

## Patched third-party addons

[`patched/`](patched/) holds local changes to BSD-licensed addons, with their original licence
notices kept. Trust and GearInfo are **not** included because their licences don't allow it.
See [`patched/README.md`](patched/README.md) and [`docs/trust-patches.md`](docs/trust-patches.md).

## Not included

- Map images (`maps/`): these are Square Enix assets decoded from your own game install. Both
  addons build them on first use.
- `settings.xml` and other runtime state, `.bak` files and logs.
