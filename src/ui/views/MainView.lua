-- ui/views/MainView
local Component = require("ui.component")
local Clock = require("ui.ClockComponent")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")
local Door = require("ui.Door")
local PlayerCard = require("ui.PlayerCard")

local MEController = require("ui.widgets.MEController")
local DOORWAYS = require("config").Doorways

local theme = require("common.theme")

---
-- local Doorways = {
-- 	D_00 = {
-- 		id = "0",
-- 		name = "Main Entrance",
-- 		x = 18,
-- 		y = 1,
-- 		w = 4,
-- 		h = 1,
-- 	},
-- 	D_01 = {
-- 		id = "1",
-- 		name = "ME Controller",
-- 		x = 17,
-- 		y = 3,
-- 		w = 1,
-- 		h = 3,
-- 	},
-- 	D_02 = {
-- 		id = "2",
-- 		name = "ME Server Room",
-- 		x = 34,
-- 		y = 8,
-- 		w = 3,
-- 		h = 1,
-- 	},
-- 	D_03 = {
-- 		id = "3",
-- 		name = "GTMO",
-- 		x = 48,
-- 		y = 8 + 1,
-- 		w = 1,
-- 		h = 2,
-- 	},
-- 	D_04 = {
-- 		id = "4",
-- 		name = "ME Patterns",
-- 		x = 44,
-- 		y = 11,
-- 		w = 3,
-- 		h = 1,
-- 	},
-- }
---

local MainView = {}
MainView.__index = MainView
setmetatable(MainView, { __index = Component })

-- monitor res: 7x5 per block

function MainView.new(B, state)
	local self = setmetatable(Component.new(), MainView)

	self.components = {}
	self.state = state or {}

	local monW, monH = B:getSize()
	print("MainView: new() - Monitor size:", monW, monH)

	local realW = 157
	local realH = 33

	B:setBackground(theme.backgroundColor)

	-- === Header ===
	local headerH = 2
	local fHeader = B:addFrame({
		x = 1,
		y = 1,
		width = realW,
		height = headerH,
		background = theme.headerBackgroundColor,
	})

	fHeader:addLabel({
		x = realW / 2 - 20,
		y = 1,
		text = "GregTech Factory Central Monitoring System",
		foreground = colors.white,
	})

	local clock = Clock.new(fHeader, realW - 10, 1)
	table.insert(self.components, clock)

	-- === Main ===
	local sideW = 30
	local bottomH = 8

	-- local fMain = ExperimentalFrame.new(B, 1, 3, monW - sideW, monH - bottomH )
	-- local fMain = ExperimentalFrame.new(B, 1, 3, monW, monH - bottomH)
	local bfMain = ExperimentalFrame.new(B, 1, 2, realW, realH - headerH + 1)
	local cMain = bfMain:getContainer()

	local buildingW = 70
	local buildingH = 20
	local xOff = (realW / 2 ) - (buildingW / 2) + 1
	local yOff = 2
  print("xOff, yOff:", xOff, yOff)

	local bfBuilding = ExperimentalFrame.new(cMain, xOff, yOff, buildingW, buildingH)

	local cBuilding = bfBuilding:getContainer()
	-- local cBuilding = cMain:addFrame({
	--   x = xOff+2,
	--   y = yOff,
	--   width = buildingW,
	--   height = buildingH+5,
	-- })

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
	local bfMePatterns =
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

	-- === Doorways === --

	local doorXOff = 3
	local doorYOff = 1

	for _, doorData in pairs(DOORWAYS) do
		-- local door = Door.new(cBuilding, doorData.id,doorData.x, doorData.y, doorData.w, doorData.h)
		local door = Door.new(
			cMain,
			state,
			doorData.id,
			doorData.key,
			doorData.x + doorXOff,
			doorData.y + doorYOff,
			doorData.w,
			doorData.h
		)
		table.insert(self.components, door)
	end

	-- === Doorways === --

	local wMEController = MEController.new(cBuilding, state, "MEController", 4, 4)

	-- other shit???

	local cPlayerList = cMain:addFrame({
    x = 1,
    y = 1,
    width = 30,
    height = realH -3,

  })
    --:setPosition(80, 2):setSize(30, realH):setBackground(colors.black)
  cPlayerList:addLabel({
    x = 2,
    y = 1,
    text = "Players Online",
    foreground = colors.red
  })

	local function clearChildren(frame)
		for _, child in ipairs(frame:getChildren()) do
			frame:removeChild(child)
		end
	end

	state:onStateChange("players", function(_, players)
		players = players or {}

		clearChildren(cPlayerList)

		local y = 3
		for _, data in pairs(players) do
			local card = PlayerCard.new(cPlayerList, 1, y, data)
			y = y + 6 -- Adjust spacing as needed
		end
	end)

	-- local playerStartY = 10
	-- state:onStateChange("players", function()
	-- 	local players = self.state:getState("players") or {}
	-- 	for username, data in pairs(players) do
	--      print("Drawing card", playerStartY)
	-- 		PlayerCard.new(cMain, 80, playerStartY, data)
	-- 		playerStartY = playerStartY + 10
	-- 	end
	-- end)
	-- local player = {
	-- 	name = "Steve",
	-- 	health = 120,
	-- 	maxHealth = 500,
	-- 	x = 104,
	-- 	y = 65,
	-- 	z = -120,
	-- 	dimension = "Overworld",
	-- }
	--
	-- local card = PlayerCard.new(cMain, 80, 10, player)
	-- table.insert(self.components, card)

	-- === ======== === --
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
