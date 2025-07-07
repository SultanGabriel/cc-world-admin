-- Dynamic Tank Monitor on a Monitor with Basalt
-- This script displays a nicely formatted UI using Basalt on a connected monitor.
-- It shows a header, the fluid name, stored amount/capacity, and a progress bar.

local basalt = require("basalt")

-- Helper: Insert space as a thousands separator into a numeric string.
local function formatWithSpaces(numStr)
  -- Split the string into integer and fractional parts.
  local integerPart, fractionPart = numStr:match("^(%-?%d+)(%.%d+)$")
  if not integerPart then
    integerPart = numStr
    fractionPart = ""
  end
  -- Reverse the integer part, insert a space every three digits, then reverse back.
  local rev = integerPart:reverse():gsub("(%d%d%d)", "%1 ")
  local formattedInt = rev:reverse():gsub("^%s+", "")
  return formattedInt .. fractionPart
end

-- Conversion function.
-- For values below 1000 mB, it returns "XXX mB".
-- For values that convert to less than 1000 Buckets, it returns "XXX Buckets".
-- For values of 1000 Buckets or more, it returns the full bucket value with a thousands separator and appends "kB".
local function formatMillibuckets(mb)
  local buckets = mb / 1000
  if buckets < 1 then
    return mb .. " mB"
  elseif buckets < 1000 then
    local s = (buckets == math.floor(buckets)) and tostring(buckets) or string.format("%.2f", buckets)
    return formatWithSpaces(s) .. " B"
  else
    buckets = buckets / 1000
    local s = (buckets == math.floor(buckets)) and tostring(buckets) or string.format("%.2f", buckets)
    return formatWithSpaces(s) .. " kB"

  end
end

-- Converts a value in millibuckets (mB) into a human-friendly string.
-- For values below 1000 mB, it returns "XXX mB".
-- For values of 1000 mB up to 1,000,000 mB, it returns the number of Buckets.
-- For values of 1,000,000 mB and above, it returns the value in k Buckets.
-- function formatMillibuckets(mb)
--   local buckets = mb / 1000
--   if buckets < 1 then
--     return mb .. " mB"
--     -- else
--   elseif buckets < 1000 then
--     -- If it's an integer number of buckets, show without decimals.
--     if buckets == math.floor(buckets) then
--       return tostring(buckets) .. " B"
--     else
--       return string.format("%.2f B", buckets)
--     end
--   else
--     -- For 1000 buckets (1,000,000 mB) and above, use "k" notation.
--     local kBuckets = buckets / 1000
--     if kBuckets == math.floor(kBuckets) then
--       return tostring(kBuckets) .. "k B"
--     else
--       return string.format("%.2fk B", kBuckets)
--     end
--   end
-- end

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

-- Create a Basalt screen on the monitor.
-- local app = basalt.createScreen(monitor)
local app = basalt.addMonitor()
app:setMonitor(monitor)

local monW, monH = monitor.getSize()

-- Create a frame that fills the entire screen.
-- local app = app.addFrame()
-- app.addFrame(frame)

if (app == nil) then
  print("Mno pula")
  return
end

app:setSize(monW, monH)
app:setBackground(colors.black)

-- Create the header label.
local headerLabel = app:addLabel()
headerLabel:setPosition(1, 1)
headerLabel:setSize(monW, 1)
headerLabel:setBackground(colors.blue)
headerLabel:setForeground(colors.white)

local headerText = " Fissile Fuel Tank Monitor "
local padding = math.floor((monW - #headerText) / 2)
headerLabel:setText(string.rep(" ", padding) .. headerText .. string.rep(" ", monW - #headerText - padding))

-- Create the fluid details label.
local fluidLabel = app:addLabel()
fluidLabel:setPosition(1, 3)
fluidLabel:setSize(monW, 1)
fluidLabel:setText("Fluid: Unknown")
fluidLabel:setForeground(colors.white)

-- Create the storage details label.
local storedLabel = app:addLabel()
storedLabel:setPosition(1, 4)
storedLabel:setSize(monW, 1)
storedLabel:setText("Stored: 0/0 (0%)")
storedLabel:setForeground(colors.white)

-- Create the progress bar.
local progressBar = app:addProgressbar()
progressBar:setPosition(2, 6)
progressBar:setSize(monW - 2, 2)
progressBar:setProgressBar(colors.white)
-- progressBar:setBarColor(colors.blue)
progressBar:setValue(0)

-- (Optional) Create an instruction label at the bottom.
local instructionLabel = app:addLabel()
instructionLabel:setPosition(1, monH -1)
instructionLabel:setSize(monW, 1)
instructionLabel:setText("Ce te uiti ma?")
instructionLabel:setForeground(colors.gray)

local instructionLabel2 = app:addLabel()
instructionLabel2:setPosition(1, monH)
instructionLabel2:setSize(monW, 1)
instructionLabel2:setText("Vrei sa te bat????")
instructionLabel2:setForeground(colors.gray)
-- Function to update the UI with current tank data.
local function updateTankInfo()
  -- Get fluid data from the tank.
  local data = tank.getStored()
  -- local capacity = tank.getTankCapacity()
  local capacity = tank.getChemicalTankCapacity()
  local percent = tank.getFilledPercentage()

  if data and capacity and capacity > 0 then
    local fluidName = (data.name) or "Unknown"
    local amount = (data.amount) or 0

    local percentDisplay = math.floor(percent * 100)

    fluidLabel:setText("Fluid: " .. fluidName)
    -- storedLabel:setText("Stored: " .. amount .. "/" .. capacity .. " (" .. percentDisplay .. "%)")
    storedLabel:setText("Stored: " ..
      formatMillibuckets(amount) ..
      " / " .. formatMillibuckets(capacity)
      .. " (" .. percentDisplay .. "%)")
    -- formatMillibuckets(mb)

    progressBar:setProgress(percentDisplay)
  else
    fluidLabel:setText("No fluid data available")
    storedLabel:setText("")
    progressBar:setValue(0)
  end
end

-- Run the Basalt event loop and update the UI concurrently.
parallel.waitForAny(
  function()
    basalt.autoUpdate()
  end,
  function()
    while true do
      updateTankInfo()
      sleep(1)
    end
  end
)
