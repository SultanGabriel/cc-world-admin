-- /src/server/ui/screens/general.lua
-- General screen module

local GeneralScreen = {}

function GeneralScreen.new(parentFrame)
    local self = {}

    -- Create the screen frame
    local frame = parentFrame:addFrame()
        :setPosition(1, 4)
        :setSize("parent.w", "parent.h - 4")
        :setBackground(colors.lightGray)

    -- Example content for the General screen
    frame:addLabel()
        :setText("Welcome to the General Screen")
        :setPosition(2, 2)
        :setForeground(colors.black)

    -- Hide the frame by default
    frame:setVisible(false)

    -- Return screen interface
    function self:setVisible(visible)
        frame:setVisible(visible)
    end

    return self
end

return GeneralScreen
