---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

HOOKS["Initialize"] = function()
	GAMEMODE:AddACArea(Vector(866, 162, -240),Vector(1371, 664, -40),"You have entered the level select area as a result of this your timer has been stopped.")
	GAMEMODE:AddACArea(Vector(-580, 772, -768),Vector(-315, 894, -568))
end

HOOKS["InitPostEntity"] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(v:GetPos() == Vector(6560, 5112, 7412)) then
			v:SetKeyValue("target","13")
		end
	end
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if(v:GetName() == "aokilv6") then
			v:SetName("disabled")
		end
	end
	
	--all the broken spikes are belong to us
	local p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-328, 11992, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-296, 12095, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-655, 12151, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-815, 11920, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-815, 11808, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-911, 11840, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-1071, 11840, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
end