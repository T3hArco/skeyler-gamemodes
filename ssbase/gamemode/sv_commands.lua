---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

concommand.Add("rs", function(ply) 
	if ply:IsValid() and !ply:IsSuperAdmin() then return end 
	RunConsoleCommand("changelevel", game.GetMap()) 
end ) 

concommand.Add("curpos", function(ply) 
	local Pos = ply:GetPos() 

	ply:ChatPrint("Vector(".. math.Round(Pos.x) ..", ".. math.Round(Pos.y) ..", ".. math.Round(Pos.z) ..")") 
end )

concommand.Add("aimpos", function(ply) 
	local pos = ply:GetShootPos() 
	local ang = ply:GetAimVector() 
	local tracedata = {} 
	tracedata.start = pos 
	tracedata.endpos = pos+(ang*5000) 
	tracedata.filer=ply 
	tracedata.mask=MASK_SOLID_BRUSHONLY
	local trace = util.TraceLine(tracedata) 
	ply:ChatPrint(tostring(trace.Entity))
	ply:ChatPrint(tostring(trace.HitPos))
end ) 


--[[--------------------------------------------
		Administration
----------------------------------------------]]

concommand.Add("ss_ban", function(ply, cmd, args)
	if !ply:IsAdmin() then 
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local PlayerName = args[1]
	local Time = tonumber(args[2])
	local msg

	table.remove(args, 2)

	local Reason = StpRsnStrng(args)

	if (!PlayerName || !Time || !Reason) then
		ply:ChatPrint("Syntax is ss_ban PlayerName Time(Hours) Reason.\n")
		return
	end

	local Target = FindByPartial(PlayerName)
	if (type(Target) == "string") then 
		ply:ChatPrint(Target)
		return
	end

	if Time > 0 then
		msg = "("..string.upper(ply:GetRankName())..") "..ply:Nick().." banned "..Target:Nick().." for "..Time.." hours. Reason: '"..Reason.."'."
	elseif Time == 0 then
		msg = "("..string.upper(ply:GetRankName())..") "..ply:Nick().." banned "..Target:Nick().." forever. Reason: '"..Reason.."'."
	else
		ply:ChatPrint("Seriously?")
	end

	if IsValid(Target) then
		if Target:GetRank() > ply:GetRank() and !ply:IsSuperAdmin() then
			ply:ChatPrint("You can not target this rank.\n")
			return
		elseif Target:IsBot() and !ply:IsSuperAdmin() then
			ply:ChatPrint("You can't ban a BOT!")
			return
		elseif Target:IsBanned() then
			MsgN("[BANS] Attempted to ban a banned player.")
			ply:ChatPrint("This player shouldn't be here. Contact a developer!")
			return
		else
			Target:Punish(ply, Target, Time * 3600, Reason, 1) 		-- Seconds 
			Target:Kick("You have been banned from this server for '"..Reason.."'. Check www.skeyler.com for more info")
			PLAYER_META:ChatPrintAll(msg)
		end
	end
end)

concommand.Add("ss_bring", function(ply, cmd, args)
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	if !args[1] then
		ply:ChatPrint("Syntax is ss_bring PlayerName.\n")
		return
	end

	local PlayerName = args[1]
	local Target = FindByPartial(PlayerName)
	if (type(Target) == "string") then 
		ply:ChatPrint(Target)
		return
	end

	local tr = ply:GetEyeTrace()
	if IsValid(Target) then
		Target:SetPos(tr.HitPos)
		Target:ChatPrint("("..string.upper(ply:GetRankName())..") "..ply:Nick().." teleported you.\n")
		ply:ChatPrint("You teleported "..Target:Nick()..".\n")
	end
end)

SS.allwdFkrnk = {
	["O"] = 100,
	["S"] = 90,
	["D"] = 70,
	["A"] = 50,
	["M"] = 10,
	["V"] = 5,
	["R"] = 0,
	[""] = 0
}

concommand.Add("ss_fakename", function(ply, cmd, args)
	if !ply:IsAdmin() then 
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local NewName = args[1]
	local FakeRank = args[2]

	if NewName and !FakeRank then
		if !ply:IsFakenamed() then
			ply:ChatPrint("Syntax is ss_fakename NewName FakeRank.")
			return
		else
			ply:ChatPrint("Type ss_fakename if you wish to remove your fake name. Otherwise, the syntax is ss_fakename NewName ID.")
			return
		end
	end

	if FakeRank and !SS.allwdFkrnk[FakeRank] then
		ply:ChatPrint("(FAKENAME): '"..FakeRank.."' is not a valid rank. Valid rank modes are 'O', 'S', 'D', 'A', 'M', 'V' and 'R'.\n")
		return
	end

	if !ply:IsSuperAdmin() and (SS.allwdFkrnk[FakeRank] > ply:GetRank()) then
		ply:ChatPrint("You can not fakename as a higher rank!\n")
		return
	end

	local id = SS.allwdFkrnk[FakeRank]

	ply:SetFake(NewName, id, true)
end)

