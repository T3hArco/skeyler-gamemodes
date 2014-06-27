SS.Lobby.Minigame = {}

AccessorFunc(SS.Lobby.Minigame, "CurrentGame", "CurrentGame", FORCE_STRING)

SS.Lobby.Minigame.Scores = {}

SS.Lobby.Minigame.Scores[TEAM_RED] = 0
SS.Lobby.Minigame.Scores[TEAM_BLUE] = 0
SS.Lobby.Minigame.Scores[TEAM_GREEN] = 0
SS.Lobby.Minigame.Scores[TEAM_ORANGE] = 0

local stored = {}

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame.GetStored()
	return stored
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame.Get(unique)
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

-- Split up the description text.
local maxLength = 66

for unique, data in pairs(stored) do
	if (data.Base) then
		derive(unique, data.Base)
		
		local length = string.len(data.Description)
		
		if (length > maxLength) then
			local exploded, current, final = string.Explode(" ", data.Description), 1, ""
			
			for i = 1, #exploded do
				local text = table.concat(exploded, " ", current, i)
				
				if (string.len(text) > maxLength) then
					final = final .. table.concat(exploded, " ", current, i -1) .. "\n"
					
					current = i
				else
					if (i == #exploded) then
						final = final .. text
					end
				end
			end
			
			data.Description = final
		end
	end
end