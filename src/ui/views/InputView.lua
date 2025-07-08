-- ui/views/MainView
local Component = require("ui.component")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")

local DOORWAYS = require("config").Doorways

local theme = require("common.theme")

local InputView = {}
InputView.__index = InputView
setmetatable(InputView, { __index = Component })

function InputView.new(B, state)
	local self = setmetatable(Component.new(), InputView)

	self.components = {}
	self.state = state or {}

	local monW, monH = B:getSize()

	B:setBackground(theme.backgroundColor)

	-- === Header ===
	--[[ 	local fHeader = B:addFrame():setPosition(1, 1):setSize(monW, 1):setBackground(theme.headerBackgroundColor) ]]

	-- === Main ===
	local fMain = ExperimentalFrame.new(B, 1, 1, monW, monH)
	local mainContainer = fMain:getContainer()

	local btnOne = mainContainer
		:addButton()
		:setText("Start Process")
		:setPosition(2, 1)
		:setSize(29, 1)
		:setBackground(colors.green)
		:onClick(function(button, x, y)
			print("Process started!")
			print("Button clicked at: " .. x .. ", " .. y)
		end)

	mainContainer:addButton():setText("Stop Process"):setPosition(2, 3):setSize(29, 1):setBackground(colors.red)

	-- local btnD01 = mainContainer
	-- 	:addButton({
	-- 		text = "D01",
	-- 		x = 2,
	-- 		y = 5,
	-- 		width = 10,
	-- 		height = 2,
	-- 		background = colors.blue,
	-- 	})
	-- 	:onClick(function(button, x, y)
	-- 		local current = state:getState("D_01") or false
	-- 		state:setState("D_01", not current)
	-- 		print("D01 toggled to: " .. tostring(not current))
	-- 	end)

  local btnH = 1
  local btnW = 4
  local btnX = 2
  local btnY = 5
  local space = 1


  local idx = 0
  for key, door in pairs(DOORWAYS) do
    local doorState = state:getState(key) 

    mainContainer:addButton({
      text = door.id,
      x = btnX,
      y = btnY + idx * (btnH + space),
      width = btnW,
      height = btnH,
      background = colors.blue,
    })
      :onClick(function(button, x, y)
      local current = state:getState(key) or false
      state:setState(key, not current)
      print(key .. " toggled to: " .. tostring(not current))

    end)

    idx = idx + 1

    

    table.insert(self.components, doorComponent)
  end


	return self
end

function InputView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return InputView
