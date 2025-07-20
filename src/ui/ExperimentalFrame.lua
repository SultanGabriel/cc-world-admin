local Component = require("ui.component")

local theme = require("common.theme")

local ExperimentalFrame = {}
ExperimentalFrame.__index = ExperimentalFrame
setmetatable(ExperimentalFrame, { __index = Component })

function ExperimentalFrame.new(app, x, y, w, h, bgColor, bColor)
	local self = setmetatable(Component.new(), ExperimentalFrame)

	self.borderColor = theme.borderColor or bColor or colors.black
	self.backgroundColor = theme.backgroundColor or bgColor or colors.lightGray
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	-- Base container
	self.container = app:addFrame():setPosition(x, y):setSize(w, h):setBackground(self.backgroundColor)

	self:_draw()

	return self
end



CHAR_CRN_BR = "\133" 
CHAR_CRN_BL = "\141" 
CHAR_CRN_UL = "\151"
CHAR_CRN_UR = "\139"
CHAR_BAR_V = "\149"
CHAR_BAR_H = "\131"
CHAR_BAR_BOT = "\140"

function ExperimentalFrame:_draw()
	-- Top border
	local borderTop = CHAR_CRN_UL
	local borderBot = CHAR_CRN_BL

	for i = 1, self.w - 2 do
		borderTop = borderTop .. CHAR_BAR_H
		borderBot = borderBot .. CHAR_BAR_BOT
	end

	borderTop = borderTop .. CHAR_BAR_V
	borderBot = borderBot .. CHAR_CRN_BR

	self.container:addLabel({
		x = 1,
		y = 1,
		text = borderTop,
		foreground = self.borderColor
	})

	self.container:addLabel({
		x = 1,
		y = self.h - 1,
		text = borderBot,
		foreground = self.borderColor
	})

	for i = 1, self.h - 3 do
		self.container:addLabel({
			x = 1,
			y = i + 1,
			text = CHAR_BAR_V,
			foreground = self.borderColor
		})

		self.container:addLabel({
			x = self.w,
			y = 1 + i,
			text = CHAR_BAR_V,
			foreground = self.borderColor
		})
	end

	-- self.top = self.container:addFrame()
	-- 	:setPosition(1, 1)
	-- 	:setSize(w, 1)
	-- 	:setBackground(self.borderColor)
	--
	-- -- Bottom border
	-- self.bottom = self.container:addFrame()
	-- 	:setPosition(1, h)
	-- 	:setSize(w, 1)
	-- 	:setBackground(self.borderColor)
	--
	-- -- Left border
	-- self.left = self.container:addFrame()
	-- 	:setPosition(1, 2)
	-- 	:setSize(1, h - 2)
	-- 	:setBackground(self.borderColor)
	--
	-- -- Right border
	-- self.right = self.container:addFrame()
	-- 	:setPosition(w, 2)
	-- 	:setSize(1, h - 2)
	-- 	:setBackground(self.borderColor)
	--
	-- -- Content area
	self.inner = self.container:addFrame():setPosition(2, 2):setSize(self.w - 2, self.h - 3):setBackground(theme.backgroundColor)
	-- :setBackground(self.backgroundColor)
	return self
end

function ExperimentalFrame:getContainer()
	return self.inner
end
--
-- function ExperimentalFrame:setBorderColor(color)
-- 	self.borderColor = colorBackground
-- 	self.top:setBackground(color)
-- 	self.bottom:setBackground(color)
-- 	self.left:setBackground(color)
-- 	self.right:setBackground(color)
-- 	return self
-- end
--
-- function ExperimentalFrame:setBackground(color)
-- 	self.backgroundColor = color
-- 	self.inner:setBackground(color)
-- 	return self
-- end
--
-- function ExperimentalFrame:setPosition(x, y)
-- 	self.container:setPosition(x, y)
-- 	return self
-- end
--
-- function ExperimentalFrame:setSize(w, h)
-- 	self.w = w
-- 	self.h = h
-- 	self.container:setSize(w, h)
-- 	self.top:setSize(w, 1)
-- 	self.bottom:setPosition(1, h):setSize(w, 1)
-- 	self.left:setSize(1, h - 2)
-- 	self.right:setPosition(w, 2):setSize(1, h - 2)
-- 	self.inner:setSize(w - 2, h - 2)
-- 	return self
-- end

return ExperimentalFrame
