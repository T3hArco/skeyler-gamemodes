----------
-- Lobby
----------

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:KeyValue(key, value)
	self[key] = tonumber(value)
	if(key == "perm")then
		self.Entity:SetNWString("perm", value)
	end
end

function ENT:Initialize()
	self:SetModel("models/props_lab/blastdoor001a.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER_MOVEMENT)
	self:DrawShadow(false)
	
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:EnableMotion(false)
	end
end
