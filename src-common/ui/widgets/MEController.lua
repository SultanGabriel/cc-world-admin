-- components/Door.lua
local Component = require("ui.component")

local MEControllerWidget = {}
MEControllerWidget.__index = MEControllerWidget
setmetatable(MEControllerWidget, { __index = Component })

function MEControllerWidget.new(app, state,  key, x, y)--, w, h)doorID,
	local self = setmetatable(Component.new(), MEControllerWidget)

	self.state = state
	-- self.doorID = doorID
  self.key = key
	self.x = x
	self.y = y
	-- self.w = w
	-- self.h = h




	self.fBackground = app:addFrame({
		x = self.x,
		y = self.y,
		width =10,
		height = 9,
		background = colors.gray,
	})
	self.label = self.fBackground:addLabel({
		x = 2,
		y = 1,
		text = "ME Ctrl.",
		foreground = colors.white,
	})
--
--   self.state:onStateChange(self.key, function (key, newValue)
--     -- print (self, newValue)
--     if(newValue) then
--       self.open = true
--       self.fBackground:setBackground(colors.green)
--     else
--       self.open = false
--       self.fBackground:setBackground(colors.red)
--     end
--
-- end)

	return self
end


return MEControllerWidget

