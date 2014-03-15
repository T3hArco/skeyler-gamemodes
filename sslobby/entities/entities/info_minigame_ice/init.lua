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
	
	self.life = 255
	self.color = Color(255, 255, 255)
	self.players = {}
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
				local exists = false
				
				for i = 1, #self.players do
					local player = self.players[i]
					
					if (player == entity) then
						exists = true
						
						break
					end
				end
			
				if (!exists) then
					timer.Simple(0.6, function()
						if IsValid(entity) then
							if self.life != 0 then
								self.life = 0
							end
						end
					end)
					//table.insert(self.players, entity)
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

function ENT:EndTouch(entity)
	if (!self.removed) then
		if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
			for i = 1, #self.players do
				local player = self.players[i]
				
				if (player == entity) then
					table.remove(self.players, i)
					
					break
				end
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Think()
	/*
	if (#self.players > 0 and !self.removed) then
		self.color.g = math.Clamp((self.life /255) *255, 0, 255)
		self.color.b = math.Clamp((self.life /255) *255, 0, 255)
		
		self:SetColor(self.color)
		
		self.life = self.life -11
		
		if (self.life <= 0) then
			self.removed = true
			
			self:SetNoDraw(true)
			self:SetNotSolid(true)
		end
	end
	*/

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