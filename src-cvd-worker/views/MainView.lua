local Component = require('ui.component')
local theme = require('theme')
local logic = require('logic')

local MainView = {}
MainView.__index = MainView
setmetatable(MainView, { __index = Component })

local function getMouseButton(...)
    local args = { ... }
    return args[3] or args[2]
end

function MainView.new(B, state)
    local self = setmetatable(Component.new(), MainView)
    self.state = state

    local w, h = B:getSize()

    B:setBackground(theme.backgroundColor)

    local header = B:addFrame({
        x = 1,
        y = 1,
        width = w,
        height = 1,
        background = theme.headerBackgroundColor,
    })

    header:addLabel({
        x = 2,
        y = 1,
        text = 'CVD Worker',
        foreground = colors.white,
    })

    local body = B:addFrame({
        x = 1,
        y = 2,
        width = w,
        height = h - 1,
        background = theme.backgroundColor,
    })

    body:addLabel({ x = 2, y = 2, text = 'Action:', foreground = colors.lightGray })
    local actionLabel = body:addLabel({ x = 10, y = 2, text = '-', foreground = colors.white })

    body:addLabel({ x = 2, y = 3, text = 'Right Clicks:', foreground = colors.lightGray })
    local clicksLabel = body:addLabel({ x = 16, y = 3, text = '0', foreground = colors.white })

    body:addLabel({ x = 2, y = 4, text = 'Redstone In:', foreground = colors.lightGray })
    local inputLabel = body:addLabel({ x = 14, y = 4, text = 'OFF', foreground = colors.red })

    body:addLabel({ x = 2, y = 5, text = 'Redstone Out:', foreground = colors.lightGray })
    local outputLabel = body:addLabel({ x = 15, y = 5, text = 'OFF', foreground = colors.red })

    local button = body:addButton({
        x = 2,
        y = 7,
        width = 20,
        height = 1,
        text = 'Right Click Me',
        background = colors.gray,
        foreground = colors.black,
    })

    button:onClick(function(...)
        local mouseButton = getMouseButton(...)
        if mouseButton ~= 2 then
            return
        end
        logic.handleRightClick()
    end)

    local function renderOut(value)
        if value then
            outputLabel:setText('ON')
            outputLabel:setForeground(colors.lime)
        else
            outputLabel:setText('OFF')
            outputLabel:setForeground(colors.red)
        end
    end

    local function renderIn(value)
        if value then
            inputLabel:setText('ON')
            inputLabel:setForeground(colors.lime)
        else
            inputLabel:setText('OFF')
            inputLabel:setForeground(colors.red)
        end
    end

    state:onStateChange('cvd_last_action', function(_, newValue)
        actionLabel:setText(tostring(newValue or '-'))
    end)

    state:onStateChange('cvd_right_clicks', function(_, newValue)
        clicksLabel:setText(tostring(newValue or 0))
    end)

    state:onStateChange('CVD_IN', function(_, newValue)
        renderIn(newValue == true)
    end)

    state:onStateChange('CVD_OUT', function(_, newValue)
        renderOut(newValue == true)
    end)

    actionLabel:setText(tostring(state:getState('cvd_last_action') or '-'))
    clicksLabel:setText(tostring(state:getState('cvd_right_clicks') or 0))
    renderIn(state:getState('CVD_IN') == true)
    renderOut(state:getState('CVD_OUT') == true)

    return self
end

function MainView:update()
end

return MainView
