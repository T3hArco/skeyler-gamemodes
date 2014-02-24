-- Bombard Cloud effect by Mahalis for Sassilization
EFFECT.lastEmd = 0
EFFECT.setup = false
EFFECT.ePos = Vector()
EFFECT.SpawnedTime = 0
EFFECT.Radius = 44
EFFECT.LifeTime = 0.8

local function rndSph()
	return Vector(math.random()*2 - 1,math.random()*2 - 1,math.random()*2 - 1):GetNormal()
end

function EFFECT:Init(data)
	self.SpawnedTime = CurTime()
	self.ePos = data:GetOrigin()
	self.LifeTime = data:GetMagnitude()
	self.Radius = data:GetScale()
	self.setup = true
end

function EFFECT:Think()
	if not self.setup then return true end
	
	if CurTime() < self.SpawnedTime + self.LifeTime then
		if self.lastEmd + 0.08 < CurTime() then
			local rd = ((CurTime() - self.SpawnedTime) / (self.LifeTime * 0.75)) * self.Radius
			self:Emit(math.Clamp(rd,4,self.Radius+4))
			
			self.lastEmd = CurTime()
		end
		
		self.Entity:NextThink(CurTime())
		return true
	else
		return false
	end
end

function EFFECT:Emit(radius)
	local ePos = self.ePos
	
	local emitter = ParticleEmitter(ePos,false)
	
	local particle
	
	local rPct = radius/(self.Radius+4)
	
	for i=0,math.ceil(radius*1.2) do
		local pPos = rndSph() * radius * 0.3
		pPos.z = pPos.z * (1.0-(rPct*0.95))
		local vel = pPos * 10
		particle = emitter:Add("particle/smokesprites_000" .. tostring(math.floor(math.random() * 9 + 1)),ePos + pPos)
		if particle then
			particle:SetVelocity(vel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.9)
			particle:SetStartAlpha(100 + math.random()*100)
			particle:SetEndAlpha(0)
			particle:SetStartSize((3 + 3*rPct) + math.random() * 2)
			particle:SetEndSize((8 + 4*rPct) + math.random() * 6)
			local pBr = 60 * math.random() + 10
			particle:SetColor(pBr,pBr,pBr,255)
			particle:SetAirResistance(400)
			particle:SetRoll(math.random()*3 - 1.5)
			particle:SetRollDelta(math.random() * 2 - 1)
		end
	end
end

function EFFECT:Render()
end
