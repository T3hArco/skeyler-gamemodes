local matLight = Material( "models/shiny" )
local matRefract = Material( "models/spawn_effect" )

function EFFECT:Init( data )
	
 	self.Time = .5
 	self.LifeTime = CurTime() + self.Time 
 	
 	local ent = data:GetEntity()
	if not ( IsValid( ent ) and ent ~= NULL ) then
		if( CL_DISSOLVE_ENT ) then
			ent = CL_DISSOLVE_ENT
			CL_DISSOLVE_ENT = nil
		else self.clear = true return end
	end
 	
	self.ParentEntity = ent
	self:SetModel( ent:GetModel() )
	self:SetPos( ent:GetPos() )
	self:SetAngles( ent.upright and Angle( 0, ent.ang.y, 0 ) or (ent.ang or ent:GetAngles()) )
	self:SetParent( ent )
	self:ResetSequence( ent:GetSequence() )
	
	local vOffset = ent:GetPos()
	local Low, High = ent:WorldSpaceAABB()
	
	local NumParticles = ent:BoundingRadius()
	NumParticles = NumParticles * 6
	
	NumParticles = math.Clamp( NumParticles, 32, 256 )
	
	local emitter = ParticleEmitter( vOffset )
		
		for i=0, NumParticles do
			
			local vPos = Vector( math.Rand(Low.x,High.x), math.Rand(Low.y,High.y), math.Rand(Low.z,High.z) )
			local particle = emitter:Add( "particles/balloon_bit", ent:GetPos() )
			if (particle) then
				
				particle:SetVelocity( (vPos - vOffset) * 10 )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 0.5, 1.0 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 2 )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( 0 )
				
				particle:SetAirResistance( 100 )
				particle:SetGravity( Vector( 0, 0, -700 ) )
				particle:SetCollide( true )
				particle:SetBounce( 0.3 )
				
			end
			
		end
		
	emitter:Finish()
 	
end

function EFFECT:Think()
	
	if self.clear then return false end
	return ( self.LifeTime > CurTime() )
	
end

function EFFECT:Render()
	
	if self.Entity == NULL then return end
	if self.ParentEntity:IsPlayer() then return end
	
	local Fraction = (self.LifeTime - CurTime()) / self.Time
	Fraction = math.Clamp( Fraction, 0, 1 )
	
	self.Entity:SetColor( Color( 55, 255, 255, Fraction * 255 ) )
	
	local EyeNormal = self.Entity:GetPos() - EyePos()
	local Distance = EyeNormal:Length()
	EyeNormal:Normalize()
	
	local Pos = EyePos() + EyeNormal * Distance * 0.01
	
	cam.Start3D( Pos, EyeAngles() )
		
		render.MaterialOverride( matLight )
			self:DrawModel()
		render.MaterialOverride( 0 )
		
		-- If our card is DX8 or above draw the refraction effect
		if ( render.GetDXLevel() >= 80 ) then
			
			-- Update the refraction texture with whatever is drawn right now
			render.UpdateRefractTexture()
			
			matRefract:SetFloat( "$refractamount", Fraction ^ 2 * 0.05 )
			
			render.MaterialOverride( matRefract )
				self.Entity:DrawModel()
			render.MaterialOverride( 0 )
			
		end
		
	cam.End3D()
  
end