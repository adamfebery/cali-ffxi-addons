# Local Trust patches (description only)

The Trust addon (by Cyrite) has a licence that forbids redistributing it or publishing modified
versions, in whole or in part. So this repo holds **no Trust code and no diffs**, only a
description of what was changed locally. Each change has to be re-applied by hand after a Trust
update.

| Area | Change |
|---|---|
| Magic burst source | Adds a mode so the magic burster only bursts skillchains its own character closed, rather than any skillchain on the target. |
| Engage priority | Engage is queued at medium priority, and PUP Deploy only fires once engaged. Before this, a puller could run several job abilities after Provoke before it engaged, and the tank never got hate. |
| Target names condition | Exposes the existing multi-name target condition to settings files. Stock Trust only exposes the single-name one, which checks the mob a player targets rather than the ally's own name. |
| Auto barspell | Implements the `Auto` barspell mode, which upstream left stubbed. It picks the barspell from the element of the mob's TP move, using a separate element table. |
| Follow pause | Adds `//trust follow pause [on\|off]`, which toggles "pause for spells and abilities" from the command line. |
| Sub-SCH stratagems | Counts stratagem charges from the subjob level when SCH is the subjob, and uses the correct recharge time. |
| NIN tools | Lets elemental ninjutsu use either the element-specific tool or the universal one, so San-tier spells (which use different tools) can fire. |
| Send-all with me | Adds `//trust sendall withme <cmd>`, which sends a command to every character and runs it on this one too. |
| Trust.lua hooks | Writes each character's Trust modes to `trustpanel/data/<Name>.lua` for [trustpanel](../trustpanel/). Also adds shortcuts: `//ts <cmd>` (sendall withme), `//tsw <warp>` (Superwarp on everyone) and `//twr` (everyone uses a Warp Ring). |
