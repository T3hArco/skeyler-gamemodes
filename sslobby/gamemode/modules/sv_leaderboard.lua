local stored = {}

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.LeaderBoard.Add(id, data)
	stored[id] = stored[id] or {}
	
	table.insert(stored[id], data)
	
	table.sort(stored[id], function(a, b) return a.wins > b.wins end)
end


function SS.Lobby.LeaderBoard.Update()
	--Clear the table before inserting new values
	stored = {}

	DB_Query("SELECT userId, gamesWeekly, winsWeekly FROM rts_leaderboards WHERE gamesWeekly>0 ORDER BY winsWeekly DESC LIMIT 5", function(data)
		for k,v in pairs(data) do
			DB_Query("SELECT name FROM users WHERE id='".. data[k].userId .."'", function(data2)
				local info = {
					name = data2[1].name,
					empires = 0,
					hours = 0,
					games = data[k].gamesWeekly,
					wins = data[k].winsWeekly
				}
				
				SS.Lobby.LeaderBoard.Add(LEADERBOARD_WEEKLY, info)
			end)
		end
	end)

	DB_Query("SELECT userId, gamesMonthly, winsMonthly FROM rts_leaderboards WHERE gamesMonthly>0 ORDER BY winsMonthly DESC LIMIT 10", function(data)
		for k,v in pairs(data) do
			DB_Query("SELECT name FROM users WHERE id='".. data[k].userId .."'", function(data2)
				local info = {
					name = data2[1].name,
					empires = 0,
					hours = 0,
					games = data[k].gamesMonthly,
					wins = data[k].winsMonthly
				}
				
				SS.Lobby.LeaderBoard.Add(LEADERBOARD_MONTHLY, info)
			end)
		end
	end)

	DB_Query("SELECT userId, gamesDaily, winsDaily FROM rts_leaderboards WHERE gamesDaily>0 ORDER BY winsDaily DESC LIMIT 3", function(data)
		for k,v in pairs(data) do
			DB_Query("SELECT name FROM users WHERE id='".. data[k].userId .."'", function(data2)
				local info = {
					name = data2[1].name,
					empires = 0,
					hours = 0,
					games = data[k].gamesDaily,
					wins = data[k].winsDaily
				}
				
				SS.Lobby.LeaderBoard.Add(LEADERBOARD_DAILY, info)
			end)
		end
	end)

	DB_Query("SELECT userId, games, wins FROM rts_leaderboards WHERE games>0 ORDER BY wins DESC LIMIT 10", function(data)
		for k,v in pairs(data) do
			DB_Query("SELECT name FROM users WHERE id='".. data[k].userId .."'", function(data2)
				local info = {
					name = data2[1].name,
					empires = 0,
					hours = 0,
					games = data[k].games,
					wins = data[k].wins
				}
				
				SS.Lobby.LeaderBoard.Add(LEADERBOARD_ALLTIME_10, info)
			end)
		end
	end)
	
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
	else
		net.Start("ss.lblbnw")
			net.WriteUInt(id, 8)
			net.WriteUInt(0, 8)
		if (IsValid(player)) then net.Send(player) else net.Broadcast() end
	end
end