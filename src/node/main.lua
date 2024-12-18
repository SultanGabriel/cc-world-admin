local basalt = require("basalt")
local networking = require("common.utils.networking")
local config = require("common.utils.config")

-- Load configuration
local nodeConfig = config.load()
config.setDefault({
    serverId = nil,
    nodeId = os.getComputerID()
})

-- Node registration
function registerWithServer()
    if nodeConfig.serverId then
        networking.sendMessage(nodeConfig.serverId, "register", { nodeId = nodeConfig.nodeId })
    else
        print("Server ID not configured.")
    end
end

-- Main loop
rednet.open("back") -- Adjust based on modem placement
print("Node started")
registerWithServer()

while true do
    -- Simulated energy data
    local energyData = {
        stored = math.random(1000, 5000),
        capacity = 5000,
        input_rate = math.random(50, 150),
        output_rate = math.random(50, 150)
    }
    networking.sendMessage(nodeConfig.serverId, "energy_update", energyData)
    sleep(10) -- Send updates every 10 seconds
end
