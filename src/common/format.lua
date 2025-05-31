-- lib/format.lua
local M = {}

function M.formatWithSpaces(numStr)
    local int, frac = numStr:match("^(%-?%d+)(%.%d+)$")
    if not int then int, frac = numStr, "" end
    local rev = int:reverse():gsub("(%d%d%d)", "%1 ")
    local formatted = rev:reverse():gsub("^%s+", "")
    return formatted .. (frac or "")
end

function M.capitalizeFirst(str)
    return (str:gsub("^%l", string.upper))
end

function M.formatMillibuckets(mb)
    local b = mb / 1000
    if b < 1 then return mb .. " mB"
    elseif b < 1000 then return M.formatWithSpaces(tostring(math.floor(b))) .. " B"
    else return M.formatWithSpaces(tostring(math.floor(b / 1000))) .. " kB"
    end
end

return M

