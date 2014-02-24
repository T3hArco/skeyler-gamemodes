--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	
end

function ENT:Setup(ProjModel)
	self:SetModel(ProjModel)
	
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self:DrawShadow(false)
	
	self.Trail = util.SpriteTrail(self, 0, Color(180, 180, 180, 80), false, 1, 0.01, 0.5, 0.5, "trails/laser.vmt")
	
	timer.Simple(2, function() SafeRemoveEntity(self) end )
end

function ENT:Shoot(Damage, Dir)
	self.Damage = Damage
	
	local Phys = self:GetPhysicsObject()
	
	if (Phys:IsValid()) then
		Phys:Wake()
		Phys:SetVelocity(Dir:Forward() * Phys:GetMass() * 10)
	end
end

function ENT:GetEmpire()
	return self.empire
end

function ENT:SetControl(Empire)
	self.empire = Empire
	self:SetColor(Empire:GetColor())
end

function ENT:StartTouch(Ent)
	if (self.Fail) then
		return
	end
	
	self:HitEnt(Ent, self:GetPhysicsObject())
	SafeRemoveEntity(self)
end

function ENT:PhysicsCollide(data, Phys)
	if (self.Fail) then
		return
	end
	
	if (data.HitEntity:IsWorld()) then
		self.Fail = true
		Phys:EnableMotion(false)
	else
		self:HitEnt(data.HitEntity, Phys)
		SafeRemoveEntity(self)
	end
end

function ENT:HitEnt(Ent, Phys)
	if (Ent:IsUnit() or Ent:IsBuilding()) then
		if (self.empire != Ent:GetEmpire() and !Allied(self.empire, Ent:GetEmpire())) then
			self.Fail = true
			
			if (Ent.Damage) then
				self.Damage.dmgpos = Phys:GetPos()
				Ent:Damage(self.Damage)
			end
		end
	end
end