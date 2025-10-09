-- Basalt + CC:Tweaked + Create integration (yard-only stations)
-- - SLOTS simplified (routeId, link_color is also the bundled redstone color)
-- - ROUTES map routeId -> list of Create Station names in the world
-- - Only 6 yard stations are wrapped; presence via station:isTrainPresent()

local DEF_WAIT = 60
local config = {
        MONITOR_MAIN = 'monitor_28', -- e.g. "monitor_21" or nil to auto-pick first
        REDSTONE_SIDE = 'top', -- the bundled side wired to 6 colors
        TICK_INTERVAL = 0.25,

        DEV = { enabled = false, force_present_slots = {} },

        DEFAULT_LOOPS = 4,
        DEFAULT_YARD_WAIT = 20,

        -- 6 yard lines; unset -> enabled=false
        SLOTS = {
                [1] = {
                        enabled = true,
                        name = 'Trainyard #1',
                        type = 'pax',
                        link_color = 'red',
                        station_peripheral = 'Create_Station_1',
                        train_id = 'The Snail Express',
                        routeId = 'Inner',
                        default_speed = 0.9,
                        loops_before_yard = 4,
                        yard_wait = 20,
                },
                [2] = {
                        enabled = true,
                        name = 'Trainyard #2',
                        type = 'pax',
                        link_color = 'green',
                        station_peripheral = 'Create_Station_2',
                        train_id = 'train_B',
                        routeId = 'Inner',
                        default_speed = 0.9,
                        loops_before_yard = 4,
                        yard_wait = 20,
                },
                [3] = { enabled = false, name = 'Trainyard #3', station_peripheral = 'Create_Station_3' },
                [4] = { enabled = false, name = 'Trainyard #4', station_peripheral = 'Create_Station_4' },
                [5] = { enabled = false, name = 'Trainyard #5', station_peripheral = 'Create_Station_5' },
                [6] = { enabled = false, name = 'Trainyard #6', station_peripheral = 'Create_Station_6' },
        },

        -- Route id -> list of station legs with optional per-station wait (seconds)
        ROUTES = {
                -- Inner loop with swapped cardinal directions (N<->S, E<->W)
                -- Update these station names to your exact world names as needed.
                Inner = {
                        { name = 'Create/Power Temp (N)', wait = DEF_WAIT },
                        { name = 'Village Temp (E)',      wait = DEF_WAIT },
                        { name = 'Magic Temp (S)',        wait = DEF_WAIT },
                        { name = 'Baza (S)',              wait = DEF_WAIT },
                        { name = 'GT Temp (W)',           wait = DEF_WAIT },
                },
                Outer = {
                        { name = 'GT Temp (E)',           wait = DEF_WAIT },
                        { name = 'Magic Temp (N)',        wait = DEF_WAIT },
                        { name = 'Village Temp (W)',      wait = DEF_WAIT },
                        { name = 'Create/Power Temp (S)', wait = DEF_WAIT },
                },
        },
}

-- Derive RedstoneOutput mapping like the main project: logical keys -> bundled outputs
-- Keys match state names used by logic (stop_slot1..stop_slot6)
config.RedstoneOutput = {}
for i = 1, 6 do
        local slot = config.SLOTS[i]
        if slot and slot.link_color and colors and colors[slot.link_color] then
                local key = ("stop_slot%d"):format(i)
                config.RedstoneOutput[key] = {
                        side = config.REDSTONE_SIDE,
                        mode = 'output',
                        bundled = colors[slot.link_color],
                }
        end
end

return config