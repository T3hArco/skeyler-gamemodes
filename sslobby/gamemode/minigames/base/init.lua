MINIGAME.Time = 60

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Initialize()
	self.players = {}
	self.spawnPoints = {}
	
	local spawnPoints = ents.FindByClass("info_player_spawn")
	
	for k, entity in pairs(spawnPoints) do
		if (entity.minigames) then
			if (entity.team) then
				for k2, unique in pairs(entity.minigames) do
					if (unique == self.Unique) then
						self.spawnPoints.team = self.spawnPoints.team or {}
						
						local teamID
					
						if (entity.team == "blue") then
							teamID = TEAM_BLUE
						elseif (entity.team == "red") then
							teamID = TEAM_RED
						elseif (entity.team == "green") then
							teamID = TEAM_GREEN
						elseif (entity.team == "orange") then
							teamID = TEAM_ORANGE
						end
						
						self.spawnPoints.team[teamID] = self.spawnPoints.team[teamID] or {}
					
						table.insert(self.spawnPoints.team[teamID], entity)
					end
				end
			else
				for k2, unique in pairs(entity.minigames) do
					if (unique == self.Unique) then
						table.insert(self.spawnPoints, entity)
					end
				end
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Start()
	local String = self.Name.." - "..self.Description
	for k, player in pairs(self.players) do
		player:ChatPrint(String)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Finish(timeLimit)
	local players = self:GetPlayers()

	self.players = {}
	
	for k, player in pairs(player.GetAll()) do
		player:SetNetworkedBool("ss.playingminigame", false)
		player.minigame = nil
	end

	for k, player in pairs(players) do
		self:RespawnPlayer(player)
	end
	
	if (!timeLimit) then
		SS.Lobby.Minigame:FinishGame()
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:RemovePlayer(player, noRespawn)
	for k, v in pairs(self.players) do
		if (v == player) then
			self.players[k] = nil
			
			v:SetNetworkedBool("ss.playingminigame", false)
			v.minigame = nil

			if (!noRespawn) then
				self:RespawnPlayer(player)
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:RespawnPlayer(player)
	player.leavingMinigame = true
	local spawnPoint = hook.Run("PlayerSelectSpawn", player)
	
	player:SetNetworkedBool("ss.playingminigame", false)
	player.minigame = nil

	player:Spawn()
	player:SetPos(spawnPoint:GetPos())
	player:SetEyeAngles(spawnPoint:GetAngles()) 
	
	if (player:IsBot()) then
		player:Freeze(true)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Think()
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:KeyPress(player, key)
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:DoPlayerDeath(victim, inflictor, dmginfo)
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:CanPlayerSlap(player, target, nextSlap)
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

function MINIGAME:CanPlayerSuicide(player)
	return true
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:PlayerLoadout(player)
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

function MINIGAME:GetSpawnPoints(player)
	if (self.spawnPoints.team) then
		local teamID = player:Team()
		
		return self.spawnPoints.team[teamID]
	else
		return self.spawnPoints
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:AnnounceWin(player)
	if (IsValid(player)) then
		local teamID = player:Team()
		
		if (teamID > TEAM_READY) then
			local nick = player:Nick()
			local teamName = team.GetName(teamID)
			
			SS.Lobby.Minigame:AddScore(teamID, 1)
			
			util.PrintAll("[MINIGAME] " .. nick .. " has won the game for the " .. teamName .. " team!")
		end
	else
		local teams = {}
		
		for k, player in pairs(self.players) do
			if (IsValid(player)) then
				local id = player:Team()
				local exists = false
				
				for i = 1, #teams do
					if (teams[i].id == id) then
						exists = true
						
						break
					end
				end
				
				if (!exists) then
					table.insert(teams, {id = id, players = {}})
				end
				
				for i = 1, #teams do
					if (teams[i].id == id) then
						table.insert(teams[i].players, player)
					end
				end
			end
		end
		
		if (#teams == 1) then
			local players = teams[1].players
			local teamName = team.GetName(teams[1].id)
			
			if (#players > 1) then
				util.PrintAll("[MINIGAME] The " .. teamName .. " team has won the game!")
			else
				local nick = players[1]:Nick()
	
				util.PrintAll("[MINIGAME] " .. nick .. " has won the game for the " .. teamName .. " team!")
			end
			
			SS.Lobby.Minigame:AddScore(teams[1].id, 1)
			
			return true
		end
		
		return false
	end
end