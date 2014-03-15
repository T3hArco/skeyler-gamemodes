

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

	local PlayerName = tostring(args[1])
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

local allowedids = {0, 5, 10, 50, 70, 90, 100}
concommand.Add("ss_fakename", function(ply, cmd, args)
	if !ply:IsAdmin() then return end


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

concommand.Add("ss_kick", function(ply, cmd, args)
	if !ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local PlayerName = tostring(args[1])
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

concommand.Add("ss_mute", function(ply, cmd, args)
	if !ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local PlayerName = tostring(args[1])

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

concommand.Add("ss_slay", function(ply, cmd, args)
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("You do not have access to this command.\n")
		return
	end

	local PlayerName = tostring(args[1])
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