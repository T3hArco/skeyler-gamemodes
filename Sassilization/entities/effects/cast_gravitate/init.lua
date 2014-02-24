/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Position = data:GetStart()			--Where the effect takes place
	self.WeaponEnt = data:GetEntity()
	self.Scale = data:GetScale()			--Radius of effect
	self.Magnitude = data:GetMagnitude()		--basically time effect takes place, usually Radius/10 or Radius/20
	self.LifeSpan = CurTime() + self.Magnitude
	self.MaxLifeSpan = CurTime() + self.Magnitude
	self.c = self.WeaponEnt:GetColor()
	
	
	self.StartAlpha = 255				--starting alpha of the particles
	self.Emitter = ParticleEmitter( self.Position )
	
		
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	local LifeSpan = self.LifeSpan - CurTime()
	if LifeSpan > 0 then 

		--Set a random angle, and normalise it.
		local Angle = Vector(math.Rand(-100,100),math.Rand(-100,100),0):GetNormalized()		--basically grabs a random normalized vector
		local startpos = self.Position + Angle * math.Rand(0,self.Scale) -- spawns a random dot in the radius
		local tempColor = math.Rand(155,255) / 255
		
		local particle = self.Emitter:Add( "particles/fire_glow",  startpos ) -- Defines the sprite used
			
			particle:SetVelocity(Vector(0,0,math.Rand(20,50)))	--should be a bit faster than the other one... also...
			particle:SetDieTime( 1 )					-- time in seconds the particle is alive for
			particle:SetStartAlpha( self.StartAlpha )			-- Alpha value at the start of the particles life
			particle:SetEndAlpha( 0 )					-- Alpha value at the end of the particles life
			particle:SetStartSize( math.Rand( 0.5, 3 ) )		-- Size at the start of the particles life
			particle:SetEndSize(  math.Rand( 0.5, 3 ) )--Size at the end of the particles life
			particle:SetRoll( math.Rand( self.Scale/10, self.Scale/2.5 ) )	 --particle 'orientation'
			particle:SetRollDelta( math.random( -1, 1 ) )			--how fast the particle turns
			particle:SetColor(self.c.r*tempColor,self.c.g*tempColor,self.c.b*tempColor)					--Particle colour, always has a blue tint
			particle:VelocityDecay( false )					--If particle suffers drag.
		return true
	else
		self.Emitter:Finish()							--finish; end the emitter
		return false
	end
end


--If you don't have a render function it errors out
function EFFECT:Render() 
end
