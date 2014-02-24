----------
-- Lobby
----------

include("shared.lua")

surface.CreateFont("PortalScreenBig", {
	font 		= "Eccentric Std",
	size 		= 800,
	weight 		= 600,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})

surface.CreateFont("PortalScreenMedium", {
	font 		= "Arial",
	size 		= 45,
	weight 		= 600,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})

surface.CreateFont("PortalScreenSmall", {
	font 		= "Arial",
	size 		= 30,
	weight 		= 600,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})

local BackgroundTexture = surface.GetTextureID("sassilization/leaderboards/server_info")

local StatusMessages = {"Online", "Full", "Closed"}
local StatusMessagesEx = {"You can join", "The server is full", "This server is not up at the moment"}
local StatusTextures = {surface.GetTextureID("sassilization/ready"), surface.GetTextureID("sassilization/forbidden"), surface.GetTextureID("sassilization/closed")}

ENT.PlayerList = {"Bentech", "Smitty", "GodKnows", "CookMunster", "FireKnight", "Snoipa", "Dick", "AGS£SVSD£SDFVSETT2", "AB!233C", "Spacetech", "Cold", "Sassafrass"}

function ENT:Initialize()
	--self:SetStatus(CommLink.Status.CLOSED)
	
	local Width, Height = 64, 32
	
	self.Bounds = Vector(1, 1, 1) * Width
	
	local cam_rot = Vector(0, 90, 90)
	local cam_offset = Vector(0.1, -Width, Height)

	self.CamPos = self:LocalToWorld(cam_offset)
	
	local Ang = self:GetAngles()
	Ang:RotateAroundAxis(Ang:Right(), cam_rot.x)
	Ang:RotateAroundAxis(Ang:Up(), cam_rot.y)
	Ang:RotateAroundAxis(Ang:Forward(), cam_rot.z)
	
	self.CamAng = Ang
	
	self.PlayerListPos = 0
	self.NextPlayerListUpdate = CurTime()
end

function ENT:SetStatus(Status)
	self.Status = Status
	self.StatusMessage = StatusMessages[Status]
	self.StatusMessageEx = StatusMessagesEx[Status]
	self.StatusTexture = StatusTextures[Status]
end

function ENT:DrawPortalScreen()
	surface.SetTexture(self.StatusTexture)
	surface.DrawTexturedRect(75, 420, 200, 180)
	
	surface.SetFont("PortalScreenBig")
	self:DrawText("Server Name", 700, 20)
	
	surface.SetFont("PortalScreenSmall")
	for i=1, 7 do
		local Offset = i + self.PlayerListPos
		if(self.PlayerList[Offset]) then
			self:DrawText(self.PlayerList[Offset], 877, 348 + ((i - 1) * 36))
		end
	end
	
	surface.SetFont("PortalScreenMedium")
	
	self:DrawText(self.StatusMessage, 120, 320)
	
	self:DrawText("Players Online: 45 / 50", 376, 350)
	self:DrawText("Map: Map Name Here", 376, 390)
end


function ENT:Draw()
	self:SetRenderBounds(self.Bounds * -1, self.Bounds)
	
	cam.Start3D2D(self.CamPos, self.CamAng, 0.1)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetTexture(BackgroundTexture)
		surface.DrawTexturedRect(0, 0, 1280, 640)
		--self:DrawPortalScreen()
	cam.End3D2D()
end

function ENT:Think()
	if(self.NextPlayerListUpdate > CurTime()) then
		return
	end
	self.NextPlayerListUpdate = CurTime() + 7
	
	self.PlayerListPos = self.PlayerListPos + 7
	
	if(table.Count(self.PlayerList) < self.PlayerListPos) then
		self.PlayerListPos = 0
	end
end

function ENT:DrawText( txt, x, y, col, offset )
	col = col or color_white
	offset=offset or 1.5
	surface.SetTextPos( x+offset, y+offset )
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.DrawText( txt )
	surface.SetTextPos( x, y )
	surface.SetTextColor( col.r, col.g, col.b, col.a )
	surface.DrawText( txt )
end
