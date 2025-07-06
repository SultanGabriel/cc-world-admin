-- ui/views/MainView
local Component = require("ui.component")
local Clock = require("ui.ClockComponent")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")

local theme = require("common.theme")

local MainView = {}
MainView.__index = MainView
setmetatable(MainView, { __index = Component })

function MainView.new(B)
	local self = setmetatable(Component.new(), MainView)

	self.components = {}

	local monW, monH = B:getSize()

	B:setBackground(theme.backgroundColor)

	-- === Header ===
	local fHeader = B:addFrame():setPosition(1, 1):setSize(monW, 2):setBackground(theme.headerBackgroundColor)

	fHeader:addLabel({
		x = monW / 2 - 20,
		y = 1,
		text = "GregTech Factory Central Monitoring System",
		foreground = colors.white,
	})
	-- :setText("GregTech Factory Central Monitoring System")
	-- :setPosition(monW / 2 - 20, 1)
	-- :setForeground(colors.white)

	-- fHeader:addLabel({
	-- 	x = monW - 10,
	-- 	y = 1,
	-- 	text = os.date("%H:%M:%S"),
	-- })

  local clock = Clock.new(fHeader, monW - 10, 1)
  table.insert(self.components, clock)

	-- canvas:text(1, 1, "Hello Canvas!", 1, 32768)
	-- canvas:line(1, 1, monW, 1, "-", colors.white, colors.pink)
	-- :setText(os.date("%H:%M:%S")):setPosition(monW - 10, 1):setForeground(colors.white)

	-- === Main ===
	local sideW = 30
	local bottomH = 8

	-- local fMain = ExperimentalFrame.new(B, 1, 3, monW - sideW, monH - bottomH )
	local fMain = ExperimentalFrame.new(B, 1, 3, monW, monH - bottomH)

	fMain:getContainer():addLabel():setText("Main Control Panel"):setPosition(2, 1)
	-- local canvasBox = fMain:getContainer():addFrame():setSize(20, 10):setBackground(colors.black)

	-- Draw with canvas
	-- canvasBox.getCanvas()
	--     canvas:line(1, 1, 10, 10, "*", colors.red, colors.black) -- Draws a red line
	-- :rect(1, 1, 10, 3, "=", colors.red, colors.black)  -- rectangle
	-- :text(2, 2, "Hi!", colors.white, colors.black)     -- text
	-- :line(1, 5, 15, 9, ".", colors.green, colors.blue) -- line

	-- -- === Side Panel ===
	-- local fSide = ExperimentalFrame.new(B, monW - sideW + 1, 3, sideW, monH - bottomH)
	-- fSide:getContainer()
	--   :addLabel()
	--   :setText("System Status")
	--   :setPosition(2, 1)

	-- === Bottom Panel ===
	local fBottom = ExperimentalFrame.new(B, 1, monH - bottomH + 1, monW, bottomH)
	fBottom:getContainer():addLabel():setText("Footer Information"):setPosition(2, 1)


-- 	local canvasPlugin = require("lib.basalt.src.plugins.canvas")
-- 	local Canvas = canvasPlugin.API
-- 	
--   self.canvas = Canvas.new(B)
--   if self.canvas then
--     self.canvas:text(1, 1, "Hello Canvas!", 1, 32768)
-- -- Draw a horizontal line near the top
-- self.canvas:line(2, 2, 20, 2, "-", colors.red, colors.black)
--
-- -- Draw a rectangle somewhere below
-- self.canvas:rect(5, 5, 10, 4, "#", colors.yellow, colors.blue)
--
-- -- Draw another diagonal line
-- self.canvas:line(5, 10, 30, 15, "/", colors.green, colors.black)
--
--   else
--     error("Canvas plugin not found or failed to initialize.")
--   end


	return self
end

function MainView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return MainView

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
