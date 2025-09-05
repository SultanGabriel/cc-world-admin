-- logger.lua
local Logger = {}
Logger.__index = Logger

-- ANSI color codes
local COLORS = {
    TRACE = '\27[36m', -- Cyan
    DEBUG = '\27[34m', -- Blue
    INFO  = '\27[32m', -- Green
    WARN  = '\27[33m', -- Yellow
    ERROR = '\27[31m', -- Red
    FATAL = '\27[35m', -- Magenta
    RESET = '\27[0m',
}

local LEVELS = {
    TRACE = 0,
    DEBUG = 1,
    INFO  = 2,
    WARN  = 3,
    ERROR = 4,
    FATAL = 5,
}

local DEFAULT_LEVEL = LEVELS.INFO

local instance = nil -- Singleton instance

function Logger.getInstance(tag, level, logFile)
    if not instance then
        instance = Logger.new(tag or 'App', level or 'INFO', logFile)
    end
    return instance
end

--- Create a new logger
-- @param tag string – optional tag prefix
-- @param level string – minimum log level (default: "INFO")
-- @param logFile string – optional file path to write logs to
function Logger.new(tag, level, logFile)
    local self = setmetatable({}, Logger)

    self.tag = tag or 'Log'
    self.levelThreshold = LEVELS[string.upper(level or 'INFO')] or DEFAULT_LEVEL
    self.logFile = logFile

    if logFile then
        local f = fs.open(logFile, 'a')
        if f then
            f.writeLine('=== Logger started @ ' .. os.date() .. ' ===')
            f.close()
        end
    end

    return self
end

function Logger:_write(level, message)
    if LEVELS[level] < self.levelThreshold then return end

    local time = os.date('%H:%M:%S')
    local label = string.format('[%s] [%s] [%s]', time, self.tag, level)
    local color = COLORS[level] or ''
    local reset = COLORS.RESET
    local formatted = string.format('%s%s %s%s', color, label, message, reset)

    print(formatted)

    if self.logFile then
        local f = fs.open(self.logFile, 'a')
        if f then
            f.writeLine(label .. ' ' .. message)
            f.close()
        end
    end
end

-- Define level methods
for name, _ in pairs(LEVELS) do
    Logger[string.lower(name)] = function(self, msg)
        self:_write(name, msg)
    end
end

return Logger

-- You can now use the same logger anywhere like this:
-- lua
-- local Logger = require("lib.logger")
-- local log = Logger.getInstance()
-- log:info("Hello from module A")
-- In another file:
-- lua
-- local Logger = require("lib.logger")
-- Logger.getInstance():debug("Something happened in module B")
-- ✅ Only the first call to getInstance() creates the logger. All other calls return the same instance.
-- If you want log() available globally without requiring in every file, you can add in your startup.lua or init.lua:
-- _G.LOG = require("lib.logger").getInstance("GlobalApp", "DEBUG", "app.log")
