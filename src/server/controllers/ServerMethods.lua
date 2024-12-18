-- This file defines the methods and controllers for managing server logic.

-- Import the NetworkManager class
local NetworkManager = require("NetworkManager")
local NodeController = require("controllers.NodeController")
-- Future controllers can be imported here, e.g., EnergyController, UnitController

-- ServerMethods
local ServerMethods = {}
ServerMethods.__index = ServerMethods

-- Constructor for ServerMethods
function ServerMethods.new(serverId)
    local self = setmetatable({}, ServerMethods)

    -- Initialize the NetworkManager instance
    self.networkManager = NetworkManager.new(serverId)

    -- Attach controllers directly
    self.controllers = {
        nodeController = NodeController.new(),
        -- Attach other controllers here, e.g., energyController = EnergyController.new()
    }

    return self
end

-- Initialize the server
function ServerMethods:initialize()
    -- Initialize the NetworkManager as a server
    self.networkManager:initializeServer()

    -- Initialize all controllers
    for name, controller in pairs(self.controllers) do
        if controller.initialize then
            controller:initialize(self.networkManager)
            print("Controller initialized: " .. name)
        end
    end

    print("Server ready to handle communications and controllers.")

    -- Start handling messages
    self.networkManager:handleMessages()
end

return ServerMethods