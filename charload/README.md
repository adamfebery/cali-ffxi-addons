# charload

Loads addons only on specific characters, and runs commands depending on a character's main job.
Load it from `scripts/init.txt` so every character runs it.

- **On login (and when charload is loaded):** it loads the addons listed for that character,
  then sends that character's command for its current main job. It waits 5 seconds first,
  because job info isn't always ready the moment the login event fires.
- **On logout:** it unloads everything it loaded.
- **After every job change:** it sends the command for the new job. The `other` entry is the
  fallback for jobs that have no entry of their own.

## Setup

Edit the two tables at the top of `charload.lua`:

```lua
local per_char = {
    Char1 = {'trustpanel', 'gearbar'},       -- addons for this character
}

local per_job = {
    Char1 = {WHM = 'trust start', other = 'trust stop'},
}
```

## Commands
- `//charload`: send the job commands again.
