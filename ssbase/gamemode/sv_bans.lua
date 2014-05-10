---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

--[[SS.Bans = {}

function PLAYER_META:Ban(ply, target, time, Reason)

	local ip
	local expiretime = os.time() + time
	local Query

	if self:IsBot() then 
		ip = "127.0.0.1"
		Query = "INSERT INTO punishments (punishmentid, steamid64, steamid, name, lastregisteredip, expiretime, reason, admin) VALUES (1, '"..self:SteamID64().."', 'BOT', '"..DB:escape(self:Name()).."', '"..ip.."', '"..expiretime.."', '"..DB:escape(Reason).."', '"..DB:escape(ply:Name()).."')"
	else
		if self:IsBanned() then
			MsgN("[BANS] Attempted to ban a banned player.")
			ply:ChatPrint("This player shouldn't be here. Contact a developer!")
			return
		end

		local playerid = self.profile.id
		ip = string.Replace(self:IPAddress() != "loopback" and self:IPAddress() or "127.0.0.1", ".", "")
		Query = "INSERT INTO punishments (playerid, punishmentid, steamid64, steamid, name, lastregisteredip, expiretime, reason, admin) VALUES ('"..playerid.."', 1, '"..self:SteamID64().."', '"..string.sub(self:SteamID(), 7).."', '"..DB:escape(self:Name()).."', '"..ip.."', '"..expiretime.."', '"..DB:escape(Reason).."', '"..DB:escape(ply:Name()).."')"
	end

	DB_Query(Query)
	SS.Bans:LoadBans()
end

function PLAYER_META:IsBanned(SteamID)

	local steamid

	if SteamID and SteamID != "BOT" then
		steamid = string.sub(SteamID, 7)
	else
		steamid = SteamID
	end

	if SS.Bans.MySQLBans[steamid] then
		if SS.Bans.MySQLBans[steamid].time <= os.time() then
			SS.Bans:RemoveMySQLBan(steamid)
			return false
		end
		return true
	end

	return false
end

function SS.Bans:LoadBans()
	local Query = "SELECT * FROM punishments WHERE punishmentid = '1'"
	DB_Query(Query, function(data)
		if data then
			self.MySQLBans = {}
			for k, v in pairs(data) do
				self.MySQLBans[data[k].steamid] = {
					tableid = data[k].id,
					name = data[k].name,
					time = data[k].expiretime,
					reason = data[k].reason,
					admin = data[k].admin
				}
			end
		end
		MsgN("[BANS] Loaded succesfully!")
	end)
end

function SS.Bans:RemoveMySQLBan(SteamID)
	local t = self.MySQLBans[SteamID]
	local id = t.tableid
	local Query = "DELETE FROM punishments WHERE id = '"..id.."'"

	DB_Query(Query, 
		function()
			MsgN("[BANS] Ban removed succesfully!")
		end
	)

	self:LoadBans()
end

function SS.Bans:Unban(SteamID, pl)

	if !PLAYER_META:IsBanned(SteamID) then
		pl:ChatPrint("This player is not banned!")
		return
	end

	local steamid
	if SteamID == "BOT" then
		steamid = SteamID
	else
		steamid = string.sub(SteamID, 7)
	end

	local t = self.MySQLBans[steamid]
	local id = t.tableid
	local name = t.name

	local Query = "DELETE FROM punishments WHERE id = '"..id.."'"

	DB_Query(Query,
		function()
			MsgN("[BANS] Ban removed succesfully!") 
			pl:ChatPrint("Player '"..name.. "' with SteamID '"..SteamID.."' has been unbanned succesfully!")
		end,

		function()
			MsgN("[BANS] Failed to remove ban from MySQL!") 
			pl:ChatPrint("Failed to unban SteamID "..SteamID.."! Please contact a developer.")
		end
	)

	self:LoadBans()
end]]