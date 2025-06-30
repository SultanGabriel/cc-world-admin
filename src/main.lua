local basalt = require("lib.basalt")
local MainView = require("ui.views.MainView")

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
    local inputView = MainView.new(basalt.createFrame():setTerm(monitorInput))
    table.insert(views, inputView)
  end

	local B = basalt.createFrame():setTerm(monitor)

  B:setSize(monitor.getSize())

  local mainView = MainView.new(B)

  table.insert(views, mainView)




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
	function()
    for _, view in ipairs(views) do
      view:update()
    end
  end
	-- function()
	-- 	-- updateLoop(),
	-- 	-- if CANVAS then
	-- 	-- 	CANVAS:line(1, 1, 10, 10, " ", colors.red, colors.green)
	-- 	--
	-- 	-- 	CANVAS:addCommand(function()
	-- 	-- 		-- Draw red text on black background
	-- 	-- 		CANVAS:drawText(1, 1, "Hello")
	-- 	-- 		CANVAS:drawFg(1, 1, colors.red)
	-- 	-- 		CANVAS:drawBg(1, 1, colors.black)
	-- 	--
	-- 	-- 		-- Or use blit for more efficient drawing
	-- 	-- 		CANVAS:blit(1, 2, "Hello", "fffff", "00000") -- white on black
	-- 	-- 	end)
	-- 	end
	-- end
	--function() basalt.autoUpdate() end
)
basalt.run()
