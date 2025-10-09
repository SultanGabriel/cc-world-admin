local TrainSlot = require("views.TrainSlot")

local MainView = {}
MainView.__index = MainView

-- Layout variables for overall view
local VIEW = {
  headerHeight = 1,
}

function MainView.new(B, state)
  local self = setmetatable({}, MainView)
  self.B, self.state = B, state
  self.slots = {}

  local w, h = B:getSize()
  local C = _G.colors or require("colors")
  local header = B:addFrame({ x = 1, y = 1, width = w, height = VIEW.headerHeight, background = C.blue })
  header:addLabel({ x = 2, y = 1, text = "Trainyard", foreground = C.white })

  local body = B:addFrame({ x = 1, y = VIEW.headerHeight + 1, width = w, height = h - VIEW.headerHeight, background = C.black })
  self.body = body

  -- Always render 6 slots; TrainSlot handles enabled/disabled styling
  for i = 1, 6 do
    self.slots[i] = TrainSlot.new(body, i, state)
  end

  return self
end

function MainView:update()
  for _, comp in pairs(self.slots) do
    comp:update()
  end
end

return MainView