local basalt = require("lib.basalt")

local MonitorSelector = {}

function MonitorSelector.select(frame, callback)
	local w, h = frame:getSize()
	local pMonitors = {}

	for _, name in ipairs(peripheral.getNames()) do
		if name:find("monitor") then
			table.insert(pMonitors, name)
		end
	end

	if #pMonitors < 1 then
		print("No monitors found.")
		return
	-- end
	elseif #pMonitors == 1 then
		callback(peripheral.wrap(pMonitors[1]))
		return
	end

	frame:setBackground(colors.gray)

	frame:addLabel():setText("Please select the monitor you want to use"):setForeground(colors.white):setPosition(2, 1)

	local list = frame:addList():setPosition(2, 3):setSize(w - 2, h - 5)

	for _, item in ipairs(pMonitors) do
		list:addItem(item)
	end

	frame:addButton():setText("Save"):setPosition(w - 8, h - 1):setSize(8, 1):onClick(function()
		local selected = list:getItem(list:getItemIndex())
		if selected then
			callback(peripheral.wrap(selected))
		end
	end)
end

return MonitorSelector
