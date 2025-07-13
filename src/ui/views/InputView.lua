-- ui/views/MainView
local Component = require("ui.component")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")

local DOORWAYS = require("config").Doorways

local theme = require("common.theme")

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

	print("InputView: new() - Monitor size:", monW, monH)

	B:setBackground(theme.backgroundColor)

	-- === Header ===
	--[[ 	local fHeader = B:addFrame():setPosition(1, 1):setSize(monW, 1):setBackground(theme.headerBackgroundColor) ]]

	-- === Main ===
	local fMain = ExperimentalFrame.new(B, 1, 1, realW, realH)
	local mainContainer = fMain:getContainer()

	local btnH = 1
	local btnW = 4
	local btnX = 2
	local btnY = 1
	local space = 0

	local idx = 0
	for key, door in pairs(DOORWAYS) do
		local doorState = state:getState(key)

		mainContainer
			:addButton({
				text = door.id,
				x = btnX,
				y = btnY + idx * (btnH + space),
				width = btnW,
				height = btnH,
				background = colors.blue,
			})
			:onClick(function(button, x, y)
				local current = state:getState(key) or false
				state:setState(key, not current)
				print(key .. " toggled to: " .. tostring(not current))
			end)

		idx = idx + 1

		-- table.insert(self.components, doorComponent)
	end

	-- === Media Player Controls ===
	idx = idx + 1

	mainContainer:addLabel():setText("[ MEDIA CONTROLS ]"):setPosition(btnX, btnY + idx * (btnH + space))

	idx = idx + 1

	-- Play Button
	mainContainer
		:addButton({
			text = "Play",
			x = btnX,
			y = btnY + idx * (btnH + space),
			width = 6,
			height = 1,
			background = colors.green,
		})
		:onClick(function()
			if MPIO and MPIO.tracks[1] then
				print("[MediaPlayer] Playing:", MPIO.tracks[1])
				MPIO:play(MPIO.tracks[1])
			else
				print("[MediaPlayer] No track available to play.")
			end
		end)

	-- Pause Button
	mainContainer
		:addButton({
			text = " Pause",
			x = btnX + 7,
			y = btnY + idx * (btnH + space),
			width = 7,
			height = 1,
			background = colors.yellow,
		})
		:onClick(function()
			if MPIO then
				print("[MediaPlayer] Pausing playback.")
				MPIO:pause()
			end
		end)

	-- Stop Button
	mainContainer
		:addButton({
			text = " Stop",
			x = btnX + 15,
			y = btnY + idx * (btnH + space),
			width = 6,
			height = 1,
			background = colors.red,
		})
		:onClick(function()
			if MPIO then
				print("[MediaPlayer] Stopping playback.")
				MPIO:stop()
			end
		end)

	-- Next Button
	mainContainer
		:addButton({
			text = " Next",
			x = btnX + 22,
			y = btnY + idx * (btnH + space),
			width = 6,
			height = 1,
			background = colors.cyan,
		})
		:onClick(function()
			if MPIO and #MPIO.tracks > 0 then
				print("[MediaPlayer] Switching to next track.")
				MPIO:nextTrack()
			else
				print("[MediaPlayer] No tracks available to switch.")
			end
		end)

	return self
end

function InputView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return InputView
