-- /src/server/ui/screens/units.lua
-- Units screen module

local UnitsScreen = {}

function UnitsScreen.new(parentFrame)
    local self = {}

    -- Create the screen frame
    local frame = parentFrame:addFrame()
        :setPosition(1, 4)
        :setSize("parent.w", "parent.h - 4")
        :setBackground(colors.green)

    -- Example content for the Units screen
    frame:addLabel()
        :setText("Unit Control")
        :setPosition(2, 2)
        :setForeground(colors.white)

    -- Hide the frame by default
    frame:setVisible(false)

    -- Return screen interface
    function self:setVisible(visible)
        frame:setVisible(visible)
    end

    return self
end

return UnitsScreen
