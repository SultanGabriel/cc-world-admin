package.path = package.path .. ";../common/utils/?.lua"

local basalt = require("basalt")
local Configurator = require("Configurator")

-- Define pages for the configuration
local pages = {
    {
        name = "Bundled Redstone",
        fields = {
            { key = "redstone_channels", label = "Configure Bundled Redstone Channels:", type = "bundledRedstone" },
        },
    },
    {
        name = "Peripherals Setup",
        fields = {
            { key = "peripheral1", nameKey = "peripheral1_name", label = "Peripheral 1:", type = "peripherals" },
            { key = "peripheral2", nameKey = "peripheral2_name", label = "Peripheral 2:", type = "peripherals" },
        },
    },
    {
        name = "Summary",
        fields = {
            { key = "summary", label = "Configuration Complete! Review settings before saving.", type = "text" },
        },
    },
}

-- Create the configurator
local config = Configurator.new("Enhanced Configurator", pages, "config.txt")

-- Show the configurator UI
config:show()

-- After saving, access the configuration data
print("Configuration Saved:")
print(textutils.serialize(config.data))
