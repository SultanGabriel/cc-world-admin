local Popup = {}
local C = _G.colors 
local CONF = require("config")

local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

local function makeStepper(parent, x, y, label, initial, min, max, step, fmt)
  local frame = parent:addFrame({ x = x, y = y, width = 48, height = 1, background = C.gray })
  frame:addLabel({ x = 1, y = 1, text = label, foreground = C.black })
  local val = initial
  local function clampv(v)
    if v < min then return min end
    if v > max then return max end
    return v
  end
  local function fmtv(v)
    if fmt then return fmt(v) end
    return tostring(v)
  end
  local minus = frame:addButton({ x = 22, y = 1, width = 3, height = 1, text = "-", background = C.black, foreground = C.white })
  local disp  = frame:addLabel({ x = 26, y = 1, text = fmtv(val), foreground = C.black })
  local plus  = frame:addButton({ x = 34, y = 1, width = 3, height = 1, text = "+", background = C.black, foreground = C.white })
  minus:onClick(function()
    val = clampv((val or 0) - step)
    disp:setText(fmtv(val))
  end)
  plus:onClick(function()
    val = clampv((val or 0) + step)
    disp:setText(fmtv(val))
  end)
  return {
    get = function()
      return val
    end,
    set = function(v)
      val = clampv(v)
      disp:setText(fmtv(val))
    end,
  }
end

local function makeRouteSelector(parent, x, y, currentRouteId)
  local keys = {}
  for k, _ in pairs(CONF.ROUTES or {}) do table.insert(keys, k) end
  table.sort(keys)
  local idx = 1
  for i, k in ipairs(keys) do if k == currentRouteId then idx = i break end end

  local frame = parent:addFrame({ x = x,
   y = y,
    width = 48, height = 1, background = C.gray })
  frame:addLabel({ x = 1,
   y = 1,
    text = "Route:", foreground = C.black })
  local prev = frame:addButton({ x = 22,
   y = 1,
    width = 3, height = 1, text = "<", background = C.black, foreground = C.white })
  local lbl  = frame:addLabel({ x = 26,
   y = 1,
    text = keys[idx] or "-", foreground = C.black })
  local next = frame:addButton({ x = 34,
   y = 1,
    width = 3, height = 1, text = ">", background = C.black, foreground = C.white })
  local function refresh()
    lbl:setText(keys[idx] or "-")
  end
  prev:onClick(function()
    if #keys == 0 then return end
    idx = idx - 1; if idx < 1 then idx = #keys end
    refresh()
  end)
  next:onClick(function()
    if #keys == 0 then return end
    idx = idx + 1; if idx > #keys then idx = 1 end
    refresh()
  end)
  return { get = function() return keys[idx] end }
end

function Popup.open(rootFrame, idx, state, onSave)
  local w, h = rootFrame:getSize()
  local overlay = rootFrame:addFrame({ x = 1, y = 1, width = w, height = h, background = C.black or 0 })
  --overlay:setOpacity(0.6):setZIndex(200)

  local boxW, boxH = 42, 9
  local box = rootFrame:addFrame({
    x = math.floor(w/2 - boxW/2),
    y = math.floor(h/2 - boxH/2),
    width = boxW, height = boxH,
    background = C.gray or 128,
  })
  --box:setBorder(C.white ):setZIndex(201)

  box:addLabel({ x = 2, y = 1, text = ("Edit Schedule [Slot %d]"):format(idx), foreground = C.white })

  local slotObj = state:getState(("SLOT_%d"):format(idx)) or {}
  local sc = slotObj.sched or { speed = 1.0, loops_before_yard = 4, yard_wait = 20 }
  local currentRouteId = slotObj.routeId

  local speedStep = makeStepper(box, 2, 3, "Max Speed (0.1..1.0):", sc.speed or 1.0, 0.1, 1.0, 0.05, function(v) return string.format("%.2f", v) end)
  local loopsStep = makeStepper(box, 2, 4, "Loops before Yard:", sc.loops_before_yard or 4, 1, 999, 1, function(v) return tostring(math.floor(v)) end)
  local waitStep  = makeStepper(box, 2, 5, "Yard Wait (sec):", sc.yard_wait or 20, 0, 3600, 5, function(v) return tostring(math.floor(v)) end)
  local routeSel  = makeRouteSelector(box, 2, 6, currentRouteId)

  box:addButton({ x = boxW - 18, y = boxH - 2, width = 8, height = 1, text = "Save", background = C.lime , foreground = C.black })
    :onClick(function()
      local v = speedStep.get()
      local loops = math.max(1, math.floor(loopsStep.get()))
      local wait = math.max(0, math.floor(waitStep.get()))
      local routeId = routeSel.get()
      if onSave then onSave({ speed = v, loops_before_yard = loops, yard_wait = wait, routeId = routeId }) end
      box:destroy(); overlay:destroy()
    end)

  box:addButton({ x = boxW - 9, y = boxH - 2, width = 8, height = 1, text = "Cancel", background = C.red , foreground = C.white })
    :onClick(function() box:destroy(); overlay:destroy() end)
end

return Popup