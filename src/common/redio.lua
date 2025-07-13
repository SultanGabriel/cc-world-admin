-- lib/RedIO.lua

--- A robust redstone IO controller for managing digital input/output bindings with state
--- Focused on digital signals only; analog and simple "io" mode removed for clarity

local DEBUG_LOGS = true

local RedIO = {}
RedIO.__index = RedIO

--- Create a new RedIO instance
-- @param redstoneSideOrPeripheral string | peripheral table (e.g., "back" or peripheral.wrap("back"))
-- @param stateFrame Basalt frame containing state
-- @param config table mapping logical names (e.g., D_01) to redstone configuration:
--        { side = "left", mode = "input"|"output", bundled = optionalColorMask }
function RedIO.new(redstoneSideOrPeripheral, stateFrame, config)
	if DEBUG_LOGS then
		print("[RedIO] Initializing RedIO instance")
	end

	local self = setmetatable({}, RedIO)

	if type(redstoneSideOrPeripheral) == "string" then
		if DEBUG_LOGS then
			print("[RedIO] Wrapping redstone peripheral: " .. redstoneSideOrPeripheral)
		end
		if redstoneSideOrPeripheral == "back" then
			self.redstSide = "back"
			self.peripheral = redstone
		elseif redstoneSideOrPeripheral == "left" then
			self.redstSide = "left"
			self.peripheral = redstone
		elseif redstoneSideOrPeripheral == "right" then
			self.redstSide = "right"
			self.peripheral = redstone
		elseif redstoneSideOrPeripheral == "top" then
			self.redstSide = "top"
			self.peripheral = redstone
		elseif redstoneSideOrPeripheral == "bottom" then
			self.redstSide = "bottom"
			self.peripheral = redstone
		else
			error("Invalid redstone side: " .. redstoneSideOrPeripheral)
		end
	elseif type(redstoneSideOrPeripheral) == "table" and redstoneSideOrPeripheral.getInput then
		self.peripheral = redstoneSideOrPeripheral
		if DEBUG_LOGS then
			print("[RedIO] Using provided peripheral: " .. tostring(redstoneSideOrPeripheral))
		end
	else
		error("Invalid redstone side or peripheral: " .. tostring(redstoneSideOrPeripheral))
	end

	-- self.peripheral = type(redstoneSideOrPeripheral) == "string"
	--     and peripheral.wrap(redstoneSideOrPeripheral)
	-- or redstoneSideOrPeripheral

	assert(self.peripheral, "Invalid redstone peripheral")

	self.stateFrame = stateFrame
	self.config = config or {}
	self.inputCache = {}

	self:_setupBindings()
	self:_selfChecks()

	if DEBUG_LOGS then
		print("[RedIO] Initialization complete")
	end
	return self
end

--- Internal: Verify config consistency and duplicates
function RedIO:_selfChecks()
	if DEBUG_LOGS then
		print("[RedIO] Performing self checks on configuration")
	end
	local dup = {}
	for key, cfg in pairs(self.config) do
		assert(cfg.side and cfg.mode, "Config missing side or mode: " .. key)
		assert(cfg.mode == "input" or cfg.mode == "output", "Invalid mode: " .. key)
		assert(not dup[key], "Duplicate config entry for key: " .. key)

		dup[key] = true
	end
	if DEBUG_LOGS then
		print("[RedIO] Self checks passed")
	end
end

--- Internal: Setup hooks from state to redstone outputs
function RedIO:_setupBindings()
	if DEBUG_LOGS then
		print("[RedIO] Setting up output bindings")
	end
	for key, cfg in pairs(self.config) do
		if cfg.mode == "output" then
			self.stateFrame:onStateChange(key, function(_, newValue)
				if DEBUG_LOGS then
					print("[RedIO] State changed for " .. key .. ": " .. tostring(newValue))
				end
				self:_writeRedstone(cfg, newValue)
			end)

			local cur = self.stateFrame:getState(key)
			self:_writeRedstone(cfg, cur)
		end
	end
end

--- Write a redstone output (simple or bundled)
function RedIO:_writeRedstone(cfg, value)
	if DEBUG_LOGS then
		print("[RedIO] Writing redstone output for side " .. cfg.side .. ", value: " .. tostring(value))
	end
	if cfg.bundled then
		local cur = self.peripheral.getBundledOutput(cfg.side)
		if value then
			self.peripheral.setBundledOutput(cfg.side, colors.combine(cur, cfg.bundled))
		else
			self.peripheral.setBundledOutput(cfg.side, colors.subtract(cur, cfg.bundled))
		end
	else
		self.peripheral.setOutput(cfg.side, value)
	end
end

--- Poll all configured inputs and write changes to state
function RedIO:pollInputs()
	if DEBUG_LOGS then
		-- print("[RedIO] Polling inputs")
	end
	for key, cfg in pairs(self.config) do
		if cfg.mode == "input" then
			local val
			if cfg.bundled then
				val = colors.test(self.peripheral.getBundledInput(cfg.side), cfg.bundled)
			else
				val = self.peripheral.getInput(cfg.side)
			end

			if self.inputCache[key] ~= val then
				if DEBUG_LOGS then
					print("[RedIO] Input changed for " .. key .. ": " .. tostring(val))
				end
				self.inputCache[key] = val
				self.stateFrame:setState(key, val)
			end
		end
	end
end

--- Public: Set logical output
function RedIO:set(name, value)
	if DEBUG_LOGS then
		print("[RedIO] set called for " .. name .. " = " .. tostring(value))
	end
	local cfg = self.config[name]
	if not cfg or cfg.mode ~= "output" then
		return
	end
	self.stateFrame:setState(name, value)
end

--- Public: Toggle logical output
function RedIO:toggle(name)
	if DEBUG_LOGS then
		print("[RedIO] toggle called for " .. name)
	end
	local cur = self:get(name)
	if cur ~= nil then
		self:set(name, not cur)
	end
end

--- Public: Get current logical state
function RedIO:get(name)
	local value = self.stateFrame:getState(name)
	if DEBUG_LOGS then
		print("[RedIO] get called for " .. name .. " = " .. tostring(value))
	end
	return value
end

return RedIO
