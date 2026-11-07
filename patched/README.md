# Patched third-party addons

These are full copies of BSD-3 addons with local changes. Each keeps its original copyright and
licence notice. An upstream update will overwrite the changes, so re-apply them from here.

## thtracker (original by Krizz), rewritten as v1.3
- Shows the Treasure Hunter level from the gear you wear when you first land an action on a
  mob, marked "(gear)". The value comes from item descriptions and augments (via extdata), plus
  `//th bonus N` per job, plus 1 for a /THF subjob.
- Procs raise the level and mark it "(proc)".
- `//th pos` now works and saves.

## craft (original by Mojo): progress HUD
- `//craft hud` toggles an on-screen box. It shows the current item, done/total, a countdown to
  the next synth, OK/HQ (by tier)/break counts, items made, and craft skill-ups.
- `//craft hud reset` clears the counts.

## warnme (original by Marian Arlt): sound alerts
- Plays `sounds/alert.wav` when your current target uses a move listed in `data/sounds.lua`.
- Commands: `//wm sound add|remove <name>`, `list`, `test`, `reload`.
- **`sounds/alert.wav` is not included.** It was a copy of `warning.wav` from the Gallionaire
  addon, which is GPL-3. Copy that file (or any .wav) to `warnme/sounds/alert.wav`.

## gearinfo-meter (for GearInfo by Sebyg666)
GearInfo has no licence file, so only our own new file is here.

`Meter_display.lua` replaces GearInfo's tile grid with meter bars. Each bar is grey under the
cap, green at the cap and amber over it, and sections are laid out per job. To use it:
1. Copy `Meter_display.lua` into `addons/gearinfo/`.
2. In `GearInfo.lua`, change the `Image_processing` require to `Meter_display`.
3. Make `update()` build a data table and pass it to `meters.render`.
4. Make `//gi hide` toggle `settings.display.hidden`.

The same patch also fixes GearInfo's movement check in `Action_Processing.lua`. The original
used `and` between the x and y position comparisons, so moving along only one axis didn't
count as moving. The patch uses `or`.
