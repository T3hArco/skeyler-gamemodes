---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

local tmax = nil
local tmin = nil

HOOKS["InitPostEntity"] = function()
	local push = nil
	for k,v in pairs(ents.FindByClass("trigger_push")) do if(v:GetPos() == Vector(5864, 4808, -128)) then push = v end end
	push:SetKeyValue("spawnflags","0")
	push:Spawn()
	tmax = push:LocalToWorld(push:OBBMaxs())
	tmin = push:LocalToWorld(push:OBBMins())
end

HOOKS["Think"] = function()
	if !tmin then return end
	for k,v in pairs(player.GetAll()) do
		if(GAMEMODE:IsInArea(v,tmin,tmax)) then
			v:SetVelocity(Vector(0,0,50))
		end
	end
end