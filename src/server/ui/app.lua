-- /src/server/ui/app.lua
-- Main UI logic for the server application

-- Import Basalt
local Basalt = require("basalt")

-- Import screens
local GeneralScreen = require("ui/screens/general")
local EnergyScreen = require("ui/screens/energy")
local UnitsScreen = require("ui/screens/units")

-- Main application UI module
local App = {}

function App.new()
    local self = {}

    local mainFrame = Basalt.addMonitor()
    local monitor = peripheral.find("monitor")
    mainFrame:setMonitor(monitor)
        :setTheme({FrameBG = colors.black, FrameFG = colors.white})

    -- Create the main application frame
    -- local mainFrame = Basalt.createFrame()

    -- Create a table for screens
    local screens = {
        General = GeneralScreen.new(mainFrame),
        Energy = EnergyScreen.new(mainFrame),
        Units = UnitsScreen.new(mainFrame),
    }

    -- Hide all screens initially except General
    for name, screen in pairs(screens) do
        if name == "General" then
            screen:setVisible(true)
        else
            screen:setVisible(false)
        end
    end

    -- Function to switch screens
    local function openScreen(name)
        for screenName, screen in pairs(screens) do
            screen:setVisible(screenName == name)
        end
    end

    -- Create the tab bar
    local tabBar = mainFrame:addMenubar()
        :setPosition(1, 1)
        :setSize("parent.w")
        :addItem("General")
        :addItem("Energy")
        :addItem("Units")
        :onChange(function(self)
            local selectedTab = self:getItemIndex()
            if selectedTab == 1 then
                openScreen("General")
            elseif selectedTab == 2 then
                openScreen("Energy")
            elseif selectedTab == 3 then
                openScreen("Units")
            end
        end)

    -- Return the app interface
    function self:getFrame()
        return mainFrame
    end

    return self
end

return App