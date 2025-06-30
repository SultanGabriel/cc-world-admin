local Component = require("ui.component")
local BorderedFrame = {}
BorderedFrame.__index = BorderedFrame
setmetatable(BorderedFrame, { __index = Component })

function BorderedFrame.new(app, x, y, w, h)
	local self = setmetatable(Component.new(), BorderedFrame)

	self.borderColor = colors.black
	self.backgroundColor = colors.gray

	-- Outer frame (for border)
	self.frame = app:addFrame()
		:setPosition(x, y)
		:setSize(w, h)
		:setBackground(self.backgroundColor)

	-- Top border
	self.frame:addLabel()
		:setPosition(1, 1)
		:setText("+" .. string.rep("-", w - 2) .. "+")
		:setForeground(self.borderColor)
		:setBackground(self.backgroundColor)

	-- Bottom border
	self.frame:addLabel()
		:setPosition(1, h)
		:setText("+" .. string.rep("-", w - 2) .. "+")
		:setForeground(self.borderColor)
		:setBackground(self.backgroundColor)

	-- Left & right borders
	for i = 2, h - 1 do
		self.frame:addLabel()
			:setPosition(1, i)
			:setText("|")
			:setForeground(self.borderColor)
			:setBackground(self.backgroundColor)

		self.frame:addLabel()
			:setPosition(w, i)
			:setText("|")
			:setForeground(self.borderColor)
			:setBackground(self.backgroundColor)
	end

	-- Inner container (for content)
	self.inner = self.frame:addFrame()
		:setPosition(2, 2)
		:setSize(w - 2, h - 2)
		:setBackground(self.backgroundColor)

	return self
end

function BorderedFrame:getContainer()
	return self.inner
end

function BorderedFrame:setBorderColor(color)
	self.borderColor = color

	return self
end

function BorderedFrame:setBackground(color)
	self.backgroundColor = color
	self.frame:setBackground(color)
	self.inner:setBackground(color)
	return self
end

function BorderedFrame:setPosition(x, y)
	self.frame:setPosition(x, y)
	return self
end

return BorderedFrame

