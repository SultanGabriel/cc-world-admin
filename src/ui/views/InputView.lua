-- ui/views/MainView
local Component = require("ui.component")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")

local theme = require("common.theme")

local InputView = {}
InputView.__index = InputView
setmetatable(InputView, { __index = Component })

function InputView.new(B)
	local self = setmetatable(Component.new(), InputView)

	self.components = {}

	local monW, monH = B:getSize()

	B:setBackground(theme.backgroundColor)

  -- === Header ===
  local fHeader = B:addFrame()
    :setPosition(1, 1)
    :setSize(monW, 2)
    :setBackground(theme.headerBackgroundColor)
        
	fHeader:addLabel()
		:setText("GregTech Factory - Command Center")
		:setPosition(monW / 2 - 16, 1)
		:setForeground(colors.white)



  -- fHeader:addLabel()
  --   :setText(os.date("%H:%M:%S"))
  --   :setPosition(monW - 10, 1)
  --   :setForeground(colors.white)

  -- === Main ===
  local fMain = ExperimentalFrame.new(B, 1, 3, monW , monH )
  local mainContainer = fMain:getContainer()

  local btnOne = mainContainer:addButton()
    :setText("Start Process")
    :setPosition(2, 1)
    :setSize(29, 1)
  :setBackground(colors.green)
  :onClick(function(button, x, y)
    print("Process started!")
    print("Button clicked at: " .. x .. ", " .. y)

  end)
  
  mainContainer    :addButton()
    :setText("Stop Process")
    :setPosition(2, 3)
    :setSize(29, 1)
  :setBackground(colors.red)
  
  -- fMain:getContainer()
  --   :addLabel()
  --   :setText("Main Control Panel")
  --   :setPosition(2, 1)
  -- 
  -- -- === Side Panel ===
  -- local fSide = ExperimentalFrame.new(B, monW - sideW + 1, 3, sideW, monH - bottomH)
  -- fSide:getContainer()
  --   :addLabel()
  --   :setText("System Status")
  --   :setPosition(2, 1)
  --
  -- -- === Bottom Panel ===
  -- local fBottom = ExperimentalFrame.new(B, 1, monH - bottomH + 1, monW, bottomH)
  -- fBottom:getContainer()
  --   :addLabel()
  --   :setText("Footer Information")
  --   :setPosition(2, 1)
  --

	return self
end

function InputView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return InputView


------------	MUITZA SUGI PULA SI HAI SA NU NE CACAM PE NOI 
----- local bfMain = BorderedFrame.new(B, 2, 2, 50, 12)
	--
	-- local fMain = bfMain:getContainer()
	--
	-- fMain:addLabel():setText("Main Control Panel"):setPosition(2, 2):setBackground(colors.lightGray)
	--
	-- local fancy = ExperimentalFrame.new(B, 2, 13, 50, 10):setBorderColor(colors.lightGray)
	-- -- :setBackground(colors.white)
	--
	-- fancy
	-- 	:getContainer()
	-- 	:addLabel()
	-- 	:setText("Inside the experimental frame")
	-- 	:setPosition(2, 11)
	-- 	:setSize(30, 10)
	-- 	:setForeground(colors.black)
	-- fMain:addLabel()
	-- :setText("Main Control Panel")
	-- :setPosition(2, 1)
	--

	-- :setPosition(1, 2)
	-- :setSize(monW - 2, monH - 3)
	-- B.addChild(fMain)

	-- local indicators = IndicatorsPanel.new(app, 2, 2, 30, "System Status", {
	--     { label = "Pump", color = colors.red, state = "inactive" },
	--     { label = "Heater", color = colors.orange, state = "active" },
	--     { label = "Cooler", color = colors.blue, state = "inactive" }
	-- })
	-- table.insert(self.components, indicators)
