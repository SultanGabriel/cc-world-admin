-- ui/component.lua
local Component = {}
Component.__index = Component

function Component.new()
    local self = setmetatable({}, Component)
    return self
end

function Component:update()
    -- Override in subclasses
end

return Component
