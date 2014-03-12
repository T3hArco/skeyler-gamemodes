AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

AccessorFunc(ENT, "m_eElevator", "Elevator")
AccessorFunc(ENT, "m_iElevatorID", "ElevatorID", FORCE_NUMBER)

--------------------------------------------------
--
--------------------------------------------------

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:DrawShadow(false)
	
	--[[self.light = ents.Create("env_sprite")
	self.light:SetPos(self:GetPos() -self:GetForward() *2)
	self.light:SetKeyValue("rendercolor", "0 255 0")
	self.light:SetKeyValue("rendermode", "3")
	self.light:SetKeyValue("scale", "0.5")
	self.light:SetKeyValue("spawnflags", "1")
	self.light:SetKeyValue("model", "sprites/light_glow02.spr")
	self.light:Spawn()
	self.light:Activate()
	]]
	
	self.light = ents.Create("env_lightglow")
	self.light:SetPos(self:GetPos() -self:GetForward() *2)
	self.light:SetKeyValue("rendercolor", "0 255 0")
	self.light:SetKeyValue("VerticalGlowSize", "7")
	self.light:SetKeyValue("HorizontalGlowSize", "7")
	self.light:SetKeyValue("MinDist", "0")
	self.light:SetKeyValue("MaxDist", "250")
	self.light:SetKeyValue("OuterMaxDist", "2000")
	self.light:SetKeyValue("GlowProxySize", "4")
	self.light:Spawn()
	self.light:Activate()
	
	--[[
	self.light.sprite = ents.Create("env_sprite")
	self.light.sprite:SetPos(self:GetPos() -self:GetForward() *2)
	self.light.sprite:SetKeyValue("rendercolor", "0 255 0")
	self.light.sprite:SetKeyValue("rendermode", "3")
	self.light.sprite:SetKeyValue("scale", "0.1")
	self.light.sprite:SetKeyValue("spawnflags", "1")
	self.light.sprite:SetKeyValue("model", "sprites/light_glow02.spr")
	self.light.sprite:Spawn()
	self.light.sprite:Activate()
]]
	self:SetRed()
end

--------------------------------------------------
--
--------------------------------------------------

function ENT:KeyValue(key, value)
	if (key == "hammerid") then
		self:SetElevatorID(value)
	end
end

--------------------------------------------------
--
--------------------------------------------------

function ENT:SetRed()
	self.light:SetKeyValue("rendercolor", "255 0 0")
	--self.light.sprite:SetKeyValue("rendercolor", "255 0 0")
end

--------------------------------------------------
--
--------------------------------------------------

function ENT:SetGreen()
	self.light:SetKeyValue("rendercolor", "0 255 0")
	--self.light.sprite:SetKeyValue("rendercolor", "0 255 0")
end