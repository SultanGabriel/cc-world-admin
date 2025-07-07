-- ui/views/MainView
local Component = require("ui.component")
local Clock = require("ui.ClockComponent")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")

local theme = require("common.theme")

local MainView = {}
MainView.__index = MainView
setmetatable(MainView, { __index = Component })

-- monitor res: 7x5 per block

function MainView.new(B, state)
	local self = setmetatable(Component.new(), MainView)

	self.components = {}
	self.state = state or {}

	local monW, monH = B:getSize()

	B:setBackground(theme.backgroundColor)

	-- === Header ===
	local headerH = 2
	local fHeader = B:addFrame({
		x = 1,
		y = 1,
		width = monW,
		height = headerH,
		background = theme.headerBackgroundColor,
	})

	fHeader:addLabel({
		x = monW / 2 - 20,
		y = 1,
		text = "GregTech Factory Central Monitoring System",
		foreground = colors.white,
	})

	local clock = Clock.new(fHeader, monW - 10, 1)
	table.insert(self.components, clock)

	-- === Main ===
	local sideW = 30
	local bottomH = 8

	-- local fMain = ExperimentalFrame.new(B, 1, 3, monW - sideW, monH - bottomH )
	-- local fMain = ExperimentalFrame.new(B, 1, 3, monW, monH - bottomH)
	local bfMain = ExperimentalFrame.new(B, 1, 3, monW, monH - headerH)
	local cMain = bfMain:getContainer()

	local buildingW = 70
	local buildingH = 20
	local xOff = 3
	local yOff = 2

	local bfBuilding = ExperimentalFrame.new(cMain, xOff, yOff, buildingW, buildingH)

	local cBuilding = bfBuilding:getContainer()

	local innerH = buildingH - 3

	local meW = 18
	local topRowH = 8
	local serverRoomW = 18
	local drawerHoleW = 10
	local meAutocraftW = 14
	local meAutocraftH = 7
	local gtmoW = buildingW - meW - serverRoomW - drawerHoleW - 1

	local corridor1W = 6
	local corridor2H = 4
	local corridor2W = drawerHoleW + serverRoomW - 1

	local elevatorH = 5
	local elevatorW = 8

	local gtmoX = meW + corridor1W + serverRoomW + drawerHoleW - 4

	local bfMEController = ExperimentalFrame.new(cBuilding, 0, 0, meW, innerH)
	local bfServerRoom = ExperimentalFrame.new(cBuilding, meW + corridor1W - 2, 0, serverRoomW, topRowH)
	local bfDrawerHole = ExperimentalFrame.new(cBuilding, meW + corridor1W + serverRoomW - 3, 0, drawerHoleW, topRowH)
	local bfMeAutocraft =
		ExperimentalFrame.new(cBuilding, gtmoX - meAutocraftW + 1, topRowH + corridor2H - 2, meAutocraftW, meAutocraftH)
	local bfGTMO = ExperimentalFrame.new(cBuilding, gtmoX, 0, gtmoW, innerH)

	local bfCorridor1 = ExperimentalFrame.new(cBuilding, meW - 1, 0, corridor1W, innerH)
	local bfCorridor2 = ExperimentalFrame.new(cBuilding, meW + corridor1W - 2, topRowH - 1, corridor2W, corridor2H)

	local fCorridorWay = cBuilding:addFrame({
		x = meW + corridor1W - 2,
		y = topRowH,
		width = 1,
		height = corridor2H - 2,
		background = colors.lightGray,
	})

	local bfElevator = ExperimentalFrame.new(cBuilding, meW + corridor1W - 2, innerH - elevatorH, elevatorW, elevatorH)

	local fElevatorDoor = cBuilding:addFrame({
		x = meW + corridor1W - 2,
		y = innerH - elevatorH + 2,
		width = 1,
		height = 1,
		background = colors.lightGray,
	})


	-- -- === Side Panel ===
	-- local fSide = ExperimentalFrame.new(B, monW - sideW + 1, 3, sideW, monH - bottomH)
	-- fSide:getContainer()
	--   :addLabel()
	--   :setText("System Status")
	--   :setPosition(2, 1)

	-- === Bottom Panel ===
	-- local fBottom = ExperimentalFrame.new(B, 1, monH - bottomH + 1, monW, bottomH)
	-- fBottom:getContainer():addLabel():setText("Footer Information"):setPosition(2, 1)

	return self
end

function MainView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return MainView
