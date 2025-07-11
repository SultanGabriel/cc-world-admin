-- components/MatrixStatusFrame.lua
local Component = require("ui.component")
local ExperimentalFrame = require("ui.ExperimentalFrame")

local MatrixStatusFrame = {}
MatrixStatusFrame.__index = MatrixStatusFrame
setmetatable(MatrixStatusFrame, { __index = Component })

function MatrixStatusFrame.new(app, x, y)
	local self = setmetatable(Component.new(), MatrixStatusFrame)

	self.w = 32
	self.h = 12

	self.energyStorage = {
    online = true,
		capacity = 0,
		stored = 0,
		input = 0,
		output = 0,
		maxIO = 0,
	}

	self.frame = ExperimentalFrame.new(app, x, y, self.w, self.h)
	self.fMain = self.frame:getContainer()
	-- ::getContainer()

	-- Title
	self.fMain:addLabel({
		text = "INDUCTION MATRIX",
		x = math.floor((self.w - 16) / 2),
		y = 1,
		foreground = colors.white,
		background = colors.gray,
	})

	-- Status bar
	self.statusLabel = self.fMain:addLabel({
		text = "ONLINE",
		x = math.floor((self.w - 6) / 2),
		y = 2,
		width = 8,
		foreground = colors.black,
		background = colors.lime,
	})

	-- Info section
	-- self.infoLabels = {}
	-- local infoY = 4
	-- local infoX = 8
	--
	-- local infoData = {
	-- 	{ "Capacity:", "307.20 TFE" },
	-- 	{ "Stored:", "197.68 TFE" },
	-- 	{ "Input:", "7.52 MFE/t" },
	-- 	{ "Output:", "59.64 MFE/t" },
	-- 	{ "Max I/O:", "104.86 MFE/t" },
	-- }
	--
	-- for i, entry in ipairs(infoData) do
	-- 	local labelLeft = self.fMain:addLabel({
	-- 		text = entry[1],
	-- 		x = infoX,
	-- 		y = infoY + i - 1,
	-- 		foreground = colors.black,
	-- 	})
	--
	-- 	local labelRight = self.fMain:addLabel({
	-- 		text = entry[2],
	-- 		x = infoX + 12,
	-- 		y = infoY + i - 1,
	-- 		foreground = colors.black,
	-- 	})
	--
	-- 	table.insert(self.infoLabels, { labelLeft, labelRight })
	-- end
	--
	-- Vertical Fill bar
	self.fillBar = self.fMain
		:addProgressBar({
			x = 2,
			y = self.h - 3,
			width = 20,
			height = 2,
			-- direction = "up",
			background = colors.gray,
			progressColor = colors.lime,
			progress = 0, -- Initial fill level
		})
		:setProgress(15) -- fixme remove later
	-- :setProgressColor(colors.lime):setProgress(90)

	-- I/O bar (stub)
	self.ioFrame = self.fMain:addFrame({
		x = 25,
		y = 5,
		width = 30,
		height = 6,
	})
	-- I/O Mini Bars
	local barX = 1
	local barHeight = 6

	self.ioBars = {
		charging = self.ioFrame:addProgressBar({
			x = barX,
			y = 1,
			width = 1,
			height = barHeight,
			direction = "up",
			background = colors.gray,
			progressColor = colors.green,
			progress = 50,
		}),

		discharging = self.ioFrame:addProgressBar({
			x = barX + 2,
			y = 1,
			width = 1,
			height = barHeight,
			direction = "up",
			background = colors.gray,
			progressColor = colors.red,
			progress = 50,
		}),
	}

	-- FILL I/O label
	-- self.ioLabel = self.fMain:addLabel({
	-- 	text = "FILL I/O     Empty in 6d",
	-- 	x = 2,
	-- 	y = self.h - 1,
	-- 	foreground = colors.black,
	-- })

	return self
end

function MatrixStatusFrame:updateInfo(key, value)
	for _, pair in ipairs(self.infoLabels) do
		if pair[1]:getText():match(key) then
			pair[2]:setText(value)
		end
	end
end

function MatrixStatusFrame:setFillLevel(percent)
	self.fillBar:setProgress(percent)
end

return MatrixStatusFrame
