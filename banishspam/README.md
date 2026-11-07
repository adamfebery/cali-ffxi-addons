# banishspam

Casts **Banish** on your current target on a timer, for example for Divine Magic skill-ups or
against undead.

Banish has a 15-second recast, so it fires as soon as the recast is up. The interval only sets
how often it checks (default 7s). It won't cast when:
- the target isn't a live monster in range
- you're dead, resting, in a cutscene, or out of MP
- you don't know Banish (from WHM main or sub) or it's on recast

**Load:** `//lua load banishspam`

## Commands (`//bspam` or `//banishspam`)

| Command | Does |
|---|---|
| `//bspam` | Toggle on or off |
| `//bspam on` / `off` | Set it explicitly |
| `//bspam every <s>` | Set the check interval in seconds |
