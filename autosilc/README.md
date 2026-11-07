# AutoSilc

MagianWS with the target selection replaced. Instead of scanning for mob names
you configured, AutoSilc attacks **whatever the party leader is attacking**.

Everything else is unchanged: weaponskill at TP, skillchain closing with a second
WS, buff maintenance, food, ammo, Provoke, the trial/EXP overlay, `start`/`stop`.

```
//lua load autosilc
//autosilc start
```

## How the target is chosen

Two sources, in order:

1. **Action packets** (primary). The `incoming chunk` handler already parsed
   `0x028` for skillchain windows; it now also watches the assist player. Any
   action they aim at a live, non-player mob — melee round, weaponskill, spell,
   job ability, ranged attack — is taken as "this is the target". This is
   unambiguous: the packet names an actor id and a target id outright.
2. **The leader's `target_index`** (fallback). Read straight out of the mob
   array. Cheaper, but weaker — another player's `target_index` is only
   populated while the server happens to be sending it, and it lingers on a mob
   they have already disengaged from. It is re-validated before use.

An action-derived target is trusted for `ASSIST_TTL` (30s) after it was last
seen, then dropped. Zoning clears it, because mob ids do not survive a zone.

## Commands that differ from MagianWS

| Command | Behaviour |
| --- | --- |
| `//autosilc assist` | Assist the party leader (the default). |
| `//autosilc assist <name>` | Pin the assist to a specific party member instead. |
| `//autosilc target add <name>` | Now an optional **whitelist**, not target selection. Empty = assist on anything. Add names to refuse to assist on anything else. |
| `//autosilc pull` / `pullrange` | Disabled. The leader pulls. |
| `//autosilc range` | No longer selects targets, but is now the ceiling on how far Silc will walk to one. |
| `//autosilc songs on\|off\|now` | New. Song rotation toggle and forced re-sing. |

Everything else (`ws`, `ws2`, `tp`, `food`, `ammo`, `item`, `buff`, `buffset`,
`provoke`, `follow`, `home`, `trial`, `mode`, `spell`, `debug`, `status`,
`show`/`hide`, `start`/`stop`) is identical to MagianWS.

## Songs

A fixed rotation, hardcoded in `autosilc.lua`:

1. Advancing March
2. Victory March
3. Valor Minuet V, under **Marcato** when the ability is up

**The trigger is joining a party with the addon loaded, not `//autosilc start`.**
Songs are maintained from then on, engaged or idle, and stop when the party
breaks. `//autosilc songs off` is the kill switch; `songs now` forces a full
re-sing; `//autosilc status` shows the on/off state.

This is deliberately not a buff set. The buff maintainer identifies a buff by a
single status id, and both marches are status **214** (every Valor Minuet is
198) - once Advancing March lands, `is_buff_active(214)` reports Victory March
as up too and it is never sung. It also cannot pair a job ability with a cast,
which the Marcato'd minuet needs.

What *is* countable is how many copies of a status the player carries, so each
status is a group: two songs on 214 means expect to see 214 twice. Fewer means
one of that group dropped, and songs expire in the order they were sung, so the
oldest is the one gone. Songs are also refreshed on a 14-minute clock, which is
roughly what Silc's songs actually last with his instrument and duration gear.
A song that drops early does not wait for that clock - the group-short check and
the `lose buff` handler both catch it.

One song is issued per maintenance pass, with a 12s lock afterwards: a song is
an 8s cast and the tick is 10s, so without the lock the next pass would start a
second song on top of the first. An interrupted cast recovers on the pass after
the lock, because its group is still short - that path never consults the clock.

A Marcato'd song is *not* refreshed on the clock while Marcato is down, since
that would swap a strong song for a weak one. If it has actually dropped, it is
re-sung either way.

**Three songs needs three song slots** (Clarion Call, or the instrument for it).
With two slots the minuet overwrites Advancing March and the rotation will
re-sing forever.

## The assist hold

Reacting on the frame the leader's first swing resolves is inhumanly fast, so a
newly seen target is held for a random **2-12 seconds** before anything is done
about it. `ASSIST_DELAY_MIN` / `ASSIST_DELAY_MAX` in `autosilc.lua` are the
bounds; the 2s scan tick coarsens it slightly, so the real wait runs up to ~14s.

