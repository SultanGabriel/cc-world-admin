local basalt = require("lib.basalt.src")
local MainView = require("ui.views.MainView")
local InputView = require("ui.views.InputView")
local EnergyView = require("ui.views.EnergyView")

local selectedMonitor = nil
local views = {}

CANVAS = nil
local MONITOR_MAIN = "monitor_1"
local MONITOR_INPUT = "monitor_2"
local MONITOR_ENERGY = "monitor_3"
local MONITOR_STATS = "monitor_4"

local function initMainScreen()
	local monitor = peripheral.wrap(MONITOR_MAIN)
	if not monitor then
		error("Monitor not found: " .. MONITOR_MAIN)
	end

	local monitorInput = peripheral.wrap(MONITOR_INPUT)
	if monitorInput then
		local inputView = InputView.new(basalt.createFrame():setTerm(monitorInput))
		table.insert(views, inputView)
	end

	local monitorEnergy = peripheral.wrap(MONITOR_ENERGY)
	if monitorEnergy then
		local energyView = EnergyView.new(basalt.createFrame():setTerm(monitorEnergy))
		table.insert(views, energyView)
	end

	local B = basalt.createFrame():setTerm(monitor)

	B:setSize(monitor.getSize())

	local mainView = MainView.new(B)

	table.insert(views, mainView)

	-- local mAIN = basalt.createFrame():setTerm(monitorEnergy)
	-- local canvas = mAIN:getCanvas()
	-- -- canvas:bg(1, 1, colors.blue)
	-- canvas:line(1, 1, 10, 10, "*", colors.red, colors.green)
	--
	-- canvas:line(2, 2, 20, 2, "-", colors.red, colors.black)
	--
	-- -- Draw a rectangle somewhere below
	-- canvas:rect(5, 5, 10, 4, "#", colors.yellow, colors.blue)
	--
	-- -- Draw another diagonal line
	-- canvas:line(5, 10, 30, 15, "/", colors.green, colors.black)
	-- canvas:ellipse(10, 10, 5, 3, "@", colors.green, colors.black) -- Creates an ellipse
	--
	-- local monW, monH = monitor.getSize()
	-- app:setSize(monW, monH)
	-- app:setBackground(colors.gray)
	--
	-- app:addLabel():setText("TESTTESTEST"):setPosition(2, 2):setForeground(colors.pink)

	-- CANVAS = app:getCanvas()
end

local function init()
	-- local frame = basalt.getMainFrame()
	--
	-- frame:setBackground(colors.gray)
	--
	-- frame:addLabel():setText("Chernobyl Fissile Fuel Management System"):setPosition(2, 2):setForeground(colors.white)

	initMainScreen()

	-- MonitorSelector.select(frame, function(monitor)
	-- 	if monitor then
	-- 		selectedMonitor = monitor
	-- 		initApp(selectedMonitor)
	-- 	end
	-- end)
end

init()
-- basalt.run()
-- parallel.waitForAny(updateLoop)
parallel.waitForAny(
	-- View update loop
	function()
		while true do
			for _, view in ipairs(views) do
				-- print("Updating view: " .. tostring(view))
				view:update()
			end
			sleep(1)
		end
	end,

	-- Basalt update loop
	function()
		basalt.run()
	end
)
