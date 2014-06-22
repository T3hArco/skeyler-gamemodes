--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

util.AddNetworkString( "SetWinners" )

function GM:StartGame()
	if(self.Started) then
		return
	end
	self.Started = true
	self.StartTime = tostring(os.time())
	
	--for k,v in pairs(self.Players) do
	--	v = true
	--end
	
	--PrintTable(self.Players)
	
	for k,v in pairs(player.GetAll()) do
		v:UnLock()
		v:Spawn()
	end
	
	timer.Create("UpdateResources", 10, 0, function() self:UpdateResources() end )
	
	if(SA.DEV) then
		return
	end
	
	--timer.Create("UpdateMinimapBuildings", 20, 0, self.UpdateMinimapBuildings, self)
	--timer.Create("UpdateMinimapUnits", 20, 0, self.UpdateMinimapUnits, self)
end

function GM:UpdateResources()
	
	for _, empire in pairs(empire.GetAll()) do
		if(empire:GetCities() > 0 or empire:GetFarms() > 0 or (empire:GetCities() == 0 and empire:GetFood() < 50)) then
			empire:AddFood( empire:GetFoodIncome() )
		end
		if(empire:GetCities() > 0 or empire:GetMines() > 0 or (empire:GetCities() == 0 and empire:GetIron() < 50)) then
			empire:AddIron( empire:GetIronIncome() )
		end
		empire:AddGold( empire:GetGoldIncome() )
		if( IsValid( empire:GetPlayer() ) ) then
			empire:GetPlayer():SetFrags( empire:GetGold() )
		end
	end
	self:CheckGame()
	
end

function GM:CheckGame()
	if(SA.DEV) then
		return
	end

	for _, empire1 in pairs(empire.GetAll()) do
		local Amount = empire1:GetGold()
		if(Amount >= SA.WIN_LIMIT) then
			self:EndGame(empire1)
			return
		elseif(Amount >= SA.WIN_GOAL_MIN) then
			local CanWin = true
			for _, otherEmpire in pairs(empire.GetAll()) do
				if(empire1 ~= otherEmpire and empire1:GetPlayer() and empire1:GetPlayer().Alliance and otherEmpire:GetPlayer() and otherEmpire:GetPlayer().Alliance and !Allied(empire1, otherEmpire)) then
					if(Amount - otherEmpire:GetGold() < SA.WIN_LEAD) then
						CanWin = false
						break
					end
				end
			end
			if(CanWin) then
				self:EndGame( empire1 )
				return
			end
		end
	end
end

