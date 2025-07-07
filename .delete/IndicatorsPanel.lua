-- ui/indicators_panel.lua
local Component = require("ui.component")
local Indicator = require("ui.Indicator")

local Panel = {}
Panel.__index = Panel
setmetatable(Panel, { __index = Component })

function Panel.new(app, x, y, width, title, indicatorsConfig)
    local self = setmetatable(Component.new(), Panel)

    self.indicators = {}
    self.container = app:addFrame()
        :setPosition(x, y)
        :setSize(width, #indicatorsConfig + 2)
        :setBackground(colors.lightGray)
        --:setBorder(colors.lightGray)

    self.titleLabel = self.container:addLabel()
        :setText(" " .. title)
        :setPosition(2, 1)
        :setForeground(colors.black)

    for i, cfg in ipairs(indicatorsConfig) do
        local led = Indicator.new(self.container, 2, i + 1, cfg.label, cfg.color)
        led:setState(cfg.state or "inactive")
        table.insert(self.indicators, led)
    end

    return self
end

function Panel:update()
    for _, ind in ipairs(self.indicators) do
        ind:update()
    end
end

-- Optional: Allow external control of individual indicators
function Panel:setIndicatorState(index, state)
    if self.indicators[index] then
        self.indicators[index]:setState(state)
    end
end

return Panel

