-- components/dynamic_tank.lua
local Component = require("ui.component")
local format = require("common.format")

local TankComponent = {}
TankComponent.__index = TankComponent
setmetatable(TankComponent, { __index = Component })

function TankComponent.new(app, peripheral, x, y, w, h)
    local self = setmetatable(Component.new(), TankComponent)

    self.peripheral = peripheral
    self.lastAmount = 0
    self.lastTime = os.clock()

    self.container = app:addFrame():setPosition(x, y):setSize(w, h)
    self.container:setBackground(colors.black)
    --:setBorder(colors.white)

    self.fluidLabel = self.container:addLabel()
        :setPosition(2, 1)
        :setForeground(colors.white)

    self.storedLabel = self.container:addLabel()
        :setPosition(2, 2)
        :setForeground(colors.white)

    self.ioLabel = self.container:addLabel()
        :setPosition(2, 3)
        :setForeground(colors.white)

    -- Thicker progress bar: use multiple stacked bars (simulate thickness)
    self.progressBar1 = self.container:addProgressBar()
        :setPosition(2, 5)
        :setSize(w - 4, 1)
        :setProgressColor(colors.white)

    self.progressBar2 = self.container:addProgressBar()
        :setPosition(2, 6)
        :setSize(w - 4, 1)
        :setProgressColor(colors.white)

    return self
end

function TankComponent:update()
    local now = os.clock()
    local dt = now - self.lastTime
    self.lastTime = now

    local data = self.peripheral.getStored()
    local capacity = self.peripheral.getChemicalTankCapacity()
    local percent = self.peripheral.getFilledPercentage()

    if data and capacity then
        local name = format.capitalizeFirst(data.name:match("^[^:]+:(.+)$") or data.name)
        local amount = data.amount or 0
        local rate = math.floor((amount - self.lastAmount) / (dt * 20))
        self.lastAmount = amount

        local percentDisplay = math.floor(percent * 100)
        self.fluidLabel:setText(" Fluid: " .. name)
        self.storedLabel:setText("Stored: " .. format.formatMillibuckets(amount) .. " / " .. format.formatMillibuckets(capacity) .. " (" .. percentDisplay .. "%)")
        self.ioLabel:setText("Flow: " .. rate .. " mB/tick")

        self.progressBar1:setProgress(percentDisplay)
        self.progressBar2:setProgress(percentDisplay)
    else
        self.fluidLabel:setText(" No fluid ")
        self.storedLabel:setText("")
        self.ioLabel:setText("Flow: 0 mB/tick")
        self.progressBar1:setProgress(0)
        self.progressBar2:setProgress(0)
    end
end

return TankComponent

