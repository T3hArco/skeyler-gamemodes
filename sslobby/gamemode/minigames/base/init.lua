MINIGAME.Time = 10
MINIGAME.Disabled = false

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Initialize()
	self.players = {}
	self.spawnPoints = {}
	
	local spawnPoints = ents.FindByClass("info_player_spawn")
	
	for k, entity in pairs(spawnPoints) do
		if (entity.minigames) then
			for k2, unique in pairs(entity.minigames) do
				if (unique == self.Unique) then
					table.insert(self.spawnPoints, entity)
				end
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Start()
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Finish(timeLimit)
	local players = self:GetPlayers()

	for k, player in pairs(players) do
		self:RespawnPlayer(player)
	end
	
	self.players = {}
	
	if (!timeLimit) then
		SS.Lobby.Minigame:ShiftGame()
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:RemovePlayer(player)
	for k, v in pairs(self.players) do
		if (v == player) then
			table.remove(self.players, k)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:RespawnPlayer(player)
	local spawnPoint = hook.Run("PlayerSelectSpawn", player)
	
	player:Spawn()
	player:SetPos(spawnPoint:GetPos())
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Think()
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:PlayerDeath(victim, inflictor, attacker)
print(self.Name)
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:CanPlayerSlap(player, target, nextSlap)
	return nextSlap
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:PlayerSlap(player, target, nextSlap)
	return nextSlap
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:HasRequirements(players, teams)
	return true
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:GetPlayers()
	return self.players
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:HasPlayer(player)
	local players = self:GetPlayers()
	
	for k, v in pairs(players) do
		if (v == player) then
			return true
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:GetSpawnPoints()
	return self.spawnPoints
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:AnnounceWin(player)
	local teamID = player:Team()
	
	if (teamID > TEAM_READY) then
		local nick = player:Nick()
		local teamName = team.GetName(teamID)
		
		SS.Lobby.Minigame:AddScore(teamID, 1)
		
		util.PrintAll("[MINIGAME] " .. nick .. " has won the game for team " .. teamName .. "!")
	end
end