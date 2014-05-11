---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

SS.Punishments = {}
local BAN_ID = 1
local MUTE_ID = 2

function PLAYER_META:Punish(ply, target, time, Reason, id)

	local ip
	local expiretime = os.time() + time
	local Query

	if self:IsBot() then 
		ip = "127001"
		Query = "INSERT INTO punishments (punishmentid, steamid64, steamid, name, lastregisteredip, expiretime, reason, admin) VALUES ('"..id.."', '"..self:SteamID64().."', 'BOT', '"..DB:escape(self:Name()).."', '"..ip.."', '"..expiretime.."', '"..DB:escape(Reason).."', '"..DB:escape(ply:Name()).."')"
	else
		local playerid = self.profile.id
		ip = string.Replace(self:IPAddress() != "loopback" and self:IPAddress() or "127.0.0.1", ".", "")
		Query = "INSERT INTO punishments (playerid, punishmentid, steamid64, steamid, name, lastregisteredip, expiretime, reason, admin) VALUES ('"..playerid.."', '"..id.."', '"..self:SteamID64().."', '"..string.sub(self:SteamID(), 7).."', '"..DB:escape(self:Name()).."', '"..ip.."', '"..expiretime.."', '"..DB:escape(Reason).."', '"..DB:escape(ply:Name()).."')"
	end

	DB_Query(Query)
	SS.Punishments:LoadPunishments()
end

function PLAYER_META:IsBanned(steamid)

	local SteamID
	if steamid and steamid != "BOT" then
		SteamID = string.sub(steamid, 7)
	elseif !steamid then
		SteamID = string.sub(self:SteamID(), 7)
	else
		SteamID = steamid -- BOT
	end

	if SS.Punishments.MySQLBans[SteamID] then
		if SS.Punishments.MySQLBans[SteamID].time <= os.time() then
			SS.Punishments:RemoveFromMySQL(SteamID, true, 1)
			return false
		end
		return true
	end

	return false
end

function PLAYER_META:IsMuted(steamid)

	local SteamID
	if steamid and steamid != "BOT" then
		SteamID = string.sub(steamid, 7)
	elseif !steamid then
		SteamID = string.sub(self:SteamID(), 7)
	else
		SteamID = steamid -- BOT
	end

	if SS.Punishments.MySQLMutes[SteamID] then
		if SS.Punishments.MySQLMutes[SteamID].time <= os.time() then
			SS.Punishments:RemoveFromMySQL(SteamID, true, 2)
			return false
		end
		return true
	end

	return false
end

function SS.Punishments:LoadPunishments()
	local Query = "SELECT * FROM punishments"
	DB_Query(Query, function(data)
		if data then
			self.MySQLBans = {}
			self.MySQLMutes = {}
			for k, v in pairs(data) do
				if data[k].punishmentid == BAN_ID then
					self.MySQLBans[data[k].steamid] = {
						tableid = data[k].id,
						name = data[k].name,
						time = data[k].expiretime,
						reason = data[k].reason,
						admin = data[k].admin
					}
				elseif data[k].punishmentid == MUTE_ID then
						self.MySQLMutes[data[k].steamid] = {
						tableid = data[k].id,
						name = data[k].name,
						time = data[k].expiretime,
						reason = data[k].reason,
						admin = data[k].admin
					}
				end
			end
		end
		MsgN("[PUNISHMENTS] Loaded succesfully!")
	end)
end

function SS.Punishments:RemoveFromMySQL(SteamID, ConsoleCheck, PunishmentID, pl)

	local t
	if PunishmentID == BAN_ID then
		t = self.MySQLBans[SteamID]
	elseif PunishmentID == MUTE_ID then
		t = self.MySQLMutes[SteamID]
	end

	local ptype = PunishmentID == BAN_ID and "Ban" or PunishmentID == MUTE_ID and "Mute"
	local action = ptype == "Ban" and "unbanned" or ptype == "Mute" and "unmuted"
	local id = t.tableid
	local name = t.name
	local Query = "DELETE FROM punishments WHERE id = '"..id.."'"

	DB_Query(Query, 
		function()
			MsgN("[PUNISHMENTS] "..ptype.." removed succesfully!")
			if !ConsoleCheck then pl:ChatPrint("Player '"..name.. "' with SteamID '"..SteamID.."' has been "..action.." succesfully!") end
		end,

		function()
			MsgN("[PUNISHMENTS] Failed to remove "..string.lower(ptype).." from MySQL!") 
			if !ConsoleCheck then pl:ChatPrint("Failed to unban/unmute SteamID "..SteamID.."! Please contact a developer.") end
		end
	)

	self:LoadPunishments()
end

function SS.Punishments:TimeRemaining(SteamID)

	local t = self.MySQLMutes[string.sub(SteamID, 7)]
	local time = string.FormattedTime(t.time - os.time(), "%02i:%02i:%02i")
	local reason = t.reason
	local admin = t.admin

	return "You were muted by "..admin.." due to '"..reason.."'. Time remaining: "..time.."."
end

function SS.Punishments:Unban(SteamID, pl)

	if !PLAYER_META:IsBanned(SteamID) then
		pl:ChatPrint("This SteamID is not banned!")
		return
	end

	if SteamID != "BOT" then
		SteamID = string.sub(SteamID, 7)
	end

	self:RemoveFromMySQL(SteamID, false, 1, pl)
end

function SS.Punishments:Unmute(SteamID, pl)

	if !PLAYER_META:IsMuted(SteamID) then
		pl:ChatPrint("This SteamID is not muted!")
		return
	end

	if SteamID != "BOT" then
		SteamID = string.sub(SteamID, 7)
	end

	self:RemoveFromMySQL(SteamID, false, 2, pl)
end