concommand.Add("ss_goto", function(ply, cmd, args)
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	if !args[1] then
		ply:ChatPrint("Syntax is ss_goto PlayerName.\n")
		return
	end

	local PlayerName = args[1]
	local Target = FindByPartial(PlayerName)
	if (type(Target) == "string") then 
		ply:ChatPrint(Target)
		return
	end

	if IsValid(Target) then
		ply:SetPos(Target:GetPos())
		ply:ChatPrint("You teleported to "..Target:Nick()..".\n")
	end
end)

concommand.Add("ss_kick", function(ply, cmd, args)
	if !ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local PlayerName = args[1]
	local Reason = StpRsnStrng(args)

	if (!PlayerName) then
		ply:ChatPrint("Syntax is ss_kick PlayerName Reason.\n")
		return
	end

	local Target = FindByPartial(PlayerName)
	if (type(Target) == "string") then 
		ply:ChatPrint(Target)
		return
	end

	if Target:IsValid() then
		if !ply:IsSuperAdmin() and Target:GetRank() > ply:GetRank() then
			ply:ChatPrint("You can not target this rank.\n")
			return
		else
			if Reason then
				msg = "("..string.upper(ply:GetRankName())..") "..ply:Nick().." kicked "..Target:Nick().." for '"..Reason.."'."
			else
				msg = "("..string.upper(ply:GetRankName())..") "..ply:Nick().." kicked "..Target:Nick().."."
				Reason = "No reason provided."
			end
			Target:Kick(Reason)
			PLAYER_META:ChatPrintAll(msg)
		end
	end
end)

concommand.Add("ss_map", function(ply, cmd, args) 
	local map = args[1] 
	if ply and ply:IsValid() then 
		if !ply:IsAdmin() then
			ply:ChatPrint("You do not have access to this command.\n")
			return
		end 
		if !map then
			ply:ChatPrint("Syntax is ss_map NewMap\n")
			return
		end
	end 



	local prefix = "" 
	if ply and ply:IsValid() then 
		prefix = "("..string.upper(ply:GetRankName())..") "..ply:Nick() 
	else 
		prefix = "(Console)" 
	end 

	-- if file.Exists("maps/"..map..".bsp", "MOD") then
		ChatPrintAll(prefix.." is changing the map to "..map..".")
		for k, v in pairs(player.GetAll()) do
			v:EmitSound("vo/k_lab/kl_initializing02.wav", 40, 115)
		end
		timer.Simple(4.2, function() RunConsoleCommand("changelevel", map) end)
	-- elseif ply and ply:IsValid() then 
	-- 	ply:ChatPrint("Couldn't find map "..map..".bsp.") 
	-- else 
	-- 	print("Couldn't find map "..map..".bsp") 
	-- end
end)

concommand.Add("ss_mute", function(ply, cmd, args)
	if !ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local PlayerName = args[1]
	local Time = tonumber(args[2])

	if (!PlayerName || !Time) then
		ply:ChatPrint("Syntax is ss_mute PlayerName Time(Hours) Reason(Optional).\n")
		return
	end

	table.remove(args, 2)
	local Reason = StpRsnStrng(args) or "No reason was specified"
	local Target = FindByPartial(PlayerName)
	if (type(Target) == "string") then 
		ply:ChatPrint(Target)
		return
	end

	if IsValid(Target) then
		if (Target:GetRank() > ply:GetRank() and !ply:IsSuperAdmin()) then
			ply:ChatPrint("You can not target this rank.\n")
			return
		else
			if Target:IsMuted() then
				ply:ChatPrint("This player is already muted.")
				return
			end
			Target:Punish(ply, Target, Time * 3600, Reason, 2)
			PLAYER_META:ChatPrintAll("("..string.upper(ply:GetRankName())..") "..ply:Nick().." muted "..Target:Nick()..". Reason: '"..Reason.."'.")
		end
	end
end)

concommand.Add("ss_password", function(ply, cmd, args)
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	if !args[1] then
		ply:ChatPrint("Syntax is ss_password NewPassword.\n")
		return
	end

	local pass = args[1]

	if pass == "" then
		PLAYER_META:ChatPrintAll("("..string.upper(ply:GetRankName())..") "..ply:Nick().." has removed the server's password.")
		RunConsoleCommand("sv_password", pass)
		return
	end

	PLAYER_META:ChatPrintAll("("..string.upper(ply:GetRankName())..") "..ply:Nick().." has changed the server's password.")
	SS.PrintToAdmins("[ADMINS] ("..string.upper(ply:GetRankName())..") "..ply:Nick().." has changed the password to '"..pass.."'.\n")
	RunConsoleCommand("sv_password", pass)
end)

