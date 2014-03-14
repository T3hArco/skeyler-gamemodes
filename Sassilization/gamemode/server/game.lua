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

function GM:EndGame( empire )
	if !gameOver then
		local randTitle = math.random(1, #Titles)
		for k,v in pairs(Titles) do
			if k == randTitle then
				if empire:GetPlayer() and empire:GetPlayer().Alliance then
					if #empire:GetPlayer().Alliance == 0 then
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
				if empire:GetPlayer() and empire:GetPlayer().Alliance then
					if #empire:GetPlayer().Alliance == 0 then
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
		if empire:GetPlayer() then
			if empire:GetPlayer().Alliance then
				allyTable = empire:GetPlayer().Alliance
			end
		end
		for _, pl in pairs( player.GetAll() ) do
			net.Start("SetWinners")
				net.WriteString(empire:Nick())
				net.WriteTable(allyTable)
				net.WriteString(randTitle)
				net.WriteString(randDesc)
			net.Send(pl)
		end
		gameOver = true
		timer.Simple(SA.INTERMISSION, function()
			self:RestartGame(MAPS.GetNextMap())
		end)
	end
end

function GM:RestartGame(NextMap)
	if(SA.DEV) then
		return
	end

	for k,v in pairs(player.GetAll()) do
		v:ConCommand("connect 208.115.236.184:40000")
	end
	
	game.ConsoleCommand( "changelevel "..NextMap.."\n" )

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