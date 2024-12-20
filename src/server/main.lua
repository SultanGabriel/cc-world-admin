package.path = package.path .. ";../common/utils/?.lua"
package.path = package.path .. ";../../libs/basalt/Basalt/init.lua"

local config = require("config")
local ServerMethods = require("controllers.ServerMethods")

local App = require("ui/app")
local Basalt = require("basalt")


-- Main function to start the server
local function main()
    -- Initialize the server ID
    local serverId = os.getComputerID()

    -- Initialize ServerMethods
    local server = ServerMethods.new(serverId)

    -- Set up Basalt UI using App
    local app = App.new()
    local uiFrame = app:getFrame()

    -- Initialize the server logic
    parallel.waitForAny(
        function()
            server:initialize()
        end,
        function()
            Basalt.autoUpdate()
        end
    )
end

-- Run the main function
main()