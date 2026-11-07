# jpstop

For leaving a job-point grind running unattended. Once your unspent job points reach a
threshold (default **500**), jpstop waits for combat to end, then **stops Trust and quits the
game** with `/shutdown`.

Combat counts as over when you aren't engaged and nothing claimed by your party is still alive
nearby, for at least 6 seconds. That way it never quits halfway through a fight. Unspent JP is
read from the job point counter and updated from "earns a job point" messages.

**Load:** `//lua load jpstop`

## Commands (`//jpstop`)

| Command | Does |
|---|---|
| `status` | Show unspent JP against the threshold |
| `on` / `off` | Arm or disarm it (`cancel` also disarms) |
| `set <jp>` | Change the threshold |

> **Warning:** it really does run `/shutdown`. Unload it (`//lua unload jpstop`) when you're
> playing normally.
