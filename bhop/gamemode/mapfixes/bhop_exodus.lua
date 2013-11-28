HOOKS["Initialize"] = function()
	GAMEMODE:AddACArea(Vector(866, 162, -240),Vector(1371, 664, -40),"You have entered the level select area as a result of this your timer has been stopped.")
	GAMEMODE:AddACArea(Vector(-580, 772, -768),Vector(-315, 894, -568))
end

[09:56:03] Min = Vector(867, 161, -240)
[09:56:03] Max = Vector(1371, 664, -240)


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
end