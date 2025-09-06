
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

function MainView.new(B, state)
	local self = setmetatable(Component.new(), MainView)

	self.components = {}
	self.state = state or {}

	local monW, monH = B:getSize()
	print('MainView: new() - Monitor size:', monW, monH)

	local realW = 114
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
		text = 'Cernavoda Nuclear Fission Powerplant',
		foreground = colors.white,
	})

	local clock = Clock.new(fHeader, realW - 10, 1)
	table.insert(self.components, clock)

	-- === Main ===

	local FMain = ExperimentalFrame.new(B, 1, headerH + 1, realW, realH - headerH - 1)
	local fMain = FMain:getContainer()


	-- === Footer ===

	R_VIEW_HEIGHT = 22
	R_VIEW_WIDTH = 32

	R_VIEWS_XOFFSET = 4
  R_VIEWS_YOFFSET = 4

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
	local R1 = FissionReactor.new(fR1, 2, 2, self.state)
	table.insert(self.components, R1)
	

	return self
end

function MainView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return MainView
