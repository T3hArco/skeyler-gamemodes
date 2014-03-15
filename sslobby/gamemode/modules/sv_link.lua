local storedTriggers = {}

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:AddServerTrigger(id)
	storedTriggers[id] = {players = {}, queue = {}, sending = false, map = nil}
	
	-- FIX THIS LATER
	if (id == 1) then
		storedTriggers[id].ip = game.IsDedicated() and "208.115.236.184" or "192.168.1.152"
		storedTriggers[id].dataPort = 40001
		storedTriggers[id].connectPort = 27015
	--elseif (id == 2) then
		--storedTriggers[id].ip = "208.115.236.184"
		--storedTriggers[id].dataPort = 40002
		--storedTriggers[id].connectPort = 27016
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:AddPlayerInfo(id, unique, info)
	local data = storedTriggers[id]
	
	if (data) then
		data.players[unique] = data.players[unique] or info
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lkngtpl")
util.AddNetworkString("ss.lkngtplr")

function SS.Lobby.Link:AddQueue(id, player)
	local screen = SS.Lobby.Link:GetScreenByID(id)
	
	if (screen:GetStatus() != STATUS_LINK_UNAVAILABLE) then
		-- Remove the player from a previous screen.
		for id2, data in pairs(storedTriggers) do
			if (id != id2) then
				SS.Lobby.Link:RemoveQueue(id2, player)
			end
		end
		
		local data = storedTriggers[id]
		
		if (data) then
			local hasPlayer = self:HasQueue(id, player)
			
			if (!hasPlayer) then
				table.insert(data.queue, player)
				
				local steamID = player:SteamID()
				
				net.Start("ss.lkngtpl")
					net.WriteUInt(id, 8)
					net.WriteString(steamID)
				net.Broadcast()
				
				print("Added player '" .. tostring(player) .. "' from trigger: " .. id .. ".")
			end
		else
			print("Missing server trigger: " .. id .. "??")
		end
	end
end

