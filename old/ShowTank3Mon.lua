-- Dynamic Tank Monitor on a Monitor
-- This script displays a nicely formatted UI on a connected monitor.
-- It shows a header, the fluid name, stored amount/capacity, and a progress bar.

-- Find the monitor peripheral.
local monitor = peripheral.find("monitor")
if not monitor then
    print("Monitor peripheral not found!")
    return
end

-- Find the Mekanism dynamic tank peripheral.
local tank = peripheral.find("dynamicValve")
if not tank then
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Dynamic tank not found!")
    return
end

-- Helper function to draw a progress bar using block characters.
-- Filled portion uses "█" and empty uses "░".
-- @param percent A number between 0 and 1 representing the fill percentage.
-- @param width The total width (in characters) for the progress bar.
local function drawProgressBar(percent, width)
    local filled = math.floor(percent * width + 0.5)
    local empty = width - filled
    return string.rep("█", filled) .. string.rep("░", empty)
end

-- Main update loop.
while true do
    monitor.clear()
    local monW, monH = monitor.getSize()

    -- Draw header on the first line.
    monitor.setBackgroundColor(colors.blue)
    monitor.setTextColor(colors.white)
    local headerText = " Dynamic Tank Monitor "
    local padding = math.floor((monW - #headerText) / 2)
    local headerLine = string.rep(" ", padding) .. headerText .. string.rep(" ", monW - #headerText - padding)
    monitor.setCursorPos(1, 1)
    monitor.write(headerLine)

    -- Reset colors for content.
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)

    -- Fetch tank data.
    -- local data = tank.getFluid()
    -- if data and data.amount and data.capacity and data.capacity > 0 then
    --     local fluidName = (data.fluid and data.fluid.name) or "Unknown"
    --     local amount = data.amount
    --     local capacity = data.capacity
    --     local percent = amount / capacity
    --     local percentDisplay = math.floor(percent * 100)

    -- Get fluid data from the tank.
    local data = tank.getStored()
    local capacity = tank.getTankCapacity()
    local percent = tank.getFilledPercentage()

    if data and capacity and capacity > 0 then
        local fluidName = (data.name) or "Unknown"
        local amount = (data.amount) or 0
        local percentDisplay = math.floor(percent * 100)

        -- Display fluid details.
        monitor.setCursorPos(1, 3)
        monitor.write("Fluid: " .. fluidName)
        monitor.setCursorPos(1, 4)
        monitor.write("Stored: " .. amount .. "/" .. capacity .. " (" .. percentDisplay .. "%)")

        -- Draw a progress bar on the next line.
        local barY = 6
        if barY > monH - 2 then
            barY = monH - 2  -- ensure we have room
        end
        local progressBarWidth = monW - 2  -- leave a small margin
        local progressBar = drawProgressBar(percent, progressBarWidth)
        monitor.setCursorPos(2, barY)
        monitor.write(progressBar)
    else
        -- If no fluid data is available, display an error message.
        local msg = "No fluid data available"
        local msgPadding = math.floor((monW - #msg) / 2)
        monitor.setCursorPos(1, 3)
        monitor.write(string.rep(" ", msgPadding) .. msg)
    end

    -- Optional: Display an instruction at the bottom.
    monitor.setCursorPos(1, monH)
    monitor.write("Press Ctrl+T to exit")

    sleep(1)  -- Update every second.
end

