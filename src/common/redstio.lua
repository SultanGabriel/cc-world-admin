--- rsio.lua - Redstone I/O abstraction layer

---@class IO_LVL
---@field LOW integer
---@field HIGH integer
---@field FLOATING integer
---@field DISCONNECT integer
local IO_LVL = {
	LOW = 0,
	HIGH = 1,
	FLOATING = 2,
	DISCONNECT = -1,
}

---@class IO_DIR
---@field IN integer
---@field OUT integer
local IO_DIR = {
	IN = 0,
	OUT = 1,
}

---@class IO_MODE
---@field DIGITAL_IN integer
---@field DIGITAL_OUT integer
---@field ANALOG_IN integer
---@field ANALOG_OUT integer
local IO_MODE = {
	DIGITAL_IN = 0,
	DIGITAL_OUT = 1,
	ANALOG_IN = 2,
	ANALOG_OUT = 3,
}

---@class IO_PORT
---@field SCRAM integer
---@field ALARM integer
---@field POWER_LEVEL integer
local IO_PORT = {
	SCRAM = 1,
	ALARM = 2,
	POWER_LEVEL = 3,
	-- Add more ports here
}

--- Mapping of ports to physical redstone sides (must be configured by user)
---@type table<IO_PORT, string>
local MAPPED_SIDES = {
	[IO_PORT.SCRAM] = 'top',
	[IO_PORT.ALARM] = 'right',
	[IO_PORT.POWER_LEVEL] = 'back',
	-- Configure these per your setup
}

--- Mapping of ports to their I/O mode
---@type table<IO_PORT, IO_MODE>
local MODES = {
	[IO_PORT.SCRAM] = IO_MODE.DIGITAL_OUT,
	[IO_PORT.ALARM] = IO_MODE.DIGITAL_OUT,
	[IO_PORT.POWER_LEVEL] = IO_MODE.ANALOG_OUT,
	-- Define modes for all ports
}

--- Get the I/O direction for a port
---@param port IO_PORT
---@return IO_DIR
local function get_io_dir(port)
	local mode = MODES[port]
	if mode == IO_MODE.DIGITAL_OUT or mode == IO_MODE.ANALOG_OUT then
		return IO_DIR.OUT
	else
		return IO_DIR.IN
	end
end

--- Logic handlers for input/output activation levels
---@type table<IO_PORT, { _out: fun(any): any, _in: fun(IO_LVL): boolean }>
local ACTIVE_LOGIC = {
	[IO_PORT.SCRAM] = {
		_out = function(active)
			return not active
		end, -- active low
		_in = function(level)
			return level == IO_LVL.LOW
		end,
	},
	[IO_PORT.ALARM] = {
		_out = function(active)
			return active
		end, -- active high
		_in = function(level)
			return level == IO_LVL.HIGH
		end,
	},
	[IO_PORT.POWER_LEVEL] = {
		_out = function(value)
			return value
		end,
		_in = function(level)
			return level
		end,
	},
	-- Define logic for each port
}

--- Convert boolean to IO_LVL
---@param value boolean
---@return IO_LVL
local function digital_read(value)
	return value and IO_LVL.HIGH or IO_LVL.LOW
end

--- Convert IO_LVL to boolean
---@param level IO_LVL
---@return boolean
local function digital_write(level)
	return level == IO_LVL.HIGH
end

--- Set a port output value
---@param port IO_PORT
---@param value boolean|integer
local function set_output(port, value)
	local side = MAPPED_SIDES[port]
	local mode = MODES[port]
	local logic = ACTIVE_LOGIC[port]

	if not side then
		error('No side mapped for port ' .. tostring(port))
	end
	if not logic then
		error('No logic defined for port ' .. tostring(port))
	end

	if mode == IO_MODE.DIGITAL_OUT then
		redstone.setOutput(side, logic._out(value))
	elseif mode == IO_MODE.ANALOG_OUT then
		redstone.setAnalogOutput(side, logic._out(value))
	else
		error('Port is not configured as output')
	end
end

--- Get a port input value
---@param port IO_PORT
---@return boolean|integer
local function get_input(port)
	local side = MAPPED_SIDES[port]
	local mode = MODES[port]
	local logic = ACTIVE_LOGIC[port]

	if not side then
		error('No side mapped for port ' .. tostring(port))
	end
	if not logic then
		error('No logic defined for port ' .. tostring(port))
	end

	if mode == IO_MODE.DIGITAL_IN then
		return logic._in(digital_read(redstone.getInput(side)))
	elseif mode == IO_MODE.ANALOG_IN then
		return redstone.getAnalogInput(side)
	else
		error('Port is not configured as input')
	end
end

--- Send a non-blocking digital pulse
---@param port IO_PORT
---@param duration number Duration in seconds
local function pulse_output(port, duration)
	local dir = get_io_dir(port)
	if dir ~= IO_DIR.OUT then
		error("Port " .. tostring(port) .. " is not configured as output")
	end

	-- Fire and forget coroutine
	local function do_pulse()
		set_output(port, true)
		sleep(duration)
		set_output(port, false)
	end

	-- Fork it
	local thread = coroutine.create(do_pulse)
	coroutine.resume(thread)
end

---@class rsio
---@field IO_LVL IO_LVL
---@field IO_MODE IO_MODE
---@field IO_DIR IO_DIR
---@field IO_PORT IO_PORT
---@field set fun(port: IO_PORT, value: boolean|integer)
---@field get fun(port: IO_PORT): boolean|integer
---@field get_io_dir fun(port: IO_PORT): IO_DIR
local rsio = {
	IO_LVL = IO_LVL,
	IO_MODE = IO_MODE,
	IO_DIR = IO_DIR,
	IO_PORT = IO_PORT,

	set = set_output,
	get = get_input,
	get_io_dir = get_io_dir,
	pulse = pulse_output,
}

-- Self-checks to validate configuration
rsio.NUM_PORTS = 3     -- update when adding ports
rsio.NUM_DIG_PORTS = 2 -- SCRAM + ALARM
rsio.NUM_ANA_PORTS = 1 -- POWER_LEVEL

assert(rsio.NUM_PORTS == (rsio.NUM_DIG_PORTS + rsio.NUM_ANA_PORTS),
	'port counts inconsistent')

local dup_chk = {}
for _, v in pairs(IO_PORT) do
	assert(dup_chk[v] ~= true, 'duplicate in port list')
	dup_chk[v] = true
end

assert(#dup_chk == rsio.NUM_PORTS, 'port list malformed')

return rsio