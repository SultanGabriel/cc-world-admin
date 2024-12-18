-- NetworkManager.lua
local NetworkManager = {}
NetworkManager.__index = NetworkManager

-- Constructor
function NetworkManager.new(id)
    local self = setmetatable({}, NetworkManager)
    self.id = id -- Unique identifier for the server or node
    self.callbacks = {} -- Table to store method callbacks
    self.pendingResponses = {} -- Table to store pending responses for nodes
    self.isServer = false -- Flag to distinguish between server and nodes
    return self
end

-- Initialize as a server
function NetworkManager:initializeServer()
    self.isServer = true
    local modem = self:getModem() -- Automatically detect the modem
    if modem then
        rednet.open(modem)
        print("Server initialized with ID: " .. self.id)
    else
        error("No modem found. Please attach a modem to use the NetworkManager.")
    end
end

-- Initialize as a node
function NetworkManager:initializeNode()
    self.isServer = false
    local modem = self:getModem() -- Automatically detect the modem
    if modem then
        rednet.open(modem)
        print("Node initialized with ID: " .. self.id)
    else
        error("No modem found. Please attach a modem to use the NetworkManager.")
    end
end

-- Find modem
function NetworkManager:getModem()
    for _, side in ipairs({"top", "bottom", "left", "right", "front", "back"}) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
            return side
        end
    end
    return nil
end

-- Define a method
function NetworkManager:defineMethod(name, callback)
    self.callbacks[name] = callback
    print("Method registered: " .. name)
end

-- Send a request
function NetworkManager:sendRequest(targetId, method, data, responseCallback)
    local packet = {
        sender = self.id,
        method = method,
        data = data,
    }
    if responseCallback then
        self.pendingResponses[method] = responseCallback
    end
    rednet.send(targetId, packet)
end

-- Handle incoming messages
function NetworkManager:handleMessages()
    while true do
        local senderId, message = rednet.receive()
        if type(message) == "table" then
            if message.method and self.callbacks[message.method] then
                local callback = self.callbacks[message.method]
                local response = callback(senderId, message.data)
                if response then
                    rednet.send(senderId, response)
                end
            elseif self.pendingResponses[message.method] then
                local responseCallback = self.pendingResponses[message.method]
                responseCallback(senderId, message.data)
                self.pendingResponses[message.method] = nil
            else
                print("Unhandled message: ", message.method or "unknown")
            end
        else
            print("Invalid message received")
        end
    end
end

-- Utility to send a response
function NetworkManager:sendResponse(targetId, method, data)
    local packet = {
        sender = self.id,
        method = method,
        data = data,
    }
    rednet.send(targetId, packet)
end

return NetworkManager
