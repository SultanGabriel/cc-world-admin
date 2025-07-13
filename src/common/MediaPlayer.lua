-- lib/MediaPlayer.lua

--- Stateful wrapper for the 'speaker' peripheral, acting as a simple media player.

local dfpwm = require("cc.audio.dfpwm")

local MediaPlayer = {}
MediaPlayer.__index = MediaPlayer

-- Config
local AUDIO_DIR = "src/TankMonitor/src/music"
local AUDIO_CHUNK_SIZE = 16 * 1024

function MediaPlayer.new(stateFrame, speakerPeripheral)
	assert(speakerPeripheral and speakerPeripheral.playAudio, "MediaPlayer requires a valid speaker peripheral")
	local self = setmetatable({}, MediaPlayer)

	self.speaker = speakerPeripheral
	self.stateFrame = stateFrame
	self.currentTrack = nil
	self.decoder = nil
	self.handle = nil
	self.volume = 1.0
	self.paused = false
	self.tracks = {}

	self:_init()
	return self
end

function MediaPlayer:_init()
	self.stateFrame:initializeState("media_tracks", {})
	self.stateFrame:initializeState("media_playing", false)
	self.stateFrame:initializeState("media_current", nil)

	self:refreshTrackList()
end

function MediaPlayer:refreshTrackList()
  if not fs.exists(AUDIO_DIR) then
    print("[MediaPlayer] Directory missing, creating:", AUDIO_DIR)
    fs.makeDir(AUDIO_DIR)
  end

  local files = fs.list(AUDIO_DIR)
  local dfpwmFiles = {}
  for _, file in ipairs(files) do
    if file:match("%.dfpwm$") then
      table.insert(dfpwmFiles, file)
    end
  end

  self.tracks = dfpwmFiles
  self.stateFrame:setState("media_tracks", self.tracks)

  print("[MediaPlayer] Tracks found:", #self.tracks)
end

function MediaPlayer:play(trackName)
	if not trackName or not fs.exists(fs.combine(AUDIO_DIR, trackName)) then
		error("Track not found: " .. tostring(trackName))
	end

	self:stop()
	self.currentTrack = trackName
	self.decoder = dfpwm.make_decoder()
	self.paused = false

	local path = fs.combine(AUDIO_DIR, trackName)
	self.handle = io.open(shell.resolve(path), "rb")
	self.stateFrame:setState("media_playing", true)
	self.stateFrame:setState("media_current", trackName)

	-- Launch async playback
	parallel.waitForAny(function()
		while self.handle do
			if self.paused then
				os.sleep(0.1)
			else
				local chunk = self.handle:read(AUDIO_CHUNK_SIZE)
				if not chunk then
					break
				end

				local buffer = self.decoder(chunk)

				while not self.speaker.playAudio(buffer, self.volume) do
					os.pullEvent("speaker_audio_empty")
				end
			end
		end
		self:stop()
	end)
end

function MediaPlayer:pause()
	self.paused = true
end

function MediaPlayer:resume()
	if self.currentTrack and self.paused then
		self.paused = false
	end
end

function MediaPlayer:stop()
	if self.handle then
		self.handle:close()
		self.handle = nil
	end
	self.speaker.stop()
	self.currentTrack = nil
	self.paused = false
	self.stateFrame:setState("media_playing", false)
	self.stateFrame:setState("media_current", nil)
end

function MediaPlayer:isPlaying()
	return self.currentTrack ~= nil and not self.paused
end

function MediaPlayer:setVolume(vol)
	self.volume = math.max(0, math.min(vol, 3.0))
end

return MediaPlayer
