# oddyweak

In Odyssey Sheol, when you target a mob, oddyweak shows a box with:
- the mob's family
- its slash / pierce / blunt damage multipliers, with **USE** and **AVOID** marked
- the weapon types your current main job can use for that damage type
- its two weakest elements

It only shows in the Odyssey zones.

**Load:** `//lua load oddyweak`. Drag the box to move it.

## Commands (`//ow` or `//oddyweak`)

| Command | Does |
|---|---|
| `sheol a\|b\|c` | Which Sheol you're in (default C). Each Sheol adds its own resistance on top of the family's |
| `save` | Save the box position after dragging it |

## Reading the numbers

On BG-Wiki's Sheol tables, "-50% X damage" is a **resistance**: the mob takes *less* of that
type. It is not a weakness. oddyweak works the numbers out for you. In Sheol C, regular mobs
take ×0.5 and NMs/Agon take ×0.375 from their resisted type. In Sheol B it's ×0.75 and ×0.625.

## Credits

`sheol_resistances.lua` and `sheol_types.lua` come from
[MarianArlt/sheolhelper](https://github.com/MarianArlt/sheolhelper) (BSD-3). Its licence notice
is kept in those files.
