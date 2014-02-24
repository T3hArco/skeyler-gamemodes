AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetNotSolid(true)
end

concommand.Add("dicks",function()
	local s=ents.FindByClass("info_weeklyleaderboard")
	
	for k, v in pairs(s) do
		local d=ents.Create("info_weeklyleaderboard")
		d:SetPos(v:GetPos())
		d:SetAngles(v:GetAngles())
		d:Spawn()
		
		v:Remove()
	end
end)