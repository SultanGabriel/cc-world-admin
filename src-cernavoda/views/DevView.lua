
local Component = require('ui.component')
local Clock = require('ui.ClockComponent')
local BorderedFrame = require('ui.BorderedFrame')
local ExperimentalFrame = require('ui.ExperimentalFrame')
local GregMap = require('ui.GregMap')
local FissionReactor = require('ui.FissionReactor')

local theme = require('theme')

local DevView = {}
DevView.__index = DevView
setmetatable(DevView, { __index = Component })


function DevView.new(B, state)
	local self = setmetatable(Component.new(), DevView)

	self.components = {}
	self.state = state or {}

	local monW, monH = B:getSize()
	print('DevView: new() - Monitor size:', monW, monH)

	local realW = 61
	local realH = 35

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
		text = 'Cernavoda Nuclear Fission Powerplant',
		foreground = colors.white,
	})


	-- === Main ===

	local FMain = ExperimentalFrame.new(B, 1, headerH + 1, realW, realH - headerH - 1)
	local fMain = FMain:getContainer()



	return self
end

function DevView:update()
	for _, c in ipairs(self.components) do
		-- c:update()
	end
end

return DevView
