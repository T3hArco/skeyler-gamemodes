--          _   _                  _           _   
--     /\  | | | |                | |         | |  
--    /  \ | |_| | __ _ ___    ___| |__   __ _| |_ 
--   / /\ \| __| |/ _` / __|  / __| '_ \ / _` | __|
--  / ____ \ |_| | (_| \__ \ | (__| | | | (_| | |_ 
-- /_/    \_\__|_|\__,_|___/  \___|_| |_|\__,_|\__|
--                                                 
--                                                 
-- © 2014 metromod.net do not share or re-distribute
-- without permission of its author (Chewgum - chewgumtj@gmail.com).
--

atlaschat = atlaschat or {}

AddCSLuaFile("sh_utilities.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("cl_expression.lua")
AddCSLuaFile("cl_theme.lua")
AddCSLuaFile("cl_panel.lua")

include("sh_utilities.lua")
include("sh_config.lua")
include("cl_theme.lua") -- Nothing is actually used serverside.

resource.AddFile("materials/atlaschat/emoticons/overrustle.png")
resource.AddFile("materials/atlaschat/emoticons/garry.png")
resource.AddFile("materials/atlaschat/emoticons/gaben.png")

---------------------------------------------------------
-- Create the atlaschat sql tables.
---------------------------------------------------------

hook.Add("Initialize", "atlaschat.Initialize", function()
	local exists = sql.TableExists("atlaschat_players")
	
	if (!exists) then
		sql.Query("CREATE TABLE atlaschat_players(id INTEGER NOT NULL PRIMARY KEY, steamID TEXT DEFAULT \"\" NOT NULL, title TEXT DEFAULT \"\" NOT NULL)")
	end
	
	local exists = sql.TableExists("atlaschat_ranks")

	atlaschat.ranks = {}
	
	if (!exists) then
		sql.Query("CREATE TABLE atlaschat_ranks(id INTEGER NOT NULL PRIMARY KEY, usergroup TEXT DEFAULT \"\" NOT NULL, icon TEXT DEFAULT \"\" NOT NULL)")
	else
		local query = sql.Query("SELECT * FROM atlaschat_ranks")
		
		if (query) then
			for i = 1, #query do
				local data = query[i]
				
				atlaschat.ranks[data.usergroup] = data.icon
			end
		end
	end
end)

---------------------------------------------------------
-- Player connect message.
---------------------------------------------------------

util.AddNetworkString("atlaschat.plcnt")

gameevent.Listen("player_connect")

hook.Add("player_connect", "atlaschat.PlayerConnect", function(data)
	net.Start("atlaschat.plcnt")
		net.WriteString(data.name)
		net.WriteString(data.networkid)
	net.Broadcast()
end)

---------------------------------------------------------
-- Loading a players data.
---------------------------------------------------------

util.AddNetworkString("atlaschat.plload")

net.Receive("atlaschat.plload", function(bits, player)
	local loaded = player.atlaschatLoaded
	
	if (!loaded) then
		local steamID = sql.SQLStr(player:SteamID())
		local query = sql.Query("SELECT * FROM atlaschat_players WHERE steamID=" .. steamID)
		
		if (query == nil) then
			sql.Query("INSERT INTO atlaschat_players(id, steamID) VALUES(NULL, " .. steamID .. ")")
		else
			query = query[1]
		
			if (query.title and query.title != "") then
				player:SetNetworkedString("ac_title", query.title)
			end
		end
		
		timer.Simple(0.2, function()
			if (IsValid(player)) then
				atlaschat.config.SyncVariables(player)
			end
		end)
		
		for unique, icon in pairs(atlaschat.ranks) do
			net.Start("atlaschat.crtrnkgt")
				net.WriteString(unique)
				net.WriteString(icon)
			net.Send(player)
		end
		
		player.atlaschatLoaded = true
	end
end)

---------------------------------------------------------
-- Setting a players title.
---------------------------------------------------------

util.AddNetworkString("atlaschat.stplttl")

net.Receive("atlaschat.stplttl", function(bits, player)
	local isAdmin = player:IsSuperAdmin()
	
	if (isAdmin) then
		local target = net.ReadString()
		
		target = util.FindPlayerAtlaschat(target, player)
		
		if (IsValid(target)) then
			local title = net.ReadString()
			local steamID = sql.SQLStr(target:SteamID())
			
			target:SetNetworkedString("ac_title", title)
			
			sql.Query("UPDATE atlaschat_players SET title=" .. sql.SQLStr(title) .. " WHERE steamID=" .. steamID)
		end
	end
end)

---------------------------------------------------------
-- Creating a new rank.
---------------------------------------------------------

util.AddNetworkString("atlaschat.crtrnk")
util.AddNetworkString("atlaschat.crtrnkex")
util.AddNetworkString("atlaschat.crtrnkgt")

net.Receive("atlaschat.crtrnk", function(bits, player)
	local isAdmin = player:IsSuperAdmin()
	
	if (isAdmin) then
		local userGroup = net.ReadString()
		
		if (atlaschat.ranks[userGroup] != nil) then
			atlaschat.Notify(":exclamation: Could not create the rank: The rank already exist!", player)
		else
			atlaschat.ranks[userGroup] = "icon16/user.png"
			
			sql.Query("INSERT INTO atlaschat_ranks(id, usergroup, icon) VALUES(NULL, " .. sql.SQLStr(userGroup) .. ", " .. sql.SQLStr("icon16/user.png") .. ")")
			
			net.Start("atlaschat.crtrnkgt")
				net.WriteString(userGroup)
				net.WriteString("icon16/user.png")
			net.Broadcast()
			
			atlaschat.Notify(":information: Successfully created the rank '" .. userGroup .. "'!", player)
		end
	end
end)

---------------------------------------------------------
-- Removing a rank.
---------------------------------------------------------

util.AddNetworkString("atlaschat.rmvrnk")

net.Receive("atlaschat.rmvrnk", function(bits, player)
	local isAdmin = player:IsSuperAdmin()
	
	if (isAdmin) then
		local userGroup = net.ReadString()
		
		if (atlaschat.ranks[userGroup]) then
			atlaschat.ranks[userGroup] = nil
			
			sql.Query("DELETE FROM atlaschat_ranks WHERE usergroup=" .. sql.SQLStr(userGroup))
			
			net.Start("atlaschat.crtrnkgt")
				net.WriteString(userGroup)
				net.WriteString("")
				net.WriteUInt(1, 8)
			net.Broadcast()
			
			atlaschat.Notify(":information: Successfully removed the rank '" .. userGroup .. "'!", player)
		else
			atlaschat.Notify(":exclamation: Could not remove the rank: The rank does not exist!", player)
		end
	end
end)

---------------------------------------------------------
-- Changing the icon of the rank.
---------------------------------------------------------

util.AddNetworkString("atlaschat.chnric")

net.Receive("atlaschat.chnric", function(bits, player)
	local isAdmin = player:IsSuperAdmin()
	
	if (isAdmin) then
		local userGroup = net.ReadString()
		
		if (atlaschat.ranks[userGroup]) then
			local icon = net.ReadString()
			
			atlaschat.ranks[userGroup] = icon
			
			sql.Query("UPDATE atlaschat_ranks SET icon=" .. sql.SQLStr(icon) .. " WHERE usergroup=" .. sql.SQLStr(userGroup))
			
			net.Start("atlaschat.crtrnkgt")
				net.WriteString(userGroup)
				net.WriteString(icon)
				net.WriteUInt(2, 8)
			net.Broadcast()
			
			atlaschat.Notify(":information: Successfully changed the icon of rank '" .. userGroup .. "' to '" .. icon .. "'!", player)
		else
			atlaschat.Notify(":exclamation: Could not change the icon: The rank does not exist!", player)
		end
	end
end)

---------------------------------------------------------
-- Private chatting.
---------------------------------------------------------

local privateMessages = {}

---------------------------------------------------------
-- Creating a private chat.
---------------------------------------------------------

util.AddNetworkString("atlaschat.stpm")
util.AddNetworkString("atlaschat.nwpm")

net.Receive("atlaschat.stpm", function(bits, player)
	local key, count = nil, table.Count(privateMessages)
	
	for i = 1, count do
		if (privateMessages[i] == nil) then
			key = i
			
			break
		end
	end
	
	if (!key) then key = count +1 end
	
	privateMessages[key] = {players = {player}, creator = player}

	net.Start("atlaschat.nwpm")
		net.WriteUInt(key, 8)
	net.Send(player)
	
	local data = privateMessages[key]
	
	net.Start("atlaschat.gtplpm")
		net.WriteUInt(key, 8)
		net.WriteUInt(#data.players, 8)
		
		for i = 1, #data.players do
			net.WriteEntity(data.players[i])
		end
		
		net.WriteEntity(data.creator)
	net.Send(player)
end)

---------------------------------------------------------
-- Sending a text message in a private chat.
---------------------------------------------------------

util.AddNetworkString("atlaschat.rxpm")
util.AddNetworkString("atlaschat.txpm")

net.Receive("atlaschat.txpm", function(bits, player)
	local key = net.ReadUInt(8)
	local text = net.ReadString()
	local receivers = privateMessages[key]
	
	if (receivers) then
		receivers = receivers.players
		
		net.Start("atlaschat.rxpm")
			net.WriteUInt(key, 8)
			net.WriteString(text)
			net.WriteEntity(player)
		net.Send(receivers)
	end
end)

---------------------------------------------------------
-- Leaving a private chat.
---------------------------------------------------------

util.AddNetworkString("atlaschat.lvpm")

net.Receive("atlaschat.lvpm", function(bits, player)
	local key = net.ReadUInt(8)
	local data = privateMessages[key]
	
	if (data) then
		for i = 1, #data.players do
			local value = data.players[i]
			
			if (value == player) then
				table.remove(data.players, i)
				
				break
			end
		end
		
		net.Start("atlaschat.nkickpm")
			net.WriteUInt(key, 8)
			net.WriteEntity(player)
			net.WriteBit(1)
		net.Send(data.players)
		
		if (#data.players <= 0) then
			privateMessages[key] = nil
		end
	end
end)

---------------------------------------------------------
-- Joining a private chat.
---------------------------------------------------------

util.AddNetworkString("atlaschat.jnpm")
util.AddNetworkString("atlaschat.gtplpm")

net.Receive("atlaschat.jnpm", function(bits, player)
	local key = net.ReadUInt(8)
	local data = privateMessages[key]

	if (data) then
		local exists = false
		
		for i = 1, #data.players do
			local info = data.players[i]
			
			if (info == player) then
				exists = true
				
				break
			end
		end
		
		if (!exists) then
			table.insert(data.players, player)
			
			-- Send information about the chat room to the player.
			net.Start("atlaschat.gtplpm")
				net.WriteUInt(key, 8)
				net.WriteUInt(#data.players, 8)
				
				for i = 1, #data.players do
					net.WriteEntity(data.players[i])
				end
				
				net.WriteEntity(data.creator)
			net.Send(player)
			
			-- Network that this player has joined the chat room.
			net.Start("atlaschat.gtplpm")
				net.WriteUInt(key, 8)
				net.WriteUInt(1, 8)
				net.WriteEntity(player)
			net.Send(data.players)
		end
	end
end)

---------------------------------------------------------
-- Kicking a player a private chat.
---------------------------------------------------------

util.AddNetworkString("atlaschat.kickpm")
util.AddNetworkString("atlaschat.nkickpm")

net.Receive("atlaschat.kickpm", function(bits, player)
	local key = net.ReadUInt(8)
	local data = privateMessages[key]
	
	if (data) then
		if (data.creator == player) then
			local target = net.ReadEntity()
		
			for i = 1, #data.players do
				local info = data.players[i]
				
				if (info == target) then
					net.Start("atlaschat.nkickpm")
						net.WriteUInt(key, 8)
						net.WriteEntity(target)
						net.WriteBit(0)
					net.Send(data.players)
					
					table.remove(data.players, i)
					
					break
				end
			end
		end
	end
end)

---------------------------------------------------------
-- Inviting a player a private chat.
---------------------------------------------------------

util.AddNetworkString("atlaschat.invpm")
util.AddNetworkString("atlaschat.sinvpm")

net.Receive("atlaschat.invpm", function(bits, player)
	local key = net.ReadUInt(8)
	local target = net.ReadString()
	
	target = util.FindPlayerAtlaschat(target, player)
	
	if (IsValid(target)) then
		net.Start("atlaschat.sinvpm")
			net.WriteUInt(key, 8)
			net.WriteEntity(player)
		net.Send(target)
	end
end)

---------------------------------------------------------
-- Clears your configuration.
---------------------------------------------------------

util.AddNetworkString("atlaschat.clrcfg")
util.AddNetworkString("atlaschat.rqclrcfg")

net.Receive("atlaschat.rqclrcfg", function(bits, player)
	local target = net.ReadString()
	
	if (target != "") then
		target = util.FindPlayerAtlaschat(target, player)
		
		if (IsValid(target)) then
			if (target != player and !player:IsAdmin()) then return end
			
			net.Start("atlaschat.clrcfg")
			net.Send(target)
			
			if (target == player) then
				atlaschat.Notify("Successfully reset your atlaschat configuration! Close and open your chatbox to apply.", target)
			else
				atlaschat.Notify(player:Nick() .. " has reset your atlaschat configuration! Close and open your chatbox to apply.", target)
				atlaschat.Notify("You have reset " .. target:Nick() .. "'s atlaschat configuration! Close and open your chatbox to apply.", player)
			end
		end
	else
		if (player:IsAdmin()) then
			net.Start("atlaschat.clrcfg")
			net.Broadcast()
			
			atlaschat.Notify(player:Nick() .. " has reset everyone's atlaschat configuration! Close and open your chatbox to apply.")
		end
	end
end)

---------------------------------------------------------
-- Atlas chat messages.
---------------------------------------------------------

util.AddNetworkString("atlaschat.msg")

function atlaschat.Notify(text, player)
	net.Start("atlaschat.msg")
		net.WriteString(text)
	if (IsValid(player)) then net.Send(player) else net.Broadcast() end
end

---------------------------------------------------------
-- Net message for larger text!
---------------------------------------------------------

util.AddNetworkString("atlaschat.chat")
util.AddNetworkString("atlaschat.chatText")

net.Receive("atlaschat.chat", function(bits, player)
	local text = net.ReadString()
	local team = util.tobool(net.ReadBit())
	
	text = hook.Run("PlayerSay", player, text, team, !player:Alive())
	
	if (text and text != "") then
		if (game.IsDedicated()) then
			ServerLog(player:Nick() .. ": " .. text .. "\n")
		end
		
		local filter = {}
		local players = util.GetPlayers()
		
		for i = 1, #players do
			local target = players[i]
			
			if (IsValid(target)) then
				local canSee = hook.Run("PlayerCanSeePlayersChat", text, team, target, player)
				
				if (canSee or target == player) then
					table.insert(filter, target)
				end
			end
		end
		
		net.Start("atlaschat.chatText")
			net.WriteString(text)
			net.WriteEntity(player)
			net.WriteBit(team)
		net.Send(filter)
	end
end)