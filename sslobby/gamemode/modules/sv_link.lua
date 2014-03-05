-- make this a local
storedTriggers = storedTriggers or {}

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:AddServerTrigger(id)
	storedTriggers[id] = {players = {}, queue = {}, sending = false}
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

net.Receive("ss.lkngtplr", function(bits, player)
	local id = net.ReadUInt(8)
	
	SS.Lobby.Link:AddQueue(id, player)
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

function SS.Lobby.Link:GetTriggerByID(id)
	local triggers = self:GetTriggers()
	
	for k, trigger in pairs(triggers) do
		if (trigger.id == id) then
			return trigger
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:GetTriggers()
	local triggers = ents.FindByClass("trigger_server_sass")
	
	return triggers
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
			
			if (count >= SS.Lobby.Link.MinPlayers) then
				if (!data.sending) then
					data.sending = true
				
					local screen = SS.Lobby.Link:GetScreenByID(id)
					screen:SetStatus(STATUS_LINK_PREPARING)
					
					timer.Create("SS.Lobby.Link.Send." .. id, 4, 1, function()
						if (data.sending) then
							local pitch, position = math.random(85, 110), screen:GetPos()
					
							for i = 1, 5 do
								sound.Play("vo/k_lab/kl_initializing02.wav", position, 75, pitch, 1)
							end
							
							for i = 1, count do
								local player = data.queue[i]
								
								player:Freeze(true)
							end
					
							timer.Simple(4.5, function()
								if (data.sending) then
									local send = {}
									
									print("SENDING")
									
									for i = 1, count do
										local player = data.queue[i]
	
										-- priority on vip?
										table.insert(send, player)
									end
									
									-- send here
									
									-- we need to unfreeze players that didnt make it
									for i = 1, count do
										local player = data.queue[i]
										
										player:Freeze(false)
									end
								end
							end)
						end
					end)
				end
			else
				if (data.sending) then
					data.sending = false
					
					local screen = SS.Lobby.Link:GetScreenByID(id)
					screen:SetStatus(STATUS_LINK_READY)
					
					for i = 1, count do
						local player = data.queue[i]
						
						player:Freeze(false)
					end
					
					timer.Remove("SS.Lobby.Link.Send." .. id)
				end
			end
		end
		
		nextTick = CurTime() +0.5
	end
end)

concommand.Add("cn",function()
socket.SetupHost("62.220.184.236", 58017)
socket.AddAllowedClient("62.220.184.236")
socket.AddAllowedClient("192.168.1.1")
socket.Connect("62.220.184.236", 58015)
end)
---------------------------------------------------------
--
---------------------------------------------------------

socket.AddCommand("sassinfo", function(sock, ip, port, buffer, errorCode)
	local _, data = buffer:Read(buffer:Size())
	
	data = util.Decompress(data)
	
	--[[
	local _, id = buffer:ReadShort()
	local _, unique = buffer:ReadShort()
	local _, name = buffer:ReadString()
	local _, food = buffer:ReadLong()
	local _, gold = buffer:ReadLong()
	local _, iron = buffer:ReadLong()
	local _, cities = buffer:ReadLong()
	
	
	local info = {
		unique = unique,
		name = name,
		food = food,
		gold = gold,
		iron = iron,
		cities = cities
	}
	
	SS.Lobby.Link:AddPlayerInfo(id, unique, info)
	]]
end)

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.gtminmp")

socket.AddCommand("sassmap", function(sock, ip, port, buffer, errorCode)
	local _, data = buffer:Read(buffer:Size())
	
	data = util.Decompress(data)
	
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
	
	net.Start("ss.gtminmp")
		for id, data in pairs(final) do
			local unitCount = table.Count(data.units)
			
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
	
	PrintTable(final)
end)