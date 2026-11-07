_addon.name = 'charload'
_addon.author = 'local'
_addon.version = '1.3'
_addon.commands = {'charload'}

-- Addons to load only on specific characters. Unloaded again on logout.
-- 2026-10-24: HealBot removed from all three. It and Trust were both healing
-- on Char3 WHM and burning his MP; Trust's WHM healer does it alone now.
-- Old setup in charload.lua.bak-20261024-nohb.
local per_char = {
}

-- Commands sent when a character is on a given main job (on login, on load
-- and after every job change), and when it's on any other job.
local per_job = {
}

local loaded = {}

local function apply_job(name, job)
    local jobs = per_job[name]
    if not jobs or not job then return end
    local cmd = jobs[job] or jobs.other
    if cmd then windower.send_command(cmd) end
end

local function on_login(name)
    if not name then return end
    for _, addon in ipairs(per_char[name] or {}) do
        windower.send_command('lua load ' .. addon)
        loaded[#loaded + 1] = addon
    end
    -- Job info isn't always ready the moment the login event fires.
    coroutine.schedule(function()
        local player = windower.ffxi.get_player()
        if player then apply_job(name, player.main_job) end
    end, 5)
end

local function on_logout()
    for _, addon in ipairs(loaded) do
        windower.send_command('lua unload ' .. addon)
    end
    loaded = {}
end

windower.register_event('load', function()
    local player = windower.ffxi.get_player()
    if player then on_login(player.name) end
end)

windower.register_event('login', function(name) on_login(name) end)
windower.register_event('logout', on_logout)

windower.register_event('job change', function()
    local player = windower.ffxi.get_player()
    if player then apply_job(player.name, player.main_job) end
end)

-- //charload re-sends the job commands.
windower.register_event('addon command', function()
    local player = windower.ffxi.get_player()
    if player then apply_job(player.name, player.main_job) end
end)
