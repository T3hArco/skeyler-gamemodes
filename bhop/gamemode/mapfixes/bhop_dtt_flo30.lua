HOOKS["InitPostEntity"] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		local p = v:GetPos()
		if(p.y == 127.5 && p.z == 172.5 && (p.x < -216 && p.x > -232)) then
			v:Remove()
		end
	end
end