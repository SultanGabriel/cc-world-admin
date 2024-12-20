local basalt = require("basalt")
local IndicatorLight = require("ui.components.IndicatorLight")
local theme = require("ui.theme")

local EnergyCard = {}
EnergyCard.__index = EnergyCard

-- Utility function to format energy values
local function formatEnergy(value)
    if value >= 1e12 then
        return string.format("%.2f TRF", value / 1e12)
    elseif value >= 1e9 then
        return string.format("%.2f GRF", value / 1e9)
    elseif value >= 1e6 then
        return string.format("%.2f MRF", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.2f kRF", value / 1e3)
    else
        return string.format("%d RF", value)
    end
end

-- Constructor for the EnergyCard class
function EnergyCard:new(parentFrame, name, x, y, width, height)
    local self = setmetatable({}, EnergyCard)

    local percentageLabelOffset = 7;

    -- Create the card frame
    self.cardFrame = parentFrame:addFrame()
        :setPosition(x, y)
        :setSize(width, height)
        :setBackground(theme.bg_card)
        :setBorder(theme.border)

    -- Add title
    self.cardFrame:addLabel()
        :setPosition(2, 2)
        :setText(name)
        :setForeground(theme.text)

    -- Add progress bar
    self.progressBar = self.cardFrame:addProgressbar()
        :setPosition(2, 4)
        :setSize(width - percentageLabelOffset - 3, 1) -- Leave space for percentage text
        :setDirection("right")
        :setBackground(colors.lightGray)
        :setProgressBar(colors.green)
        :setValue(0)

    -- Add percentage label
    self.percentageLabel = self.cardFrame:addLabel()
        :setPosition(width - percentageLabelOffset, 4) -- Position at the end of the progress bar
        :setText(" 0%")
        :setBackground(theme.bg_card)
        :setForeground(theme.text)

    -- Add input and output labels
    self.inputLabel = self.cardFrame:addLabel()
        :setPosition(2, 6)
        :setText("Input: 0 RF")
        :setBackground(theme.bg_card)
        :setForeground(theme.text)

    self.outputLabel = self.cardFrame:addLabel()
        :setPosition(2, 7)
        :setText("Output: 0 RF")
        :setBackground(theme.bg_card)
        :setForeground(theme.text)

    -- Add stored and capacity labels
    self.storedLabel = self.cardFrame:addLabel()
        :setPosition(2, 8)
        :setText("Stored: 0 RF")
        :setBackground(theme.bg_card)
        :setForeground(theme.text)

    self.capacityLabel = self.cardFrame:addLabel()
        :setPosition(2, 9)
        :setText("Capacity: 0 RF")
        :setBackground(theme.bg_card)
        :setForeground(theme.text)
        :setBorder(theme.border, "bottom") -- Border bottom for container styling

    -- Add indicator lights
    local indicatorsOffset = 14

    self.chargingLight = IndicatorLight:new(
        self.cardFrame,
        "Charging",
        width - indicatorsOffset,
        6
    )
    self.dischargingLight = IndicatorLight:new(
        self.cardFrame,
        "Discharging",
        width - indicatorsOffset,
        7
    )
    self.testLight = IndicatorLight:new(
        self.cardFrame,
        "Test",
        width - indicatorsOffset,
        8
    )

    return self
end

-- Method to update the energy card values
function EnergyCard:updateEnergy(input, output, capacity, stored)
    local percentage = math.floor((stored / capacity) * 10000) / 100
    print(percentage)
    self.progressBar:setProgress(percentage)
    self.percentageLabel:setText(percentage .. " %")

    self.inputLabel:setText("Input: " .. formatEnergy(input))
    self.outputLabel:setText("Output: " .. formatEnergy(output))
    self.storedLabel:setText("Stored: " .. formatEnergy(stored))
    self.capacityLabel:setText("Capacity: " .. formatEnergy(capacity))

    -- Update indicator lights
    self.chargingLight:setState(input > output)
    self.dischargingLight:setState(output > input)
    self.testLight:setState(stored > (capacity * 0.5)) -- Example condition for the "test" light
end

return EnergyCard
