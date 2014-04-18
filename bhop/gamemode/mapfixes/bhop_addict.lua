---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

HOOKS["InitPostEntity"] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(v:GetSaveTable().target == "telecave2") then --easiest way to fix
			v:SetKeyValue("target","cave1")
			v:Spawn() 
		end
	end
end