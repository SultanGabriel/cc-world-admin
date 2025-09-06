
local Component = require('ui.component')
local Clock = require('ui.ClockComponent')
local BorderedFrame = require('ui.BorderedFrame')
local ExperimentalFrame = require('ui.ExperimentalFrame')
local GregMap = require('ui.GregMap')
local FissionReactor = require('ui.FissionReactor')

local theme = require('theme')

local MainView = {}
MainView.__index = MainView
setmetatable(MainView, { __index = Component })

local L = require('logger').getInstance('View Main', 'DEBUG')

function MainView.new(B, state)
	local self = setmetatable(Component.new(), MainView)
	
	assert(B, 'Basalt frame cannot be nil')
	assert(state, 'State object cannot be nil')

	self.components = {}
	self.state = state 
	self.B = B
	self.width = 114
	self.height = 33

	local monW, monH = B:getSize()

	L:info('MainView: new() - Monitor size: ' .. monW .. 'x' .. monH)

	self:draw()

	return self
end

function MainView:draw()
	L:info('MainView: draw() - Drawing main view components')
	
	local B = self.B
	B:setBackground(theme.backgroundColor)

	-- === Header ===
	local headerH = 1
	local fHeader = B:addFrame({
		x = 1,
		y = 1,
		width = self.width,
		height = headerH,
		background = theme.headerBackgroundColor,
	})

	fHeader:addLabel({
		x = self.width / 2 - 20,
		y = 1,
		text = 'Cernavoda Nuclear Fission Powerplant',
		foreground = colors.white,
	})

	local clock = Clock.new(fHeader, self.width - 10, 1)
	table.insert(self.components, clock)

	-- === Main ===

	local FMain = ExperimentalFrame.new(B, 1, headerH + 1, self.width, self.height - headerH - 1)
	local fMain = FMain:getContainer()


	-- === Footer ===

	R_VIEW_HEIGHT = 26
	R_VIEW_WIDTH = 34

	R_VIEWS_XOFFSET = 4
	R_VIEWS_YOFFSET = 2

	local fR1 = fMain:addFrame({
		x = R_VIEWS_XOFFSET,
		y = R_VIEWS_YOFFSET,
		width = R_VIEW_WIDTH,
		height = R_VIEW_HEIGHT,
		background = theme.panelBackgroundColor,
	})


	local fR2 = fMain:addFrame({
		x = R_VIEWS_XOFFSET + R_VIEW_WIDTH + 2,
		y = R_VIEWS_YOFFSET,
		width = R_VIEW_WIDTH,
		height = R_VIEW_HEIGHT,
		background = theme.panelBackgroundColor,
	})

	local fR3 = fMain:addFrame({
		x = R_VIEWS_XOFFSET + R_VIEW_WIDTH * 2 + 4,
		y = R_VIEWS_YOFFSET,
		width = R_VIEW_WIDTH,
		height = R_VIEW_HEIGHT,
		background = theme.panelBackgroundColor,
	})

  -- Fission reactor element
	local R1 = FissionReactor.new(fR1, self.state, 1, 1, "R01")
	table.insert(self.components, R1)

	local R2 = FissionReactor.new(fR2, self.state, 1, 1, "R02")
	table.insert(self.components, R2)

	local R3 = FissionReactor.new(fR3, self.state, 1, 1, "R03")
	table.insert(self.components, R3)

end

function MainView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return MainView
