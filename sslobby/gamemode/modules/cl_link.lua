-- make this a local
storedTriggers = storedTriggers or {}

---------------------------------------------------------
-- Adding a screen.
---------------------------------------------------------

function SS.Lobby.Link:AddScreen(id)
	storedTriggers[id] = {
		map = surface.GetTextureID("sassilization/minimaps/sa_angelsarena"),
		chat = {},
		players = {},
		minimap = {}
	}
	
	for i = 1, 14 do
		local unit = math.random(0, 1) == 1
		
		table.insert(storedTriggers[id].minimap, {x = math.random(0, 333), y = math.random(0, 334), width = unit and 3 or 8, height = unit and 3 or 8, unit = unit,color = Color(math.random(0,255), math.random(0,255), math.random(0,255)), dirx=math.random(0,332),diry=math.random(100,300)})
	end
end

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
		local full = #data.players >= SS.Lobby.Link.MaxPlayers
		
		if (!full) then
			local hasPlayer = SS.Lobby.Link:HasPlayer(id, steamID)
			
			if (!hasPlayer) then
				table.insert(data.players, steamID)
				
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
		local hasPlayer, index = SS.Lobby.Link:HasPlayer(id, steamID)
		
		if (hasPlayer) then
			table.remove(data.players, index)
			
			print("Removed player '" .. tostring(steamID) .. "' from trigger: " .. id .. ".")
		end
	else
		print("Missing server trigger: " .. id .. "??")
	end
end)

---------------------------------------------------------
-- Checks if a screen/trigger has the player.
---------------------------------------------------------

function SS.Lobby.Link:HasPlayer(id, steamID)
	local data = storedTriggers[id]
	
	if (data) then
		for i = 1, #data.players do
			local info = data.players[i]
			
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

function SS.Lobby.Link:GetPlayers(id)
	return storedTriggers[id].players
end