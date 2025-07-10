-- ui/views/EnergyView.lua
local Component = require("ui.component")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")
local MatrixStatusFrame = require("ui.MatrixComponent")
local basalt = require("lib.basalt.src")

local DOORWAYS = require("config").Doorways

local theme = require("common.theme")

local EnergyView = {}
EnergyView.__index = EnergyView
setmetatable(EnergyView, { __index = Component })

function EnergyView.new(B, state)
	local self = setmetatable(Component.new(), EnergyView)

	self.components = {}
	self.state = state

	local monW, monH = B:getSize()
  print("EnergyView: new() - Monitor size:", monW, monH)

	B:setBackground(theme.backgroundColor)

	-- === Header ===
	local fHeader = B:addFrame():setPosition(1, 1):setSize(monW, 2):setBackground(theme.headerBackgroundColor)

	fHeader:addLabel({
		x = monW / 2 - 21,
		y = 1,
		text = "GregTech Factory - Energy Monitoring System",
		foreground = colors.white,
	})

	-- fHeader:addLabel()
	--   :setText(os.date("%H:%M:%S"))
	--   :setPosition(monW - 10, 1)
	--   :setForeground(colors.white)

	-- === Main ===
	local fMain = ExperimentalFrame.new(B, 1, 3, monW, monH - 2)
	local mainContainer = fMain:getContainer()

	local matrix = MatrixStatusFrame.new(mainContainer, 2, 2)

	-- matrix:setFillLevel(64)
	-- matrix:updateInfo("Input", "7.52 MFE/t")

	-- local doorLabel = mainContainer:addLabel():setPosition(2, 15):setText("Door Closed")
	--
	-- state:onStateChange("D_01", function(self, val)
	-- 	doorLabel:setText(val and "Door Opened" or "Door Closed")
	-- end)
  -- Door labels
  local idx = 0
  local startX = 38
  local startY = 2
  for _, door in pairs(DOORWAYS) do
    print(door.name, door.key, door.id)
    local open = self.state:getState(door.key)
    local doorLabel = mainContainer:addLabel()
      :setPosition(startX , startY + idx)
      :setText(door.name .. ": " ..  (open and "Open" or "Closed"))
      :setForeground(colors.red)

    -- doorLabel:bind("text", door.key)

    idx = idx + 1
    state:onStateChange(door.key, function(name, val)
      doorLabel:setText(door.name .. ": " .. (val and "Open" or "Closed"))
      :setForeground(val and colors.green or colors.red)
    end)
  end

	return self
end

function EnergyView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return EnergyView
