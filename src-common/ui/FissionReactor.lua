
local Component = require("ui.component")

local FissionReactor = {}
FissionReactor.__index = FissionReactor
setmetatable(FissionReactor, { __index = Component })

REACT_W = 12
REACT_H = 8
SYMBOLS = {
    "\149", -- |
    "\131", -- -
    "\140", -- _
    "\133", -- +
    "\139", -- /
    "\141", -- \
    "\151", -- ^
    "\148", -- v
    "\142", -- <
    "\143", -- >
    "\134", -- *
    "\135", -- x
    "\136", -- o
}

function FissionReactor.new(app, x, y, state)
	local self = setmetatable(Component.new(), FissionReactor)

    self.ANIMATE = true

    self.width = 46
    self.height = 24

    self.container = app:addFrame({
        x = x,
        y = y,
        width = self.width,
        height = self.height,
        background = colors.yellow,
    })

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


    local grafik = {
        "    \156\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\148   ",
        "    \149                \149   ",
        "    \149                \149   ",
        "\149                        \149",
        "\149                        \149",
        "\149                        \149",
        "\149                        \149",
        "\149                        \149",
        "    \149                \149",

        "    \149                \149   ",
        "    \149                \149   ",
        "    \156\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\148   ",
    }

    y_offset = 2
    for i = 1, #grafik do
        self.container:addLabel({
            x = 1,
            y = i + y_offset,
            text = grafik[i],
            foreground = colors.brown,
            background = colors.gray,
        })
    end

    self.innerGrafik2 = {}

    for i = 1, 4 do
        self.innerGrafik2[i] = ""
        for j = 1, 7 do
            self.innerGrafik2[i] = self.innerGrafik2[i] .. SYMBOLS[math.random(1, #SYMBOLS)]
        end
    end


    self.coreAnimLabels = {}

    for i = 1, #self.innerGrafik2 do
        self.coreAnimLabels[i] = self.container:addLabel({
            x = 11,
            y = i + 4,
            text = self.innerGrafik2[i],
            foreground = colors.red,
            background = colors.lightGray,
        })
    end

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
        print("FissionReactor: update() - Animating core")

        local RND_1_PASS = 0.3
        local RND_2_PASS = 0.1

        for i = 1, 4 do

            if math.random() < RND_1_PASS then
                
            end

            self.innerGrafik2[i] = ""
            for j = 1, 7 do
                -- if math.random() < RND_2_PASS then
                --     break
                -- end
                self.innerGrafik2[i] = self.innerGrafik2[i] .. SYMBOLS[math.random(1, #SYMBOLS)]
            end
        end
    
        for i = 1, #self.coreAnimLabels do
            self.coreAnimLabels[i]:setText(self.innerGrafik2[i])    
        end

        
    end

end

return FissionReactor
