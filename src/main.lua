local basalt = require("lib.basalt")
local TankComponent = require("ui.TankComponent")
local Indicator = require("ui.Indicator")
local IndicatorsPanel = require("ui.IndicatorsPanel")
local MonitorSelector = require("ui.MonitorSelector")

local selectedMonitor = nil
local components = {}

local function updateLoop()
	while true do
		for _, comp in ipairs(components) do
			if comp.update then
				comp:update()
			end
		end
	end
end

local MONITOR_ID = "monitor_1"
local function initApp()
	local monitor = peripheral.wrap(MONITOR_ID)
	if not monitor then
		error("Monitor not found: " .. MONITOR_ID)
	end

	local app = basalt.createFrame():setTerm(monitor)
	local monW, monH = monitor.getSize()
	app:setSize(monW, monH)
	app:setBackground(colors.gray)

	app:addLabel():setText("Tschernobyl Fissile Fuel Management System"):setPosition(2, 2):setForeground(colors.white)

	local tanks = { peripheral.find("dynamicValve") }
	local x, y = 2, 3
	local tankHeight, spacing = 6, 1

	for _, tank in ipairs(tanks) do
		local tankComp = TankComponent.new(app, tank, x, y, monW - 2, tankHeight)
		table.insert(components, tankComp)
		y = y + tankHeight + spacing
	end

	-- local status = Indicator.new(app, 2, 16, "Fueling", colors.yellow)
	-- status:setState("intermittent")
	-- table.insert(components, status)

	-- local panel = IndicatorsPanel.new(app, 16, 12, 24, "System Status", {
	-- 	{ label = "Sugi Pula", color = colors.yellow, state = "intermittent" },
	-- 	{ label = "Muie", color = colors.green, state = "active" },
	-- 	{ label = "Da mue tie ma", color = colors.pink, state = "intermittent" },
	-- 	{ label = "hhahaha", color = colors.red, state = "inactive" },
	-- 	{ label = "Fueling", color = colors.yellow, state = "intermittent" },
	-- })
	-- table.insert(components, panel)
	--parallel.waitForAny(updateLoop)
end

local function init()
	-- local frame = basalt.getMainFrame()
	--
	-- frame:setBackground(colors.gray)
	--
	-- frame:addLabel():setText("Chernobyl Fissile Fuel Management System"):setPosition(2, 2):setForeground(colors.white)
	initApp()

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
	-- function() end,
	function()
		-- updateLoop()
	end
	--function() basalt.autoUpdate() end
)
basalt.run()
