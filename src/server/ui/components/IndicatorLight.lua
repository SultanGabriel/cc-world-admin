local theme = require("ui.theme")

local IndicatorLight = {}
IndicatorLight.__index = IndicatorLight

-- Constructor for the IndicatorLight class
function IndicatorLight:new(parentFrame, labelText, x, y)
    local self = setmetatable({}, IndicatorLight)

    -- Create the indicator frame
    self.lightFrame = parentFrame:addFrame()
        :setPosition(x, y)
        :setSize(12, 1) -- Small square with a label next to it
        :setBackground(theme.bg_card)
        -- :setBackground(colors.black)

    -- Add the light square
    self.lightSquare = self.lightFrame:addFrame()
        :setPosition(1, 1)
        :setSize(1, 1)
        :setBackground(theme.indicator_off)

    -- Add the label
    self.label = self.lightFrame:addLabel()
        :setPosition(3, 1) -- Adjust to align properly with the square
        :setText(labelText)
        -- :setBackground(colors.black)
        :setForeground(theme.text)

    return self
end

-- Method to set the light's state
function IndicatorLight:setState(isOn)
    if isOn then
        self.lightSquare:setBackground(theme.indicator_on)
    else
        self.lightSquare:setBackground(theme.indicator_off)
    end
end

return IndicatorLight
