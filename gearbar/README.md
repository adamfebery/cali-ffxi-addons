# gearbar

A bar of FFXIV-style buttons you can click to send GearSwap commands, swap weapons and fire
weapon skills. It rebuilds itself for each job.

**Load:** `//lua load gearbar`. Alt + drag moves the bar.

## Commands (`//gb` or `//gearbar`)

| Command | Does |
|---|---|
| `show` / `hide` | Show or hide the bar |
| `size <px>` | Button size, 24-128 (default 52) |
| `pos <x> <y>` | Place the bar |
| `tooltips` | Toggle hover tooltips |
| `plate <key> [text]` | Put a tag above the job plate; with no key it clears the tag. bluesets uses this to show the active set |
| `reload` | Reload the addon code, the job files and the art |

## Job files

The bar is built from `jobs/<Character>/<JOB>.lua`, or from `jobs/<JOB>.lua` when there's no
per-character file. Each button gives a label, a command, and optional rules for lighting up:

- `equip = {...}`: lights when those items are equipped (use this for weapons).
- `on` / `off`: lights or clears when GearSwap's chat line says so (use this for modes and DT).
- `needs`: dims a weapon skill when the weapon it needs isn't in your hand.

## Art

`art/` is drawn by `tools/make_art.py`. A button whose label has no drawn face yet still works.
It gets the plain frame for its kind, with a text label.
