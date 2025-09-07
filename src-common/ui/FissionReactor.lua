local Component = require('ui.component')
local ExperimentalFrame = require('ui.ExperimentalFrame')

local FissionReactor = {}
FissionReactor.__index = FissionReactor
setmetatable(FissionReactor, { __index = Component })

REACT_W = 12
REACT_H = 8
SYMBOLS = {
    '\149', -- |
    '\159', -- -
    '\167', -- _
    '\155', -- +
    '\139', -- /
    '\141', -- \
    '\151', -- ^
    '\148', -- v
    '\142', -- <
    '\127', -- >
    '\134', -- *
    '\135', -- x
    '\171', -- o
}

function FissionReactor.new(B, state, x, y, reactorId)
    local self = setmetatable(Component.new(), FissionReactor)

    assert(B, 'Basalt frame cannot be nil')
    assert(state, 'State object cannot be nil')
    assert(reactorId, 'Reactor ID cannot be nil')

    self.ANIMATE = true
    self.FMM_STATE = {
        ACTIVE = true,
        CTRL_MODE = 'SCRAM', -- 'AUTO', 'MANUAL', 'SCRAM'
    }

    self.state = state
    self.B = B
    self.reactorId = reactorId

    self.width = 34
    self.height = 26
    -- fixme remove later 
    self.state:initializeState(self.reactorId .. '_ACTIVE', false)
    self.state:initializeState(self.reactorId .. '_CTRL_MODE', 'SCRAM')

    if (reactorId == "R01") then
        self.FMM_STATE.ACTIVE = true
        self.state:setState(self.reactorId .. '_ACTIVE', true)
        self.FMM_STATE.CTRL_MODE = 'AUTO'
        self.state:setState(self.reactorId .. '_CTRL_MODE', 'AUTO')
        self.ANIMATE = true
    else
        -- self.FMM_STATE.ACTIVE = false
        -- self.state:setState(self.reactorId .. '_ACTIVE', false)
        -- self.FMM_STATE.CTRL_MODE = 'SCRAM'
        -- self.state:setState(self.reactorId .. '_CTRL_MODE', 'SCRAM')
        -- self.ANIMATE = false
    end

    -- ======================
    self.FMain = ExperimentalFrame.new(B, x, y, self.width, self.height, nil,
                                       colors.red)
    -- self.FMain:setBackground(colors.gray)
    self.container = self.FMain:getContainer()
    -- self.container = app:addFrame({
    --     x = x,
    --     y = y,
    --     width = self.width,
    --     height = self.height,
    --     background = colors.yellow,
    -- })

    -- Draw reactor:
    -- self.reactorBoxVertical = self.container:addFrame({
    --     x = 4,
    --     y = 1,
    --     width = 10,
    --     height = 10,
    --     background = colors.brown,
    -- })
    -- self.reactorBoxHorizontal = self.container:addFrame({
    --     x = 1,
    --     y = 3,
    --     width = 16,
    --     height = 6,
    --     background = colors.brown,
    -- })

    self.titleLabel = self.container:addLabel({
        x = self.width / 2 - 4,
        y = 2,
        text = 'Unit ' .. self.reactorId,
        foreground = colors.white,
        background = colors.red,
    })

    -- local grafik = {
    --     -- '\127',
    --     '\127\127\127\127\156\140\140\140\140\140\140\148\127\127\127\127',
    --     '    \149      \149    ',
    --     '    \149      \149    ',
    --     '\156\140\140\140\133      \141\140\140\140\148',
    --     '\149              \149',
    --     -- '\149               \149',
    --     '\149              \149',
    --     '\149              \149',
    --     '\141\140\140\140\148      \156\140\140\156\133',
    --     '    \149      \149 \158  ',
    --     '    \149      \149\158   ',
    --     '    \141\140\140\140\140\140\140\133    ',
    -- }
    -- local grafik = {
    --     -- '\127',
    --     -- '\127\127\127\127\156\140\140\140\140\148\127\127\127\127',
    --     '\151\131\131\131\149',
    --     '\156\140\133   \141\140\148',
    --     '\156\140\133       \141\140\148',
    --     '\149           \149',
    --     '\149           \149',
    --     '\141\140\148       \156\140\133',
    --     '\141\140\148   \156\140\133',
    --     '\149   \149',
    --     '\127\127\127\127\131\131\131\131\129\127\127\127\127',
    --     -- '\127\127\127\127\141\140\140\140\140\133\127\127\127\127',
    -- }


    -- Core Graphic
    local grafik = {
        -- '\127',
        -- '\127\127\127\127\156\140\140\140\140\148\127\127\127\127',
        '\151\131\131\131\149',
        '\156\140\133   \141\140\148',
        '\156\140\133       \141\140\148',
        '\149           \149',
        '\149           \149',
        '\141\140\148       \156\140\133',
        '\141\140\148   \156\140\133',
        '\149   \149',
        '\131\131\131\131\129',
        -- '\127\127\127\127\141\140\140\140\140\133\127\127\127\127',
    }
    local grafik_offsets = {
        4, 2, 0, 0, 0, 0, 2, 4, 4

    }

    local y_offset = 5
    for i = 1, #grafik do
        self.container:addLabel({
            x = 1 + grafik_offsets[i],
            y = i + y_offset,
            text = grafik[i],
            foreground = colors.lightGray,
            background = colors.black,
        }):setBackgroundEnabled(true)
    end

    self.innerGrafik2 = {}
    self.innerGrafik_W = 7
    self.innerGrafik_H = 5

    for i = 1, self.innerGrafik_H do
        self.innerGrafik2[i] = ''
        for j = 1, self.innerGrafik_W do
            self.innerGrafik2[i] = self.innerGrafik2[i] ..
                SYMBOLS[math.random(1, #SYMBOLS)]

            if i == self.innerGrafik_H and j >= (self.innerGrafik_W -5) then
                print("MUIE")
                break
            end
        end
    end

    self.coreAnimLabels = {}

    for i = 1, #self.innerGrafik2 do
        local innerXOffset = 0
        if i == self.innerGrafik_H  then
            innerXOffset = 2
            -- print("R:", r, "i:", i, "j:", j)
        end
        self.coreAnimLabels[i] = self.container:addLabel({
            x = 4 + innerXOffset,
            y = i + 2 + y_offset,
            text = self.innerGrafik2[i],
            foreground = colors.red,
            background = colors.lightGray,
        })
    end


    -- ACTIVE / INACTIVE INDICATOR
    self.indicator = self.container:addButton({
        x = self.width - 10,
        y = 6,
        width = 8,
        height = 3,
        text = 'ACTIVE',
        foreground = colors.black,
        background = colors.green,
    }):setBackgroundEnabled(true)

    self.state:onStateChange(self.reactorId .. '_ACTIVE', function(_, newState)
        self.FMM_STATE.ACTIVE = newState
        if newState then
            self.indicator:setText('ACTIVE')
            self.indicator:setBackground(colors.green)
            self.ANIMATE = true
        else
            self.indicator:setText('INACTIVE')
            self.indicator:setBackground(colors.red)
            self.ANIMATE = false
            -- Clear core animation
            for i = 1, #self.coreAnimLabels do
                self.coreAnimLabels[i]:setText(string.rep(' ', self.innerGrafik_W))
            end
        end
    end)

    self.state:setState(self.reactorId .. '_ACTIVE', self.FMM_STATE.ACTIVE)


    -- CTRL BTNS

self.container:addLabel({
        x = 2,
        y = self.innerGrafik_H + 7 + y_offset,
        text = 'Control Mode:',
        foreground = colors.white,
    })

    self.ctrlBtns = {}
    local ctrlBtnsOffsetY = self.innerGrafik_H + 8 + y_offset
    local ctrlBtnWidth = 8
    local ctrlBtnHeight = 1

    local ctrlBtnDefaultColor = colors.gray

    self.ctrlBtns['CTRL_AUTO'] = self.container:addButton({
        x = 2,
        y = ctrlBtnsOffsetY,
        width = ctrlBtnWidth,
        height = ctrlBtnHeight,
        text = 'AUTO',
        foreground = colors.white,
        background = self.FMM_STATE.CTRL_MODE == 'AUTO' and colors.blue or
        ctrlBtnDefaultColor,
    })
    self.ctrlBtns['CTRL_AUTO']:onClick(function()
        -- Update button backgrounds based on current state
        print('AUTO BTN clicked')
        self.state:setState(self.reactorId .. '_CTRL_MODE', 'AUTO')
    end)

    self.ctrlBtns['CTRL_MANUAL'] = self.container:addButton({
        x = 12,
        y = ctrlBtnsOffsetY,
        width = ctrlBtnWidth,
        height = ctrlBtnHeight,
        text = 'MANUAL',
        foreground = colors.white,
        background = self.FMM_STATE.CTRL_MODE == 'MANUAL' and colors.yellow or
        ctrlBtnDefaultColor,
    })
    self.ctrlBtns['CTRL_MANUAL']:onClick(function()
        -- Update button backgrounds based on current state
        print('MANUAL BTN clicked')
        self.state:setState(self.reactorId .. '_CTRL_MODE', 'MANUAL')
    end)

    self.ctrlBtns['CTRL_SCRAM'] = self.container:addButton({
        x = 22,
        y = ctrlBtnsOffsetY,
        width = ctrlBtnWidth,
        height = ctrlBtnHeight,
        text = 'SCRAM',
        foreground = colors.white,
        background = self.FMM_STATE.CTRL_MODE == 'SCRAM' and colors.red or
        ctrlBtnDefaultColor,
    })
    self.ctrlBtns['CTRL_SCRAM']:onClick(function()
        -- Update button backgrounds based on current state
        print('SCRAM BTN clicked')
        self.state:setState(self.reactorId .. '_CTRL_MODE', 'SCRAM')
    end)

	state:onStateChange(self.reactorId .. '_CTRL_MODE', function(_, newState)
        self.FMM_STATE.CTRL_MODE = newState
        if newState == 'AUTO' then
            self.ctrlBtns['CTRL_AUTO']:setBackground(colors.blue)
            self.ctrlBtns['CTRL_MANUAL']:setBackground(ctrlBtnDefaultColor)
            self.ctrlBtns['CTRL_SCRAM']:setBackground(ctrlBtnDefaultColor)
        elseif newState == 'MANUAL' then
            self.ctrlBtns['CTRL_AUTO']:setBackground(ctrlBtnDefaultColor)
            self.ctrlBtns['CTRL_MANUAL']:setBackground(colors.yellow)
            self.ctrlBtns['CTRL_SCRAM']:setBackground(ctrlBtnDefaultColor)
        elseif newState == 'SCRAM' then
            self.ctrlBtns['CTRL_AUTO']:setBackground(ctrlBtnDefaultColor)
            self.ctrlBtns['CTRL_MANUAL']:setBackground(ctrlBtnDefaultColor)
            self.ctrlBtns['CTRL_SCRAM']:setBackground(colors.red)
        else
            print('Unknown CTRL_MODE state: ' .. tostring(newState))
        end

	end)

    -- BURN RATE

    self.burnRateLabel = self.container:addLabel({
        x = 2,
        y = self.innerGrafik_H + 10 + y_offset,
        text = 'Burn Rate: --- mb/t',
        foreground = colors.white,
    })

    return self
end

-- function Indicator:setState(state)
-- self.state = state
-- print("[Indicator] State changed to:", state, "for", self.key)
-- if state then
-- 	self.dot:setForeground(self.colorOn)
-- else
-- 	self.dot:setForeground(self.colorOff)
-- end
-- end

function FissionReactor:update()
    if self.ANIMATE then
        -- print("FissionReactor: update() - Animating core")

        local RND_1_PASS = 0.05
        local RND_2_PASS = 0.1

        for i = 1, self.innerGrafik_H do
            -- if math.random() < RND_1_PASS then
            --     os.sleep(0.1)

            -- end

            self.innerGrafik2[i] = ''
            for j = 1, self.innerGrafik_W do
                local r = math.ceil(math.sqrt((i - self.innerGrafik_H / 2) ^ 2 +
                    (j - self.innerGrafik_W / 2) ^ 2))


                -- if r > 2 and math.random() < RND_2_PASS then
                if r > 2.5 and math.random() > RND_2_PASS then
                    self.innerGrafik2[i] = self.innerGrafik2[i] .. ' '
                else
                    self.innerGrafik2[i] = self.innerGrafik2[i] ..
                        SYMBOLS[math.random(1, #SYMBOLS)]
                end

                if i == self.innerGrafik_H and j >= (self.innerGrafik_W -4) then
                    break
                    -- print("R:", r, "i:", i, "j:", j)
                end
                -- if math.random() < RND_2_PASS then
                --     break
                -- end
            end
        end

        for i = 1, #self.coreAnimLabels do
            self.coreAnimLabels[i]:setText(self.innerGrafik2[i])
        end
    end
end

return FissionReactor
