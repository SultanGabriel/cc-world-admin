package.path = package.path .. ";../lib/Basalt/release/?.lua"
package.path = package.path .. ";../src-common/?.lua"


local basalt = require('basalt')
local MainView = require('views.MainView')


-- local RedIO = require('redio')

local views = {}

local MONITOR_MAIN = 'monitor_1'

local function initState(state)
	if not state then
		error('State Object cannot be nil')
	end

    -- Initialize all states
end

local function init()
	local monitor = peripheral.wrap(MONITOR_MAIN)
	if not monitor then
		error('Monitor not found: ' .. MONITOR_MAIN)
	end

	local B = basalt.createFrame():setTerm(monitor)

	initState(B)

	-- local redstSide = 'bottom'
	-- RedIO_In = RedIO.new(redstSide, B, REDSTONE_INPUT)

	-- RedIO_Out = RedIO.new(redstSide, B, REDSTONE_OUTPUT)
	-- -- RedIO_Out:registerOutputChangeCallback()

	local mainView = MainView.new(B, B)
	table.insert(views, mainView)

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
