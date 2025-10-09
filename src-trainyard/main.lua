package.path = package.path .. ";../lib/Basalt/release/?.lua"
package.path = package.path .. ";../src-common/?.lua"
package.path = package.path .. ";../src-trainyard/?.lua"

local basalt = require("basalt")
local CONF = require("config")
local logic = require("logic")
local MainView = require("views.MainView")

local function initState(B)
		--state:initializeState(key, false, false)
  --B:setState("slots", CONF.SLOTS)
  B:initializeState("slots", CONF.SLOTS)
  --B:setState("last_error", nil)
  B:initializeState("last_error", nil)
end

local function pickMonitor()
  if CONF.MONITOR_MAIN ~= nil and _G.peripheral then
    local ok, mon = pcall(peripheral.wrap, CONF.MONITOR_MAIN)
    if ok and mon then return mon end
  end
  if _G.peripheral and peripheral.find then
    local ok, mon = pcall(peripheral.find, "monitor")
    if ok and mon then return mon end
  end
  -- Sandbox: render to current terminal
  return term.current()
end

local function init()
  local mon = pickMonitor()
  assert(mon, "No monitor found. Set MONITOR_MAIN in config.lua or attach a monitor.")
  local B = basalt.createFrame():setTerm(mon)

  initState(B)
  logic.init(CONF, B)

  local view = MainView.new(B, B)

  basalt.schedule(function()
    local POLL = CONF.TICK_INTERVAL or 0.25
    while true do
      logic.tick()
      view:update()
      if _G.os and os.sleep then os.sleep(POLL) else sleep(POLL) end
    end
  end)

  basalt.run()
end

local ok, err = pcall(init)
if not ok then print("[trainyard] fatal: " .. tostring(err)) end