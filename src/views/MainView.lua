-- ui/views/MainView
local Component = require("ui.component")
local Clock = require("ui.ClockComponent")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")
local Door = require("ui.Door")
local GregMap = require("ui.GregMap")
local PlayerCard = require("ui.PlayerCard")

local MEController = require("ui.widgets.MEController")
local DOORWAYS = require("config").Doorways

local theme = require("theme")

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
	local headerH = 1
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
	local sideW = 34
	local bottomH = 8

	local xOff = (realW / 2) - 34
	local yOff = 6
	local gregMap = GregMap.new(B, xOff, yOff)

	-- === Doorways === --

	local doorXOff = 3
	local doorYOff = yOff - 1

	for _, doorData in pairs(DOORWAYS) do
		-- local door = Door.new(cBuilding, doorData.id,doorData.x, doorData.y, doorData.w, doorData.h)
		local door = Door.new(
			B,
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

	-- === Me Controller  === --

	-- local wMEController = MEController.new(B, state, "MEController", 4, 4)

	-- ======================================== --
	--                                          --
	--                                          --
	-- ==============Sidebars=============== --

	-- === Player List  === --

	-- local cPlayerList = playersList:getContainer()
	--
	-- local test = ExperimentalFrame.new(B,20,20,30, realH-1)
	local framePlayerList = ExperimentalFrame.new(B, 2, 3, sideW, realH - 1)
	local cPlayerList = framePlayerList:getContainer()

	-- local cPlayerList = B:addFrame({
	--   x = 0,
	--   y = 0,
	--   width=30,
	--   height= realH-1,
	--   background= colors.gray
	-- })

	--
	-- cPlayerList:addLabel({
	--   x = 8,
	--   y = 2,
	--   text = "Players Online",
	--   foreground = colors.black
	-- })

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
			local card = PlayerCard.new(cPlayerList, 2, y, data)
			y = y + 6 -- Adjust spacing as needed
		end
	end)

	-- === CURRENTLY PLAYING LABEL ===
	local playingLabel = B:addLabel({
		x = 40,
		y = realH - 3,
		text = "[Not Playing]",
		foreground = colors.lightGray,
	}
)
	-- :setText("[Not Playing]")
	-- :setPosition(btnX, btnY + idx * (btnH + space))
	-- :setForeground(colors.lightGray)

	-- Bind label to media_current and media_playing state
	state:onStateChange("media_current", function(_, newTrack)
		local isPlaying = state:getState("media_playing")
		if newTrack and isPlaying then
			playingLabel:setText("Now Playing: " .. newTrack):setForeground(colors.lime)
		else
			playingLabel:setText("[Not Playing]"):setForeground(colors.lightGray)
		end
	end)

	state:onStateChange("media_playing", function(_, isPlaying)
		local track = state:getState("media_current")
		if isPlaying and track then
			playingLabel:setText("Now Playing: " .. track):setForeground(colors.lime)
		else
			playingLabel:setText("[Not Playing]"):setForeground(colors.lightGray)
		end
	end)

	-- === Indicator Panel === --

	-- local playersList = ExperimentalFrame.new(cMain,0,0,30, realH-1)
	local fIndicatorPanel = ExperimentalFrame.new(B, realW-sideW, 3, sideW, realH-1)
  local cIndicators = ExperimentalFrame:getContainer()
	--  B:addFrame({
	-- 	x = realW - sideW,
	-- 	y = 3,
	-- 	width = sideW,
	-- 	height = realH - 1,
	--
	-- })

	return self
end

function MainView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return MainView
