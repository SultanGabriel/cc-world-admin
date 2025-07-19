-- lib/MediaPlayer.lua

--- Stateful wrapper for the 'speaker' peripheral, acting as a simple media player.

local dfpwm = require("cc.audio.dfpwm")

local MediaPlayer = {}
MediaPlayer.__index = MediaPlayer

-- Config
local AUDIO_DIR = "cc-world-admin/src/music"
--local AUDIO_DIR = "music"
local AUDIO_CHUNK_SIZE = 16 * 1024

function MediaPlayer.new(stateFrame, speakerPeripheral)
	assert(speakerPeripheral and speakerPeripheral.playAudio, "MediaPlayer requires a valid speaker peripheral")
	local self = setmetatable({}, MediaPlayer)

	self.speaker = speakerPeripheral
	self.stateFrame = stateFrame
	self.currentTrack = nil
	self.decoder = nil
	self.handle = nil
	self.volume = 3.0
	self.paused = false
	self.tracks = {}
	self._stopRequested = false

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

	self:stop(true) -- soft stop for async switching
	self.currentTrack = trackName
	self.decoder = dfpwm.make_decoder()
	self.paused = false
	self._stopRequested = false

	local path = fs.combine(AUDIO_DIR, trackName)
	self.handle = io.open(shell.resolve(path), "rb")
	self.stateFrame:setState("media_playing", true)
	self.stateFrame:setState("media_current", trackName)

	-- Launch async playback
	parallel.waitForAny(function()
		while self.handle and not self._stopRequested do
			if self.paused then
				os.sleep(0.1)
			else
				local chunk = self.handle:read(AUDIO_CHUNK_SIZE)
				if not chunk then
					break
				end

				local buffer = self.decoder(chunk)

				while not self.speaker.playAudio(buffer, self.volume) do
					if self._stopRequested then break end
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

function MediaPlayer:stop(isSoft)
	self._stopRequested = true
	if self.handle then
		self.handle:close()
		self.handle = nil
	end
	self.speaker.stop()
	self.currentTrack = nil
	self.paused = false
	self.decoder = nil
	if not isSoft then
		self.stateFrame:setState("media_playing", false)
		self.stateFrame:setState("media_current", nil)
	end
end

function MediaPlayer:isPlaying()
	return self.currentTrack ~= nil and not self.paused
end

function MediaPlayer:setVolume(vol)
	self.volume = math.max(0, math.min(vol, 3.0))
end

function MediaPlayer:nextTrack()
	if #self.tracks == 0 then
		print("[MediaPlayer] No tracks available.")
		return
	end

	local current = self.stateFrame:getState("media_current")
	local i = 0
	for idx, track in ipairs(self.tracks) do
		if track == current then
			i = idx
			break
		end
	end

	local nextIndex = (i % #self.tracks) + 1
	print("[MediaPlayer] Switching to next track:", self.tracks[nextIndex])
	self:play(self.tracks[nextIndex])
end

function MediaPlayer:playTrackById(index)
	print("[MediaPlayer] Attempting to play track at index:", index)
	if not index or index < 1 or index > #self.tracks then
		print("[MediaPlayer] Invalid track index:", index)
		return
	end

	local track = self.tracks[index]
	print("[MediaPlayer] Playing selected track:", track)
	self:play(track)
end

return MediaPlayer
