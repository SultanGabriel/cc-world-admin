-- src/common/utils/config.lua
local config = {}

local configFileName = "config.json"

function config.load()
    if fs.exists(configFileName) then
        local file = fs.open(configFileName, "r")
        local content = file.readAll()
        file.close()
        return textutils.unserializeJSON(content)
    else
        return {}
    end
end

function config.save(configuration)
    local file = fs.open(configFileName, "w")
    file.write(textutils.serializeJSON(configuration))
    file.close()
end

function config.setDefault(defaultConfig)
    local currentConfig = config.load()
    for key, value in pairs(defaultConfig) do
        if currentConfig[key] == nil then
            currentConfig[key] = value
        end
    end
    config.save(currentConfig)
end

return config
