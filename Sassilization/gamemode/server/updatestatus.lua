LOBBY_IP = "192.168.1.152"
LOBBY_PORT = 40000

---------------------------------------------------------
--
---------------------------------------------------------

function GM:SocketConnected(ip, port, buffer)
	local id = self.ServerID
	local map = game.GetMap()

	socket.Send(LOBBY_IP, LOBBY_PORT, "smap", function(buffer)
		buffer:WriteShort(id)
		buffer:WriteString(map)
	end)
end

---------------------------------------------------------
--
---------------------------------------------------------

function GM:UpdateScoreboard()
	local data = {server = self.ServerID}
	local empires = empire.GetAll()
	
	for k, empire in pairs(empires) do
		if (ValidEmpire(empire)) then
			local id = empire:GetColorID()
			local name = empire:GetName()
			local cities = empire:GetCities()
			local food = empire:GetFood()
			local iron = empire:GetIron()
			local gold = empire:GetGold()

			table.insert(data, {id = id, name = name, cities = cities, food = food, iron = iron, gold = gold})
		end
	end

	data = von.serialize(data)
	data = util.Compress(data)

	socket.Send(LOBBY_IP, LOBBY_PORT, "sif", function(buffer)
		buffer:Write(data)
	end)
end

timer.Create("SA.UpdateScoreboard", 10, 0, function()
	if (GAMEMODE.Started) then
		GAMEMODE:UpdateScoreboard()
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

function GM:UpdateMinimap()
	local data = ""
	local empires = empire.GetAll()
	
	local world = game.GetWorld()
	local saveTable = world:GetSaveTable()
	local mins, maxs = saveTable.m_WorldMins, saveTable.m_WorldMaxs
	
	local x = math.abs(maxs.x)
	local y = math.abs(mins.y)

	for k, empire in pairs(empires) do
		if (ValidEmpire(empire)) then
			data = data .. "id=" .. empire:GetColorID() .. "u{"
			
			local units = empire:GetUnits()
			local buildings = empire:GetBuildings()

			for k, unit in pairs(units) do
				if (unit and unit:IsValid()) then
					local position = unit:GetPos()
					local direction = unit.targetPosition or position
					
					local positionX = math.Round((math.abs(position.x) /x) *359)
					local positionY = math.Round((math.abs(position.y) /y) *360)
					
					local size = math.Round(math.ceil(unit.OBBMaxs.x *0.8))
					local directionX = math.Round((math.abs(direction.x) /x) *359)
					local directionY = math.Round((math.abs(direction.y) /y) *360)

					data = data .. "|x=" .. positionX .. ",y=" .. positionY .. ",dx=" .. directionX .. ",dy=" .. directionY .. ",s=" .. size
				end
			end
			
			data = data .. "}b{"
			
			for k, building in pairs(buildings) do
				if (building and building:IsValid()) then
					local position = building:GetPos()
					
					local positionX = math.Round((math.abs(position.x) /x) *359)
					local positionY = math.Round((math.abs(position.y) /y) *360)
					
					local size = math.Round(math.ceil(building:OBBMaxs().x *0.4))
					
					data = data .. "|x=" .. positionX .. ",y=" .. positionY .. ",s=" .. size
				end
			end
		end
		
		data = data .. "}"
	end
	
	data = util.Compress(data)
	
	socket.Send(LOBBY_IP, LOBBY_PORT, "smp", function(buffer)
		buffer:WriteShort(self.ServerID)
		buffer:Write(data)
	end)
end

timer.Create("SA.UpdateMinimap", 20, 0, function()
	if (GAMEMODE.Started) then
		GAMEMODE:UpdateMinimap()
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

socket.AddCommand("spl", function(sock, ip, port, buffer, errorCode)
	local _, data = buffer:Read(buffer:Size())
	
	data = util.Decompress(data)
	data = von.deserialize(data)
	
	SA.AuthedPlayers = data
end)








--[[ THIS IS VERY OLD CODE
function GM:UpdateScoreboard()
	
	if game.SinglePlayer() then return end
	if not START or ENDROUND then return end
	if not SERVERID then return end
	
	local players = player.GetAll()
	table.sort(players, function( a, b ) return math.Round(a:GetNWInt("_gold")) > math.Round(b:GetNWInt("_gold")) end)
	
	--Send the scoreboard information to the lobby
	local info = 'LEADERBOARD:'..SERVERID..'|SCORES = {'
	for _, pl in pairs(players) do
		if IsValid(pl) and pl:IsPlayer() and pl.MyColor then
			info = info..'{'
			info = info..'n="'..tmysql.escape(string.gsub( pl:GetName(), "|", "" ))..'",'
			info = info..'c={r='..pl.MyColor[1].r..',g='..pl.MyColor[1].g..',b='..pl.MyColor[1].b..'},'
			info = info..'g='..math.Round(pl:GetNWInt("_gold"))..','
			info = info..'f='..math.Round(pl:GetNWInt("_food"))..','
			info = info..'i='..math.Round(pl:GetNWInt("_iron"))..','
			info = info..'ci='..math.Round(pl:GetNWInt("_cities"))..','
			info = info..'cr='..math.Round(pl:GetNWInt("_spirits"))..','
			info = info..'s='..math.Round(pl:GetNWInt("_shrines"))..','
			info = info..'fa='..math.Round(pl:GetNWInt("_farms"))..','
			info = info..'mi='..math.Round(pl:GetNWInt("_mines"))..','
			info = info..'u='..pl:GetNWInt("_soldiers")
			if _ == #players then info = info..'}' else info = info..'},' end
		end
	end
	info = info..'}'
	tcpSend(LOBBYIP,DATAPORT,info.."\n","Scoreboard Updated")
	
end

function GM:UpdateMinimapBuildings()
	
	if game.SinglePlayer() then return end
	if not START or ENDROUND then return end
	if not SERVERID then return end
	
	if not MINIMAPS then return end
	if MINIMAPS[game.GetMap()] then
		local map = MINIMAPS[game.GetMap()]
		local info = 'MINIMAP:'..SERVERID..'|bldg|DATA = {'
		local bldgs = ents.FindByClass("bldg_*")
		for _, ent in pairs(bldgs) do
			local r,g,b,a = ent:GetColor()
			ent.lastAttacked = ent.lastAttacked == 1 and 1 or 0
			info = info..'{'
			info = info..'i='..ent:EntIndex()..','
			info = info..'s="'..math.ceil(ent:OBBMaxs().x*map.Scale)..'",'
			info = info..'c={r='..r..',g='..g..',b='..b..',a='..a..'},'
			info = info..'a='..ent.lastAttacked..','
			info = info..'x='..math.Round((ent:GetPos().x-map.Origin.x)*map.Scale)..','
			info = info..'y='..math.Round((map.Origin.y-ent:GetPos().y)*map.Scale)
			if _ == #bldgs then info = info..'}' else info = info..'},' end
			ent.lastAttacked = 0
		end
		info = info..'}'
		tcpSend(LOBBYIP,DATAPORT,info.."\n","Minimap Buildings Updated")
	end
end

function GM:UpdateMinimapUnits()
	
	if game.SinglePlayer() then return end
	if not START or ENDROUND then return end
	if not SERVERID then return end
	
	if not MINIMAPS then return end
	if MINIMAPS[game.GetMap()] then
		local map = MINIMAPS[game.GetMap()]
		local info = 'MINIMAP:'..SERVERID..'|unit|DATA = {'
		local units = ents.FindByClass("unit_*")
		for _, ent in pairs(units) do
			if ent:GetEmpire() and ent:GetEmpire():GetPlayer():IsPlayer() then
				local r,g,b,a = ent:GetEmpire():GetColor()
				local pos = ent:GetPos()
				ent.lastAttacked = ent.lastAttacked == 1 and 1 or 0
				ent.lastPos = ent.lastPos or {x=pos.x,y=pos.y}
				info = info..'{'
				info = info..'i='..ent:EntIndex()..','
				info = info..'s="'..math.ceil(ent:OBBMaxs().x*map.Scale)..'",'
				info = info..'c={r='..r..',g='..g..',b='..b..',a='..a..'},'
				info = info..'a='..ent.lastAttacked..','
				info = info..'px='..math.Round((ent.lastPos.x-map.Origin.x)*map.Scale)..','
				info = info..'py='..math.Round((map.Origin.y-ent.lastPos.y)*map.Scale)..','
				info = info..'x='..math.Round((pos.x-map.Origin.x)*map.Scale)..','
				info = info..'y='..math.Round((map.Origin.y-pos.y)*map.Scale)
				if _ == #units then info = info..'}' else info = info..'},' end
				ent.lastAttacked = 0
				ent.lastPos = {x=pos.x,y=pos.y}
			end
		end
		info = info..'}'
		tcpSend(LOBBYIP,DATAPORT,info.."\n","Minimap Units Updated")
	end
end
]]