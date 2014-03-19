SS.Lobby.Sound = {}

local stored = {}
local object = {}
object.__index = object

AccessorFunc(object, "m_iTime", "Time")
AccessorFunc(object, "m_flVolume", "Volume")
AccessorFunc(object, "m_iDuration", "Duration")

local soundDurations = {}
soundDurations["skeyler/lounge/lobby01.mp3"] = 355
soundDurations["skeyler/lounge/lobby02.mp3"] = 358
soundDurations["skeyler/lounge/lobby03.mp3"] = 425
soundDurations["skeyler/lounge/lobby04.mp3"] = 310
soundDurations["skeyler/lounge/lobby05.mp3"] = 307

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
		if unique == "lobby_music" then
			sound.object:ChangeVolume(SS.Lobby.MusicVolume:GetInt()/100, 0)
		end

		if (sound:ShouldLoop()) then
			if (sound:GetTime() <= CurTime()) then
				sound.object:Stop()
				sound.object:Play()
				sound.object:ChangeVolume(sound:GetVolume(), 0)
				
				sound:SetTime(CurTime() +sound:GetDuration())
			end
		elseif unique == "lobby_music" then
			if (sound:GetTime() <= CurTime()) then
				sound.object:Stop()
				SS.Lobby.Sound.Remove(unique)

				//If last song is finished, play a new one at random
				local music = SS.Lobby.Sound.New("lobby_music", LocalPlayer(), "skeyler/lounge/lobby0".. math.random(1, 5) ..".mp3", false)
				music:SetTime(CurTime() + music:GetDuration())
			end
		end
	end
end)