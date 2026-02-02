package.path = package.path .. ";../lib/Basalt/release/?.lua"
package.path = package.path .. ";../src-common/?.lua"

local basalt = require("basalt")
local MainView = require("views.MainView")
local DevView = require("views.DevView")
local FacilityView = require("views.FacilityView")


local CONF = require("config")

-- Logger Setup
local L = require("logger").getInstance("Main", "DEBUG", "/log.txt")

-- local RedIO = require('redio')

local views = {}

local MONITOR_MAIN = "monitor_21"
local MONITOR_DEV = "monitor_22"
local MONITOR_FACILITY = "monitor_23"

REACTORS = {}
TANKS = {
  
}

local function initReactorPeripherals(state)


end

local function initTankPeripherals(state)
  for i, tankConfig in pairs(CONF.TANKS) do
    TANKS[tankConfig.tag] = peripheral.wrap(tankConfig.peripheral)
    
    print(i, tankConfig.tag, TANKS[tankConfig.tag].getStored().name)

  end

end

local function initState(state)
	if not state then
		L:error("State Object cannot be nil")
		return
	end

	-- Initialize all states
	local stateCount = 0

	L:info("State initialized with " .. stateCount .. " entries")
end

local function init()
	local monitor = peripheral.wrap(MONITOR_MAIN)
	if not monitor then
		L:error("Monitor not found: " .. MONITOR_MAIN)
	end

	local B = basalt.createFrame():setTerm(monitor)

	initState(B)
  initTankPeripherals(B)

	-- local redstSide = 'bottom'
	-- RedIO_In = RedIO.new(redstSide, B, REDSTONE_INPUT)

	-- RedIO_Out = RedIO.new(redstSide, B, REDSTONE_OUTPUT)
	-- -- RedIO_Out:registerOutputChangeCallback()

	local mainView = MainView.new(B, B)
	table.insert(views, mainView)

	-- DevView
	local devMonitor = peripheral.wrap(MONITOR_DEV)
	if devMonitor then
		local devView = DevView.new(basalt.createFrame():setTerm(devMonitor), B)
		table.insert(views, devView)
	else
		L:error("dev Monitor not found: " .. MONITOR_DEV)
	end

	-- Facility View
	local facilityMonitor = peripheral.wrap(MONITOR_FACILITY)
	if devMonitor then
		local facilityView = FacilityView.new(basalt.createFrame():setTerm(facilityMonitor), B)
		table.insert(views, facilityView)
	else
		L:error("Facility Monitor not found: " .. MONITOR_DEV)
	end

  -- -- -- -- -- -- -- -- --

	L:info("Initialization complete with " .. #views .. " views")
	return true
end

init()

local POLL_INTERVAL = 0.5
basalt.schedule(function()
	while true do
		for _, view in ipairs(views) do
			-- print("Updating view: " .. tostring(view))
			view:update()
		end

		os.sleep(POLL_INTERVAL)
	end
end)

basalt.run()
