-- Basalt + CC:Tweaked + Create integration (yard-only stations)
-- - SLOTS simplified (routeId, link_color is also the bundled redstone color)
-- - ROUTES map routeId -> list of Create Station names in the world
-- - Only 6 yard stations are wrapped; presence via station:isTrainPresent()

local config = {
	MONITOR_MAIN = "monitor_28", -- e.g. "monitor_21" or nil to auto-pick first
	REDSTONE_SIDE = "back", -- the bundled side wired to 6 colors
	TICK_INTERVAL = 0.25,

	DEV = { enabled = false, force_present_slots = {} },

	DEFAULT_LOOPS = 4,
	DEFAULT_YARD_WAIT = 20,

	-- 6 yard lines; unset -> enabled=false
	SLOTS = {
		[1] = {
			enabled = true,
			name = "Trainyard #1",
			type = "pax",
			link_color = "blue",
			station_peripheral = "Create_Station_1",
			train_id = "The Snake Express",
			routeId = "Inner",
			default_speed = 0.9,
			loops_before_yard = 4,
			yard_wait = 20,
		},
		[2] = {
			enabled = true,
			name = "Trainyard #2",
			type = "pax",
			link_color = "green",
			station_peripheral = "Create_Station_2",
			train_id = "train_B",
			routeId = "Inner",
			default_speed = 0.9,
			loops_before_yard = 4,
			yard_wait = 20,
		},
		[3] = { enabled = false, name = "Trainyard #3", station_peripheral = "Create_Station_3" },
		[4] = { enabled = false, name = "Trainyard #4", station_peripheral = "Create_Station_4" },
		[5] = { enabled = false, name = "Trainyard #5", station_peripheral = "Create_Station_5" },
		[6] = { enabled = false, name = "Trainyard #6", station_peripheral = "Create_Station_6" },
	},

	-- Route id -> list of station legs with optional per-station wait (seconds)
	ROUTES = {
		-- Inner loop with swapped cardinal directions (N<->S, E<->W)
		-- Update these station names to your exact world names as needed.
		Inner = {
			{ name = "Create/Power Temp (S)", wait = 5 },
			{ name = "Village Temp (W)", wait = 5 },
			{ name = "Magic Temp (N)", wait = 5 },
			{ name = "GT Temp (E)", wait = 5 },
		},
		Outer = {
			{ name = "B1", wait = 10 },
			{ name = "B2", wait = 10 },
			{ name = "B3", wait = 10 },
		},
	},
}

return config

