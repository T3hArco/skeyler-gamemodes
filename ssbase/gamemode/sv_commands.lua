

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
	args[2] = tonumber(args[2])
	local Time = args[2]
	local Reason = ArgConcat(args)

	if (!PlayerName || !Time || !Reason) then
		ply:ChatPrint("Syntax is ss_ban PlayerName Time(Hours) Reason.\n")
		return
	end

	local Target = FindByPartial(PlayerName)
	if (type(Target) == "string") then 
		ply:ChatPrint(Target)
		return
	end

	if Target:IsValid() then
		if Target:GetRank() > ply:GetRank() and !ply:IsSuperAdmin() then
			ply:ChatPrint("This rank is inmune to yours.\n")
			return
		else
			Target:Ban(Time * 60, Reason)
			Target:Kick(Reason)
			PLAYER_META:ChatPrintAll("("..string.upper(ply:GetRankName())..") "..ply:Nick().." banned "..Target:Nick().." for "..Time.." hours. Reason: '"..Reason.."'.")
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

local allowedids = {0, 5, 10, 50, 70, 90, 100}
concommand.Add("ss_fakename", function(ply, cmd, args)
	if !ply:IsAdmin() then 
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local NewName = args[1]
	local id = tonumber(args[2])

	if NewName and !id then
		if !ply:IsFakenamed() then
			ply:ChatPrint("Syntax is ss_fakename NewName ID.")
			return
		else
			ply:ChatPrint("Type ss_fakename if you wish to remove your fake name. Otherwise, the syntax is ss_fakename NewName ID.")
			return
		end
	end

	if id and !table.HasValue(allowedids, id) then
		ply:ChatPrint("That is not a valid id. Valid id's are 0, 5, 10, 50, 70, 90 and 100.\n")
		return
	end

	ply:SetFake(NewName, id)
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
	local Reason = ArgConcat(args)

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
	if !ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local map = args[1]

	if !map then
		ply:ChatPrint("Syntax is ss_map NewMap\n")
		return
	end

	if file.Exists("maps/"..map..".bsp", "MOD") then
		PLAYER_META:ChatPrintAll("("..string.upper(ply:GetRankName())..") "..ply:Nick().." is changing the map to "..map..".\n")
		for k, v in pairs(player.GetAll()) do
			v:EmitSound("vo/k_lab/kl_initializing02.wav", 40, 115)
		end
		timer.Simple(4.2, function() RunConsoleCommand("changelevel", map) end)
	else
		ply:ChatPrint("Couldn't find map "..map..".bsp.\n")
	end
end)

concommand.Add("ss_mute", function(ply, cmd, args)
	if !ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local PlayerName = args[1]

	if (!PlayerName) then
		ply:ChatPrint("Syntax is ss_mute PlayerName.\n")
		return
	end

	local Target = FindByPartial(PlayerName)
	if (type(Target) == "string") then 
		ply:ChatPrint(Target)
		return
	end

	if Target:IsValid() then
		if (Target:GetRank() > ply:GetRank() and !ply:IsSuperAdmin()) then
			ply:ChatPrint("You can not target this rank.\n")
			return
		else
			if (!Target:IsSSMuted()) then
				Target:SetSSMuted(true)
				PLAYER_META:ChatPrintAll("("..string.upper(ply:GetRankName())..") "..ply:Nick().." muted "..Target:Nick()..".")
			else
				Target:SetSSMuted(false)
				PLAYER_META:ChatPrintAll("("..string.upper(ply:GetRankName())..") "..ply:Nick().." unmuted "..Target:Nick()..".")
			end
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

concommand.Add("ss_restart", function(ply, cmd, args)
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
	local Reason = ArgConcat(args)

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

	if args[1] and args[2] and args[3] then 
		local name, time = args[1], args[2] 
		table.remove(args, 2); table.remove(args, 1); 
		vote.Start(ply, name, time, function(result) ChatPrintAll(result) end, unpack(args)) 
	end 
end )


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
	["restart"] = "ss_restart",
	["slay"] = "ss_slay"
}

function SS.ToConCommand(ply, text)
	local t = text

	t = string.gsub(t, "/", "", 1)
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