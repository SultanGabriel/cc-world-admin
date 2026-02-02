local Component = require("ui.component")
local BorderedFrame = require("ui.BorderedFrame")
local ExperimentalFrame = require("ui.ExperimentalFrame")
local GregMap = require("ui.GregMap")
local FissionReactor = require("ui.FissionReactor")
local TankComponent = require("ui.TankComponentAdvanced")

local theme = require("theme")
local CONF = require("config")

local FacilityView = {}
FacilityView.__index = FacilityView
setmetatable(FacilityView, { __index = Component })

local L = require("logger").getInstance("Fac View")

function FacilityView.new(B, state)
	local self = setmetatable(Component.new(), FacilityView)

	self.components = {}
	self.state = state or {}

	local monW, monH = B:getSize()
	-- print'FacilityView: new() - Monitor size:', monW, monH)
	L:info("Fac View: Monitor Size: w: " .. monW .. " h:" .. monH)

	local realW = 82
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
		text = "Cernavoda Nuclear Fission Powerplant",
		foreground = colors.white,
	})

	-- === Main ===

	local FMain = ExperimentalFrame.new(B, 1, headerH + 1, realW, realH - headerH - 1)
	local fMain = FMain:getContainer()

	self.tankViews = {}

	if TANKS then
		for i, tankConfig in pairs(CONF.TANKS) do
			self.tankViews[tankConfig.tag] = TankComponent.new(fMain, TANKS[tankConfig.tag], 2, 2 + 8 * (i - 1), 32, 8)

			print(i, tankConfig.tag, TANKS[tankConfig.tag].getStored().name)
			table.insert(self.components, self.tankViews[tankConfig.tag])
		end
	else
		L:error("Tanks have not been initialized!")
	end

	return self
end

function FacilityView:update()
	for _, c in ipairs(self.components) do
		c:update()
	end
end

return FacilityView
