-- make this a local
storedTriggers = storedTriggers or {}

---------------------------------------------------------
-- Adding a screen.
---------------------------------------------------------

function SS.Lobby.Link:AddScreen(id)
	storedTriggers[id] = {
		map = surface.GetTextureID("sassilization/minimaps/sa_orbit"),
		chat = {},
		queue = {},
		players = {},
		minimap = {}
	}
	for i =1, math.random(1,8) do
		storedTriggers[id].players[i] = {name = "Chewgum",gold=math.random(1,500),food=math.random(1,500),iron=math.random(1,550)}
	end
end

net.Receive("ss.gtminmp", function(bits)
	local unitCount = net.ReadUInt(8)
	
	storedTriggers[1].minimap = {}
	
	for i = 1, unitCount do
		local x = net.ReadUInt(16)
		local y = net.ReadUInt(16)
		local dx = net.ReadUInt(16)
		local dy = net.ReadUInt(16)
		local size = net.ReadUInt(8)

		table.insert(storedTriggers[1].minimap, {x = x, y = y, dirx = dx, diry = dy, width = size, height = size, unit = true, color = Color(math.random(0,255), math.random(0,255), math.random(0,255))})
	end
	
	local buildingCount = net.ReadUInt(8)
	
	for i = 1, buildingCount do
		local x = net.ReadUInt(16)
		local y = net.ReadUInt(16)
		local size = net.ReadUInt(8)
		print(x,y,size)
		table.insert(storedTriggers[1].minimap, {x = x, y = y, width = size, height = size, color = Color(math.random(0,255), math.random(0,255), math.random(0,255))})
	end
end)
	
---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:GetScreen(id)
	return storedTriggers[id]
end

---------------------------------------------------------
-- Adding a player from a screen/trigger.
---------------------------------------------------------

net.Receive("ss.lkngtpl", function(bits)
	local id = net.ReadUInt(8)
	local steamID = net.ReadString()
	
	local data = storedTriggers[id]
	
	if (data) then
		local full = #data.queue >= SS.Lobby.Link.MaxPlayers
		
		if (!full) then
			local hasPlayer = SS.Lobby.Link:HasQueue(id, steamID)
			
			if (!hasPlayer) then
				table.insert(data.queue, steamID)
				
				print("Added player '" .. tostring(steamID) .. "' from trigger: " .. id .. ".")
			end
		end
	else
		print("Missing server trigger: " .. id .. "??")
	end
end)

---------------------------------------------------------
-- Removing a player from a screen/trigger.
---------------------------------------------------------

net.Receive("ss.lknrmpl", function(bits)
	local id = net.ReadUInt(8)
	local steamID = net.ReadString()
	
	local data = storedTriggers[id]
	
	if (data) then
		local hasPlayer, index = SS.Lobby.Link:HasQueue(id, steamID)
		
		if (hasPlayer) then
			table.remove(data.queue, index)
			
			print("Removed player '" .. tostring(steamID) .. "' from trigger: " .. id .. ".")
		end
	else
		print("Missing server trigger: " .. id .. "??")
	end
end)

---------------------------------------------------------
-- Checks if a screen/trigger has the player.
---------------------------------------------------------

function SS.Lobby.Link:HasQueue(id, steamID)
	local data = storedTriggers[id]
	
	if (data) then
		for i = 1, #data.queue do
			local info = data.queue[i]
			
			if (steamID == info) then
				return true, i
			end
		end
	else
		print("Missing server trigger: " .. id .. "??")
	end
end

---------------------------------------------------------
-- Returns all the players in a screen/trigger.
---------------------------------------------------------

function SS.Lobby.Link:GetQueue(id)
	return storedTriggers[id].queue
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:GetPlayerInfo(id)
	return storedTriggers[id].players
end