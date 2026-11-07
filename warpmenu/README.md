# warpmenu

A small clickable warp menu that runs [Superwarp](https://github.com/AkadenTK/superwarp) for you:

| Entry | Sends |
|---|---|
| Jeuno (Survival Guide) | `sw sg jeuno` |
| Mhaura (Home Point) | `sw hp mhaura` |
| Eastern Adoulin (Waypoint) | `sw wp eastern adoulin` |
| Close Menu | hides the menu |

Superwarp has to be loaded.

**Load:** `//lua load warpmenu`

## Commands
- `//warpmenu toggle`: show or hide the menu. It's handy bound to a key, for example
  `bind ^w warpmenu toggle`.

To change the destinations, edit `menu_content` and the click handler in `warpmenu.lua`.