The hold sits on `assist_target()`, the one thing the two act-on-a-new-target
paths share - the answer to "what mob?". The first engage and the mid-fight
switch are therefore both covered without either of them knowing it exists.

While the hold runs, Silc **stays on whatever he had already committed to**
rather than standing still - dropping the current mob for twelve seconds would
be more conspicuous than the snap it is meant to hide. If there is nothing to
stay on (the old mob died, or this is the first pull), he stands still, and
crucially does *not* walk home: `try_return_home()` is skipped for the duration,
or he would trek back and immediately turn around again.

The commitment is cleared on zone change and on `//autosilc stop`, so restarting
holds before the first mob instead of snapping onto whatever is already going.
`//autosilc status` and the overlay show `Fermigo > Mob (holding 7s)` while it
runs.

## Following stops at melee contact

Following is for closing the gap, not for fighting. The moment a melee round
goes out at a mob we are in range of it, so the follow is cancelled there and
then - otherwise `follow[engaged]` re-issues `/follow <t>` on every 2s scan and
Silc spends the whole fight walking into the mob.

The trigger is the category-1 action packet from us, which is the same signal
pull mode already used to cancel its approach-walk. It fires on the **swing, not
on the swing connecting**: a miss happened at melee range just the same, and
treating it as "not there yet" would keep us walking until we happened to land
one.

Two pieces of state, because `/follow` is a toggle and stopping it needs to know
whether it is currently on:

| | |
| --- | --- |
| `melee_contact_id` | The mob we have swung at. Compared against the *current* target's id, so switching mobs re-enables the approach without needing a reset. |
| `follow_active` | Whether the client has been told to follow, so the stop is only sent when there is something to stop. |

If the mob walks off afterwards, the `out of range` / `cannot see` message
clears the latch, the approach resumes, and the next round that goes out stops
it again.

## `follow` off means off

`settings.follow` used to be checked in one place only - the engaged branch.
The two branches that run when Silc is *not* engaged (approaching a target, and
having just targeted one) issued `/follow <t>` regardless, so with follow off he
still walked: on the mob's death he drops to idle, resolves the next assist
target, and set off toward it from there.

Both branches now honour the setting. With follow off he faces the mob and
attacks if it is inside 20y, and never moves.

Two guards go with it, which matter when follow is *on*:

* **A chase ceiling.** `scan_range` is now the furthest he will walk for a mob.
  The fallback target source is the leader's `target_index`, and mob indices get
  recycled - a stale one resolves to an unrelated mob, which an unbounded follow
  turns into a sprint across the zone.
* **Deselect cancels the follow.** The invalid-target path called
  `stop_pull_follow()`, which returns immediately outside pull mode, so the
  cursor was dropped while the client kept walking.

## Two changes that are easy to miss

**The claim test is inverted.** MagianWS refuses any mob carrying a claim,
because a claimed mob belongs to someone else. Here the mob we want is claimed
almost by definition — the leader claimed it. `claim_is_ours()` accepts a claim
held by anyone in the party and rejects everything else.

**Retargeting mid-fight tests `target_index`, not the client cursor.** With
`follow` on, the unlock timer in `prerender` deliberately clears the cursor a
second after each follow. Cursor-based logic would therefore think it had lost
the target on every scan and re-issue `/attack` forever. The engaged branch
compares our own mob's `target_index` against the assist mob's `index`, and
switches with `/attack <t>` — a bare `/attack` toggles, so while engaged it would
disengage instead of switching.

## Relationship to MagianWS

This is a fork, not a shared library: `autosilc.lua` is a copy of
`magianws.lua` with a patch applied, and `sc_data.lua` is copied verbatim.
Comments in the source say "MagianWS did X, this does Y" at each point they
diverge. Fixes made in one do not propagate to the other.

The pull-mode branches inside `try_engage_target()` are dead code —
`settings.pull_mode` is pinned to `false` at load — kept so the two files stay
line-for-line comparable.
