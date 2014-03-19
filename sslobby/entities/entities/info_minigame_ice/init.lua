AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self:SetModel("models/sassafrass/icecube.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:DrawShadow(false)
	
	self.life = 1
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:StartTouch(entity)
	if (!self.removed) then
		if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
			local position = self:GetPos()
			local playerPosition = entity:GetPos()
			
			if (playerPosition.z >= position.z) then
				if (!self.timer) then
					timer.Simple(0.6, function()
						if IsValid(entity) then
							self.life = 0
						end
					end)
					
					self.timer = true
				end
			end
		end

		local physicsObject = self:GetPhysicsObject()
		
		if (IsValid(physicsObject)) then
			physicsObject:Sleep()
			physicsObject:EnableMotion(false)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Think()
	if !self.removed then
		if (self.life <= 0) then
			self.removed = true
			
			self:SetNoDraw(true)
			self:SetNotSolid(true)
		end
	end
	
	self:NextThink(CurTime() +0.05)
	
	return true
end