local adapter = require("adapter")
local RedIO = require("redio")

local M = { conf = nil, B = nil, redio = nil }

-- Internal cache: map slot index -> yard station peripheral
local stationBySlot = {}   -- [i] = peripheral
-- Discovery deprecated: we bind directly from config (slot.station_peripheral)

local function round(x) return math.floor(x + 0.5) end
local function clamp(x, a, b) return math.max(a, math.min(b, x)) end

-- Helpers for object-based slot state
local function slotKey(i) return ("SLOT_%d"):format(i) end
local function getSlot(B, i)
  return B:getState(slotKey(i)) or {}
end
local function setSlot(B, i, obj)
  B:setState(slotKey(i), obj)
end
local function patchSlot(B, i, patch)
  local obj = getSlot(B, i)
  for k, v in pairs(patch) do obj[k] = v end
  setSlot(B, i, obj)
end

-- NOTE: discoverStations deprecated; stations are provided via config only

local function bindSlotsToStations(B)
  -- Bind directly from config: slot.station_peripheral (explicit)
  local SLOTS = B:getState("slots") or {}
  for i = 1, 6 do
    local slot = SLOTS[i]
    if slot and slot.enabled then
      if slot.station_peripheral and _G.peripheral and peripheral.wrap then
        local ok, per = pcall(peripheral.wrap, slot.station_peripheral)
        stationBySlot[i] = ok and per or nil
      else
        stationBySlot[i] = nil
      end
    else
      stationBySlot[i] = nil
    end
  end
end

local function initStates(conf, B)
  for i = 1, 6 do
    local slot = conf.SLOTS[i] or {}
    local enabled = slot.enabled == true
    local initial = {
      enabled = enabled,
      name = slot.name or ("Slot " .. i),
      type = slot.type,
      routeId = slot.routeId,
      status = enabled and "idle" or "inactive",
      awaiting = false,
      present = false,
      mismatch = false,
      trainName = nil,
      pushed = false,
      sched = {
        speed = slot.default_speed or 1.0,
        loops_before_yard = slot.loops_before_yard or conf.DEFAULT_LOOPS,
        yard_wait = slot.yard_wait or conf.DEFAULT_YARD_WAIT,
      },
    }
    B:initializeState(slotKey(i), initial)
    -- keep RedIO compatibility; initialize stop bit even for disabled to avoid missing state
    B:initializeState(("stop_slot%d"):format(i), false)
  end
end

local function initRedIO(conf, B)
  local outputs = {}
  for i = 1, 6 do
    local slot = conf.SLOTS[i]
    if slot and slot.enabled and slot.link_color and colors[slot.link_color] then
      outputs[("stop_slot%d"):format(i)] = { side = conf.REDSTONE_SIDE, mode = "output", bundled = colors[slot.link_color] }
    end
  end
  if type(_G.redstone) ~= "table" then
    -- Sandbox: no redstone peripheral available -- fixme this works in sandbox
    return { dummy = true }
  end
  return RedIO.new(conf.REDSTONE_SIDE, B, outputs)
end

function M.init(conf, B)
  M.conf, M.B = conf, B
  initStates(conf, B)
  M.redio = initRedIO(conf, B)
  bindSlotsToStations(B)
end

