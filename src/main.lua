local basalt = require("lib.basalt.src")
local MainView = require("ui.views.MainView")
local InputView = require("ui.views.InputView")
local EnergyView = require("ui.views.EnergyView")

local selectedMonitor = nil
local views = {}

local MONITOR_MAIN = "monitor_1"
local MONITOR_INPUT = "monitor_2"
local MONITOR_ENERGY = "monitor_3"
local MONITOR_STATS = "monitor_4"

local function init()
	local monitor = peripheral.wrap(MONITOR_MAIN)
	if not monitor then
		error("Monitor not found: " .. MONITOR_MAIN)
	end

	local B = basalt.createFrame():setTerm(monitor)

	B:initializeState("D_01", false, false)
	--:initializeState("D_02", false, false)

	local mainView = MainView.new(B, B)
	table.insert(views, mainView)

	--- Other views
	local monitorInput = peripheral.wrap(MONITOR_INPUT)
	if monitorInput then
		local inputView = InputView.new(basalt.createFrame():setTerm(monitorInput), B)
		table.insert(views, inputView)
	end

	local monitorEnergy = peripheral.wrap(MONITOR_ENERGY)
	if monitorEnergy then
		local energyView = EnergyView.new(basalt.createFrame():setTerm(monitorEnergy), B)
		table.insert(views, energyView)
	end
end

init()

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
