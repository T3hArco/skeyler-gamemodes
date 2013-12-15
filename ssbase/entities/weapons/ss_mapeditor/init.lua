util.AddNetworkString("StartPosition")
util.AddNetworkString("EndPosition")

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

SWEP.Weight       = 5
SWEP.AutoSwitchTo    = false
SWEP.AutoSwitchFrom     = false

net.Receive("StartPosition",function(len,ply)
	local v1,v2 = Vector(0,0,0),Vector(0,0,0)
	local ov1,ov2 = net.ReadVector(),net.ReadVector()
	v1.x = math.min(ov1.x,ov2.x)
	v1.y = math.min(ov1.y,ov2.y)
	v1.z = math.min(ov1.z,ov2.z)
	v2.x = math.max(ov1.x,ov2.x)
	v2.y = math.max(ov1.y,ov2.y)
	v2.z = v1.z
	ply.SZ = {v1,v2}
end)

net.Receive("EndPosition",function(len,ply)
	local v1,v2 = Vector(0,0,0),Vector(0,0,0)
	local ov1,ov2 = net.ReadVector(),net.ReadVector()
	v1.x = math.Round(math.min(ov1.x,ov2.x))
	v1.y = math.Round(math.min(ov1.y,ov2.y))
	v1.z = math.Round(math.min(ov1.z,ov2.z))
	v2.x = math.Round(math.max(ov1.x,ov2.x))
	v2.y = math.Round(math.max(ov1.y,ov2.y))
	v2.z = v1.z
	ply.EZ = {v1,v2}
end)

hook.Add("PlayerSay","addmap",function(ply,text,pub)
	if(ply:HasWeapon("ss_mapeditor")) then
		if(string.lower(text) == "!setspawn") then
			local a = ply:GetAngles()
			local p = ply:GetPos()
			ply.StP = {Vector(math.Round(p.x),math.Round(p.y),math.Round(p.z)),Angle(0,math.Round(a.y/90)*90,0)}
			ply:ChatPrint("Spawn Point Set!")
			return ""
		elseif(string.sub(string.lower(text),1,8) == "!addmap ") then
			local args = string.Explode(" ",text)
			table.remove(args,1)
			if(!args[1] || tonumber(args[1]) == 0) then
				ply:ChatPrint("Invalid Arguments!")
				return ""
			end
			if(args[2]) then
				ply:ChatPrint("Wrong number of arguments!")
				return ""
			end
			if(!ply.SZ || !ply.EZ) then
				ply:ChatPrint("No defined Start or End Zones")
				return ""
			end
			if(!ply.StP) then
				ply:ChatPrint("No defined Spawn Point!")
				return ""
			end
			SS:AddMap(game.GetMap(),args[1],ply.StP[1],ply.StP[2],ply.SZ[1],ply.SZ[2],ply.EZ[1],ply.EZ[2])
			ply.SZ = nil
			ply.EZ = nil
			ply.StP = nil
			GAMEMODE:AreaSetup()
			ply:ChatPrint("Map Setup!")
			return ""
		elseif(string.lower(text) == "!addmap") then
			ply:ChatPrint("Invalid Arguments!")
			return ""
		end
	end
end)