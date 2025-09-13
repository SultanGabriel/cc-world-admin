package.path = package.path .. ';../lib/Basalt/release/?.lua'
package.path = package.path .. ';../src-common/?.lua'

local basalt = require('basalt')
local MainView = require('views.MainView')
local InputView = require('views.InputView')
local EnergyView = require('views.EnergyView')

local DOORWAYS = require('config').Doorways
local REDSTONE_INPUT = require('config').RedstoneInput
local REDSTONE_OUTPUT = require('config').RedstoneOutput
local INDICATORS = require('config').Indicators

local RedIO = require('redio')
local PlayerDetectorIO = require('playerdetectorio')
local MediaPlayer = require('MediaPlayer')

--- Indicators
-- I_PDIO_READY (PDIO Ready)
-- I_CHATBOX_READY (Chatbox Ready)
-- I_REDIO_READY (REDIO Ready)
-- I_MPIO_READY (Media Player Ready)

-- I_PDIO_ENABLED (Domn' paznic)
-- 
-- 
-- 
-- 
-- 

-- local selectedMonitor = nil
local views = {}
RedIO_In = nil
RedIO_Out = nil
PDIO = nil
MPIO = nil

local MONITOR_MAIN = 'monitor_17'
local MONITOR_INPUT = 'monitor_18'
local MONITOR_ENERGY = 'monitor_20' -- fixme rename this mdfkr some time
-- local MONITOR_STATS = "monitor_4"

APP_STATE = nil -- fixme well this is going to be the new state object
-- fixme
FRAME_MAIN = nil
FRAME_INPUT = nil
FRAME_ENERGY = nil
FRAME_STATS = nil -- fixme to replace frame_energy in the future

local function initState(state)
	if not state then
		error('State Object cannot be nil')
	end

	-- Initialize all states
	for key, _ in pairs(DOORWAYS) do
		state:initializeState(key, false, false)
	end

	for key, _ in pairs(REDSTONE_OUTPUT) do
		state:initializeState(key, false, false)
	end

	for key, _ in pairs(INDICATORS) do
		state:initializeState(key, false, false)
	end

	-- PDIO Thingies
	state:initializeState('players', {})
	state:initializeState('PDIO_Zones_Enabled', false)
	state:initializeState('PDIO_Events_Enabled', false)
	-- Media player Thingies
	state:initializeState('media_tracks', {})
	state:initializeState('media_playing', false)
	state:initializeState('media_current', nil)
end

local MONITORS = {}
local function init()
	-- Init Application State
	APP_STATE = basalt.createFrame() -- fime
	if not APP_STATE then
		error('Failed to create application state frame')
	end

	initState(APP_STATE)

	-- Init Monitors
	MONITORS[MONITOR_MAIN] = peripheral.wrap(MONITOR_MAIN)
	if not MONITORS[MONITOR_MAIN] then
		error('Main monitor not found: ' .. MONITOR_MAIN)
	end

	MONITORS[MONITOR_INPUT] = peripheral.wrap(MONITOR_INPUT)
	if not MONITORS[MONITOR_INPUT] then
		error('Input monitor not found: ' .. MONITOR_INPUT)
	end

	MONITORS[MONITOR_ENERGY] = peripheral.wrap(MONITOR_ENERGY)
	if not MONITORS[MONITOR_ENERGY] then
		error('Energy monitor not found: ' .. MONITOR_ENERGY)
	end


	-- Redstone Peripherals
	local redstSide = 'bottom'
	RedIO_In = RedIO.new(redstSide, APP_STATE, REDSTONE_INPUT)
	RedIO_Out = RedIO.new(redstSide, APP_STATE, REDSTONE_OUTPUT)
	-- RedIO_Out:registerOutputChangeCallback()
	CHATBOX = peripheral.wrap('chatBox_0')
	PD = peripheral.wrap('playerDetector_0')

	if PD ~= nil then
		PDIO = PlayerDetectorIO.new(APP_STATE, PD, CHATBOX)
		APP_STATE:setState('PDIO', true)
		print('[MAIN] PlayerDetectorIO initialized!')
	else
		APP_STATE:setState('players', {})
		APP_STATE:setState('PDIO_Zones_Enabled', false)
		APP_STATE:setState('PDIO_Events_Enabled', false)

		APP_STATE:setState('PDIO', false)
	end

	local speaker = peripheral.wrap('speaker_8') -- or peripheral.wrap("speaker_0") if fixed
	if speaker then
		print('[MAIN] Speaker found!')
		print('[MAIN] Initiating Media Player!')
		MPIO = MediaPlayer.new(APP_STATE, speaker)
	else
		print('[MAIN] Speaker is not connected..')
		APP_STATE:setState('media_tracks', {})
		APP_STATE:setState('media_playing', false)
		APP_STATE:setState('media_current', nil)
	end

	-- local mainView = MainView.new(FRAME_MAIN, APP_STATE)
	-- table.insert(views, mainView)

	--- Other views
end

local function initViews()
	FRAME_MAIN = MainView.new(
		basalt.createFrame():setTerm(MONITORS[MONITOR_MAIN]), APP_STATE)
	table.insert(views, FRAME_MAIN)

	FRAME_INPUT = InputView.new(
		basalt.createFrame():setTerm(MONITORS[MONITOR_INPUT]), APP_STATE)
	table.insert(views, FRAME_INPUT)

	FRAME_ENERGY = EnergyView.new(
		basalt.createFrame():setTerm(MONITORS[MONITOR_ENERGY]), APP_STATE)
	table.insert(views, FRAME_ENERGY)
end

init()
initViews()

local POLL_INTERVAL = 0.5
basalt.schedule(function()
	while true do
		if RedIO_In then
			RedIO_In:pollInputs()
		end

		if PDIO then
			PDIO:update()
		end

		for _, view in ipairs(views) do
			-- print("Updating view: " .. tostring(view))
			view:update()
		end

		os.sleep(POLL_INTERVAL)
	end
end)

-- parallel.waitForAny(
-- 	-- Basalt update loop
-- 	function()
basalt.run()
-- 	end
-- )