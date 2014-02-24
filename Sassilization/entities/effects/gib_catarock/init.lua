Gibs_Stone = {
	"models/props_combine/breenbust_chunk05.mdl",
	"models/props_combine/breenbust_chunk06.mdl",
	"models/props_combine/breenbust_chunk07.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl",
	"models/mrgiggles/sassilization/brick_small.mdl"
}

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
	end
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity(true);
		phys:Wake();
		phys:SetVelocity(Vector(math.random(-0.1,0.1),math.random(-0.1,0.1),math.random(0,2)))
		phys:ApplyForceCenter(Vector(math.random(-0.1,0.1),math.random(-0.1,0.1),math.random(0,2)))
	end
	self.Time = RealTime() + math.random(1, 3)
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
	
end
