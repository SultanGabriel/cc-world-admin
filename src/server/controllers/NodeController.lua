-- This file defines the logic for managing nodes on the server.

local NodeController = {}
NodeController.__index = NodeController

-- Constructor for NodeController
function NodeController.new()
    local self = setmetatable({}, NodeController)

    -- Table to store registered nodes
    self.registeredNodes = {}

    return self
end

-- Initialize the NodeController
function NodeController:initialize(networkManager)
    -- Define NodeController-specific methods
    networkManager:defineMethod("registerNode", function(senderId, data)
        local nodeId = data.nodeId
        local nodeInfo = data.info

        self.registeredNodes[nodeId] = {
            id = nodeId,
            info = nodeInfo,
            lastSeen = os.time(),
        }

        print("Node registered: " .. nodeId)
        return {status = "success", message = "Node registered successfully"}
    end)

    networkManager:defineMethod("ping", function(senderId, data)
        if self.registeredNodes[senderId] then
            self.registeredNodes[senderId].lastSeen = os.time()
            print("Ping received from node: " .. senderId)
            return {status = "success", message = "Ping acknowledged"}
        else
            print("Ping received from unregistered node: " .. senderId)
            return {status = "error", message = "Node not registered"}
        end
    end)

    networkManager:defineMethod("getNodeInfo", function(senderId, data)
        local nodeId = data.nodeId
        if self.registeredNodes[nodeId] then
            return {status = "success", info = self.registeredNodes[nodeId]}
        else
            return {status = "error", message = "Node not found"}
        end
    end)
end

return NodeController
