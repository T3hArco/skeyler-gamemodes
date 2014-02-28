include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local width, height = 64, 32
local camOffset = Vector(0.1, -width, height)
local camScale = 0.026

surface.CreateFont("SassLeaderboard", {
	font 		= "Helvetica",
	size 		= 160,
	weight 		= 1000,
	blursize 	= 1
})

surface.CreateFont("SassLeaderboard_Shadow", {
	font 		= "Helvetica",
	size 		= 160,
	weight 		= 1000,
	blursize 	= 32,
	antialias 	= false
})

local Leaders = {}

Leaders[true] = {}

for i =1,5 do
Leaders[true][i] = {"Chewgum2", math.random(100, 10000)}
end

ENT.Weekly = false

function ENT:Initialize()
	local Width, Height = 128, 64
	
	self.CamPos = self:GetPos() + self:GetForward() * 0.1 + self:GetRight() * Width * 0.5 + self:GetUp() * Height * 0.5
	
	local Ang = self:GetAngles()
	self.CamAng = Angle(0, Ang.y + 90, Ang.p + 90)
	
	self.Bounds = Vector(1, 1, 1) * Width
	
	if(self:GetClass() == "info_weeklyleaderboard") then
		self.Weekly = true
	end
	
	self.intersectPoint = Vector()
	self.projectionPos = self:LocalToWorld(camOffset)
	self.projectionAng = self.CamAng
	self.projectionNorm = self:GetForward()
	self.mousePos = Vector()
end

local color_text = Color(230, 230, 230)
local color_shadow = Color(0, 0, 0, 160)

function ENT:DrawTranslucent()
	self:SetRenderBounds(self.Bounds * -1, self.Bounds)
	
	cam.Start3D2D(self.CamPos, self.CamAng, 0.1)
		surface.SetDrawColor(255, 255, 255, 255)
		
		if(self.BackdropTexture) then
			surface.SetTexture(self.BackdropTexture)
		end
		
		surface.DrawTexturedRect(0, 0, 1280, 640)
		
		
	cam.End3D2D()
	
	cam.Start3D2D(self.CamPos, self.CamAng, 0.026)
		
		self:PaintLeaderboard()
		self:DrawMouse()
		
	cam.End3D2D()
end

function ENT:PaintLeaderboard()
	if(self.BackdropTexture and Leaders[self.Weekly]) then
		local spacing = 0
		
		for k,v in ipairs(Leaders[self.Weekly]) do
			if(v[2] > 0) then
				draw.SimpleText(v[1], "SassLeaderboard_Shadow", 2850, 612 +spacing, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(v[2], "SassLeaderboard_Shadow", 4410, 612 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				draw.SimpleText(v[1], "SassLeaderboard", 2852, 615 +spacing, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(v[1], "SassLeaderboard", 2850, 612 +spacing, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				
				draw.SimpleText(v[2], "SassLeaderboard", 4412, 615 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(v[2], "SassLeaderboard", 4410, 612 +spacing, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				spacing = spacing +154
			else
				break
			end
		end
	end
end

function ENT:UpdateMouse()
	self.intersectPoint = false
	self.intersectPoint = intersectRayPlane(EyePos(), EyePos() +(LocalPlayer():GetAimVector()*2000), self.projectionPos, self.projectionNorm )

	if(self.intersectPoint)then
		self.mousePos = self:WorldToLocal(self.intersectPoint) -camOffset
	
		self.mousePos.x = self.mousePos.y
		self.mousePos.y = -self.mousePos.z
		self.mousePos = self.mousePos /camScale
	end
	
end

function ENT:DrawMouse()
	self:UpdateMouse()
	if( self.mousePos and self.mousePos.x > 0 &&
		self.mousePos.y > 0 &&
		self.mousePos.x < width * 2 / camScale &&
		self.mousePos.y < height * 2 / camScale) then
		
		surface.SetDrawColor(Color(0,0,0,200))
		surface.DrawRect( self.mousePos.x - 12, self.mousePos.y - 12, 24, 24 )
		surface.SetDrawColor(Color(0,0,0,200))
		surface.DrawOutlinedRect( self.mousePos.x - 12, self.mousePos.y - 12, 24, 24 )
		
		--DrawText( tostring(math.Round(self.mousePos.x)).." "..tostring(math.Round(self.mousePos.y)), self.mousePos.x, self.mousePos.y+20 )
	end
	
end

net.Receive("Leaderboard.Update", function(bits)
	local ID = tobool(net.ReadBit())
	
	Leaders[ID] = {}
	
	for i = 1,10 do
		local Name = net.ReadString()
		local Wins = net.ReadShort()
		
		Leaders[ID][i] = {Name, Wins}
	end
end)

--RunConsoleCommand("dicks")