local RedIO = require('redio')

local M = {
    conf = nil,
    state = nil,
    redIn = nil,
    redOut = nil,
}

local function hasRedstone()
    return type(rawget(_G, 'redstone')) == 'table'
end

function M.init(conf, state)
    M.conf = conf
    M.state = state

    if not hasRedstone() then
        return
    end

    M.redIn = RedIO.new(conf.REDSTONE_SIDE, state, conf.RedstoneInput or {})
    M.redOut = RedIO.new(conf.REDSTONE_SIDE, state, conf.RedstoneOutput or {})
end

function M.handleRightClick()
    local count = M.state:getState('cvd_right_clicks') or 0
    local current = M.state:getState('CVD_OUT') == true
    local nextValue = not current

    M.state:setState('cvd_right_clicks', count + 1)
    M.state:setState('cvd_last_action', 'Right click #' .. tostring(count + 1))
    M.state:setState('CVD_OUT', nextValue)
end

function M.tick()
    if M.redIn ~= nil then
        M.redIn:pollInputs()
    end
end

return M