net.Receive("ss.lkngtplr", function(bits, player)
	local id = net.ReadUInt(8)
	local hasQueue = SS.Lobby.Link:HasQueue(id, player)

	if (!hasQueue) then
		SS.Lobby.Link:AddQueue(id, player)
	else
		SS.Lobby.Link:RemoveQueue(id, player)
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lknrmpl")

function SS.Lobby.Link:RemoveQueue(id, player)
	local data = storedTriggers[id]
	
	if (data) then
		local hasPlayer, index = self:HasQueue(id, player)
		
		if (hasPlayer) then
			table.remove(data.queue, index)
			
			local steamID = player:SteamID()
			
			net.Start("ss.lknrmpl")
				net.WriteUInt(id, 8)
				net.WriteString(steamID)
			net.Broadcast()
			
			print("Removed player '" .. tostring(player) .. "' from trigger: " .. id .. ".")
		end
	else
		print("Missing server trigger: " .. id .. "??")
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:HasQueue(id, player)
	local data = storedTriggers[id]
	
	if (data) then
		for i = 1, #data.queue do
			local info = data.queue[i]
			
			if (player == info) then
				return true, i
			end
		end
	else
		print("Missing server trigger: " .. id .. "??")
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:GetScreenByID(id)
	local screens = self:GetScreens()
	
	for k, screen in pairs(screens) do
		if (screen:GetTriggerID() == id) then
			return screen
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:GetScreens()
	local screens = ents.FindByClass("info_sass_screen")
	
	return screens
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:GetQueue(id)
	return storedTriggers[id].queue
end

---------------------------------------------------------
--
---------------------------------------------------------

local nextTick = 0

hook.Add("Tick", "SS.Lobby.Link", function()
	if (nextTick <= CurTime()) then
		for id, data in pairs(storedTriggers) do
			local count = #data.queue
			local screen = SS.Lobby.Link:GetScreenByID(id)
			
			if (count >= SS.Lobby.Link.MinPlayers) then
				if (!data.sending) then
					data.sending = true
	
					screen:SetStatus(STATUS_LINK_PREPARING)
					
					local id = id
					
					timer.Create("SS.Lobby.Link.Send." .. id, 4, 1, function()
						if (data.sending) then
							local data = storedTriggers[id]
							local pitch, position = math.random(85, 110), screen:GetPos()
					
							for i = 1, 5 do
								sound.Play("vo/k_lab/kl_initializing02.wav", position, 75, pitch, 1)
							end
							
							for i = 1, #data.queue do
								local player = data.queue[i]
								
								if (IsValid(player)) then
									player:Freeze(true)
								end
							end
							
							local send = {}

							for i = 1, math.min(#data.queue, SS.Lobby.Link.MaxPlayers) do
								local player = data.queue[i]
	
								if (IsValid(player)) then
								
									-- priority on vip?
									table.insert(send, player)
								end
							end
							
							local authed = {}
							
							for i = 1, #send do
								local player = send[i]
	
								if (IsValid(player)) then
									local steamID = player:SteamID()
									
									table.insert(authed, steamID)
								end
							end
							
							socket.Send(data.ip, data.dataPort, "spl", function(data)
								authed = util.Compress(von.serialize(authed))
								
								return data .. authed
							end)
							
							timer.Simple(4.5, function()
								if (data.sending) then
									local data = storedTriggers[id]
									PrintTable(send)
									for i = 1, #send do
										local player = send[i]
										
										if (IsValid(player)) then
											SS.Lobby.Link:RemoveQueue(id, player)
											
											player:SendLua("LocalPlayer():ConCommand(\"connect " .. tostring(data.ip) .. ":" .. data.connectPort .. "\")")
										end
									end
									
									screen:SetStatus(STATUS_LINK_IN_PROGRESS)
									
									-- we need to unfreeze players that didnt make it
									for i = 1, #data.queue do
										local player = data.queue[i]
										
										if (IsValid(player)) then
											player:Freeze(false)
										end
									end
								end
							end)
						end
					end)
				end
			else
				if (data.sending and screen:GetStatus() != STATUS_LINK_IN_PROGRESS) then
					data.sending = false

					screen:SetStatus(STATUS_LINK_READY)
					
					for i = 1, #data.queue do
						local player = data.queue[i]
						
						if (IsValid(player)) then
							player:Freeze(false)
						end
					end
					
					timer.Remove("SS.Lobby.Link.Send." .. id)
				end
			end
		end
		
		nextTick = CurTime() +0.5
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lbgtscr")

net.Receive("ss.lbgtscr", function(bits, player)
	local id = net.ReadUInt(8)
	local data = storedTriggers[id]
	
	if (data and data.map) then
		net.Start("ss.lbgtsmap")
			net.WriteUInt(id, 8)
			net.WriteString(data.map)
		net.Send(player)
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lbgtssin")

socket.AddCommand("sif", function(sock, ip, port, data)
	data = von.deserialize(util.Decompress(data[1]))

	local count = table.Count(data)

	net.Start("ss.lbgtssin")
		net.WriteUInt(data.server, 8)
		net.WriteUInt(count, 8)
		
		for k, info in pairs(data) do
			if (k != "server") then
				net.WriteUInt(info.id, 8)
				net.WriteString(info.name)
				net.WriteUInt(info.food, 16)
				net.WriteUInt(info.iron, 16)
				net.WriteUInt(info.gold, 16)
			end
		end
	net.Broadcast()
end)

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.gtminmp")

socket.AddCommand("smp", function(sock, ip, port, data)
	local server = tonumber(data[1])
	local data = util.Decompress(data[2])
	local exploded = string.Explode("id=", data)
	
	if (exploded[1] == "") then table.remove(exploded, 1) end
	
	local final = {}
	
	for k, v in pairs(exploded) do
		local id = string.sub(v, 1, 1)

		final[id] = {units = {}, buildings = {}}
		
		local units =  string.match(v, "u{(.*)}b")
		units = string.Explode("|", units)
		
		if (units[1] == "") then table.remove(units, 1) end
		
		for k, info in pairs(units) do
			local data = string.Explode(",", info)

			final[id].units[k] = {}

			for k2, v2 in pairs(data) do
				local key, value = string.match(v2, "(.+)=(.+)")

				final[id].units[k][key] = tonumber(value)
			end
		end
		
		local buildings =  string.match(v, "b{(.*)}")
		buildings = string.Explode("|", buildings)
		
		if (buildings[1] == "") then table.remove(buildings, 1) end
		
		for k, info in pairs(buildings) do
			local data = string.Explode(",", info)
			
			final[id].buildings[k] = {}
			
			for k2, v2 in pairs(data) do
				local key, value = string.match(v2, "(.+)=(.+)")
				
				final[id].buildings[k][key] = tonumber(value)
			end
		end
	end
	
	local finalCount = table.Count(final)

	net.Start("ss.gtminmp")
		net.WriteUInt(server, 8)
		net.WriteUInt(finalCount, 8)
		
		for id, data in pairs(final) do
			local unitCount = table.Count(data.units)
			
			net.WriteUInt(id, 8)
			net.WriteUInt(unitCount, 8)
			
			for k, v in pairs(data.units) do
				net.WriteUInt(v.x, 16)
				net.WriteUInt(v.y, 16)
				net.WriteUInt(v.dx, 16)
				net.WriteUInt(v.dy, 16)
				net.WriteUInt(v.s, 8)
			end
			
			local buildingCount = table.Count(data.buildings)
			
			net.WriteUInt(buildingCount, 8)
			
			for k, v in pairs(data.buildings) do
				net.WriteUInt(v.x, 16)
				net.WriteUInt(v.y, 16)
				net.WriteUInt(v.s, 8)
			end
		end
	net.Broadcast()
end)

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lbgtsmap")

socket.AddCommand("smap", function(sock, ip, port, data)
	local id = tonumber(data[1])
	local map = data[2]

	local screen = SS.Lobby.Link:GetScreenByID(id)
	screen:SetStatus(STATUS_LINK_READY)

	storedTriggers[id].map = map
	
	net.Start("ss.lbgtsmap")
		net.WriteUInt(id, 8)
		net.WriteString(map)
	net.Broadcast()
end)