local function buildRouteEntries(B, slotIdx, yardName)
  local conf = M.conf
  local slot = conf.SLOTS[slotIdx]
  local slotObj = getSlot(B, slotIdx)
  local sc = slotObj.sched or {}
  local routeId = slotObj.routeId or slot.routeId
  local route = conf.ROUTES[routeId]
  assert(route and #route > 0, "Unknown or empty routeId: " .. tostring(routeId))

  local loops = math.max(1, tonumber(sc.loops_before_yard or conf.DEFAULT_LOOPS))
  local speed = clamp(tonumber(sc.speed or slot.default_speed or 1.0), 0.1, 1.0)
  local throttle = clamp(round(speed * 100), 5, 100)

  local entries = {}
  table.insert(entries, { dest = yardName, waitSeconds = math.max(0, tonumber(sc.yard_wait or 0)), throttle = throttle, yard = true })
  for _ = 1, loops do
    for _, leg in ipairs(route) do
      local wait = tonumber(leg.wait or 1)
      table.insert(entries, { dest = leg.name, waitSeconds = wait, throttle = throttle, yard = false })
    end
  end
  return entries
end

-- UI interaction: Save schedule and assert STOP via state (RedIO binding handles hardware)
function M.updateSlotConfig(idx, newCfg)
  local B, conf = M.B, M.conf
  local obj = getSlot(B, idx)
  local old = obj.sched or {}
  obj.sched = {
    speed = clamp(tonumber(newCfg.speed) or old.speed or 1.0, 0.1, 1.0),
    loops_before_yard = math.max(1, math.floor(tonumber(newCfg.loops_before_yard) or old.loops_before_yard or conf.DEFAULT_LOOPS)),
    yard_wait = math.max(0, math.floor(tonumber(newCfg.yard_wait) or old.yard_wait or conf.DEFAULT_YARD_WAIT)),
  }
  if newCfg.routeId then obj.routeId = newCfg.routeId end
  obj.awaiting = true
  obj.status = "awaiting update"
  setSlot(B, idx, obj)
  B:setState(("stop_slot%d"):format(idx), true) -- assert STOP
end

function M.releaseTrain(idx)
  local B = M.B
  local obj = getSlot(B, idx)
  B:setState(("stop_slot%d"):format(idx), false)
  if obj.pushed then
    obj.awaiting = false
    obj.status = "running"
    obj.pushed = false
  else
    obj.status = "released (no update)"
  end
  setSlot(B, idx, obj)
end

function M.holdTrain(idx)
  local B = M.B
  local obj = getSlot(B, idx)
  B:setState(("stop_slot%d"):format(idx), true)
  obj.status = "held"
  setSlot(B, idx, obj)
end

-- Called every tick: detect presence/mismatch; when awaiting+present apply schedule
function M.tick()
  local B = M.B
  for i = 1, 6 do
    local slotConf = M.conf.SLOTS[i] or {}
    local obj = getSlot(B, i)
    if obj.enabled then
      local st = stationBySlot[i]
      if not st then
        bindSlotsToStations(B)
        st = stationBySlot[i]
      end

      local present, trainName = false, nil
      if st then
        local okP, resP = pcall(st.isTrainPresent)
        if okP then present = resP == true end
        if present then
          local okN, resN = pcall(st.getTrainName)
          if okN then trainName = resN end
        end
      end

      -- DEV sandbox: force presence for slots
      if M.conf.DEV and M.conf.DEV.enabled then
        local forced = M.conf.DEV.force_present_slots and M.conf.DEV.force_present_slots[i]
        if forced then present = true; trainName = trainName or (slotConf.train_id or ("DEV_TRAIN_" .. i)) end
      end

      obj.present = present
      obj.trainName = trainName
      obj.mismatch = present and slotConf.train_id ~= nil and trainName ~= slotConf.train_id or false

      if present and obj.awaiting then
        if obj.mismatch then
          obj.status = "awaiting update (mismatch)"
        else
          local yardName = st and st.getStationName and st.getStationName() or (slotConf.name or ("Trainyard #" .. i))
          local entries = buildRouteEntries(B, i, yardName)
          local okPush, err
          if st then
            local concreteColor = slotConf.link_color or "red" -- default safety
            okPush, err = adapter.applySchedule(entries, (slotConf.name or ("Trainyard #" .. i)), st, concreteColor)
          else
            -- DEV: pretend schedule was applied successfully
            okPush, err = true, nil
          end
          if okPush then
            obj.status = "awaiting release"
            obj.pushed = true
          else
            B:setState("last_error", tostring(err))
            obj.status = "push failed"
          end
        end
      end

      setSlot(B, i, obj)
    else
      -- keep inactive state stable
      obj.status = "inactive"
      obj.present = false
      obj.mismatch = false
      setSlot(B, i, obj)
    end
  end
end

return M
