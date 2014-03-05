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
	if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
		local exists = false
		
		for i = 1, #self.players do
			local player = self.players[i]
			
			if (player == entity) then
				exists = true
				
				break
			end
		end

		if (!exists) then
			table.insert(self.players, entity)
		end
	end
	
	local physicsObject = self:GetPhysicsObject()
	
	if (IsValid(physicsObject)) then
		physicsObject:Sleep()
		physicsObject:EnableMotion(false)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:EndTouch(entity)
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

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Think()
	if (#self.players > 0) then
		self.color.g = math.Clamp((self.life /255) *255, 0, 255)
		self.color.b = math.Clamp((self.life /255) *255, 0, 255)
		
		self:SetColor(self.color)
		
		self.life = self.life -7
		
		if (self.life <= 0) then
			timer.Simple(0, function() self:Remove() end)
		end
	end
	
	self:NextThink(CurTime() +0.05)
	
	return true
end