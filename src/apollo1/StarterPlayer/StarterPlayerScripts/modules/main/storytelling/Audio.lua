local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local soundsFolder = Instance.new("Folder")
soundsFolder.Name = "Sounds"
soundsFolder.Parent = Workspace

local Audio = {
	active = {},
}

local function createEmitterAt(position: Vector3): Part
	local emitter = Instance.new("Part")
	emitter.Name = "AudioEmitter"
	emitter.Anchored = true
	emitter.CanCollide = false
	emitter.CanQuery = false
	emitter.CanTouch = false
	emitter.Size = Vector3.new(0.2, 0.2, 0.2)
	emitter.Transparency = 1
	emitter.Position = position
	emitter.Parent = soundsFolder
	return emitter
end

local function buildSound(soundConfig):Sound
	local sound:Sound = Instance.new("Sound")
	sound.SoundId = soundConfig.soundId 
	sound.Volume = soundConfig.volume or 1
	sound.PlaybackSpeed = soundConfig.playbackSpeed or 1
	sound.Looped = (soundConfig.looped == true)
	if next(soundConfig.additional or {}) then
		for prop, value in pairs(soundConfig.additional) do
			if sound[prop] ~= nil then
				sound[prop] = value
			end
		end
	end
	return sound
end

function Audio:playAudio(soundConfig, options)
	if not soundConfig or not soundConfig.soundId then
		return nil
	end
	local sound = buildSound(soundConfig)
	local emitter = nil
	local parent = options and options.parent
	local position = options and options.position
	if position and not parent then
		emitter = createEmitterAt(position)
		parent = emitter
	end
	if not parent then
		parent = SoundService
	end
	sound.Parent = parent

	if not sound.IsLoaded then
		sound.Loaded:wait()
	end
	local duration = (options and options.duration) or (soundConfig.duration)
	if duration ~= nil then
		local speed = sound.TimeLength / duration
		sound.PlaybackSpeed = speed
	end

	if soundConfig.playOnRemove then
		sound.PlayOnRemove = true
		sound:Destroy()
	else
		sound:Play()
	end

	local handle = {
		sound = sound,
		emitter = emitter,
		stop = function()
			if sound and sound.Parent then
				sound:Stop()
				sound:Destroy()
			end
			if emitter then
				emitter:Destroy()
			end
		end,
		duration = duration or sound.TimeLength,
	}

	self.active[sound] = handle

	local conn = sound.Ended:Connect(function()
		if self.active[sound] then
			self.active[sound] = nil
			if emitter then
				emitter:Destroy()
			end
			sound:Destroy()
		end
	end)
    table.insert(self.conns, conn)
	return handle
end

function Audio:stopAudio(handle)
	if handle and handle.stop then
		handle.stop()
	end
end

return Audio