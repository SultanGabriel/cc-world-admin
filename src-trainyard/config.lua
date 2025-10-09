-- Basalt + CC:Tweaked + Create integration (yard-only stations)
-- - SLOTS simplified (routeId, link_color is also the bundled redstone color)
-- - ROUTES map routeId -> list of Create Station names in the world
-- - Only 6 yard stations are wrapped; presence via station:isTrainPresent()

local config = {
  MONITOR_MAIN = "monitor_28",         -- e.g. "monitor_21" or nil to auto-pick first
  REDSTONE_SIDE = "back",     -- the bundled side wired to 6 colors
  TICK_INTERVAL = 0.25,

        DEV = { enabled = false, force_present_slots = {} },

        DEFAULT_LOOPS = 4,
        DEFAULT_YARD_WAIT = 20,

        -- 6 yard lines; unset -> enabled=false
        SLOTS = {
                [1] = { enabled = true,  name = "Yard A", type = "pax",   link_color = "blue",
                        station_peripheral = "create_train_station_0",
                        train_id = "train_A", routeId = "InnerLoop",
                        default_speed = 0.9, loops_before_yard = 4, yard_wait = 20 },
                [2] = { enabled = true,
                        name = "Yard B", type = "pax", link_color = "green",
                        station_peripheral = "create_train_station_1",
                        train_id = "train_B", routeId = "InnerLoop",
                        default_speed = 0.9, loops_before_yard = 4, yard_wait = 20 },
                [3] = { enabled = false, name="Yard C" },
                [4] = { enabled = false, name="Yard D" },
                [5] = { enabled = false, name="Yard E" },
                [6] = { enabled = false, name="Yard F" },
        },

        -- Route id -> list of station legs with optional per-station wait (seconds)
        ROUTES = {
                Inner= {
                        { name = "A1", wait = 5 },
                        { name = "A2", wait = 5 },
                        { name = "A3", wait = 5 },
                        { name = "A4", wait = 5 },
                },
                Outer= {
                        { name = "B1", wait = 10 }, { name = "B2", wait = 10 }, { name = "B3", wait = 10 },
                },
        },
}

return config