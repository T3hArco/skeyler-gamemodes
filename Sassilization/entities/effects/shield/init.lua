function EFFECT:Init(data)
	
	self.Origin = data:GetOrigin()
	self.Hitpos = data:GetStart()
	self.Normal = ( self.Hitpos - self.Origin ):GetNormal()
	self.LifeTime = RealTime() + 1.5
	
	self.Entity:SetModel( "models/jaanus/monoshield.mdl" )
	self.Entity:SetPos( self.Origin )
	
	local	ang = self.Normal:Angle()
		ang.p = ang.p + 90
	self.Entity:SetAngles( ang )
	
	local emitter = ParticleEmitter( self.Hitpos )
		
		local a = self.Normal:Angle()
		local right = a:Right()
		local up = a:Up()
		local speed = 6
		for i=0, 20 do
			local particle = emitter:Add( "effects/energyball", self.Hitpos )
				local rPct = (i/21) * math.pi * 2
				particle:SetVelocity( (right * math.cos(rPct) + up * math.sin(rPct)) * speed )
				particle:SetDieTime( math.Rand( 1.0, 2.0 ) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 6, 10 ) )
				particle:SetEndSize( math.Rand( 2, 4 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetColor( 95, 250, 240 )
		end
		
	emitter:Finish()
	
end

function EFFECT:Think( )
	
	local timeleft = self.LifeTime - RealTime()
	if timeleft > 1 then
		local percent = (1-timeleft)/0.5
		self.Entity:SetColor( Color(255, 255, 255, 255*percent) )
		return true
	elseif timeleft > 0 then
		local percent = timeleft
		self.Entity:SetColor( Color(255, 255, 255, 255*percent) )
		return true
	else return false end
	
end

function EFFECT:Render()
	
	self.Entity:DrawModel()
	
end



