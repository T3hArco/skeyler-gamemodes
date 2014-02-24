EFFECT.Time = math.Rand(5, 10)

local MODELS = {
	"galleon_frontmast",
	"galleon_rearmast",
	"galleon_scuttled_front",
	"galleon_scuttled_rear"
}

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ang = data:GetAngle()
	local stage = math.Round(data:GetMagnitude())
	self.Entity:SetModel("models/jaanus/"..MODELS[stage]..".mdl")

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	--self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.Entity:SetCollisionBounds( Vector( -128 -128, -128 ), Vector( 128, 128, 128 ) )

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetAngles(Angle( math.Rand(-16,16), math.Rand(-16,16), math.Rand(-16,16)))
	end
	self.Time = RealTime() + math.random(8, 12)
end

function EFFECT:Think()
	if RealTime() > self.Time then
		return false
	end
	return true
end

function EFFECT:Render()
	self.Entity:DrawModel()
end
