local basalt = require('lib.basalt.src')
local MainView = require('views.MainView')
local InputView = require('views.InputView')
local EnergyView = require('views.EnergyView')

local DOORWAYS = require('config').Doorways
local REDSTONE_INPUT = require('config').RedstoneInput
local REDSTONE_OUTPUT = require('config').RedstoneOutput

local RedIO = require('common.redio')
local PlayerDetectorIO = require('common.playerdetectorio')
local MediaPlayer = require('common.MediaPlayer')

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

local function initState(state)
	if not state then
		error('State cannot be nil')
	end

	-- Initialize all door states if not already present
	for key, _ in pairs(DOORWAYS) do
		state:initializeState(key, false, false) -- no persistence, default: closed
	end


	for key, _ in pairs(REDSTONE_OUTPUT) do
		state:initializeState(key, false, false) -- no persistence, default: closed
	end
end

local function init()
	local monitor = peripheral.wrap(MONITOR_MAIN)
	if not monitor then
		error('Monitor not found: ' .. MONITOR_MAIN)
	end

	local B = basalt.createFrame():setTerm(monitor)

	initState(B)

	local redstSide = 'bottom'
	RedIO_In = RedIO.new(redstSide, B, REDSTONE_INPUT)

	RedIO_Out = RedIO.new(redstSide, B, REDSTONE_OUTPUT)
  -- RedIO_Out:registerOutputChangeCallback()


	CHATBOX = peripheral.wrap('chatBox_0')
	PD = peripheral.wrap('playerDetector_0')

	if PD ~= nil then
		PDIO = PlayerDetectorIO.new(B, PD, CHATBOX)
	else
		B:initializeState('players', {})
	end


	local speaker = peripheral.wrap('speaker_8') -- or peripheral.wrap("speaker_0") if fixed
	if speaker then
    print("[MAIN] Speaker found!")
    print("[MAIN] Initiating Media Player!")
		MPIO = MediaPlayer.new(B, speaker)
	else
    print("[MAIN] Speaker is not connected..")
		B:initializeState('media_tracks', {})
		B:initializeState('media_playing', false)
		B:initializeState('media_current', nil)
	end


	local mainView = MainView.new(B, B)
	table.insert(views, mainView)

	--- Other views
	local monitorInput = peripheral.wrap(MONITOR_INPUT)
	if monitorInput then
		local inputView = InputView.new(
		basalt.createFrame():setTerm(monitorInput), B)
		table.insert(views, inputView)
	end

	local monitorEnergy = peripheral.wrap(MONITOR_ENERGY)
	if monitorEnergy then
		local energyView = EnergyView.new(
		basalt.createFrame():setTerm(monitorEnergy), B)
		table.insert(views, energyView)
	end
end

init()

local POLL_INTERVAL = 0.5
basalt.schedule(function()
	while true do
		if RedIO_In then
      -- print("polling rio")
			RedIO_In:pollInputs()
		end

		if PDIO then
			PDIO:update()
		end

		os.sleep(POLL_INTERVAL)
	end
end)

parallel.waitForAny(
-- View update loop
	function()
		while true do
			for _, view in ipairs(views) do
				-- print("Updating view: " .. tostring(view))
				view:update()
			end
			sleep(1)
		end
	end,

	-- Basalt update loop
	function()
		basalt.run()
	end
)
