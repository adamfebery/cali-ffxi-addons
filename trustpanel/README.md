# trustpanel

One on-screen button that changes what your other characters' **Trust** addons (by Cyrite) are
doing. Each click moves everyone to the next mode:

| Mode | What the others do |
|---|---|
| **BUFF ONLY** | Not engaged and no weapon skills, just buffing |
| **SAVAGE** | Assist you and engage when you engage. They spam Savage Blade while you spam Shijin Spiral, and those two make Light in either order |
| **LIGHT SC** | Same engage, but they follow skillchain steps instead of spamming (Shijin Spiral > Savage Blade = Light) |
| **DARK SC** | Sniper Shot > Savage Blade (Distortion) > Asuran Fists = Darkness |

The skillchain plans are the `Light` and `BrdDark` sets in `trust/data/skillchains/`. Commands
go out through the **Send** addon (`send @others trust ...`).

**Load:** `//lua load trustpanel`. Drag the button to move it.

## Commands (`//tp` or `//trustpanel`)
- `show` / `hide`: show or hide the button.

## Setup

The bard's name (`BARD`), the mode list (`ORDER`, `LOOK`) and the Trust commands each mode
sends are at the top of `trustpanel.lua`. Edit them to match your party and your jobs.

Showing each character's current Trust modes on the panel needs a local hook in Trust. That
hook writes `trustpanel/data/<Name>.lua` and isn't in this repo; see
[docs/trust-patches.md](../docs/trust-patches.md). Without it the button still works, but it
can't show live modes.
