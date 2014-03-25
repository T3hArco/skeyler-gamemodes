---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

HOOKS["Think"] = function()
	for k,v in pairs(player.GetAll()) do
		if(GAMEMODE:IsInArea(v,Vector(5948,-3972,576),Vector(6098,-3900,787))) then
			v:SetPos(Vector(8429, -5231, 1179))
		end
	end
end