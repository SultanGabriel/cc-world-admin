-- enhancedConfigLib.lua
local basalt = require("basalt")

local Configurator = {}

-- Helper to detect and list peripherals
local function getPeripherals()
    local peripherals = {}
    for _, side in ipairs(peripheral.getNames()) do
        table.insert(peripherals, side)
    end
    return peripherals
end

-- Create a new configurator instance
function Configurator.new(title, pages, saveFile)
    local self = {}
    self.title = title
    self.pages = pages
    self.saveFile = saveFile
    self.data = {}
    self.currentPage = 1

    -- Load configuration from file if it exists
    function self:load()
        if fs.exists(self.saveFile) then
            local file = fs.open(self.saveFile, "r")
            self.data = textutils.unserialize(file.readAll()) or {}
            file.close()
        end
    end

    -- Save configuration to file
    function self:save()
        local file = fs.open(self.saveFile, "w")
        file.write(textutils.serialize(self.data))
        file.close()
    end

    -- Render a specific page
    function self:renderPage(frame)
        frame:removeAll()
        local page = self.pages[self.currentPage]

        frame:addLabel()
            :setText(self.title)
            :setPosition("parent.w / 2  " .. self.title .. " / 2", 2)
            :setBackground(colors.gray)
            :setForeground(colors.white)

        local y = 4
        for i, field in ipairs(page.fields) do
            frame:addLabel()
                :setText(field.label)
                :setPosition(3, y)
                :setBackground(colors.gray)
                :setForeground(colors.white)

            if field.type == "bundledRedstone" then
                local redstoneFrame = frame:addFrame()
                    :setSize(30, 10)
                    :setPosition(15, y)
                    :setBackground(colors.black)
                for channel = 1, 16 do
                    local btn = redstoneFrame:addButton()
                        :setText("CH " .. channel)
                        :setSize(6, 1)
                        :setPosition(2, channel)
                        :setBackground(colors.gray)
                    if self.data[field.key] and self.data[field.key][channel] then
                        btn:setBackground(colors.green)
                    end
                    btn:onClick(function()
                        local state = not (self.data[field.key] and self.data[field.key][channel])
                        self.data[field.key] = self.data[field.key] or {}
                        self.data[field.key][channel] = state
                        btn:setBackground(state and colors.green or colors.gray)
                    end)
                end
            elseif field.type == "peripherals" then
                local peripherals = getPeripherals()
                local dropdown = frame:addDropdown()
                    :setSize(20, 1)
                    :setPosition(15, y)
                    :addItems(table.unpack(peripherals))
                dropdown:onSelect(function(value)
                    self.data[field.key] = value
                end)
                local input = frame:addInput()
                    :setSize(20, 1)
                    :setPosition(15, y + 2)
                    :setDefaultValue(self.data[field.nameKey] or "")
                input:onChange(function(value)
                    self.data[field.nameKey] = value
                end)
                frame:addLabel()
                    :setText("Name:")
                    :setPosition(3, y + 2)
                    :setBackground(colors.gray)
                    :setForeground(colors.white)
            end

            y = y + 4
        end

        -- Navigation Buttons
        if self.currentPage > 1 then
            frame:addButton()
                :setText("Previous")
                :setPosition(3, y + 2)
                :onClick(function()
                    self.currentPage = self.currentPage - 1
                    self:renderPage(frame)
                end)
        end

        if self.currentPage < #self.pages then
            frame:addButton()
                :setText("Next")
                :setPosition(15, y + 2)
                :onClick(function()
                    self.currentPage = self.currentPage + 1
                    self:renderPage(frame)
                end)
        else
            frame:addButton()
                :setText("Finish")
                :setPosition(15, y + 2)
                :onClick(function()
                    self:save()
                    basalt.stop()
                end)
        end
    end

    -- Show the configuration UI
    function self:show()
        local frame = basalt.createFrame()
        :setSize("parent.w", "parent.h")
        :setBackground(colors.gray)
        self:renderPage(frame)
        basalt.autoUpdate()
    end

    -- Initialize configuration by loading existing data
    self:load()

    return self
end

return Configurator
