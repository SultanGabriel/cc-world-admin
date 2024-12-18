-- /src/server/ui/screens/energy.lua
-- Energy screen module

local EnergyScreen = {}

function EnergyScreen.new(parentFrame)
    local self = {}

    -- Create the screen frame
    local frame = parentFrame:addFrame()
        :setPosition(1, 4)
        :setSize("parent.w", "parent.h - 4")
        :setBackground(colors.lightBlue)

    -- Example content for the Energy screen
    frame:addLabel()
        :setText("Energy Monitoring")
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

return EnergyScreen
