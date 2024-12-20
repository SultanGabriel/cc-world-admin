-- Energy screen module

-- local createEnergyCard = require('ui.components.energyCard')
local EnergyCard = require("ui.components.EnergyCard")
local theme = require("ui.theme")

local EnergyScreen = {}

function EnergyScreen.new(parentFrame)
    local self = {}

    -- Create the screen frame
    local frame = parentFrame:addFrame()
        :setPosition(1, 4)
        :setSize("parent.w", "parent.h - 4")
        :setBackground(theme.bg_container)

    -- Example content for the Energy screen
    frame:addLabel()
        :setText("Energy Monitoring")
        :setPosition(2, 2)
        :setForeground(theme.text)



    local energyCard = EnergyCard:new(
    frame, "Energy Node 1", 2, 2, 40, 10)

    -- frame:addChild(energyComponent)

    -- Example of updating the energy component
    energyCard:updateEnergy(5000, 300, 10000000000000, 9535000099)


    -- Hide the frame by default
    frame:setVisible(false)

    -- Return screen interface
    function self:setVisible(visible)
        frame:setVisible(visible)
    end

    return self
end

return EnergyScreen
