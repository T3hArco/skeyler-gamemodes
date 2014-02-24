function EFFECT:Init( data )

	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Scale = data:GetScale()
	self.Magnitude = data:GetMagnitude()
	self.LifeSpan = CurTime() + self.Magnitude
	self.MaxLifeSpan = CurTime() + self.Magnitude
	
	self.StartAlpha = 35
	self.Emitter = ParticleEmitter( self.Position )
		
end

function EFFECT:Think( )
	local HowFast = self.Scale / 5
	local LifeSpan = self.LifeSpan - CurTime()
	if LifeSpan > 0 then 
		for i=1,10 do
			local Angle = Vector(math.Rand(-100,100),math.Rand(-100,100),0):GetNormalized()
			local particle = self.Emitter:Add( "particles/flamelet"..math.Round(math.Rand(1,5)),  self.Position )
				particle:SetVelocity(Angle * HowFast*4)
				particle:SetDieTime( HowFast/8 )
				particle:SetStartAlpha( self.StartAlpha )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 1, self.Scale/5 ) )
				particle:SetEndSize( math.Rand( self.Scale/10, self.Scale/2.5 ) )
				particle:SetRoll( math.Rand( self.Scale/10, self.Scale/2.5 ) )
				particle:SetRollDelta( math.random( -1, 1 ) )
				particle:SetColor(35,230,40)
				particle:VelocityDecay( false )
		end
		return true
	else
		self.Emitter:Finish()
		return false	
	end
end

function EFFECT:Render() 
end
