local stored = {}

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.LeaderBoard.Add(id, data)
	stored[id] = stored[id] or {}
	
	table.insert(stored[id], data)
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.LeaderBoard.Get(id)
	return stored[id]
end

---------------------------------------------------------
--
---------------------------------------------------------

net.Receive("ss.lblbnw", function(bits)
	local id = net.ReadUInt(8)
	local length = net.ReadUInt(8)

	--Clear the table for this type when networking everything new in
	stored[id] = {}
	
	for i = 1, length do
		local name = net.ReadString()
		local empires = net.ReadUInt(16)
		local hours = net.ReadUInt(16)
		local games = net.ReadUInt(16)
		local wins = net.ReadUInt(16)
		
		local data = {
			name = name,
			empires = empires,
			hours = hours,
			games = games,
			wins = wins
		}
		
		SS.Lobby.LeaderBoard.Add(id, data)
	end
end)