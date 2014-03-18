local storedTriggers = {}

local colorTable = {
	Color(200, 60, 60, 255),     -- Red
	Color(90, 90, 90, 255),     -- Grey
	Color(45, 150, 140, 255),     -- Torquise
	Color(150, 150, 45, 255),     -- Yellow
	Color(200, 60, 165, 255),     -- Pink
	Color(100, 37, 125, 255),     -- Purple
	Color(60, 77, 201, 255),     -- Blue
	Color(100, 75, 30, 255),     -- Brown
	Color(60, 160, 50, 255),     -- Green | The ones from this point on are overflow in case someone leaves the game and we need another color for a new player
	Color(180, 204, 137, 255),	-- Olive | The reason I copy pasted old ones was so that there are colors for people to go to without any problems, this is just temporarily for the dedicated server without the Lobby.
	Color(255, 159, 51, 255),	-- Orange
	Color(93, 255, 77, 255), 	-- Bright Green
	Color(255, 179, 252, 255),	-- Bubblegum
	Color(128, 42, 42, 255),	-- Maroon
	Color(237, 237, 66, 255),	-- Bright Yellow
	Color(200, 0, 200, 255),     -- Magenta
	Color(200, 200, 0, 255),     -- Yellow
	Color(0, 200, 200, 255),     -- Cyan
	Color(255, 140, 50, 255),    -- Orange
	Color(100, 0, 200, 255),     -- Purple
	Color(0, 128, 128, 255),     -- Teal
	Color(100, 64, 0, 255),      -- Brown
	Color(255, 255, 0, 255)     -- Pineapple Yellow (LuaPineapple Only) wtf?
}

---------------------------------------------------------
-- Adding a screen.
---------------------------------------------------------

function SS.Lobby.Link:AddScreen(id)
	storedTriggers[id] = {
		map = nil,
		queue = {},
		players = {},
		minimap = {}
	}
end
	
---------------------------------------------------------
-- 
---------------------------------------------------------

function SS.Lobby.Link:GetScreen(id)
	return storedTriggers[id]
end

---------------------------------------------------------
-- Resets a screen.
---------------------------------------------------------

net.Receive("ss.lbgtsrs", function(bits)
	local server = net.ReadUInt(8)
	
	storedTriggers[id].map = nil
	storedTriggers[id].players = {}
	storedTriggers[id].minimap = {}
end)

---------------------------------------------------------
--
---------------------------------------------------------

net.Receive("ss.lbgtsmap", function(bits)
	local server = net.ReadUInt(8)
	local map = net.ReadString()
	
	storedTriggers[server] = {
		map = surface.GetTextureID("sassilization/minimaps/" .. map),
		queue = {},
		players = {},
		minimap = {}
	}
end)

---------------------------------------------------------
--
---------------------------------------------------------

net.Receive("ss.lbgtssin", function(bits)
	local server = net.ReadUInt(8)
	local count = net.ReadUInt(8)
	
	storedTriggers[server].players = {}
	
	for i = 1, count do
		local teamID = net.ReadUInt(8)
		local name = net.ReadString()
		local food = net.ReadUInt(16)
		local iron = net.ReadUInt(16)
		local gold = net.ReadUInt(16)
		
		table.insert(storedTriggers[server].players, {teamID = teamID, name = name, gold = gold, food = food, iron = iron})
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

net.Receive("ss.gtminmp", function(bits)
	local server = net.ReadUInt(8)
	local finalCount = net.ReadUInt(8)
	
	storedTriggers[server].minimap = {}
	
	for i = 1, finalCount do
		local colorID = net.ReadUInt(8)
		local unitCount = net.ReadUInt(8)
		
		local color = colorTable[colorID]
		
		for i = 1, unitCount do
			local x = net.ReadUInt(16)
			local y = net.ReadUInt(16)
			local dx = net.ReadUInt(16)
			local dy = net.ReadUInt(16)
			local size = net.ReadUInt(8)
		
			table.insert(storedTriggers[server].minimap, {x = x, y = y, dirx = dx, diry = dy, width = size, height = size, unit = true, color = color})
		end
		
		local buildingCount = net.ReadUInt(8)
		
		for i = 1, buildingCount do
			local x = net.ReadUInt(16)
			local y = net.ReadUInt(16)
			local size = net.ReadUInt(8)
		
			table.insert(storedTriggers[server].minimap, {x = x, y = y, width = size, height = size, color = color})
		end
	end
end)

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
	
	return false
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