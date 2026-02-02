-- Create Mod CC:Tweaked integration for Train Stations and Schedules.
-- Docs:
-- - Train Schedule: https://wiki.createmod.net/users/cc-tweaked-integration/train/train-schedule
-- - Train Station:  https://wiki.createmod.net/users/cc-tweaked-integration/train/train-station

local A = {}
local DEBUG_ADAPTER = true
local function dbg(...)
  if DEBUG_ADAPTER then print('[adapter]', ...) end
end

-- Discover all Create Train Stations and index by station name
local function findStationsByName()
  local types = { "train_station", "create_train_station", "create:train_station" }
  local map = {}
  -- FIXME later when ingame 
  -- for _, t in ipairs(types) do
  --   local list = {}
  --   if _G.peripheral and peripheral.find then list = { peripheral.find(t) } end
  --   for _, st in ipairs(list) do
  --     local ok, name = pcall(st.getStationName)
  --     if ok and name and name ~= "" then
  --       map[name] = st
  --     end
  --   end
  -- end
  return map
end

-- Build a Create schedule per required pattern:
--  throttle -> destination(+delay) repeated, and on the final yard destination add redstone link condition
-- entries: { { dest="Station", waitSeconds=5, throttle=80, yard=false }, ..., { dest=yardName, waitSeconds=20, throttle=80, yard=true } }
local function buildCreateSchedule(entries, title, concreteColor)
  local sched = { cyclic = true, entries = {}, title = title or "Trainyard" }
  local color = (concreteColor or "white"):lower()
  local concreteId = ("minecraft:%s_concrete"):format(color)

  for _, e in ipairs(entries) do
    dbg('entry', e.dest, 'wait', tostring(e.waitSeconds), 'thr', tostring(e.throttle), e.yard and '(yard)' or '')
    -- throttle BEFORE destination
    if e.throttle and e.throttle > 0 then
      table.insert(sched.entries, {
        instruction = { id = "create:throttle", data = { value = math.floor(e.throttle) } },
      })
    end

    local delayCond = { id = "create:delay", data = { value = math.floor(e.waitSeconds or 0), time_unit = 1 } }
    local condRow = nil
    if e.yard then
      -- Add redstone link with red conductor cap + slot-specific concrete color
      local linkCond = {
        id = "create:redstone_link",
        data = {
          frequency = {
            { count = 1, id = "railways:red_conductor_cap" },
            { count = 1, id = concreteId },
          },
          inverted = 0,
        },
      }
      dbg('yard conditions: delay', delayCond.data.value, 'link', linkCond.data.frequency[2].id)
      condRow = { delayCond, linkCond }
    else
      condRow = { delayCond }
    end

    table.insert(sched.entries, {
      instruction = { id = "create:destination", data = { text = e.dest } },
      conditions = { condRow },
    })
  end

  return sched
end

-- Apply schedule to the currently present train at the given yard station.
-- yardStation is the Create train-station peripheral for the yard slot.
function A.applyScheduleToStation(yardStation, schedule)
  if not yardStation then return false, "No station peripheral" end
  local name = 'unknown'
  local okN, n = pcall(yardStation.getStationName)
  if okN and n then name = n end
  dbg('applyScheduleToStation ->', name, 'entries', #schedule.entries, 'cyclic', tostring(schedule.cyclic))
  -- Station is the only place we can call setSchedule per docs (for present train)
  local ok, err = pcall(yardStation.setSchedule, schedule)
  if not ok then
    dbg('setSchedule failed:', tostring(err))
    return false, ("setSchedule failed: %s"):format(tostring(err))
  end
  dbg('setSchedule OK')
  return true
end

-- High-level entrypoint used by logic: build a schedule and apply to yard station
-- routeEntries: ordered list of destinations + waits; yardName appended by logic
function A.applySchedule(routeEntries, title, yardStation, concreteColor)
  dbg('applySchedule title', tostring(title), 'color', tostring(concreteColor), 'entries', #routeEntries)
  local sched = buildCreateSchedule(routeEntries, title, concreteColor)
  dbg('built schedule entries', #sched.entries)
  return A.applyScheduleToStation(yardStation, sched)
end

return A