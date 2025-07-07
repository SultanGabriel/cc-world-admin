-- Mekanism Dynamic Tank Monitor using Basalt UI
-- Ensure Basalt is installed and the dynamic tank peripheral is connected.
-- Adjust the peripheral type ("mekanism_dynamic_tank") if needed.

-- Load Basalt
local basalt = require("basalt")

-- Attempt to locate the dynamic tank peripheral.
-- (Replace the peripheral name below if your setup is different.)
local tank = peripheral.find("dynamicValve")
if not tank then
    error("Dynamic tank peripheral not found. Please connect the tank and try again.")
end

-- Create the Basalt UI application.
local app = basalt.createScreen()

-- Create a full-screen frame as our UI container.
local w, h = app:getSize()
local frame = app:addFrame()
frame:setSize(w, h)
frame:setBackground(colors.black)

-- Create a label to display the fluid name and amount.
local fluidLabel = frame:addLabel()
fluidLabel:setPosition(2, 2)
fluidLabel:setSize(50, 1)
fluidLabel:setText("Loading tank info...")

-- Create a progress bar to visually represent the fill level.
local progressBar = frame:addProgressBar()
progressBar:setPosition(2, 4)
progressBar:setSize(50, 1)
progressBar:setColor(colors.blue)

-- Function to update the UI with the current tank data.
local function updateTankInfo()
    -- Call the dynamic tank method.
    -- It’s expected to return a table containing fluid info,
    -- such as:
    --   data.fluid – a table with fluid details (e.g., data.fluid.name)
    --   data.amount – the current stored amount
    --   data.capacity – the maximum capacity of the tank
    -- local data = tank.getFluid()
    if data and data.amount and data.capacity then
        local fluidName = (data.fluid and data.fluid.name) or "Unknown"
        local amount = data.amount
        local capacity = data.capacity
        local percent = amount / capacity

        fluidLabel:setText("Fluid: " .. fluidName .. " (" .. amount .. "/" .. capacity .. ")")
        progressBar:setValue(percent)
    else
        -- When no fluid is detected (tank empty or error)
        fluidLabel:setText("Tank empty or data unavailable")
        progressBar:setValue(0)
    end
end

-- To keep the UI responsive while updating the tank info,
-- we run the Basalt event loop and our update loop concurrently.
parallel.waitForAny(
    function() app:run() end,  -- Start the Basalt UI event loop.
    function() 
        while true do
            updateTankInfo()
            sleep(1)  -- Update every second.
        end 
    end
)

