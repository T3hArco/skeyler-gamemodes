--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

AccessorFunc( ENT, "m_Empire", "Empire" )

function ENT:Setup(ResourceModel)
	self:SetModel(ResourceModel)
	
	self:SetMoveType(MOVETYPE_NONE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:PhysicsInitBox( self:OBBMins(), self:OBBMaxs() )
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self:DrawShadow(false)
	
	local Phys = self:GetPhysicsObject()
	if(Phys:IsValid()) then
		Phys:EnableMotion(false)
	end
	
	local Trace = {}
 	Trace.start = self:GetPos()
	Trace.endpos = Trace.start - Vector(0, 0, 320)
	Trace.mask = SOLID
	Trace.filter = self
	local tr = util.TraceLine(Trace)
	if(tr.HitWorld) then
		self:SetPos(tr.HitPos + (tr.HitNormal * 2))
		local Ang = tr.HitNormal:Angle()
		Ang.p = Ang.p + 90
		if(tr.HitNormal == Vector(0, 0, 1)) then
			Ang.y = math.random(0, 360)
		end
		self:SetAngles(Ang)
	end
end

function ENT:UpdateControl()
	
	for k,v in ipairs(ents.FindInSphere(self:GetPos(), 40)) do
		if((v:GetClass() == "building_city" or v:GetClass() == "building_house") and v:IsBuilt() and not v.Destroyed) then
			if(self:GetEmpire()) then
				if(v:GetEmpire() == self:GetEmpire()) then
					return
				end
			elseif(v:GetEmpire()) then
				self:SetControl(v:GetEmpire(), v)
				return
			end
		end
	end
	if( self:GetEmpire() ) then
		self:RemoveControl()
	end
end

function ENT:SetControl(Empire, Ent)
	
	self:SetEmpire(Empire)
	
	if(not IsValid(self.Shack)) then
		self.Shack = ents.Create("prop_dynamic")
		self.Shack:SetModel("models/mrgiggles/sassilization/shack.mdl")
		self.Shack:SetPos(self:GetPos() + (self:GetRight() * math.random(5, 6)) + (self:GetUp() * -5))
		self.Shack:SetAngles(Angle(self:GetAngles().p, math.random(0, 360), self:GetAngles().r))
		self.Shack:Spawn()
		self.Shack:Activate()
		self.Shack.IsShack = true
	end
	
	self.Shack:SetColor(Empire:GetColor())
	self:OnControl(Empire, true)
	
end

function ENT:RemoveControl()
	SafeRemoveEntity(self.Shack)
	
	self.Shack = false
	
	if(IsValid(self:GetEmpire())) then
		self:OnControl(self:GetEmpire(), false)
	end
	
	self:SetEmpire(nil)
end
