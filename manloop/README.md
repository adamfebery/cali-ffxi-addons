# manloop

Keeps a set mix of Puppetmaster maneuvers up, for example while you skill up the automaton. The
default is **2 Wind + 1 Water**.

It fires only when the maneuver recast (id 210) is ready, which is the same check Trust's PUP
uses. It tracks burden the same way `autocontrol` does (+15 per maneuver, decaying over time,
with Heat Sink for Water), so it won't push an element into Overload. It also waits while
you're asleep, stunned, petrified, charmed, under amnesia or overloaded.

**Load:** `//lua load manloop`

## Commands (`//ml` or `//manloop`)

| Command | Does |
|---|---|
| `start` / `stop` | Start or stop the loop |
| `set <element> <n> [<element> <n> ...]` | Choose the mix, e.g. `//ml set wind 2 water 1` |
| `repair <hp%>` / `repair off` | Use Repair when the automaton drops below that HP%. Needs an oil in the ammo slot |
| `status` | Show the mix, the maneuvers up, and the Repair setting |
