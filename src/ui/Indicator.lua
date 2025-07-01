-- components/indicator.lua
local Component = require("ui.component")

local Indicator = {}
Indicator.__index = Indicator
setmetatable(Indicator, { __index = Component })

function Indicator.new(app, x, y, labelText, color, labelRight)
	local self = setmetatable(Component.new(app), Indicator)

	self.color = color or colors.green
	self.labelText = labelText or "Status"
	self.labelRight = labelRight ~= false -- default true
	self.state = "inactive"
	self.blinkState = true
	self.lastBlink = os.clock()

	-- Outer container
	self.container = app:addFrame():setPosition(x, y):setSize(20, 1):setBackground(colors.black)

	-- Status dot
	self.dot = self.container:addLabel():setSize(1, 1):setBackground(colors.gray)

	-- Label
	self.label = self.container:addLabel():setForeground(colors.white):setText(self.labelText)

	if self.labelRight then
		self.dot:setPosition(1, 1)
		self.label:setPosition(3, 1)
	else
		self.label:setPosition(1, 1)
		self.dot:setPosition(#self.labelText + 3, 1)
	end

	return self
end

function Indicator:setState(state)
	self.state = state
	if state == "active" then
		self.dot:setBackground(self.color)
	elseif state == "inactive" then
		self.dot:setBackground(colors.black)
	elseif state == "intermittent" then
		-- Blink will be handled in update()
	end
end

function Indicator:update()
	if self.state ~= "intermittent" then
		return
	end
	local now = os.clock()
	if now - self.lastBlink >= 0.5 then
		self.blinkState = not self.blinkState
		self.dot:setBackground(self.blinkState and self.color or colors.gray)
		self.lastBlink = now
	end
end

return Indicator
