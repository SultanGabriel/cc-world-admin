-- components/Door.lua
local Component = require("ui.component")

local Door = {}
Door.__index = Door
setmetatable(Door, { __index = Component })

function Door.new(app, state, doorID, key, x, y, w, h)
	local self = setmetatable(Component.new(), Door)

	self.state = state
	self.doorID = doorID
  self.key = key
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.open = false

	-- app:addLabel({
	--   x = self.x,
	--   y = self.y,
	--   text = "Door ID: " .. self.doorID,
	--   foreground = colors.white,
	-- })

	self.fBackground = app:addFrame({
		x = self.x,
		y = self.y,
		width = self.w,
		height = self.h,
		background = colors.black,
	})
	self.label = self.fBackground:addLabel({
		x = 1,
		y = 1,
		text = doorID,
		foreground = colors.white,
	})

  self.state:onStateChange(self.key, function (key, newValue)
    -- print (self, newValue)
    if(newValue) then
      self.open = true
      self.fBackground:setBackground(colors.green)
    else
      self.open = false
      self.fBackground:setBackground(colors.red)
    end

end)

	-- self.color = color or colors.green
	-- self.labelText = labelText or "Status"
	-- self.labelRight = labelRight ~= false -- default true
	-- self.state = "inactive"
	-- self.blinkState = true
	-- self.lastBlink = os.clock()
	--
	-- -- Outer container
	-- self.container = app:addFrame():setPosition(x, y):setSize(20, 1):setBackground(colors.black)
	--
	-- -- Status dot
	-- self.dot = self.container:addLabel():setSize(1, 1):setBackground(colors.gray)
	--
	-- -- Label
	-- self.label = self.container:addLabel():setForeground(colors.white):setText(self.labelText)
	--
	-- if self.labelRight then
	-- 	self.dot:setPosition(1, 1)
	-- 	self.label:setPosition(3, 1)
	-- else
	-- 	self.label:setPosition(1, 1)
	-- 	self.dot:setPosition(#self.labelText + 3, 1)
	-- end
	--
	return self
end

-- function Door:setState(state)
-- 	self.state = state
-- 	if state == "active" then
-- 		self.dot:setBackground(self.color)
-- 	elseif state == "inactive" then
-- 		self.dot:setBackground(colors.black)
-- 	elseif state == "intermittent" then
-- 		-- Blink will be handled in update()
-- 	end
-- end
--
-- function Door:update()
-- 	if self.state ~= "intermittent" then
-- 		return
-- 	end
-- 	local now = os.clock()
-- 	if now - self.lastBlink >= 0.5 then
-- 		self.blinkState = not self.blinkState
-- 		self.dot:setBackground(self.blinkState and self.color or colors.gray)
-- 		self.lastBlink = now
-- 	end
-- end

return Door
