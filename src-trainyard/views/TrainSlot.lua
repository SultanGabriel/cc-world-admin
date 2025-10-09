local logic = require("logic")
local C = _G.colors

local ExperimentalFrame = require("ui.ExperimentalFrame")

local TrainSlot = {}
TrainSlot.__index = TrainSlot

-- Theme/colors
local theme = {
  text = C.white,
  dim = C.lightGray,
  ok = C.lime,
  warn = C.orange,
  err = C.red,
  border = C.gray,
}

-- Layout variables for easy scaling
local LAYOUT = {
  marginX = 2,       -- left/right margin inside body
  startY = 2,        -- first card Y in body
  cardHeight = 6,    -- card/container height
  cardSpacing = 1,   -- vertical space between cards
  innerPadX = 2,     -- padding inside card for content
  buttonGap = 1,     -- gap between buttons
}

local function colorChip(frame, x, y, label, clr)
  return frame:addLabel({ x = x, y = y, text = "  " .. (label or "-"), foreground = clr or theme.dim })
end

function TrainSlot.new(parent, idx, state)
  local self = setmetatable({}, TrainSlot)
  self.idx, self.state = idx, state

  local w, _ = parent:getSize()
  local y = LAYOUT.startY + (idx - 1) * (LAYOUT.cardHeight + LAYOUT.cardSpacing)

  local boxFrame = ExperimentalFrame.new(parent, LAYOUT.marginX, y, w - (2 * LAYOUT.marginX), LAYOUT.cardHeight)
  self.box = boxFrame:getContainer()

  local slots = state:getState("slots") or {}
  local slot = slots[idx] or {}
  local obj = state:getState(("SLOT_%d"):format(idx)) or {}
  local enabled = obj.enabled == true

  -- Title row
  local nameTxt = obj.name or slot.name or ("Slot " .. idx)
  local typeTxt = "[" .. (obj.type or slot.type or (enabled and "?" or "inactive")) .. "]"
  local nameLbl = self.box:addLabel({ x = LAYOUT.innerPadX, y = 1, text = nameTxt, foreground = enabled and theme.text or theme.dim })
  self.box:addLabel({ x = LAYOUT.innerPadX + #nameTxt + 2, y = 1, text = typeTxt, foreground = theme.dim })

  -- Compute dynamic placements based on container width
  local cw, _ = self.box:getSize()
  local colorX = math.max(LAYOUT.innerPadX + 18, cw - LAYOUT.innerPadX - 12)
  local clr = (C and slot.link_color and C[slot.link_color]) or (enabled and C.orange or theme.dim)
  self.colorLbl = colorChip(self.box, colorX, 1, slot.link_color or "-", clr)

  -- Status & presence row
  self.box:addLabel({ x = LAYOUT.innerPadX, y = 2, text = "Status:", foreground = theme.dim })
  self.statusLbl = self.box:addLabel({ x = LAYOUT.innerPadX + 8, y = 2, text = obj.status or (enabled and "idle" or "inactive"), foreground = enabled and theme.ok or theme.dim })

  local presenceX = math.floor(cw * 0.45)
  self.presenceLbl = self.box:addLabel({ x = presenceX, y = 2, text = enabled and "(no train)" or "(inactive)", foreground = theme.dim })
  self.mismatchLbl = self.box:addLabel({ x = presenceX + 14, y = 2, text = "", foreground = theme.err })

  -- Route/config row
  local sc = (obj and obj.sched) or {}
  self.box:addLabel({ x = LAYOUT.innerPadX, y = 3, text = "Route:", foreground = theme.dim })
  self.routeLbl = self.box:addLabel({ x = LAYOUT.innerPadX + 8, y = 3, text = (obj and obj.routeId) or slot.routeId or "-", foreground = enabled and theme.text or theme.dim })
  self.box:addLabel({ x = LAYOUT.innerPadX + 22, y = 3, text = "Cfg:", foreground = theme.dim })
  self.schedLbl = self.box:addLabel({ x = LAYOUT.innerPadX + 27, y = 3, text = "", foreground = enabled and theme.text or theme.dim })

  -- Action buttons (only for active slots)
  self.btnEdit, self.btnRelease, self.btnHold = nil, nil, nil
  if enabled then
    local btnEditW, btnReleaseW, btnHoldW = 8, 9, 7
    local totalBtnsW = btnEditW + btnReleaseW + btnHoldW + (2 * LAYOUT.buttonGap)
    local startX = cw - LAYOUT.innerPadX - totalBtnsW + 1
    self.btnEdit = self.box:addButton({ x = startX, y = 3, width = btnEditW, height = 1, text = "Edit", background = C.gray or 128, foreground = C.black })
      :onClick(function()
        local Popup = require("views.PopupSchedule")
        Popup.open(parent, idx, state, function(newCfg) logic.updateSlotConfig(idx, newCfg) end)
      end)
    self.btnRelease = self.box:addButton({ x = startX + btnEditW + LAYOUT.buttonGap, y = 3, width = btnReleaseW, height = 1, text = "Release", background = C.lime, foreground = C.black })
      :onClick(function() logic.releaseTrain(idx) end)
    self.btnHold = self.box:addButton({ x = startX + btnEditW + LAYOUT.buttonGap + btnReleaseW + LAYOUT.buttonGap, y = 3, width = btnHoldW, height = 1, text = "Hold", background = C.red, foreground = C.white })
      :onClick(function() logic.holdTrain(idx) end)
  else
    -- Inactive card hint
    self.box:addLabel({ x = cw - LAYOUT.innerPadX - 12, y = 3, text = "Slot disabled", foreground = theme.dim })
  end

  self.enabled = enabled
  self:update()
  return self
end

local function cfgSummary(sc)
  return ("v=%.2f L=%d Y=%ds"):format(sc.speed or 1.0, sc.loops_before_yard or 1, sc.yard_wait or 0)
end

function TrainSlot:update()
  local s = self.state
  local obj = s:getState(("SLOT_%d"):format(self.idx)) or {}
  self.enabled = obj.enabled == true
  if not self.enabled then
    -- Keep inactive visuals static
    self.statusLbl:setText("inactive")
    self.statusLbl:setForeground(theme.dim)
    self.presenceLbl:setText("(inactive)")
    self.presenceLbl:setForeground(theme.dim)
    self.mismatchLbl:setText("")
    self.schedLbl:setText("-")
    return
  end

  local status = obj.status or "idle"
  self.statusLbl:setText(status)
  local fg = theme.warn
  if status == "idle" or status == "running" then fg = theme.ok end
  if status == "push failed" then fg = theme.err end
  self.statusLbl:setForeground(fg)

  local present = obj.present or false
  local mismatch = obj.mismatch or false
  local trainName = obj.trainName
  if present then
    self.presenceLbl:setText("(present)")
    self.presenceLbl:setForeground(theme.ok)
  else
    self.presenceLbl:setText("(no train)")
    self.presenceLbl:setForeground(theme.dim)
  end
  if mismatch and trainName then
    self.mismatchLbl:setText("mismatch: " .. tostring(trainName))
  else
    self.mismatchLbl:setText("")
  end

  local sc = obj.sched or {}
  self.schedLbl:setText(cfgSummary(sc))
end

return TrainSlot