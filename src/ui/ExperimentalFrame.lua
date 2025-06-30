local Component = require("ui.component")
local ExperimentalFrame = {}
ExperimentalFrame.__index = ExperimentalFrame
setmetatable(ExperimentalFrame, { __index = Component })

function ExperimentalFrame.new(app, x, y, w, h)
	local self = setmetatable(Component.new(), ExperimentalFrame)

	self.borderColor = colors.black
	self.backgroundColor = colors.lightGray
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	-- Base container
	self.container = app:addFrame()
		:setPosition(x, y)
		:setSize(w, h)

	-- Top border
	self.top = self.container:addFrame()
		:setPosition(1, 1)
		:setSize(w, 1)
		:setBackground(self.borderColor)

	-- Bottom border
	self.bottom = self.container:addFrame()
		:setPosition(1, h)
		:setSize(w, 1)
		:setBackground(self.borderColor)

	-- Left border
	self.left = self.container:addFrame()
		:setPosition(1, 2)
		:setSize(1, h - 2)
		:setBackground(self.borderColor)

	-- Right border
	self.right = self.container:addFrame()
		:setPosition(w, 2)
		:setSize(1, h - 2)
		:setBackground(self.borderColor)

	-- Content area
	self.inner = self.container:addFrame()
		:setPosition(2, 2)
		:setSize(w - 2, h - 2)
		:setBackground(self.backgroundColor)

	return self
end

function ExperimentalFrame:getContainer()
	return self.inner
end

function ExperimentalFrame:setBorderColor(color)
	self.borderColor = color
	self.top:setBackground(color)
	self.bottom:setBackground(color)
	self.left:setBackground(color)
	self.right:setBackground(color)
	return self
end

function ExperimentalFrame:setBackground(color)
	self.backgroundColor = color
	self.inner:setBackground(color)
	return self
end

function ExperimentalFrame:setPosition(x, y)
	self.container:setPosition(x, y)
	return self
end

function ExperimentalFrame:setSize(w, h)
	self.w = w
	self.h = h
	self.container:setSize(w, h)
	self.top:setSize(w, 1)
	self.bottom:setPosition(1, h):setSize(w, 1)
	self.left:setSize(1, h - 2)
	self.right:setPosition(w, 2):setSize(1, h - 2)
	self.inner:setSize(w - 2, h - 2)
	return self
end

return ExperimentalFrame

