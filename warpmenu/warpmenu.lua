_addon.name = 'WarpMenu'
_addon.author = 'Custom'
_addon.version = '1.3'

require('tables')
require('chat')
texts = require('texts')

local settings = {
    pos = { x = 300, y = 300 },
    text = { font = 'Consolas', size = 10, red = 255, green = 255, blue = 255 },
    bg = { alpha = 200, red = 0, green = 0, blue = 0 },
    padding = 5
}

local menu_content = [[
  Superwarp Menu
  --------------------
  [1] Jeuno (Survival Guide)
  [2] Mhaura (Home Point)
  [3] Eastern Adoulin (Waypoint)
  [4] Close Menu
]]

local gui = texts.new(menu_content, settings)
local menu_visible = false

gui:hide()

gui:register_event('left_click', function(x, y, det)
    local box_y = gui:pos_y()
    local relative_y = y - box_y
    
    if relative_y > 35 and relative_y < 55 then
        windower.send_command('sw sg jeuno')
    elseif relative_y >= 55 and relative_y < 75 then
        windower.send_command('sw hp mhaura')
    elseif relative_y >= 75 and relative_y < 95 then
        windower.send_command('sw wp eastern adoulin')
    elseif relative_y >= 95 and relative_y < 115 then
        gui:hide()
        menu_visible = false
    end
end)

windower.register_event('addon command', function(...)
    local params = {...}
    local cmd = params[1] and params[1]:lower() or ''
    
    windower.add_to_chat(207, 'WarpMenu received command: ' .. tostring(cmd))
    
    if cmd == 'toggle' then
        if menu_visible then
            gui:hide()
            menu_visible = false
            windower.add_to_chat(207, 'WarpMenu hidden.')
        else
            gui:show()
            menu_visible = true
            windower.add_to_chat(207, 'WarpMenu shown.')
        end
    else
        windower.add_to_chat(207, 'WarpMenu: Unknown command. Use //warpmenu toggle')
    end
end)