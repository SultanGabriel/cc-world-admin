-- components/PlayerCard.lua
local Component = require("ui.component")

local PlayerCard = {}
PlayerCard.__index = PlayerCard
setmetatable(PlayerCard, { __index = Component })

function PlayerCard.new(app, x, y, player)
	local self = setmetatable(Component.new(), PlayerCard)

	self.player = player
	self.health = math.max(0, math.min(player.health or 0, player.maxHealth or 20))

	local cardW = 26
	local cardH = 5

	self.container = app:addFrame():setPosition(x, y):setSize(cardW, cardH):setBackground(colors.gray)

	-- Name label
	self.container
		:addLabel()
		:setText(player.name)
		:setPosition(2, 1)
		:setForeground(colors.yellow)

	-- Health bar background
	self.container:addFrame():setPosition(2, 2):setSize(cardW - 2, 1):setBackground(colors.black)

	-- Health bar foreground
	self.healthBar = self.container
		:addFrame()
		:setPosition(2, 2)
		:setSize(math.floor((cardW - 2) * (self.health / player.maxHealth)), 1)
		:setBackground(colors.red)

  -- Health label
  self.healthLabel = self.container
    :addLabel({
    x = cardW - 7,
    y = 1,
    text = string.format("%d/%d", self.health, player.maxHealth or 'N/A'),
    foreground = colors.white,
  })

	-- Coordinates label
	self.container
		:addLabel()
		:setText(string.format("X:%d Y:%d Z:%d", player.x or 0, player.y or 0, player.z or 0))
		:setPosition(2, 4)
		:setForeground(colors.white)

	-- Dimension label
	self.container
		:addLabel()
		:setText("Dim: " .. (player.dimension or "Unknown"))
		:setPosition(2, 5)
		:setForeground(colors.lightGray)

	return self
end

function PlayerCard:setHealth(health)
	self.health = math.max(0, math.min(health, self.player.maxHealth))
	local barW = self.container:getSize()
	barW = barW - 4
	self.healthBar:setSize(math.floor(barW * (self.health / self.player.maxHealth)), 1)
end

function PlayerCard:update()
	-- could later refresh values from state or an external source
end

return PlayerCard
