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

--- Splits a string into parts separated by a delimiter.
-- @param str (string) The input string to split.
-- @param sep (string) The separator (single character or Lua pattern).
-- @return table An array-like table of substrings. 
--   If `str` is an empty string, returns {""}.
-- @usage
-- local parts = split("a,b,,c", ",")
-- -- parts = { "a", "b", "", "c" }
function M.split(inputstr, sep)
   -- if sep is null, set it as space
   if sep == nil then
      sep = '%s'
   end
   -- define an array
   local t={}
   -- split string based on sep   
   for str in string.gmatch(inputstr, '([^'..sep..']+)') 
   do
      -- insert the substring in table
      table.insert(t, str)
   end
   -- return the array
   return t
end

return M

