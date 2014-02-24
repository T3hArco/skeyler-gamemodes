function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	
	if not IsValid( self.Ent ) then
		self.Ent = nil
		return
	end

	if self.Ent:GetClass() == "unit_nw_entity" then
		self.count = 1
	else
		self.count = 2
	end
	
	self.Sc = data:GetScale()
	self.LifeTime = data:GetMagnitude()
	self.LifeTime = self.LifeTime and CurTime() + self.LifeTime or nil
	self.Mins = self.Ent:OBBMins()/2
	self.Maxs = self.Ent:OBBMaxs()/2
	self.Emitter = ParticleEmitter( self.Ent:GetPos() )
end

function EFFECT:Think( )
	if not self.Ent then return false end
	if not IsValid( self.Ent ) then self.Emitter:Finish() return false end
	if self.LifeTime and CurTime() > self.LifeTime then self.Emitter:Finish() return false end
	
	self.Size = math.Rand(4,8) * self.Sc
	
	local position = self.Ent:LocalToWorld(self.Ent:OBBCenter())
	position.z = self.Ent:GetPos().z
	
	for i = 1, self.count do
		local random = Vector(math.Rand(self.Mins.x or 0, 1), math.Rand(self.Mins.y or 0, 1), -self.Mins.z*2) +Vector(math.Rand(-1, self.Maxs.x or 0), math.Rand(-1, self.Maxs.y or 0), self.Mins.z*2)
		local particle = self.Emitter:Add("effects/fire_cloud1", position +random)
	
		particle:SetVelocity(Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(1,10)))
		particle:SetDieTime( math.Rand(0.5,1) )
		particle:SetStartAlpha( math.Rand( 130, 150 ) )
		particle:SetEndAlpha(1)
		particle:SetStartSize( self.Size )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.Rand( -95, 95 ) )
		particle:SetRollDelta( math.Rand( -0.1, 0.1 ) )
		particle:SetColor( math.Rand( 150, 255 ), math.Rand( 120, 150 ), 100 )
		particle:SetGravity(Vector(0, 0, 20))
	end
	
	return true
end

function EFFECT:Render()
end