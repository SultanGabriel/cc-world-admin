-- components/indicator.lua
local Component = require("ui.component")

local Clock = {}
Clock.__index = Clock
setmetatable(Clock, { __index = Component })

function Clock.new(app, x, y)
	local self = setmetatable(Component.new(), Clock)
	self.color = colors.white

	self.label = app:addLabel({
		x = x or 1,
		y = y or 1,
		text = os.date("%H:%M:%S"),
		foreground = self.color,
	})

	return self
end

function Clock:update()
	local currentTime = os.date("%H:%M:%S")

	if self.label:getText() ~= currentTime then
		self.label:setText(currentTime)
	end
end

return Clock
