function EFFECT:Init( effectdata ) 
	self.pos = effectdata:GetOrigin()
	self.Entity:SetPos(startpoint)
	self.radius = effectdata:GetRadius()
	self.Alpha = 255
	self.Time = CurTime() + effectData:GetMagnitude()*0.5 --if magnitude given is 1, effect will last for 0.5seconds
	self.Em = ParticleEmitter(self.pos)
end

function EFFECT:Think()
	for i=1, 20 do
		local part = em:Add("particles/smokey",self.Em)
		if part then
			part:SetColor(150,150,150,math.random(255))
			part:SetVelocity(Vector(0.0001,0.0001,0.0001))
			part:SetDieTime(self.Secs)
			part:SetStartAlpha(255)
			part:SetEndAlpha(0)
			part:SetLifeTime(0)
			part:SetStartSize(10)
			part:SetEndSize(0)
		end
	end
	return self.Time > CurTime()
end

function EFFECT:Render()

end