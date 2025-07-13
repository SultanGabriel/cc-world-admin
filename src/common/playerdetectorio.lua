-- lib/PlayerDetectorIO.lua

--- A wrapper around the playerDetector peripheral using state and event binding

local ZONES = require("config").Zones

local PlayerDetectorIO = {}
PlayerDetectorIO.__index = PlayerDetectorIO

DEBUG_LOGS = true

local function log(msg)
	if DEBUG_LOGS then
		print("[PlayerDetectorIO] " .. msg)
	end
end

--- Create a new instance of the player detector controller
-- @param stateFrame basalt frame to store player state
-- @param playerDetectorPeripheral player detector
-- @param chatBoxPeripheral chat box peripheral for sending messages
function PlayerDetectorIO.new(stateFrame, playerDetectorPeripheral, chatBoxPeripheral)
	local self = setmetatable({}, PlayerDetectorIO)

	self.peripheral = playerDetectorPeripheral
	self.chatBox = chatBoxPeripheral

	self.stateFrame = stateFrame
	self.players = {}

	self.enableEvents = true
	self.enableZones = true

	self.playerActiveZones = {} -- moved here for persistent tracking

	self:_selfCheck()
	self:_init()

	return self
end

function PlayerDetectorIO:_selfCheck()
  assert(self.peripheral and self.peripheral.getOnlinePlayers, "PlayerDetectorIO requires a valid playerDetector peripheral")
  assert(self.chatBox and self.chatBox.sendMessage, "PlayerDetectorIO requires a valid chatBox peripheral")
  assert(self.stateFrame, "PlayerDetectorIO requires a valid stateFrame")

  log("Self-check passed: All required peripherals and state frame are valid.")
	
end

function PlayerDetectorIO:_init()
	log("Initializing PlayerDetectorIO...")

	-- Initial state setup
	self.stateFrame:initializeState("players", {})
  self.stateFrame:initializeState("PDIO_Zones_Enabled", self.enableZones)
  self.stateFrame:initializeState("PDIO_Events_Enabled", self.enableEvents)

	-- Set up event listeners
	self.stateFrame:onStateChange("PDIO_Zones_Enabled", function(_, enabled)
    self.enableZones = enabled
    log("Zone notifications " .. (enabled and "enabled" or "disabled"))
  end)

  self.stateFrame:onStateChange("PDIO_Events_Enabled", function(_, enabled)
    self.enableEvents = enabled
    log("Event loop " .. (enabled and "enabled" or "disabled"))
  end)


	log("PlayerDetectorIO initialized successfully.")
end

--- Polls current online players and updates the state frame
function PlayerDetectorIO:updateOnlinePlayers()
	local usernames = self.peripheral.getOnlinePlayers()
	-- log("Polling online players: " .. table.concat(usernames, ", "))

	local updatedPlayers = {}

	for _, username in ipairs(usernames) do
		local data = self.peripheral.getPlayerPos(username)
		if data then
			updatedPlayers[username] = {
				name = username,
				health = data.health or 0,
				maxHealth = data.maxHealth or 20,
				x = data.x,
				y = data.y,
				z = data.z,
				dimension = data.dimension,
			}
		end
	end

	self.players = updatedPlayers
	self.stateFrame:setState("players", self.players)
end

--- Update function to poll and conditionally run event/zone systems
function PlayerDetectorIO:update()
	self:updateOnlinePlayers()

	if self.enableEvents then
    self:PlayerEventLoop()
	end

	if self.enableZones then
		self:_runZoneCheck()
	end
end

--- Renamed Event Loop
function PlayerDetectorIO:PlayerEventLoop()
	local event, a, b, c = os.pullEvent()

	if event == "playerClick" then
		log("Click: " .. a .. " on " .. b)
	-- self.stateFrame:setState("click_" .. a, os.clock())
	elseif event == "playerJoin" then
		log("Join: " .. a .. " in " .. b)

		self:_say("&a" .. a .. " &7joined the server")
	elseif event == "playerLeave" then
		log("Leave: " .. a .. " from " .. b)

		self:_say("&c" .. a .. " &7left the server")
	elseif event == "playerChangedDimension" then
		log("DimChange: " .. a .. " from " .. b .. " to " .. c)

		self:_say("&d" .. a .. " &7changed dimension")
	end
end

function PlayerDetectorIO:_runZoneCheck()
	local players = self.peripheral.getOnlinePlayers()
	local seenPlayers = {}

	local function isInZone(pos, zone)
		if pos = nil then return false
		if zone = nil then return false

		local x1, x2 = math.min(zone.min.x, zone.max.x), math.max(zone.min.x, zone.max.x)
		local z1, z2 = math.min(zone.min.z, zone.max.z), math.max(zone.min.z, zone.max.z)
		return pos.x >= x1 and pos.x <= x2 and pos.z >= z1 and pos.z <= z2
	end

	for _, player in ipairs(players) do
		seenPlayers[player] = true
		local pos = self.peripheral.getPlayerPos(player)

		for _, zone in ipairs(ZONES) do
			local inZone = isInZone(pos, zone)
			local key = player .. ":" .. zone.name

			if inZone and not self.playerActiveZones[key] then
				self.playerActiveZones[key] = true
        self:_zoneEnter(player, zone)

			elseif not inZone and self.playerActiveZones[key] then
				self.playerActiveZones[key] = false
			end
		end
	end

	for key in pairs(self.playerActiveZones) do
		local pname = key:match("^(.-):")
		if not seenPlayers[pname] then
			self.playerActiveZones[key] = nil
		end
	end
end

function PlayerDetectorIO:_say(message)
	if self.chatBox then
		self.chatBox.sendMessage(message, "Domn Paznic", "[]", "&6")
	end
end

function PlayerDetectorIO:_zoneEnter(player, zone)
	self:_say("&a" .. player .. " &7entered &b" .. zone.name)
end

function PlayerDetectorIO:enableEventLoop(flag)
	self.enableEvents = flag
end

function PlayerDetectorIO:enableZoneNotifier(flag)
	self.enableZones = flag
end

return PlayerDetectorIO
