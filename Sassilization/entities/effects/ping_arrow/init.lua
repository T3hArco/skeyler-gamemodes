function EFFECT:Init( data )
	
	self.Position = data:GetStart()
	self.Creator = data:GetEntity()
	self.ParticleAngle = data:GetAngles()
	self.LifeTime = CurTime() + 3.5

	self:SetRenderBoundsWS( Vector(999999, 999999, 999999), -Vector(999999, 999999, 999999) )

	
	if !self.Creator or !self.Creator:GetEmpire() or !self.Creator:GetEmpire():GetColor() then return end
	
	self.ParticleColor = self.Creator:GetEmpire():GetColor()
	
	Pos = self.Position
	if timer.Exists(tostring(self.Creator) .. "ping") then 
		self.LifeTime = -1
		return 
	end

	sound.Play("buttons/blip1.wav", self.Position, 100, 100, 1)
	timer.Create(tostring(self.Creator) .. "ping", 0.75, 3, function()
		sound.Play("buttons/blip1.wav", self.Position, 100, 100, 1)
		self.circleSize2 = 0
		self.circle2Alpha = 255
		self.ballSpeed = 500
		self.ballAngleNew = Angle(math.random(0,360), math.random(0,360), math.random(0,360))
	end)

	local emitter = ParticleEmitter( Pos )

	for i=1,5 do
			
		local particle = emitter:Add( "particle/particle_smokegrenade", Pos )
			local spawnpos = Vector(math.random(-100,100),math.random(-100,100),0)
			local velvec = spawnpos:GetNormalized()
			local velmult = math.random(10,30)
			particle:SetVelocity(velvec*velmult)
			particle:SetLifeTime(0)
			particle:SetDieTime(3)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize( 70 )
			particle:SetEndSize( 70 )
			particle:SetRoll( math.Rand(360,480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b )
			particle:SetCollide( true )
			particle:SetBounce( 1 )
	end

	emitter:Finish()


	self.circleSize = 0
	self.circleSize2 = 0
	self.circle2Alpha = 255
	self.ballSpeed = 500
	self.ballAngle = Angle(0, 0, 0)
	self.ballAngleNew = Angle(math.random(0,360), math.random(0,360), math.random(0,360))
	
end


function EFFECT:Think( )
	if self.LifeTime == -1 then
		return false
	end
	if CurTime() > self.LifeTime then
		timer.Destroy(tostring(self.Creator) .. "ping")
		return false
	end
	self.spd = 2000*FrameTime()
	self.spd2 = 850*FrameTime()
	self.spd3 = self.ballSpeed*FrameTime()
	self.spd4 = 750*FrameTime()

	if self.ballAngle.p == self.ballAngleNew.p then
		self.ballAngleNew.p = self.ballAngleNew.p + 360
	end
	if self.ballAngle.y == self.ballAngleNew.y then
		self.ballAngleNew.y = self.ballAngleNew.y + 360
	end
	if self.ballAngle.r == self.ballAngleNew.r then
		self.ballAngleNew.r = self.ballAngleNew.r + 360
	end

	self.circleSize = math.Approach(self.circleSize, 200, self.spd)
	self.circleSize2 = math.Approach(self.circleSize2, 500, self.spd2)
	self.circle2Alpha = math.Approach(self.circle2Alpha, 0, self.spd2)
	self.ballSpeed = math.Approach(self.ballSpeed, 0, self.spd4)
	self.ballAngle.p = math.Approach(self.ballAngle.p, self.ballAngleNew.p, self.spd3)
	self.ballAngle.y = math.Approach(self.ballAngle.y, self.ballAngleNew.y, self.spd3)
	self.ballAngle.r = math.Approach(self.ballAngle.r, self.ballAngleNew.r, self.spd3)

	return true
end

local tex = surface.GetTextureID("sassilization/indicator")
local tex2 = surface.GetTextureID("sassilization/dashed_circle")
function EFFECT:Render()
	cam.IgnoreZ(true)

			--Doing this same thing twice so it renders from both sides
			cam.Start3D2D( self.Position, self.ParticleAngle + Angle(90,0,0), 1 )
				surface.SetTexture(tex)
				surface.SetDrawColor(self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b, 255)
				surface.DrawTexturedRect( -self.circleSize/2, -self.circleSize/2, self.circleSize, self.circleSize)

				surface.SetTexture(tex)
				surface.SetDrawColor(self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b, self.circle2Alpha)
				surface.DrawTexturedRect( -self.circleSize2/2, -self.circleSize2/2, self.circleSize2, self.circleSize2)
			cam.End3D2D()

			cam.Start3D2D( self.Position, self.ParticleAngle + Angle(270,0,0), 1 )
				surface.SetTexture(tex)
				surface.SetDrawColor(self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b, 255)
				surface.DrawTexturedRect( -self.circleSize/2, -self.circleSize/2, self.circleSize, self.circleSize)

				surface.SetTexture(tex)
				surface.SetDrawColor(self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b, self.circle2Alpha)
				surface.DrawTexturedRect( -self.circleSize2/2, -self.circleSize2/2, self.circleSize2, self.circleSize2)
			cam.End3D2D()

			cam.Start3D2D( self.Position + self.ParticleAngle:Forward()*100, self.ParticleAngle + self.ballAngle, 1 )
				surface.SetTexture(tex2)
				surface.SetDrawColor(self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b, 255)
				surface.DrawTexturedRect( -70/2, -70/2, 70, 70)
			cam.End3D2D()

			cam.Start3D2D( self.Position + self.ParticleAngle:Forward()*100, self.ParticleAngle + Angle(0,0,90) + self.ballAngle, 1 )
				surface.SetTexture(tex2)
				surface.SetDrawColor(self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b, 255)
				surface.DrawTexturedRect( -70/2, -70/2, 70, 70)
			cam.End3D2D()

			cam.Start3D2D( self.Position + self.ParticleAngle:Forward()*100, self.ParticleAngle + Angle(0,0,180) + self.ballAngle, 1 )
				surface.SetTexture(tex2)
				surface.SetDrawColor(self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b, 255)
				surface.DrawTexturedRect( -70/2, -70/2, 70, 70)
			cam.End3D2D()

			cam.Start3D2D( self.Position + self.ParticleAngle:Forward()*100, self.ParticleAngle + Angle(0,0,270) + self.ballAngle, 1 )
				surface.SetTexture(tex2)
				surface.SetDrawColor(self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b, 255)
				surface.DrawTexturedRect( -70/2, -70/2, 70, 70)
			cam.End3D2D()


	local offScreen = self.Position:ToScreen()
	if tonumber( offScreen.x ) <= ScrW()*0.005 then
		offScreen.x = ScrW()*0.005
		offScreen.MoveX = true
	elseif tonumber( offScreen.x ) >= ScrW()*0.995 then
		offScreen.x = ScrW()*0.995
		offScreen.MoveX = true
	end
	if tonumber( offScreen.y ) <= ScrH()*0.005 then
		offScreen.y = ScrH()*0.005
		offScreen.MoveY = true
	elseif tonumber( offScreen.y ) >= ScrH()*0.995 then
		offScreen.y = ScrH()*0.995
		offScreen.MoveY = true
	end

	if offScreen.MoveX or offScreen.MoveY then
		render.SetViewPort( 0, 0, ScrW(), ScrH() )
		cam.Start2D()
			surface.SetMaterial(Material("widgets/arrow.png"))
			surface.SetDrawColor(self.ParticleColor.r, self.ParticleColor.g, self.ParticleColor.b, 255)
			local rotatedAngle = math.atan2(offScreen.y - (ScrH()*0.75 - ScrH()*0.05), offScreen.x - ScrW()/2)*180/math.pi
			surface.DrawTexturedRectRotated( ScrW()/2, ScrH()*0.75 - ScrH()*0.05, ScrW()*0.04, ScrH()*0.15, -rotatedAngle - 90)
		cam.End2D()
	end

	cam.IgnoreZ(false)
end