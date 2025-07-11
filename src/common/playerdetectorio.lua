-- lib/PlayerDetectorIO.lua

--- A wrapper around the playerDetector peripheral using state and event binding

local PlayerDetectorIO = {}
PlayerDetectorIO.__index = PlayerDetectorIO

DEBUG_LOGS = true
local function log(msg)
  if DEBUG_LOGS then print("[PlayerDetectorIO] " .. msg) end
end

--- Create a new instance of the player detector controller
-- @param peripheralSide string or peripheral (e.g., "playerDetector_1" or peripheral.wrap(...))
-- @param stateFrame basalt frame to store player state
function PlayerDetectorIO.new(peripheralSide, stateFrame)
  local self = setmetatable({}, PlayerDetectorIO)

  self.peripheral = type(peripheralSide) == "string" and peripheral.wrap(peripheralSide) or peripheralSide
  assert(self.peripheral and self.peripheral.getOnlinePlayers, "Invalid or missing playerDetector peripheral")

  self.stateFrame = stateFrame
  self.players = {}

  return self
end

--- Polls current online players and updates the state frame
function PlayerDetectorIO:updateOnlinePlayers()
  local usernames = self.peripheral.getOnlinePlayers()
  log("Polling online players: " .. table.concat(usernames, ", "))

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
        dimension = data.dimension
      }
    end
  end

  self.players = updatedPlayers
  self.stateFrame:setState("players", self.players)
end

--- Starts listening to player events (to be run in a separate thread or with schedule)
function PlayerDetectorIO:startEventLoop()
  while true do
    local event, a, b, c = os.pullEvent()

    if event == "playerClick" then
      log("Click: " .. a .. " on " .. b)
      self.stateFrame:setState("click_" .. a, os.clock())
    elseif event == "playerJoin" then
      log("Join: " .. a .. " in " .. b)
      self:updateOnlinePlayers()
    elseif event == "playerLeave" then
      log("Leave: " .. a .. " from " .. b)
      self:updateOnlinePlayers()
    elseif event == "playerChangedDimension" then
      log("DimChange: " .. a .. " from " .. b .. " to " .. c)
      self:updateOnlinePlayers()
    end
  end
end

return PlayerDetectorIO
