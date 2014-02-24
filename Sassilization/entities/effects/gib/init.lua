Gibs_Wood = {
	"models/gibs/furniture_gibs/FurnitureTable002a_Chunk03.mdl",
	"models/gibs/wood_gib01a.mdl",
	"models/gibs/wood_gib01b.mdl",
	"models/gibs/wood_gib01c.mdl",
	"models/gibs/wood_gib01d.mdl",
	"models/gibs/wood_gib01e.mdl"
}

Gibs_Stone = {
	"models/props_combine/breenbust_chunk05.mdl",
	"models/props_combine/breenbust_chunk06.mdl",
	"models/props_combine/breenbust_chunk07.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl"
}

for i, v in ipairs( Gibs_Wood ) do
	
	util.PrecacheModel(v)
	
end

for i, v in ipairs( Gibs_Stone ) do
	
	util.PrecacheModel(v)
	
end

function EFFECT:Init( data )
	
	local modelid = data:GetScale()
	self.type = math.Round(tonumber(data:GetMagnitude()))

	if self.type == GIB_STONE then
		self.Entity:SetModel(Gibs_Stone[modelid])
		
		local mins, maxs = Vector(-1, -1, -1), Vector(1, 1, 1)
		
		self.Entity:SetSolid( SOLID_BBOX )
		self.Entity:PhysicsInitBox( mins, maxs )
		self.Entity:SetCollisionBounds( mins, maxs )
		self.Entity:SetModelScale( 0.5, 0 )
	elseif self.type == GIB_WOOD then
		self.Entity:SetModel(Gibs_Wood[modelid])
		local mins, maxs = Vector(-4, -4, -4), Vector(4, 4, 4)
		self.Entity:SetSolid( SOLID_BBOX )
		self.Entity:PhysicsInitBox( mins, maxs )
		self.Entity:SetCollisionBounds( mins, maxs )
		self.Entity:SetModelScale( 0.1, 0 )
	end
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetAngles(Angle( math.Rand(0,360), math.Rand(0,360), math.Rand(0,360)))
		if self.type == GIB_STONE then
			phys:ApplyForceCenter(VectorRand() * math.Rand(0, 2))
		else
			phys:ApplyForceCenter(VectorRand() * math.random(2, 4))
		end
	end
	self.Time = RealTime() + math.random(8, 12)
	self.Emitter = ParticleEmitter(self.Entity:GetPos())
	self.setup = IsValid( self.Entity )
	
end

function EFFECT:Think()
	
	if not self.setup then
		self.Emitter:Finish()
		return false
	end
	
	if RealTime() > self.Time then
		self.Emitter:Finish()
		return false
	end
	
	return true
	
end

function EFFECT:Render()
	
	if not self.setup then return end
	
	self.Entity:DrawModel()
	
	if self.Entity:GetVelocity():Length() > 10 and self.Entity:WaterLevel() == 0 and self.type == GIB_WOOD then
		
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
	
end