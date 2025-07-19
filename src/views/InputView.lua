-- ui/views/InputView
local Component = require('ui.component')
local BorderedFrame = require('ui.BorderedFrame')
local ExperimentalFrame = require('ui.ExperimentalFrame')

local DOORWAYS = require('config').Doorways

local theme = require('common.theme')

local InputView = {}
InputView.__index = InputView
setmetatable(InputView, { __index = Component })

function InputView.new(B, state)
	local self = setmetatable(Component.new(), InputView)
	self.components = {}
	self.state = state or {}

	local monW, monH = B:getSize()

	local realW = 50
	local realH = 12

	print('InputView: new() - Monitor size:', monW, monH)
	B:setBackground(theme.backgroundColor)

	local fMain = ExperimentalFrame.new(B, 1, 1, realW, realH)
	local mainContainer = fMain:getContainer()

	local btnW = 6
	local btnH = 1
	local btnX = 2
	local btnY = 1
	local space = 0
	local idx = 0

	-- === DOORWAY BUTTONS + LABELS ===
	for key, door in pairs(DOORWAYS) do
		local label = mainContainer:addLabel()
			:setText(door.name)
			:setPosition(btnX + btnW + 1, btnY + idx * (btnH + space))

		local btn = mainContainer:addButton({
			text = door.key,
			x = btnX,
			y = btnY + idx * (btnH + space),
			width = btnW,
			height = btnH,
			background = colors.gray, -- default = unknown
		})

		self.components[#self.components + 1] = btn

		-- Set initial button color based on state
		local function updateColor(val)
			if val == true then
				btn:setBackground(colors.green)
			elseif val == false then
				btn:setBackground(colors.red)
			else
				btn:setBackground(colors.gray)
			end
		end

		updateColor(state:getState(key))

		btn:onClick(function()
			local current = state:getState(key) or false
			state:setState(key, not current)
			print('[InputView] Toggled ' ..
			key .. ' to ' .. tostring(not current))
		end)

		-- Watch for external state changes
		state:onStateChange(key, function(_, newValue)
			updateColor(newValue)
		end)

		idx = idx + 1
	end


	mainContainer:addButton({
		text = 'Open All',
		x = btnX + 35,
		y = 1,
		width = 10,
		height = 1,
		background = colors.green,
	}):onClick(function()
		for key, _ in pairs(DOORWAYS) do
			if not state:getState(key) then
				RedIO_Out:pulse(key)
				print('[Doors] Opening:', key)
			end
		end
	end)

	-- === DOOR CONTROL BUTTONS ===

	mainContainer:addButton({
		text = 'Close All',
		x = btnX + 35,
		y = 3,
		width = 10,
		height = 1,
		background = colors.red,
	}):onClick(function()
		for key, _ in pairs(DOORWAYS) do
			if state:getState(key) then
				RedIO_Out:pulse(key)
				print('[Doors] Closing:', key)
			end
		end
	end)

	mainContainer:addButton({
		text = 'LOCKDOWN',
		x = btnX + 35,
		y = 5,
		width = 10,
		height = 1,
		background = colors.gray,
	}):onClick(function()
		for key, _ in pairs(DOORWAYS) do
			if state:getState(key) then
				RedIO_Out:pulse(key)
				print('[Doors] Lockdown - Closing:', key)
			end
		end
	end)


	-- === MEDIA PLAYER CONTROLS ===
	local mediaY = realH - 2
	local mediaX = btnX

	mainContainer:addLabel()
		:setText('[ MEDIA CONTROLS ]')
		:setPosition(mediaX, mediaY - 1)

	-- Play
	mainContainer:addButton({
		text = 'Play',
		x = mediaX,
		y = mediaY,
		width = 6,
		height = 1,
		background = colors.green,
	}):onClick(function()
		if MPIO and MPIO.tracks[1] then
			print('[MediaPlayer] Playing:', MPIO.tracks[1])
			MPIO:play(MPIO.tracks[1])
		else
			print('[MediaPlayer] No track available to play.')
		end
	end)

	-- Pause
	mainContainer:addButton({
		text = ' Pause',
		x = mediaX + 7,
		y = mediaY,
		width = 7,
		height = 1,
		background = colors.yellow,
	}):onClick(function()
		if MPIO then
			print('[MediaPlayer] Pausing playback.')
			MPIO:pause()
		end
	end)

	-- Stop
	mainContainer:addButton({
		text = 'Stop',
		x = mediaX + 15,
		y = mediaY,
		width = 6,
		height = 1,
		background = colors.red,
	}):onClick(function()
		if MPIO then
			print('[MediaPlayer] Stopping playback.')
			MPIO:stop()
		end
	end)

	-- Next
	mainContainer:addButton({
		text = 'Next',
		x = mediaX + 22,
		y = mediaY,
		width = 6,
		height = 1,
		background = colors.cyan,
	}):onClick(function()
		if MPIO and #MPIO.tracks > 0 then
			print('[MediaPlayer] Switching to next track.')
			MPIO:nextTrack()
		else
			print('[MediaPlayer] No tracks available to switch.')
		end
	end)

	return self
end

-- function InputView:update()
-- 	for _, c in ipairs(self.components) do
-- 		c:update()
-- 	end
-- end

return InputView