concommand.Add("ss_rs", function(ply, cmd, args)
	if !ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local map = game.GetMap()
	PLAYER_META:ChatPrintAll("("..string.upper(ply:GetRankName())..") "..ply:Nick().." is restarting the map.\n")
	for k, v in pairs(player.GetAll()) do
		v:EmitSound("vo/k_lab/kl_initializing02.wav", 40, 115)
	end
	timer.Simple(4.2, function() RunConsoleCommand("changelevel", map) end)
end)

concommand.Add("ss_slay", function(ply, cmd, args)
	if !ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local PlayerName = args[1]
	local Reason = StpRsnStrng(args)

	if !PlayerName then
		ply:ChatPrint("Syntax is ss_slay PlayerName Reason.\n")
		return
	end

	local Target = FindByPartial(PlayerName)
	if (type(Target) == "string") then 
		ply:ChatPrint(Target)
		return
	end

	if Target:IsValid() then
		if (Target:GetRank() > ply:GetRank()) and !ply:IsSuperAdmin() then
			ply:ChatPrint("You can not target this rank.\n")
			return
		else
			if !Reason then
				msg = "("..string.upper(ply:GetRankName())..") "..ply:Nick().." slayed "..Target:Nick().."."
			else
				msg = "("..string.upper(ply:GetRankName())..") "..ply:Nick().." slayed "..Target:Nick()..". Reason: "..Reason
			end
			Target:Kill()
			PLAYER_META:ChatPrintAll(msg)
		end
	end
end) 

concommand.Add("ss_startvote", function(ply, cmd, args) 
	if !ply:IsSuperAdmin() then 
		ply:ChatPrint("You do not have access to this command.") 
		return 
	end 

	if args[1] and args[2] and args[3] and isnumber(tonumber(args[2])) then 
		local name, time = args[1], args[2] 
		table.remove(args, 2); table.remove(args, 1); 
		vote.Start(ply, name, time, function(result) ChatPrintAll("The vote results are in and the winner is:  "..result) end, false, unpack(args)) 
	else 
		ply:ChatPrint("Syntax: ss_startvote name time option1 [,option2, option3, etc]") 
	end 
end ) 

concommand.Add("ss_revote", function(ply) 
	if vote.IsVoting() then 
		net.Start("ss_revote") 
		net.Send(ply) 
		vote.Revote(ply) 

		ply:ChatPrint("You can now revote.") 
	else 
		ply:ChatPrint("There is currently no vote.") 
	end 
end )

concommand.Add("ss_timeleft", function(ply) 
	ply:ChatPrint("Timeleft until votemap: "..votemap.GetTimeleft(true)) 
end ) 

concommand.Add("ss_unban", function(ply, cmd, args)
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("You do not have access to this command.")
		return
	end

	if !args[1] then
		ply:ChatPrint("Syntax is ss_unban SteamID. Example: ss_unban STEAM_0:0:14340930")
		return
	end

	local SteamID = string.Implode("", args)
	SS.Punishments:Unban(SteamID, ply)
end)

concommand.Add("ss_unmute", function(ply, cmd, args)
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("You do not have access to this command.")
		return
	end

	if !args[1] then
		ply:ChatPrint("Syntax is ss_unmute SteamID. Example: ss_unmute STEAM_0:0:14340930")
		return
	end

	local SteamID = string.Implode("", args)
	SS.Punishments:Unmute(SteamID, ply)
end)

--[[-------------------------------------------------
		ChatCommands
---------------------------------------------------]]

SS.ChatCommands = {
	["ban"] = "ss_ban",
	["bring"] = "ss_bring",
	["fakename"] = "ss_fakename",
	["goto"] = "ss_goto",
	["kick"] = "ss_kick",
	["map"] = "ss_map",
	["mute"] = "ss_mute",
	["password"] = "ss_password",
	["revote"] = "ss_revote",
	["rs"] = "ss_rs",
	["rtv"] = "ss_rtv",
	["slay"] = "ss_slay", 
	["timeleft"] = "ss_timeleft",
	["unban"] = "ss_unban",
	["unmute"] = "ss_unmute"
}

function SS.AddCommand(text,cmd) --for gamemodes to use to ensure they dont overwrite/get overwritten by the above table
	SS.ChatCommands[text] = cmd
end

function SS.ToConCommand(ply, text)
	local t = text

	if string.sub(t, 0, 1) == "/" then 
		t = string.gsub(t, "/", "", 1) 
	else 
		t = string.gsub(t, "!", "", 1) 
	end 
	
	cmd = string.Explode(" ", t)

	local cmdname = cmd[1]
	table.remove(cmd, 1)

	local args = string.Implode(" ", cmd)

	if SS.ChatCommands[cmdname] then
		ply:ConCommand(SS.ChatCommands[cmdname].." "..args)
		return
	end

	ply:ChatPrint("Invalid command.\n")
end