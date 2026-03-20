local config = {
    MONITOR_MAIN = nil,
    REDSTONE_SIDE = 'bottom',
    TICK_INTERVAL = 0.25,

    RedstoneInput = {
        CVD_IN = {
            side = 'bottom',
            mode = 'input',
            bundled = colors.blue,
        },
    },

    RedstoneOutput = {
        CVD_OUT = {
            side = 'bottom',
            mode = 'output',
            bundled = colors.red,
        },
    },
}

return config
