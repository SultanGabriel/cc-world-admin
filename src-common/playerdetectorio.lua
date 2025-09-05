-- lib/PlayerDetectorIO.lua
package.path = package.path .. ";../src-common/?.lua"

--- A wrapper around the playerDetector peripheral using state and event binding

local ZONES = require("config").Zones
local FORMAT = require("format")
local INDICATORS = require("config").Indicators

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
	assert(
		self.peripheral and self.peripheral.getOnlinePlayers,
		"PlayerDetectorIO requires a valid playerDetector peripheral"
	)
	assert(self.chatBox and self.chatBox.sendMessage, "PlayerDetectorIO requires a valid chatBox peripheral")
	assert(self.stateFrame, "PlayerDetectorIO requires a valid stateFrame")

	log("Self-check passed: All required peripherals and state frame are valid.")
end

function PlayerDetectorIO:_init()
	log("Initializing PlayerDetectorIO...")

	-- Initial state setup
	-- self.stateFrame:initializeState("players", {})
	-- self.stateFrame:initializeState("PDIO_Zones_Enabled", self.enableZones)
	-- self.stateFrame:initializeState("PDIO_Events_Enabled", self.enableEvents)

	self.stateFrame:setState("players", self.players)
	self.stateFrame:setState("PDIO_Zones_Enabled", self.enableZones)
	self.stateFrame:setState("PDIO_Events_Enabled", self.enableEvents)

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
    self:_dimChange(a, c)

		-- self:_say("&d" .. a .. " &7changed dimension")

	end
end

function PlayerDetectorIO:_runZoneCheck()
	local players = self.peripheral.getOnlinePlayers()
	local seenPlayers = {}

	local function isInZone(pos, zone)
		if pos == nil then
			return false
		end
    if pos.x == nil then
      return false
    end
    if pos.y == nil then
        return false
    end

		if zone == nil then
			return false
		end

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
	-- self:_say("&a" .. player .. " &7entered &b" .. zone.name)
  local joke = ""
  if zone.joke ~= nil then
    joke = zone.joke
  end
  
	local message = {
		"",
		{
			text = "[Domn' Paznic]: ",
			bold = true,
			color = "dark_red",
			hoverEvent = {
				action = "show_text",
				contents = {
					"",
					{ text = "12345678912345678", obfuscated = true, color = "gold" },
					{ text = "\n        El e omu'      \n", color = "gold" },
					{ text = "12345678912345678", obfuscated = true, color = "gold" },
				},
			},
		},
		{
			text = player,
			color = "yellow",

			hoverEvent = {
				action = "show_entity",
				contents = {
					{ name = player }
				},
			},
		},
		{ text = " has entered " },
		{ text = zone.name, bold = true },
		{ text = "! " },
		{ text = joke },
	}

	local json = textutils.serialiseJSON(message)

	self.chatBox.sendFormattedMessage(json, "#")
end

function PlayerDetectorIO:_dimChange(player, dimension)
    -- Expecting `dimension` like "minecraft:overworld", "minecraft:the_nether", "minecraft:the_end"
    log("DimChange: " .. player .. " to " .. dimension)

    -- local scope everything
    local sp = FORMAT.split(dimension, ":")  -- must return array-like table
    -- local sp = {""}
    local rawDim = nil
    local dimName = "Pizdaa Masii... (This is an error message, if you see this, then I fucked up the code, or this shit is fucket.)"
    local action = " s-o dus in "

    -- pick the right token safely
    -- If split returns {"minecraft","the_nether"} we want index 2; otherwise fall back.
    if type(sp) == "table" then
        if #sp >= 2 and sp[2] ~= "" then
            rawDim = sp[2]
        elseif #sp >= 1 and sp[1] ~= "" then
            rawDim = sp[1]
        end
    end
    if not rawDim or rawDim == "" then
        rawDim = dimension or ""
    end

    -- Map canonical Minecraft IDs to display names/action
    -- Minecraft uses "overworld", "the_nether", "the_end"
    local pretty = {
        overworld   = "Lume",
        the_nether  = "Satana!",
        the_end     = "La Dragon!"
    }

    if rawDim == "the_nether" then
        action = " s-o dus la "
    end

    dimName = pretty[rawDim] or rawDim

    -- Build chat component (Advanced Peripherals Chat Box–style JSON)
    local message = {
        "",
        {
            text  = "[Domn' Paznic]: ",
            bold  = true,
            color = "dark_red",
            hoverEvent = {
                action   = "show_text",
                contents = {
                    "",
                    { text = "12345678912345678", obfuscated = true, color = "gold" },
                    { text = "\n        El e omu'      \n", color = "gold" },
                    { text = "12345678912345678", obfuscated = true, color = "gold" },
                },
            },
        },
        {
            text  = player,
            color = "yellow",
            hoverEvent = {
                action   = "show_entity",
                contents = {
                    -- For vanilla show_entity you usually want: {type="minecraft:player", id="<uuid>", name=player}
                    -- If you don’t have UUID, name-only may still render in some clients/mods.
                    { name = player }
                },
            },
        },
        { text = action },
        { text = dimName, bold = true },
        { text = "!" },
    }

    local json = textutils.serialiseJSON(message)
    self.chatBox.sendFormattedMessage(json, "#")
end

function PlayerDetectorIO:enableEventLoop(flag)
	self.enableEvents = flag
end

function PlayerDetectorIO:enableZoneNotifier(flag)
	self.enableZones = flag
end

return PlayerDetectorIO
