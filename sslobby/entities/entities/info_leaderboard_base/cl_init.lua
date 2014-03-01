include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

surface.CreateFont("ss.leaderboard", {font = "Arvil Sans", size = 152, weight = 400, blursize = 1})
surface.CreateFont("ss.leaderboard.shadow", {font = "Arvil Sans", size = 152, weight = 400, blursize = 4, antialias = false})

local Leaders = {}

Leaders[true] = {}

for i =1,5 do
Leaders[true][i] = {"Chewgum", math.random(100, 10000)}
end

ENT.Weekly = false

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	local Width, Height = 128, 64
	
	self.CamPos = self:GetPos() + self:GetForward() * 0.1 + self:GetRight() * Width * 0.5 + self:GetUp() * Height * 0.5
	
	local Ang = self:GetAngles()
	self.CamAng = Angle(0, Ang.y + 90, Ang.p + 90)
	
	self.Weekly = self:GetClass() == "info_weeklyleaderboard"

	local bounds = Vector(Width, Width, Width)
	
	self:SetRenderBounds(bounds *-1, bounds)
end

---------------------------------------------------------
--
---------------------------------------------------------

local color_text = Color(39, 207, 255, 255)
local color_shadow = Color(0, 0, 0, 120)

function ENT:Draw()
	cam.Start3D2D(self.CamPos, self.CamAng, 0.1)
		surface.SetDrawColor(255, 255, 255, 255)
		
		if(self.BackdropTexture) then
			surface.SetTexture(self.BackdropTexture)
		end
		
		surface.DrawTexturedRect(0, 0, 1280, 640)
	cam.End3D2D()
	
	cam.Start3D2D(self.CamPos, self.CamAng, 0.02)
		self:PaintLeaderboard()
	cam.End3D2D()
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:PaintLeaderboard()
	if (self.BackdropTexture and Leaders[self.Weekly]) then
		local spacing = 0
		
		for k,v in ipairs(Leaders[self.Weekly]) do
			if(v[2] > 0) then
				draw.SimpleText(v[1], "ss.leaderboard.shadow", 3680, 662 +spacing, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				draw.SimpleText(v[1], "ss.leaderboard", 3680, 662 +spacing, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				
				draw.SimpleText(v[2], "ss.leaderboard.shadow", 5930, 662 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
				draw.SimpleText(v[2], "ss.leaderboard", 5930, 662 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			end
			spacing = spacing +195
		end
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