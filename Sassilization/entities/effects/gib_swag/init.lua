EFFECT.Time = math.Rand(5, 10)

function EFFECT:Init(data)
	local pos = data:GetOrigin()

	self.Entity:SetModel("models/jaanus/scallywag_broken.mdl")

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.Entity:SetCollisionBounds( Vector( -128 -128, -128 ), Vector( 128, 128, 128 ) )

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetAngles(Angle( math.Rand(-16,16), math.Rand(-16,16), math.Rand(-16,16)))
		phys:ApplyForceCenter(VectorRand() * math.Rand(20, 60))
	end
	self.Time = RealTime() + math.random(8, 12)
	self.Emitter = ParticleEmitter(self.Entity:GetPos())
end

function EFFECT:Think()
	if RealTime() > self.Time then
		self.Emitter:Finish()
		return false
	end
	return true
end

function EFFECT:Render()
	self.Entity:DrawModel()
	/*
	if self.Entity:GetVelocity():Length() > 5 then
		local particle = self.Emitter:Add("particles/flamelet"..math.random(1,4), self.Entity:GetPos())
		particle:SetVelocity(VectorRand() * 16)
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(255)
		particle:SetStartSize(18)
		particle:SetEndSize(8)
		particle:SetRoll(180)
		particle:SetColor(80, 80, 80)
		particle:SetLighting(true)
	end
	*/
end
