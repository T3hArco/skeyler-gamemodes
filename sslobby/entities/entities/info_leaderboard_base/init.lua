AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetNotSolid(true)
end

concommand.Add("dicks",function()

	local tbl = {}
	
	for k,v in pairs(ents.FindByClass("info_weeklyleaderboard")) do
		local p,a=v:GetPos(),v:GetAngles()
		
		table.insert(tbl,{p,a})
		
		v:Remove()
	end
	
	for i = 1, #tbl do
	local v = tbl[i]
	local n=ents.Create("info_weeklyleaderboard")
		n:SetPos(v[1])
		n:SetAngles(v[2])
		n:Spawn()
	end
end)