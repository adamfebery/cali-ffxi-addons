# bluelearn

Tells you when a mob has used a TP move you can learn as a Blue Mage spell, so you know it's
safe to kill it.

It watches every monster TP move. If the move is a blue spell you don't know yet, it marks the
mob and gives you a chat alert. A box shows your current target's status:

- green **"KILL IT - used Erratic Flutter"**: a learnable move has been seen
- grey **"no learnable move seen yet"**: let it keep using TP moves

Learning still isn't guaranteed. You need BLU as main job and enough Blue Magic skill, the kill
has to count for your party, and some NMs never teach.

**Load:** `//lua load bluelearn`

## Commands (`//bl` or `//bluelearn`)

| Command | Does |
|---|---|
| `//bl` | Show or hide the box |
| `pos <x> <y>` | Move the box |
| `reset` | Forget every mob seen so far |
