-- Dynamic Tank Monitor (Terminal UI)
-- This script monitors a Mekanism dynamic tank and displays a formatted UI on the terminal.
-- Make sure your Mekanism dynamic tank peripheral is attached.

-- Locate the dynamic tank peripheral.
local tank = peripheral.find("dynamicValve")
if not tank then
    print("Dynamic tank peripheral not found!")
    return
end

-- Helper function to draw a progress bar.
-- Filled portion uses "█", empty uses "░".
-- @param percent A number between 0 and 1 representing the fill percentage.
-- @param width The total width (in characters) for the progress bar.
local function drawProgressBar(percent, width)
    local filled = math.floor(percent * width + 0.5)
    local empty = width - filled
    return string.rep("█", filled) .. string.rep("░", empty)
end

-- Main update loop.
while true do
    term.clear()
    term.setCursorPos(1,1)
    
    local screenWidth, _ = term.getSize()
    
    -- Draw header with background color.
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    local headerText = " Dynamic Tank Monitor "
    local padding = math.floor((screenWidth - #headerText) / 2)
    local headerLine = string.rep(" ", padding) .. headerText .. string.rep(" ", screenWidth - #headerText - padding)
    print(headerLine)
    
    -- Reset colors.
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    print("")  -- Blank line
    
    -- Get fluid data from the tank.
    local data = tank.getStored()
    local capacity = tank.getTankCapacity()
    local percent = tank.getFilledPercentage()

    if data and capacity and capacity > 0 then
        local fluidName = (data.name) or "Unknown"
        local amount = (data.amount) or 0
        local percentDisplay = math.floor(percent * 100)
        
        -- Display fluid details.
        print(" Fluid:  " .. fluidName)
        print(" Stored: " .. amount .. " / " .. capacity .. " (" .. percentDisplay .. "%)")
        print("")
        
        -- Draw the progress bar.
        local progressBarWidth = screenWidth - 2  -- leave some margin
        local bar = drawProgressBar(percent, progressBarWidth)
        print(" [" .. bar .. "]")
    else
        print(" No fluid data available")
    end
    
    print("")
    print(" Press Ctrl+T to exit")
    
    sleep(1)  -- Update every second.
end

