-- make this a local
storedTriggers = storedTriggers or {}

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Link:AddServerTrigger(id)
	storedTriggers[id] = {players = {}, sending = false}
end

---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lkngtpl")

function SS.Lobby.Link:AddPlayer(id, player)
	local data = storedTriggers[id]
	
	if (data) then
		local hasPlayer = self:HasPlayer(id, player)
		
		if (!hasPlayer) then
			table.insert(data.players, player)
			
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
 
---------------------------------------------------------
--
---------------------------------------------------------

util.AddNetworkString("ss.lknrmpl")

function SS.Lobby.Link:RemovePlayer(id, player)
	local data = storedTriggers[id]
	
	if (data) then
		local hasPlayer, index = self:HasPlayer(id, player)
		
		if (hasPlayer) then
			table.remove(data.players, index)
			
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

function SS.Lobby.Link:HasPlayer(id, player)
	local data = storedTriggers[id]
	
	if (data) then
		for i = 1, #data.players do
			local info = data.players[i]
			
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

function SS.Lobby.Link:GetPlayers(id)
	return storedTriggers[id].players
end

---------------------------------------------------------
--
---------------------------------------------------------

local nextTick = 0

hook.Add("Tick", "SS.Lobby.Link", function()
	if (nextTick <= CurTime()) then
		for id, data in pairs(storedTriggers) do
			local count = #data.players
			
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
								local player = data.players[i]
								
								player:Freeze(true)
							end
					
							timer.Simple(4.5, function()
								if (data.sending) then
									local send = {}
									
									print("SENDING")
									
									for i = 1, count do
										local player = data.players[i]
	
										-- priority on vip?
										table.insert(send, player)
									end
									
									-- send here
									
									-- we need to unfreeze players that didnt make it
									for i = 1, count do
										local player = data.players[i]
										
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
						local player = data.players[i]
						
						player:Freeze(false)
					end
					
					timer.Remove("SS.Lobby.Link.Send." .. id)
				end
			end
		end
		
		nextTick = CurTime() +0.5
	end
end)