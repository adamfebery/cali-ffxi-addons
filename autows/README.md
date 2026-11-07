# autows (SimpleHotShot)

A minimal auto weapon skill. Every half second it checks whether you're **engaged with 1000+ TP**.
If you are, it sends:

```
/ws "Sniper Shot" <t>
```

It's meant for Corsair or Ranger with a marksmanship weapon. To fire a different weapon skill,
change the line in `autows.lua`.

**Load:** `//lua load autows`. There are no commands; unload it to stop.

> The `_addon.name` is still `SimpleHotShot` from when it fired Hot Shot.
