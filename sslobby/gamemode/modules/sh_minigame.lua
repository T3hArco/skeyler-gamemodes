SS.Lobby.Minigame = {}

AccessorFunc(SS.Lobby.Minigame, "CurrentGame", "CurrentGame", FORCE_STRING)

SS.Lobby.Minigame.Scores = {}

SS.Lobby.Minigame.Scores[TEAM_RED] = math.random(1, 20)
SS.Lobby.Minigame.Scores[TEAM_BLUE] = math.random(1, 20)
SS.Lobby.Minigame.Scores[TEAM_GREEN] = math.random(1, 20)
SS.Lobby.Minigame.Scores[TEAM_YELLOW] = math.random(1, 20)

local stored = {}

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:GetStored()
	return stored
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:Get(unique)
	return stored[unique]
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:GetScores()
	return self.Scores
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame.Call(name, ...)
	local current = SS.Lobby.Minigame:GetCurrentGame()
	
	if (current) then
		local data = stored[current]
		
		if (data) then
			local callback = data[name]
			
			if (callback) then
				local a, b, c, d, e, f, g = callback(data, ...)
				
				return a, b, c, d, e, f, g
			end
		else
			ErrorNoHalt("Missing function \"" .. name .. "\" for minigame \"" .. current .. "\".\n")
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function PLAYER_META:IsPlayingMinigame()
	return self:GetNetworkedBool("ss.playingminigame", false)
end

---------------------------------------------------------
--
---------------------------------------------------------

local _, folders = file.Find(GM.FolderName .. "/gamemode/minigames/*", "LUA")

for k, folder in pairs(folders) do
	MINIGAME = {}
	
	if (SERVER) then
		AddCSLuaFile(GM.FolderName .. "/gamemode/minigames/" .. folder .. "/shared.lua")
		AddCSLuaFile(GM.FolderName .. "/gamemode/minigames/" .. folder .. "/cl_init.lua")
		
		include(GM.FolderName .. "/gamemode/minigames/" .. folder .. "/init.lua")
	end
	
	if (CLIENT) then
		include(GM.FolderName .. "/gamemode/minigames/" .. folder .. "/cl_init.lua")
	end
	
	include(GM.FolderName .. "/gamemode/minigames/" .. folder .. "/shared.lua")
	
	stored[MINIGAME.Unique] = MINIGAME
	
	MINIGAME = nil
end 

local istable = istable

local function getData(destination, data)
	for k, v in pairs(data) do
		if (istable(v) and istable(destination[k])) then
			getData(destination[k], v)
		else
			if (destination[k] == nil) then
				destination[k] = v
			end
		end
	end
end

local function derive(unique, from)
	local base = stored[from]

	if (base.Base and !base.derived) then
		derive(base.unique, base.Base)
	end
	
	getData(stored[unique], base)
	
	stored[unique].derived = true
	stored[unique].BaseClass = base
end

for unique, data in pairs(stored) do
	if (data.Base) then
		derive(unique, data.Base)
	end
end