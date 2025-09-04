-- components/indicator.lua
local Component = require("ui.component")

local Indicator = {}
Indicator.__index = Indicator
setmetatable(Indicator, { __index = Component })

function Indicator.new(app, x, y, key, state)
	local self = setmetatable(Component.new(), Indicator)

	self.colorOn = colors.green
	self.colorOff = colors.red
	self.key = key

	self.labelText = key or "UNKNOWN"
	self.labelRight = true

	self.state = true -- fixme default to false
	-- self.blinkState = true
	-- self.lastBlink = os.clock()

	-- Outer container
	self.container = app:addFrame():setPosition(x, y):setSize(20, 1):setBackground(colors.black)


	-- Label
	self.label = self.container:addLabel():setForeground(colors.white):setText(self.labelText)

	-- Status dot
	self.dot = self.container:addLabel():setSize(1, 1):setText("\8"):setForeground(colors.gray)
	if self.labelRight then
		self.dot:setPosition(1, 1)
		self.label:setPosition(3, 1)
	else
		self.label:setPosition(1, 1)
		self.dot:setPosition(#self.labelText + 3, 1)
	end

	self:setState(state:getState(self.key)) -- Initialize state
	print("[Indicator] " .. key .." - Current state:", self.state)

	state:onStateChange(key, function(_, newState)
		self:setState(newState)
	end)

	return self
end

function Indicator:setState(state)
	self.state = state
	print("[Indicator] State changed to:", state, "for", self.key)
	if state then
		self.dot:setForeground(self.colorOn)
	else
		self.dot:setForeground(self.colorOff)
	end
end

function Indicator:update()
	-- if self.state ~= "intermittent" then
	-- 	return
	-- end
	-- local now = os.clock()
	-- if now - self.lastBlink >= 0.5 then
	-- 	self.blinkState = not self.blinkState
	-- 	self.dot:setBackground(self.blinkState and self.color or colors.gray)
	-- 	self.lastBlink = now
	-- end
end

return Indicator
