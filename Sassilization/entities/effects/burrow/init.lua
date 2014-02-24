function EFFECT:Init( data )
	
 	self.Time = .5
 	self.LifeTime = CurTime() + self.Time 
 	
 	local ent = EFFECT_ENT
	if( not ( IsValid( ent ) and ent ~= NULL ) ) then
		self.clear = true
		return
	end
	
	local tr = {}
	tr.start = ent:GetPos()
	tr.endpos = tr.start + Vector( 0, 0, -10 )
	tr.mask = MASK_SOLID_BRUSHONLY
	tr = util.TraceLine( tr )
	if not tr.Hit then tr.HitPos = ent:GetPos() end
 	
	self.normal = tr.HitNormal
	self.origin = tr.HitPos + self.normal
	self.ParentEntity = ent
	self:SetModel( ent:GetModel() )
	self:SetPos( self.origin )
	self:SetAngles( ent.upright and Angle( 0, ent.ang.y, 0 ) or (ent.ang or ent:GetAngles()) )
	self:SetColor( ent:GetColor() )
	self:DrawShadow( false )
	self:ResetSequence( ent:GetSequence() )
	
	local vOffset = self:OBBCenter()
	
	self.radius = self:BoundingRadius()
	
	self.Emitter = ParticleEmitter( vOffset )
 	
end

function EFFECT:Think()
	
	if self.clear then
		if( self.Emitter ) then
			self.Emitter:Finish()
		end
		return false
	end
	if not ( self.LifeTime > CurTime() ) then
		if( self.Emitter ) then
			self.Emitter:Finish()
		end
		return false
	end
	
	self:SetPos( self.origin - self.normal * 10 * (1-math.Max(self.LifeTime-CurTime(),0)/self.Time) + self.normal )
	
	local Col = Color(180, 0, 0)
	for i=1,math.random(2,3) do
		
		local particle = self.Emitter:Add("particles/smokey", self.origin+Vector(math.Rand(-self.radius,self.radius),math.Rand(-self.radius,self.radius),0) )
		
		particle:SetVelocity(Vector(math.Rand(-6,6),math.Rand(-6,6),math.Rand(0,1)):GetNormal()*self.radius*2)
		particle:SetDieTime( math.Rand(1,1.5) )
		particle:SetStartAlpha( math.Rand( 80, 100 ) )
		particle:SetEndAlpha( 1 )
		particle:SetStartSize( math.Rand(6,10) )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.Rand( -95, 95 ) )
		particle:SetRollDelta( math.Rand( -0.1, 0.1 ) )
		Col.r = math.Rand( 70, 80 )
		Col.g = math.Rand( 50, 65 )
		particle:SetColor( Col )
		
	end
	
	return true
	
end

function EFFECT:Render()
	
	if self.Entity == NULL then return end
	
	local c = self:GetColor()
	local Fraction = (self.LifeTime - CurTime()) / self.Time
	Fraction = math.Clamp( Fraction, 0, 1 )
	
	c.a = 255*Fraction
	self:SetColor( c )
	self:DrawModel()
  
end