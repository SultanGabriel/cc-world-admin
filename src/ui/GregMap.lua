-- components/GregMap.lua
local Component = require("ui.component")
local SimpleBorderedFrame = require("ui.SimpleBorderedFrame")

local GregMap = {}
GregMap.__index = GregMap
setmetatable(GregMap, { __index = Component })

function GregMap.new(B, x, y)
	local self = setmetatable(Component.new(), GregMap)

	self.x = x
	self.y = y


	-- local fMain = SimpleBorderedFrame.new(B, 1, 3, monW - sideW, monH - bottomH )
	-- local fMain = SimpleBorderedFrame.new(B, 1, 3, monW, monH - bottomH)
	-- local bfMain = SimpleBorderedFrame.new(B, 1, 2, realW, realH - headerH + 1)
	-- local cMain = bfMain:getContainer()
  local cMain = B

	local buildingW = 70
	local buildingH = 20
	-- local xOff = (realW / 2 ) - (buildingW / 2) + 1
	--  local xOff = 1
	-- local yOff = 2
  -- print("xOff, yOff:", xOff, yOff)

	local bfBuilding = SimpleBorderedFrame.new(cMain, self.x, self.y, buildingW, buildingH)

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

	local bfMEController = SimpleBorderedFrame.new(cBuilding, 0, 0, meW, innerH)
	local bfServerRoom = SimpleBorderedFrame.new(cBuilding, meW + corridor1W - 2, 0, serverRoomW, topRowH)
	local bfDrawerHole = SimpleBorderedFrame.new(cBuilding, meW + corridor1W + serverRoomW - 3, 0, drawerHoleW, topRowH)
	local bfMePatterns =
		SimpleBorderedFrame.new(cBuilding, gtmoX - meAutocraftW + 1, topRowH + corridor2H - 2, meAutocraftW, meAutocraftH)
	local bfGTMO = SimpleBorderedFrame.new(cBuilding, gtmoX, 0, gtmoW, innerH)

	local bfCorridor1 = SimpleBorderedFrame.new(cBuilding, meW - 1, 0, corridor1W, innerH)
	local bfCorridor2 = SimpleBorderedFrame.new(cBuilding, meW + corridor1W - 2, topRowH - 1, corridor2W, corridor2H)

	local fCorridorWay = cBuilding:addFrame({
		x = meW + corridor1W - 2,
		y = topRowH,
		width = 1,
		height = corridor2H - 2,
		background = colors.lightGray,
	})

	local bfElevator = SimpleBorderedFrame.new(cBuilding, meW + corridor1W - 2, innerH - elevatorH, elevatorW, elevatorH)

	local fElevatorDoor = cBuilding:addFrame({
		x = meW + corridor1W - 2,
		y = innerH - elevatorH + 2,
		width = 1,
		height = 1,
		background = colors.lightGray,
	})
-- 	self.fBackground = app:addFrame({
-- 		x = self.x,
-- 		y = self.y,
-- 		width = self.w,
-- 		height = self.h,
-- 		background = colors.black,
-- 	})
-- 	self.label = self.fBackground:addLabel({
-- 		x = 1,
-- 		y = 1,
-- 		text = doorID,
-- 		foreground = colors.white,
-- 	})
--
--   self.state:onStateChange(self.key, function (key, newValue)
--     -- print (self, newValue)
--     if(newValue) then
--       self.open = true
--       self.fBackground:setBackground(colors.green)
--     else
--       self.open = false
--       self.fBackground:setBackground(colors.red)
--     end
--
-- end)

	return self
end

return GregMap
