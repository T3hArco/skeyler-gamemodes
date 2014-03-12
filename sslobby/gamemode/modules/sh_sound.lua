SS.Lobby.Sound = {}

local stored = {}
local object = {}
object.__index = object

AccessorFunc(object, "m_iTime", "Time")
AccessorFunc(object, "m_flVolume", "Volume")
AccessorFunc(object, "m_iDuration", "Duration")

local soundDurations = {}

--------------------------------------------------
--
--------------------------------------------------

function SS.Lobby.Sound.New(unique, entity, path, loop)
	local sound = {}
	
	setmetatable(sound, object)

	sound.object = CreateSound(entity, path)
	sound.object:Stop()
	
	if (!loop) then
		sound.object:Play()
	end
	
	local duration = soundDurations[path] or SoundDuration(path)
	
	sound:SetLoop(loop)
	sound:SetTime(0)
	sound:SetDuration(duration)
	sound:SetVolume(1.0)
	
	stored[unique] = sound
	
	return sound
end

--------------------------------------------------
--
--------------------------------------------------

function SS.Lobby.Sound.Remove(unique)
	local data = stored[unique]
	
	if (data) then
		data.object:Stop()
		data = nil
	end
end

--------------------------------------------------
--
--------------------------------------------------

function object:SetLoop(bool)
	self.loop = bool
end

--------------------------------------------------
--
--------------------------------------------------

function object:ShouldLoop()
	return self.loop
end

--------------------------------------------------
--
--------------------------------------------------

hook.Add("Think", "ss.lobby.sound", function()
	for unique, sound in pairs(stored) do
		if (sound:ShouldLoop()) then
			if (sound:GetTime() <= CurTime()) then
				sound.object:Stop()
				sound.object:Play()
				sound.object:ChangeVolume(sound:GetVolume(), 0)
				
				sound:SetTime(CurTime() +sound:GetDuration())
			end
		end
	end
end)