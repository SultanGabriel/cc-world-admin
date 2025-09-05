local Component = require('ui.component')
local Clock = require('ui.ClockComponent')
local BorderedFrame = require('ui.BorderedFrame')
local ExperimentalFrame = require('ui.ExperimentalFrame')
local Door = require('ui.Door')
local GregMap = require('ui.GregMap')
local PlayerCard = require('ui.PlayerCard')

-- local MEController = require("ui.MEController")
local INDICATOR = require('ui.Indicator')
local DOORWAYS = require('config').Doorways
local INDICATORS = require('config').Indicators

local theme = require('theme')

local MainView = {}
MainView.__index = MainView
setmetatable(MainView, { __index = Component })

-- FIXME
FEATUREFLAG_INDICATORS = false

function MainView.new(B, state)
	local self = setmetatable(Component.new(), MainView)

	self.components = {}
	self.state = state or {}

	local monW, monH = B:getSize()
	print('MainView: new() - Monitor size:', monW, monH)

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
		text = 'GregTech Factory Central Monitoring System',
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


	cPlayerList:addLabel({
		x = 13,
		y = 1,
		text = 'Players',
		foreground = colors.white
	})

	local function clearChildren(frame)
		for _, child in ipairs(frame:getChildren()) do
			frame:removeChild(child)
		end
	end

	state:onStateChange('players', function(_, players)
		players = players or {}

		clearChildren(cPlayerList)

		local y = 3
		for _, data in pairs(players) do
			local card = PlayerCard.new(cPlayerList, 2, y, data)
			y = y + 6 -- spacing
		end
	end)

	-- === CURRENTLY PLAYING LABEL ===
	local playingLabel = B:addLabel({
		x = 40,
		y = realH - 1,
		text = '[Stopped]',
		foreground = colors.lightGray,
	}	)

	local track = B:addLabel({
		x = 50,
		y = realH - 1,
		text = 'Track:',
		foreground = colors.black,
	})

	-- Bind label to media_current and media_playing state
	state:onStateChange('media_current', function(_, newTrack)
		local isPlaying = state:getState('media_playing')
		if newTrack and isPlaying then
			playingLabel:setText('[Playing]')
			track:setText('Track: ' .. newTrack):setForeground(colors.black)
			-- playingLabel:setText('Now Playing: ' .. newTrack):setForeground(
			-- 	colors.lime)
		else
			-- playingLabel:setText('[Not Playing]'):setForeground(colors.lightGray)
			playingLabel:setText('[Stopped]'):setForeground(colors.lightGray)
			track:setText('Track: '):setForeground(colors.black)
		end
	end)

	state:onStateChange('media_playing', function(_, isPlaying)
		local track = state:getState('media_current')
		if isPlaying and track then
			playingLabel:setText('Now Playing: ' .. track):setForeground(colors
				.lime)
		else
			playingLabel:setText('[Not Playing]'):setForeground(colors.lightGray)
		end
	end)

	-- === Indicator Panel === --
	local fIndicatorPanel = ExperimentalFrame.new(B, realW - sideW, 3,
												  sideW - 4, realH - 4)
	if not FEATUREFLAG_INDICATORS then
		print('[MainView] new() - Indicators feature disabled.')
	else
		assert(fIndicatorPanel, '[MainView] new() - fIndicatorPanel is nil')

		local cIndicators = fIndicatorPanel:getContainer()
		local xOff_ind = 2
		for key, i in pairs(INDICATORS) do
			-- function Indicator.new(app, x, y, key)
			local ind = INDICATOR.new(cIndicators, 3, xOff_ind, key, state)
			xOff_ind = xOff_ind + 2

			-- for a, b in pairs(i) do
			-- 	print(key, 'Indicator data:', a, b)
			-- end
		end
		print('[MainView] new() - Created', #INDICATORS, 'indicators.')
	end


	return self
end

function MainView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return MainView