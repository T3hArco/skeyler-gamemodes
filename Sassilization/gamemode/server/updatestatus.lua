LOBBY_IP = "63.143.48.134"
LOBBY_PORT = 40000

---------------------------------------------------------
--
---------------------------------------------------------

function GM:SocketConnected(ip, port, data)
	local id = self.ServerID
	local map = game.GetMap()

	socket.Send(LOBBY_IP, LOBBY_PORT, "smap", function(data)
		return data .. self.ServerID .. "*&*" .. map
	end)
end

---------------------------------------------------------
--
---------------------------------------------------------

function GM:UpdateScoreboard()
	local info = {server = self.ServerID}
	local empires = empire.GetAll()
	
	for k, empire in pairs(empires) do
		if (ValidEmpire(empire)) then
			local id = empire:GetColorID()
			local name = empire:GetName()
			local cities = empire:GetCities()
			local food = empire:GetFood()
			local iron = empire:GetIron()
			local gold = empire:GetGold()

			table.insert(info, {id = id, name = name, cities = cities, food = food, iron = iron, gold = gold})
		end
	end

	info = util.Compress(von.serialize(info))

	socket.Send(LOBBY_IP, LOBBY_PORT, "sif", function(data)
		return data .. info
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

local maps = {}

maps["sa_exodus"] = 	{origin = Vector(1301, 1301, 0), 	rotation = Angle(0, -90, 0), 	scale_x = 0.134, 	scale_y = 0.135}
maps["sa_stronghold"] = {origin = vector_origin, 			rotation = Angle(0, -90, 0), 	scale_x = -0.33, 	scale_y = -0.164}
maps["sa_orbit"] = 		{origin = Vector(-90, 100, 0), 		rotation = Angle(0, 180, 0), 	scale_x = -0.201, 	scale_y = -0.206}
maps["sa_olympia"] = 	{origin = Vector(774, 1484, 0), 	rotation = Angle(0, -90, 0), 	scale_x = 0.141, 	scale_y = 0.141}

function GM:UpdateMinimap()
	local info = ""
	local empires = empire.GetAll()
	local map = maps[game.GetMap()]
	
	for k, empire in pairs(empires) do
		if (ValidEmpire(empire)) then
			info = info .. "id=" .. empire:GetColorID() .. "u{"
			
			local units = empire:GetUnits()
			local buildings = empire:GetBuildings()

			for k, unit in pairs(units) do
				if (unit and unit:IsValid()) then
					local origin = unit:GetPos()
					
					local position = Vector(origin.x -map.origin.x, map.origin.y -origin.y, origin.z)
					local direction = unit.targetPosition and unit.targetPosition:Copy() or position:Copy()
					
					if (unit.targetPosition) then
						direction.x = direction.x -map.origin.x
						direction.y = map.origin.y -direction.y
					end
					
					position:Rotate(map.rotation)
					direction:Rotate(map.rotation)
					
					local x, y = position.x *map.scale_x, position.y *map.scale_y
					local size = math.Round(math.ceil(unit.OBBMaxs.x *0.8))
					local directionX, directionY = direction.x *map.scale_x, direction.y *map.scale_y
					
					info = info .. "|x=" .. x .. ",y=" .. y .. ",dx=" .. directionX .. ",dy=" .. directionY .. ",s=" .. size
				end
			end
			
			info = info .. "}b{"
			
			for k, building in pairs(buildings) do
				if (building and building:IsValid()) then
					local origin = building:GetPos()
					
					local position = Vector(origin.x -map.origin.x, map.origin.y -origin.y, origin.z)
					position:Rotate(map.rotation)

					local x, y = position.x *map.scale_x, position.y *map.scale_y
					local size = math.Round(math.ceil(building:OBBMaxs().x *0.4))
					
					info = info .. "|x=" .. x .. ",y=" .. y .. ",s=" .. size
				end
			end
		end
		
		info = info .. "}"
	end
	
	info = util.Compress(info)
	
	socket.Send(LOBBY_IP, LOBBY_PORT, "smp", function(data)
		return data .. self.ServerID .. "*&*" .. info
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

socket.AddCommand("spl", function(sock, ip, port, data)
	data = von.deserialize(util.Decompress(data[1]))

	SA.AuthedPlayers = data
end)

---------------------------------------------------------
--
---------------------------------------------------------

socket.AddCommand("lm", function(sock, ip, port, data)
	local id = GAMEMODE.ServerID
	local map = game.GetMap()

	socket.Send(ip, port, "smap", function(data)
		return data .. GAMEMODE.ServerID .. "*&*" .. map
	end)
end)

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("InitPostEntity", "SA.SetupSocket", function()
	local ip = game.IsDedicated() and "63.143.48.134" or "192.168.1.152"
	local port = socket.GetServerPort()
	
	local dataPort
	
	if (port == 27015) then
		dataPort = 40001
		
		GAMEMODE.ServerID = 1
	elseif (port == 27016) then
		dataPort = 40002
		
		GAMEMODE.ServerID = 2
	elseif (port == 27018) then
		dataPort = 40003
		
		GAMEMODE.ServerID = 3
	elseif (port == 27019) then
		dataPort = 40004
		
		GAMEMODE.ServerID = 4
	end
	
	timer.Simple(5,function()
		socket.SetupHost(ip, dataPort)
		
		timer.Simple(2,function()
			socket.AddServer(LOBBY_IP, LOBBY_PORT)
		end)
	end)
end)