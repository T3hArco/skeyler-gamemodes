local stored = {}

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.LeaderBoard.Add(id, data)
	stored[id] = stored[id] or {}
	
	table.insert(stored[id], data)
	
	table.sort(stored[id], function(a, b) return a.wins > b.wins end)
end

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lblbnw")

function SS.Lobby.LeaderBoard.Network(id, player)
	local data = stored[id]
	
	if (data) then
		net.Start("ss.lblbnw")
			net.WriteUInt(id, 8)
			net.WriteUInt(#data, 8)
			
			for i = 1, #data do
				local info = data[i]
				
				net.WriteString(info.name)
				net.WriteUInt(info.empires, 16)
				net.WriteUInt(info.hours, 16)
				net.WriteUInt(info.games, 16)
				net.WriteUInt(info.wins, 16)
			end
		if (IsValid(player)) then net.Send(player) else net.Broadcast() end
	end
end

local names = {"Bentech", "Smitty", "GodKnows", "Chewgum", "FireKnight", "Snoipa", "Dick", "Sassafrass", "Dick ranger", "Evil Cyb0rg"}

for i = 1, 5 do
	local data = {
		name = names[i],
		empires = math.random(1, 1024),
		hours = math.random(1, 1024),
		games = math.random(1, 1024),
		wins = math.random(1, 1024)
	}
	
	SS.Lobby.LeaderBoard.Add(LEADERBOARD_WEEKLY, data)
end

for i = 1, 10 do
	local data = {
		name = names[i],
		empires = math.random(1, 1024),
		hours = math.random(1, 1024),
		games = math.random(1, 1024),
		wins = math.random(1, 1024)
	}
	
	SS.Lobby.LeaderBoard.Add(LEADERBOARD_MONTHLY, data)
end

for i = 1, 3 do
	local data = {
		name = names[i],
		empires = math.random(1, 1024),
		hours = math.random(1, 1024),
		games = math.random(1, 1024),
		wins = math.random(1, 1024)
	}
	
	SS.Lobby.LeaderBoard.Add(LEADERBOARD_DAILY, data)
end


for i = 1, 10 do
	local data = {
		name = names[i],
		empires = math.random(1, 1024),
		hours = math.random(1, 1024),
		games = math.random(1, 1024),
		wins = math.random(1, 1024)
	}
	
	SS.Lobby.LeaderBoard.Add(LEADERBOARD_ALLTIME_10, data)
end
