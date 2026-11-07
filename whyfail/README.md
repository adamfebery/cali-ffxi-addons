# whyfail

When the game says "You cannot perform that action" (or another "can't do that" line), whyfail
prints the last few commands that were sent, with how long ago each one went out:

```
[whyfail] last commands: 0.4s ago: /ws "Savage Blade" <t> | 1.2s ago: /ja "Provoke" <t>
```

It sees commands you typed and commands sent by other addons (Trust's `/ja`, `/ma`, `/ws`,
`/pet`, `/ra` and so on), as well as actions sent as raw 0x01A packets. That lets you tell which
addon the game rejected.

**Load:** `//lua load whyfail`. There are no commands.
