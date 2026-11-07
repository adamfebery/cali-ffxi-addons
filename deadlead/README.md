# deadlead

Passes party or alliance leader while you're KO'd.

The client won't send `/pcmd leader` while you're dead, but that block is only in the client's
command handler. deadlead builds the same packet the client would have sent (outgoing 0x077,
"Change Permissions") and injects it directly.

**Load:** `//lua load deadlead`

## Commands (`//dl` or `//deadlead`)

| Command | Does |
|---|---|
| `//dl` | List party members and mark the current leader |
| `//dl <name>` | Give party leader to `<name>`. A partial name is fine, and an exact match wins over a partial one |
| `//dl -a <name>` | Give alliance leader to `<name>` |

## Caveat

This only gets past the **client-side** block. If the server also checks that the sender is
alive, the packet is ignored and nothing happens. The party-leader path follows the documented
packet fields. The alliance path is inferred from the same fields and is less certain.
