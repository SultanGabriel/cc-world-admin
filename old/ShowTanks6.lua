-- Dynamic Tank Monitor on a Monitor with Basalt
-- This script displays a nicely formatted UI using Basalt on a connected monitor.
-- It supports multiple Mekanism dynamic tanks, each with its own bordered display.

local basalt = require("basalt")

-- Helper: Insert space as a thousands separator into a numeric string.
local function formatWithSpaces(numStr)
  local integerPart, fractionPart = numStr:match("^(%-?%d+)(%.%d+)$")
  if not integerPart then
    integerPart = numStr
    fractionPart = ""
  end
  local rev = integerPart:reverse():gsub("(%d%d%d)", "%1 ")
  local formattedInt = rev:reverse():gsub("^%s+", "")
  return formattedInt .. fractionPart
end

-- Capitalize first letter helper.
local function capitalizeFirst(str)
  return (str:gsub("^%l", string.upper))
end

-- Conversion function.
local function formatMillibuckets(mb)
  local buckets = mb / 1000
  if buckets < 1 then
    return mb .. " mB"
  elseif buckets < 1000 then
    local s = tostring(math.floor(buckets))
    return formatWithSpaces(s) .. " B"
  else
    buckets = buckets / 1000
    local s = tostring(math.floor(buckets))
    return formatWithSpaces(s) .. " kB"
  end
end

-- Find the monitor peripheral.
local monitor = peripheral.find("monitor")
if not monitor then
  print("Monitor peripheral not found!")
  return
end

-- Find all Mekanism dynamic tank peripherals.
local tanks = { peripheral.find("dynamicValve") }
if #tanks == 0 then
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("No dynamic tanks found!")
  return
end

local app = basalt.addMonitor()
app:setMonitor(monitor)

local monW, monH = monitor.getSize()
if (app == nil) then
  print("Mno pula")
  return
end

app:setSize(monW, monH)
app:setBackground(colors.black)

local headerLabel = app:addLabel()
headerLabel:setPosition(1, 1)
headerLabel:setSize(monW, 1)
headerLabel:setBackground(colors.pink)
headerLabel:setForeground(colors.black)

local headerText = " Tschernobyl V2 Fuel "
local padding = math.floor((monW - #headerText) / 2)
headerLabel:setText(string.rep(" ", padding) .. headerText .. string.rep(" ", monW - #headerText - padding))

local tankContainers = {}
local tankInfo = {}

-- Calculate vertical spacing per tank
local tankHeight = 6
local spacing = 1
local totalHeight = (#tanks * (tankHeight + spacing)) + 1

local startY = 3
local startX = 2
local marginRight = 2
for i, tank in ipairs(tanks) do
  local container = app:addFrame()
  container:setPosition(startX, startY)
  container:setSize(monW-marginRight, tankHeight)
  container:setBackground(colors.black)
  container:setBorder(colors.white)

  local fluidLabel = container:addLabel()
  fluidLabel:setPosition(2, 1)
  fluidLabel:setSize(monW - marginRight, 1)
  fluidLabel:setForeground(colors.white)
  fluidLabel:setText("Fluid: Unknown")

  local storedLabel = container:addLabel()
  storedLabel:setPosition(2, 2)
  storedLabel:setSize(monW - 2, 1)
  storedLabel:setForeground(colors.white)
  storedLabel:setText("Stored: 0/0 (0%)")

  local ioLabel = container:addLabel()
  ioLabel:setPosition(2, 3)
  ioLabel:setSize(monW - 2, 1)
  ioLabel:setForeground(colors.white)
  ioLabel:setText("Flow: 0 mB/tick")

  local progressBar = container:addProgressbar()
  progressBar:setPosition(2, 5)
  progressBar:setSize(monW - marginRight - startX- 4, 1)
  progressBar:setProgressBar(colors.white)
  progressBar:setValue(0)

  tankContainers[i] = {
    tankPeripheral = tank,
    lastAmount = 0,
    lastTime = os.clock(),
    fluidLabel = fluidLabel,
    storedLabel = storedLabel,
    ioLabel = ioLabel,
    progressBar = progressBar
  }

  startY = startY + tankHeight + spacing
end

local instructionLabel = app:addLabel()
instructionLabel:setPosition(1, monH - 1)
instructionLabel:setSize(monW, 1)
instructionLabel:setText("Ce te uiti ma?")
instructionLabel:setForeground(colors.gray)

local instructionLabel2 = app:addLabel()
instructionLabel2:setPosition(1, monH)
instructionLabel2:setSize(monW, 1)
instructionLabel2:setText("Vrei sa te bat????")
instructionLabel2:setForeground(colors.gray)

local function updateTankInfo()
  for i, tankData in ipairs(tankContainers) do
    local tank = tankData.tankPeripheral
    local currentTime = os.clock()
    local elapsedTime = currentTime - tankData.lastTime
    tankData.lastTime = currentTime

    local data = tank.getStored()
    local capacity = tank.getChemicalTankCapacity()
    local percent = tank.getFilledPercentage()

    if data and capacity and capacity > 0 then
      local rawName = (data.name) or "Unknown"
      local namePart = rawName:match("^[^:]+:(.+)$") or rawName
      namePart = capitalizeFirst(namePart)
      
      local amount = (data.amount) or 0
      local percentDisplay = math.floor(percent * 100)

      -- Calculate flow rate per tick
      local flowRate = math.floor((amount - tankData.lastAmount) / (elapsedTime * 20))
      tankData.lastAmount = amount

      tankData.fluidLabel:setText(" Fluid: " .. namePart .. " ")
      tankData.storedLabel:setText("Stored: " .. formatMillibuckets(amount) .. " / " .. formatMillibuckets(capacity) .. " (" .. percentDisplay .. "%)")
      tankData.ioLabel:setText("Flow: " .. flowRate .. " mB/tick")
      tankData.progressBar:setProgress(percentDisplay)
    else
      tankData.fluidLabel:setText("No fluid data available")
      tankData.storedLabel:setText("")
      tankData.ioLabel:setText("Flow: 0 mB/tick")
      tankData.progressBar:setValue(0)
    end
  end
end

parallel.waitForAny(
  function()
    basalt.autoUpdate()
  end,
  function()
    while true do
      updateTankInfo()
      sleep(0.05)  -- Updates every tick (50ms)
    end
  end
)
