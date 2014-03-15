local queue = {}
local gameTime, queueTime = CurTime(), CurTime()

local gameIndex = 0
local storedSequential = {}

for unique, minigame in pairs(SS.Lobby.Minigame.GetStored()) do
	if (unique != "base" and !minigame.Disabled) then
		table.insert(storedSequential, minigame)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lbmggtim")

function SS.Lobby.Minigame:SetCurrentGame(unique)
	local minigame = SS.Lobby.Minigame.Get(unique)

	gameTime = CurTime() +minigame.Time
	
	self.CurrentGame = unique

	local players = minigame:GetPlayers()

	for i = 1, #players do
		local player = players[i]
		
		if (IsValid(player)) then
			local spawnPoint = hook.Run("PlayerSelectSpawn", player, minigame)
			
			player:Freeze(true)
			player:KillSilent()
			player:SetNetworkedBool("ss.playingminigame", true)
			player.minigame = minigame
			player:Spawn()
			player:Freeze(false)
			
			hook.Run("PlayerLoadout", player)
		end
	end

	self.Call("Start")
	
	self:UpdateScreen()
	self:SendQueueTime(nil, true)
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:ShiftGame()
	gameIndex = gameIndex +1
	
	if (gameIndex > #storedSequential) then
		gameIndex = 1
	end

	local minigame = storedSequential[gameIndex]

	local players = {}
	local teamAmount = 0

	for i = TEAM_RED, TEAM_ORANGE do
		local found = false
		local teamPlayers = team.GetPlayers(i)
		
		for k, player in pairs(teamPlayers) do
			if (IsValid(player)) then
				local inQueue = self:HasPlayer(player)
				
				if (inQueue) then
					found = true
					
					table.insert(players, player)
				end
			end
		end
		
		if (found) then
			teamAmount = teamAmount +1
		end
	end
	
	table.sort(players, function(a, b) return a.minigameTime < b.minigameTime end)
	
	local hasRequirements = minigame:HasRequirements(#players, teamAmount)
	
	if (hasRequirements) then
		minigame.players = players

		self:SetCurrentGame(minigame.Unique)
	else
		queueTime = CurTime() +10
		
		self:SendQueueTime(nil, false)
		
		Msg("[MINIGAME] The minigame '" .. minigame.Name .. "' did not meet its requirements.\n")
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lbmgup")

function SS.Lobby.Minigame:UpdateScreen(player)
	local current = self:GetCurrentGame()
	
	net.Start("ss.lbmgup")
		net.WriteString(current or "")
		
		for teamID, score in pairs(self.Scores) do
			net.WriteUInt(score, 8)
		end
	if (IsValid(player)) then net.Send(player) else net.Broadcast() end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:SetScore(teamID, score)
	self.Scores[teamID] = score
	
	self:UpdateScreen()
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:AddScore(teamID, amount)
	self.Scores[teamID] = self.Scores[teamID] +amount
	
	self:UpdateScreen()
end

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lbmgtpl")

function SS.Lobby.Minigame:AddPlayer(player)
	local hasPlayer = self:HasPlayer(player)
	
	if (!hasPlayer) then
		player.minigameTime = CurTime()
		
		if (player:GetRank() >= 1) then
			player.minigameTime = player.minigameTime -20
		end
		
		table.insert(queue, player)
		
		net.Start("ss.lbmgtpl")
			net.WriteBit(true)
		net.Send(player)
		
		print("Added player '" .. tostring(player) .. "' to minigame queue.")
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:RemovePlayer(player)
	local hasPlayer, index = self:HasPlayer(player)

	if (hasPlayer) then
		table.remove(queue, index)
		
		net.Start("ss.lbmgtpl")
			net.WriteBit(false)
		net.Send(player)
		
		print("Removed player '" .. tostring(player) .. "' from minigame queue.")
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:HasPlayer(player)
	for i = 1, #queue do
		local info = queue[i]
		
		if (player == info) then
			return true, i
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:SendQueueTime(player, inProgress)
	net.Start("ss.lbmggtim")
		net.WriteFloat(gameTime and gameTime or queueTime)
		net.WriteBit(inProgress)
	if (IsValid(player)) then net.Send(player) else net.Broadcast() end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:FinishGame()
	gameTime, queueTime = nil, CurTime() +10
	
	SS.Lobby.Minigame:SendQueueTime(nil, false)
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame:CallWithPlayer(name, player, ...)
	local minigame = self:GetCurrentGame()
	
	minigame = SS.Lobby.Minigame.Get(minigame)
	
	if (minigame) then
		local hasPlayer = minigame:HasPlayer(player)
		
		if (hasPlayer) then
			local a, b, c, d, e = SS.Lobby.Minigame.Call(name, player, ...)
			
			if (a != nil) then
				return a, b, c, d, e
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame.BestAutoJoinTeam(prefer)
	local teams = team.GetAllTeams()
	local selected = prefer
	local preferAmount = team.NumPlayers(prefer)
	
	-- Check if the prefered team has more players than any other.
	for id, _ in pairs(teams) do
		if (id >= TEAM_RED and id <= TEAM_ORANGE) then
			local amount = team.NumPlayers(id)
			
			if (preferAmount > amount) then
				selected = id
			end
		end
	end
	
	-- If it does, select the smallest.
	if (selected != prefer) then
		local smallestTeam = TEAM_RED
		local smallestPlayers = 1000
		
		for id, tm in pairs(teams) do
			if (id >= TEAM_RED and id <= TEAM_ORANGE) then
				local count = team.NumPlayers(id)
				
				if (count < smallestPlayers or (count == smallestPlayers and id < smallestTeam)) then
					smallestTeam = id
					smallestPlayers = count
				end
			end
		end
	
		selected = smallestTeam
	end
	
	return selected
end

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lbmgjt")

net.Receive("ss.lbmgjt", function(bits, player)
	local id = net.ReadUInt(8)
	local autoJoin = SS.Lobby.Minigame.BestAutoJoinTeam(id)
	
	if (autoJoin != id) then
		player:ChatPrint("That team is full so we placed you on the " .. team.GetName(autoJoin) .. " team instead!")
		
		player:SetTeam(autoJoin)
	else
		player:SetTeam(id)
		
		player:ChatPrint("You have joined the " .. team.GetName(autoJoin) .. " team!")
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("Think", "SS.Lobby.Minigame", function()
	if (gameTime and gameTime <= CurTime()) then
		gameTime, queueTime = nil, CurTime() +10

		SS.Lobby.Minigame.Call("Finish", true)
		SS.Lobby.Minigame:SendQueueTime(nil, false)
	end
	
	if (queueTime and queueTime <= CurTime()) then
		queueTime = nil
		
		SS.Lobby.Minigame:ShiftGame()
	end
	
	SS.Lobby.Minigame.Call("Think")
end)

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("InitPostEntity", "SS.Lobby.Minigame", function()
	for i = 1, #storedSequential do
		local minigame = storedSequential[i]
		
		minigame:Initialize()
	end
	
	timer.Simple(1, function() SS.Lobby.Minigame:ShiftGame() end)
end)