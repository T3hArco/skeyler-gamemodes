---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

HOOKS["InitPostEntity"] = function()
	print('hi')
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
	timer.Simple(1,function() --cause other code runs helping us use these variables
		for k,v in pairs(ents.FindByClass("func_door")) do
			if(!v:GetNWInt("Platform",0)) then
				v:Remove()
			end
			if(v.BHSp > 100) then
				v:Remove() --only condition where we would guess its a booster but in this map its not
			end
		end
	end)
end