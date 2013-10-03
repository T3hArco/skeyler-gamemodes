---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

GM.Name 		= "Bunny Hop"
GM.Author 		= "xAaron113x"
GM.Email 		= "xaaron113x@gmail.com"
GM.Website 		= "aaron113.pw"
GM.TeamBased 	= false 

DeriveGamemode("ssbase")

GM.VIPBonusHP = false 
GM.HUDShowVel = true 
GM.HUDShowTimer = true 

TEAM_BHOP = 1  
team.SetUp(TEAM_BHOP, "Hoppers", Color(87, 198, 255), false) 

function GM:EntityKeyValue(ent, key, val) 
	if ent:GetClass() == "func_door" then 
		if key == "spawnflags" then return "2048" end 
	end  
end 

/* Spawn Velocity Cap */
function GM:SetupMove(ply, Data) 
	if !ply.InSpawn then return end 
	local vel = Data:GetVelocity() 
	vel.x = math.min(vel.x, 270) 
	vel.y = math.min(vel.y, 270) 
	vel.z = math.min(vel.z, 270) 

	Data:SetVelocity(vel) 

	return Data
end 
