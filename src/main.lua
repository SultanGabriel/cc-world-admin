-- main.lua
local basalt = require("lib.basalt")
--local Component = require("ui.component")
local TankComponent = require("ui.TankComponent")
local Indicator = require("ui.Indicator")
local IndicatorsPanel = require("ui.IndicatorsPanel")

-- Init Basalt app

-- Find and validate monitor
local function initMonitor(frame)
	local w = frame.width
	local h = frame.height

	local pNames = peripheral.getNames()
	local pMonitors = {}

	for _, item in ipairs(pNames) do
		if string.find(item, "monitor") then
			table.insert(pMonitors, item)
		end
	end

	if #pMonitors > 1 then
		print("hooply")

		frame:setBackground(colors.gray)

		frame
			:addLabel()
			:setText("Please select the monitor you want to use")
			:setForeground(colors.white)
			:setPosition(2, 1)

		local btn = frame
      :addButton()
      :setText("Save")
      :setPosition(w - 6, h - 1)
      :setSize(6, 1)
      :onClick(function()
			--list.getSelectedItem()
		end)

		local list = frame:addList():setPosition(2, 4):setSize(w - 2, h - 6)
		-- :addItem("Item 1")
		-- :addItem("Item 2")
		for _, item in ipairs(pMonitors) do
			list:addItem(item)
		end
	end

	print(monitor)

	local monitor = peripheral.find("monitor")

	if not monitor then
		print("Monitor not found!")
		return nil
	end

	return monitor
end

local function init()
	local pc = basalt.getMainFrame()

	local monitor = initMonitor(pc)

	if monitor == nil then
		return
	end

	local app = basalt.createFrame():setTerm(monitor)

	local monW, monH = monitor.getSize()
	app:setSize(monW, monH)
	app:setBackground(colors.black)

	-- Store all components
	local components = {}

	-- Find all dynamic tanks
	local tanks = { peripheral.find("dynamicValve") }
	-- Add dynamic tank components (for now, stack vertically)
	local x, y = 2, 3
	local tankHeight = 6
	local spacing = 1

	for _, tank in ipairs(tanks) do
		local tankComp = TankComponent.new(app, tank, x, y, monW - 2, tankHeight)
		table.insert(components, tankComp)
		y = y + tankHeight + spacing
	end

	local status = Indicator.new(app, 2, 1, "Fueling", colors.yellow)

	-- set initial state
	status:setState("intermittent")

	-- in update loop:
	table.insert(components, status) -- add to components list

	-- Place this below tank displays or in top-right
	local panel = IndicatorsPanel.new(app, 2, 15, 24, "System Status", {
		{ label = "Sugi Pula", color = colors.yellow, state = "intermittent" },
		{ label = "Muie", color = colors.green, state = "active" },
		{ label = "Da mue tie ma", color = colors.pink, state = "intermittent" },
		{ label = "hhahaha", color = colors.red, state = "inactive" },
		{ label = "Fueling", color = colors.yellow, state = "intermittent" },
	})

	table.insert(components, panel)
end

-- Later in logic:
-- panel:setIndicatorState(3, "active")

-- -- inside update loop function:
-- for _, comp in ipairs(components) do
--     comp:update()       -- optional for others
-- end

-- Main update loop
local function updateLoop()
	while true do
		for _, comp in ipairs(components) do
			comp:update()
		end
		sleep(0.1)
	end
end

init()

basalt.run()
-- Run app
parallel.waitForAny(
	--function() basalt.autoUpdate() end,
	updateLoop
)