function GM:EndGame( empireWin )
	if !gameOver then
		local randTitle = math.random(1, #Titles)
		for k,v in pairs(Titles) do
			if k == randTitle then
				if empireWin:GetPlayer() and empireWin:GetPlayer().Alliance then
					if #empireWin:GetPlayer().Alliance == 0 then
						randTitle = v[1]
					else
						randTitle = v[2]
					end
				else
					randTitle = v[1]
				end
			end
		end

		local randDesc = math.random(1, #Description)
		for k,v in pairs(Description) do
			if k == randDesc then
				if empireWin:GetPlayer() and empireWin:GetPlayer().Alliance then
					if #empireWin:GetPlayer().Alliance == 0 then
						randDesc = v[1]
					else
						randDesc = v[2]
					end
				else
					randTitle = v[1]
				end
			end
		end

		local allyTable = {}
		empireWin.win = true
		if empireWin:GetPlayer() then
			if empireWin:GetPlayer().Alliance then
				allyTable = empireWin:GetPlayer().Alliance
			end
		end
		for _, pl in pairs( player.GetAll() ) do
			net.Start("SetWinners")
				net.WriteString(empireWin:Nick())
				net.WriteTable(allyTable)
				net.WriteString(randTitle)
				net.WriteString(randDesc)
			net.Send(pl)
		end

		for k,v in pairs(allyTable) do
			v:GetEmpire().win = true
		end
		gameOver = true
		self.EndTime = tostring(os.time())

		DB_Query("INSERT INTO rts_matches (playerCount, startTimestamp, endTimestamp) VALUES ('"..tostring(#empire.GetAll()).."','"..self.StartTime.."','"..self.EndTime.."')", 
			function(data)
				DB_Query("SELECT ID FROM rts_matches WHERE endTimestamp='"..self.EndTime.."'",
					function(data)
						local gameID = data[1].ID
						for k,v in pairs(empire.GetAll()) do
							DB_Query("SELECT ID FROM users WHERE steamId='"..string.sub(v.SteamID, 7).."'",
								function(data)
									local playerID = data[1].ID
									DB_Query("SELECT ID FROM rts_leaderboards WHERE userId='"..playerID.."'",
										function(data)
											if data[1].games != nil then
												DB_Query("SELECT games, wins, gamesMonthly, winsMonthly, gamesWeekly, winsWeekly, gamesDaily, winsDaily FROM rts_leaderboards WHERE userId='"..playerID.."'",
													function(data)
														if v.win then
															DB_Query("UPDATE rts_leaderboards SET games=".. data[1].games + 1 ..", wins=".. data[1].wins + 1 ..", gamesMonthly=".. data[1].gamesMonthly + 1 ..", winsMonthly=".. data[1].winsMonthly + 1 ..", gamesWeekly=".. data[1].gamesWeekly + 1 ..", winsWeekly=".. data[1].winsWeekly + 1 ..", gamesDaily=".. data[1].gamesDaily + 1 ..", winsDaily=".. data[1].winsDaily + 1 .." WHERE userId='"..playerID.."'")
														else
															DB_Query("UPDATE rts_leaderboards SET games=".. data[1].games + 1 ..", gamesMonthly=".. data[1].gamesMonthly + 1 ..", gamesWeekly=".. data[1].gamesWeekly + 1 ..", gamesDaily=".. data[1].gamesDaily + 1 .." WHERE userId='"..playerID.."'")
														end
													end)
											else
												if v.win then
													DB_Query("INSERT INTO rts_leaderboards VALUES ('"..playerID.."','1','1','1','1','1','1','1','1')")
												else
													DB_Query("INSERT INTO rts_leaderboards VALUES ('"..playerID.."','1','0','1','0','1','0','1','0')")
												end
											end
										end)

									if v.win then
										DB_Query("INSERT INTO rts_match_players (rtsMatchId, userId, wonMatch) VALUES ('"..tostring(gameID).."','"..tostring(playerID).."','"..tostring(1).."')")
									else
										DB_Query("INSERT INTO rts_match_players (rtsMatchId, userId, wonMatch) VALUES ('"..tostring(gameID).."','"..tostring(playerID).."','"..tostring(0).."')")
									end

									for i,d in pairs(v.spawns) do
										DB_Query("INSERT INTO rts_constructions (rtsMatchId, rtsMatchPlayerId, constructionTypeId, amountBuilt) VALUES ('"..tostring(gameID).."','"..tostring(playerID).."','"..tostring(i).."','"..tostring(d).."')")
									end
								end)
						end
					end)
			end)

		timer.Simple(SA.INTERMISSION, function()
			self:RestartGame(MAPS.GetNextMap())
		end)
	end
end

util.AddNetworkString("sa.connectlobby")

function GM:RestartGame(NextMap)
	if(SA.DEV) then
		return
	end

	for k,v in pairs(player.GetAll()) do
		net.Start("sa.connectlobby")
		net.Send(v)
	end
	
	timer.Simple(5, function()
		game.ConsoleCommand( "changelevel "..NextMap.."\n" )
	end)

	/*
	gatekeeper.DropAllClients("Join Lobby to Play Again")
	
	local Info = [[RETURNINGPLAYERS:]]..SERVERID..[[|TICKETS = {]]
	for k,v in pairs(player.GetAll()) do 
		local tid = 0
		for _, ticket in pairs( TICKETS ) do
			if ticket.ip == pl:IPAddress() then
				tid = ticket.team
			end
		end
		info = info..[[{]]
		info = info..[[name = "]]..tmysql.escape(string.gsub( pl:GetName(), "|", "" ))..[[",]]
		info = info..[[ip = "]]..pl:IPAddress()..[[",]]
		info = info..[[team = ]]..tid
		if _ == #player.GetAll() then info = info..[[}]] else info = info..[[},]] end
		v:SendLua("LocalPlayer():ConCommand('connect "..LOBBYIP..":"..LOBBYPORT.."')")
	end
	info = info..[[}]]
	tcpSend(LOBBYIP,DATAPORT,info.."\n")
	ResetPassword()
	
	if not NEXTMAP then
		NEXTMAP = MAPS.GetNextMap()
	end
	if not (NEXTMAP and NEXTMAP ~= "") then
		NEXTMAP = game.GetMap()
	end
	
	timer.Simple( 1, function( level )
		for _, pl in pairs( player.GetAll() ) do
			game.ConsoleCommand( "kickid "..pl:UserID() )
			game.ConsoleCommand( "kickid "..pl:UserID() )
		end
		game.ConsoleCommand( "changelevel "..level.."\n" )
	end, NEXTMAP )
	*/
	
end