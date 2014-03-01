local queue = {}
local queueTime = CurTime()

local gameIndex = 0
local storedSequential = {}

for unique, minigame in pairs(SS.Lobby.Minigame:GetStored()) do
	if (unique != "base" and !minigame.Disabled) then
		table.insert(storedSequential, minigame)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lbmggtim")

function SS.Lobby.Minigame:SetCurrentGame(unique)
	local minigame = SS.Lobby.Minigame:Get(unique)
	
	queueTime = CurTime() +minigame.Time
	
	self.CurrentGame = unique
	
	self.Call("Start")
	
	self:UpdateScreen()
	self:SendQueueTime()
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
		self:ShiftGame()
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lbmgup")

function SS.Lobby.Minigame:UpdateScreen(player)
	local current = self:GetCurrentGame()
	
	net.Start("ss.lbmgup")
		net.WriteString(current)
		
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
	self.Scores[teamID] = self.Scores[teamID] +score
	
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
		
		-- add vip time
		
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

function SS.Lobby.Minigame:SendQueueTime(player)
	net.Start("ss.lbmggtim")
		net.WriteFloat(queueTime)
	if (IsValid(player)) then net.Send(player) else net.Broadcast() end
end

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("Think", "SS.Lobby.Minigame", function()
	if (queueTime <= CurTime()) then
		SS.Lobby.Minigame.Call("Finish")
		
		SS.Lobby.Minigame:ShiftGame()
	end
	
	SS.Lobby.Minigame.Call("Think")
end)

SS.Lobby.Minigame:ShiftGame()