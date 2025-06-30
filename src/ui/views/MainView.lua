-- ui/views/MainView
local Component = require("ui.component")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")

local MainView = {}
MainView.__index = MainView
setmetatable(MainView, { __index = Component })

function MainView.new(B)
	local self = setmetatable(Component.new(), MainView)

	self.components = {}

	local monW, monH = B:getSize()

	B:setBackground(colors.gray)
	B:addLabel()
		:setText("GregTech Factory Central Monitoring System")
		:setPosition(monW / 2 - 20, 1)
		:setForeground(colors.white)

	local bfMain = BorderedFrame.new(B, 2, 2, 50, 12)

	local fMain = bfMain:getContainer()

	fMain:addLabel():setText("Main Control Panel"):setPosition(2, 2):setBackground(colors.lightGray)

	local fancy = ExperimentalFrame.new(B, 2, 13, 50, 10):setBorderColor(colors.lightGray)
	-- :setBackground(colors.white)

	fancy
		:getContainer()
		:addLabel()
		:setText("Inside the experimental frame")
		:setPosition(2, 11)
		:setSize(30, 10)
		:setForeground(colors.black)
	-- fMain:addLabel()
	-- :setText("Main Control Panel")
	-- :setPosition(2, 1)
	--

	-- :setPosition(1, 2)
	-- :setSize(monW - 2, monH - 3)
	B.addChild(fMain)

	-- local indicators = IndicatorsPanel.new(app, 2, 2, 30, "System Status", {
	--     { label = "Pump", color = colors.red, state = "inactive" },
	--     { label = "Heater", color = colors.orange, state = "active" },
	--     { label = "Cooler", color = colors.blue, state = "inactive" }
	-- })
	-- table.insert(self.components, indicators)

	return self
end

function MainView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return MainView
