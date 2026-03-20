package.path = package.path .. ';../lib/Basalt/release/?.lua'
package.path = package.path .. ';../src-common/?.lua'
package.path = package.path .. ';../src-cvd-worker/?.lua'

local basalt = require('basalt')
local CONF = require('config')
local logic = require('logic')
local MainView = require('views.MainView')

local function pickMonitor()
    if CONF.MONITOR_MAIN ~= nil and _G.peripheral then
        local ok, mon = pcall(peripheral.wrap, CONF.MONITOR_MAIN)
        if ok and mon then return mon end
    end

    if _G.peripheral and peripheral.find then
        local ok, mon = pcall(peripheral.find, 'monitor')
        if ok and mon then return mon end
    end

    return term.current()
end

local function initState(state)
    state:initializeState('cvd_last_action', 'Ready')
    state:initializeState('cvd_right_clicks', 0)

    state:initializeState('CVD_IN', false)
    state:initializeState('CVD_OUT', false)
end

local function init()
    local mon = pickMonitor()
    assert(mon, 'No monitor found. Set MONITOR_MAIN in config.lua or attach a monitor.')

    local B = basalt.createFrame():setTerm(mon)
    initState(B)

    logic.init(CONF, B)
    local view = MainView.new(B, B)

    basalt.schedule(function()
        while true do
            logic.tick()
            view:update()
            if _G.os and os.sleep then os.sleep(CONF.TICK_INTERVAL or 0.25) else sleep(CONF.TICK_INTERVAL or 0.25) end
        end
    end)

    basalt.run()
end

local ok, err = pcall(init)
if not ok then
    print('[cvd-worker] fatal: ' .. tostring(err))
end
