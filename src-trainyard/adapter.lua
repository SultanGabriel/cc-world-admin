-- Create Mod CC:Tweaked integration for Train Stations and Schedules.
-- Docs:
-- - Train Schedule: https://wiki.createmod.net/users/cc-tweaked-integration/train/train-schedule
-- - Train Station:  https://wiki.createmod.net/users/cc-tweaked-integration/train/train-station

local A = {}

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

-- Build a Create schedule in the instruction/conditions format per requested spec
-- entries: { { dest="Station", waitSeconds=5, throttle=80 }, ... }
local function buildCreateSchedule(entries, title)
  local sched = { cyclic = true, entries = {}, title = title or "Trainyard" }
  for _, e in ipairs(entries) do
    table.insert(sched.entries, {
      instruction = { id = "create:destination", data = { text = e.dest } },
      conditions = {
        { { id = "create:delay", data = { value = math.floor((e.waitSeconds or 0)), time_unit = 1 } } },
      },
    })
    if e.throttle and e.throttle > 0 then
      table.insert(sched.entries, {
        instruction = { id = "create:throttle", data = { value = e.throttle } },
        conditions = { { { id = "create:delay", data = { value = 0, time_unit = 1 } } } },
      })
    end
  end
  return sched
end

-- Apply schedule to the currently present train at the given yard station.
-- yardStation is the Create train-station peripheral for the yard slot.
function A.applyScheduleToStation(yardStation, schedule)
  if not yardStation then return false, "No station peripheral" end
  -- Station is the only place we can call setSchedule per docs (for present train)
  local ok, err = pcall(yardStation.setSchedule, schedule)
  if not ok then
    return false, ("setSchedule failed: %s"):format(tostring(err))
  end
  return true
end

-- High-level entrypoint used by logic: build a schedule and apply to yard station
-- routeEntries: ordered list of destinations + waits; yardName appended by logic
function A.applySchedule(routeEntries, title, yardStation)
  local sched = buildCreateSchedule(routeEntries, title)
  return A.applyScheduleToStation(yardStation, sched)
end

return A