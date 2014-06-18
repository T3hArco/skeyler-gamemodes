AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

------------------------------------------------
--
------------------------------------------------

function ENT:Initialize()
	self:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:DrawShadow(false)
end

------------------------------------------------
--
------------------------------------------------

function ENT:PhysicsCollide(data, physicsObject)
	if (data.Speed >= 10 and data.DeltaTime > 0.1) then
		local position = self:GetPos()
		
		local effect = EffectData()
			effect:SetStart(position)
			effect:SetOrigin(position)
			effect:SetScale(1)
		util.Effect("HelicopterMegaBomb", effect)
		
		self:EmitSound("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav")
		
		local players = player.GetAll()
		
		for k, player in pairs(players) do
			local distance = player:GetPos():Distance(position)
			
			if (distance <= 92) then
				player:Kill()
			end
		end
		
		NEXT_FRAME(function() self:Remove() end)
	end
end