HOOKS["Initialize"] = function()
	GAMEMODE:AddACArea(Vector(-2534, -782, -102),Vector(-2072, -344, 64),"You have entered the level select area as a result of this your timer has been stopped.")
end

local remove = {
	Vector(-4848, -1268, -56),
	Vector(-1680.5, -2324, -84),
	Vector(5320.5, -2736, 20),
} --all the beggining to level select tps to stop people getting telehopped like level 4

HOOKS["InitPostEntity"] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(v:GetPos() == Vector(543.5, -980, -84)) then
			v:SetKeyValue("target","level15")
		end
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
end