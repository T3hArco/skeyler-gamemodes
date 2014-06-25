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

local backgroundTexture = surface.GetTextureID("skeyler/graphics/server_info_screen")

local StatusMessages = {"Online", "Full", "Closed"}
local StatusMessagesEx = {"You can join", "The server is full", "This server is not up at the moment"}
local StatusTextures = {surface.GetTextureID("sassilization/ready"), surface.GetTextureID("sassilization/forbidden"), surface.GetTextureID("sassilization/closed")}

ENT.PlayerList = {"Bentech", "Smitty", "GodKnows", "CookMunster", "FireKnight", "Snoipa", "Dick", "Sassafrass"}

local panelUnique = "sass_portal"

---------------------------------------------------------
--
---------------------------------------------------------

local background = SS.WorldPanel.NewPanel(panelUnique, 0.1)
background:SetPos(0, 0)
background:SetSize(1280, 640)

function background:Paint(screen, x, y, w, h)
	draw.Texture(x, y, w, h, color_white, backgroundTexture)
	
	draw.SimpleRect(x +w /2 +32, y +h /2 -32, 2, h /2 -10, Color(69, 69, 69, 60))
	draw.SimpleRect(x +w /2 +32 +96, y +h /2 -32, 2, h /2 -10, Color(69, 69, 69, 60))
	
	draw.SimpleRect(x +w /2 +32 +96 +96, y +h /2 -32, 2, h /2 -10, Color(69, 69, 69, 60))
end

local button = SS.WorldPanel.NewPanel(panelUnique, 0.1)
button:SetParent(background)
button:SetSize(1280 *0.19 -4, 360)
button:SetPos(1280 *0.4 +384 +104, 240)

function button:Paint(screen, x, y, w, h)
	draw.SimpleRect(x +4, y +4, w -8, h -8, self.hovered and Color(39 +30, 207 +30, 255, 255) or Color(39, 207, 255, 255))
end

function button:OnMousePressed()
	net.Start("ss.lkngtplr")
		net.WriteUInt(self.screen:GetTriggerID(), 8)
	net.SendToServer()
end

local statusPanel = SS.WorldPanel.NewPanel(panelUnique, 0.03)
statusPanel:SetParent(background)
statusPanel:SetSize(1280 *3.35, 640 *3.35)
statusPanel:SetPos(0, 0)

function statusPanel:Paint(screen, x, y, w, h)
--[[	draw.SimpleText("[SS #1] SASSILIZATION SERVER 1", "ss.sass.screen.button", x +1164, y +164, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	
	if (screen.StatusTexture) then
		local status, players = screen:GetStatus(), SS.Lobby.Link:GetQueue(screen:GetTriggerID())
		
		if (status == STATUS_LINK_PREPARING) then
			if (!screen.prepareTime) then
				screen.prepareTime = CurTime() +4
			end
			
			screen:DrawText(string.format(screen.StatusMessageEx, math.max(math.Round(screen.prepareTime -CurTime()), 0)), "ss.sass.screen.status", x +1164, y +306, preparingColor)
		elseif (status == STATUS_LINK_UNAVAILABLE) then
			screen:DrawText(screen.StatusMessageEx, "ss.sass.screen.status", x +1164, y +306, Color(243, 121, 142))
		else
			screen:DrawText(string.format(screen.StatusMessageEx, #players, SS.Lobby.Link.MinPlayers), "ss.sass.screen.status", x +1164, y +306, color_yellow)
			
			screen.prepareTime = nil
		end
	end
	]]
end

local labelsPanel = SS.WorldPanel.NewPanel(panelUnique, 0.02)
labelsPanel:SetParent(background)
labelsPanel:SetSize(1280 *5 +14, 640 *5 +14)
labelsPanel:SetPos(0, 0)

function labelsPanel:Paint(screen, x, y, w, h)
	draw.SimpleText("PLAYER NAME", "ss.sass.screen.button", x +w /2 -932, y +h /2 -354, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	
	local infoY = 0
	
	for i = 1, #screen.PlayerList do
		local name = screen.PlayerList[i]
		
		if (name) then
			draw.SimpleText(name, "ss.sass.screen.button", x +w /2 -932, y +h /2 -144 +infoY, Color(39, 207, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		--	draw.SimpleText(data.gold, "ss.sass.screen.button", x +w /2 +32 +364, y +h /2 -144 +infoY, Color(69, 69, 69, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			--draw.SimpleText(data.food, "ss.sass.screen.button", x +w /2 +512 +364, y +h /2 -144 +infoY, Color(69, 69, 69, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		--	draw.SimpleText(data.food, "ss.sass.screen.button", x +w /2 +1024 +320, y +h /2 -144 +infoY, Color(69, 69, 69, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			
			infoY = infoY +196
		end
	end
	
--[[	draw.SimpleText("GOLD", "ss.sass.screen.button", x +w /2 +32 +364, y +h /2 -354, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("FOOD", "ss.sass.screen.button", x +w /2 +512 +364, y +h /2 -354, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("IRON", "ss.sass.screen.button", x +w /2 +1024 +320, y +h /2 -354, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

	]]
	
	draw.SimpleText("JOIN SERVER", "ss.sass.screen.button", x +w -800, y +h /2 +400, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

local screenWidth, screenHeight = 64, 32
	
function ENT:Initialize()
	--self:SetStatus(CommLink.Status.CLOSED)
	
	local cam_rot = Vector(0, 90, 90)
	local cam_offset = Vector(0.1, -screenWidth, screenHeight)

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
	if (!self.setup) then
		local boundsMin, boundsMax = self:WorldToLocal(self.CamPos), self:WorldToLocal(self.CamPos + self.CamAng:Forward()*(screenWidth*2) + self.CamAng:Right()*(screenHeight*2) + self.CamAng:Up())

		self:SetRenderBounds(boundsMin, boundsMax)
	
		self.setup = true
	end

	cam.Start3D2D(self.CamPos, self.CamAng, 0.1)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		
		SS.WorldPanel.DrawPanels(panelUnique, self, 0.1)

		--self:DrawMouse()
		
		render.PopFilterMin()
		render.PopFilterMag()
	cam.End3D2D()
	
	cam.Start3D2D(self.CamPos, self.CamAng, 0.02)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		
		SS.WorldPanel.DrawPanels(panelUnique, self, 0.02)
		
		render.PopFilterMin()
		render.PopFilterMag()
	cam.End3D2D()
	
	cam.Start3D2D(self.CamPos, self.CamAng, 0.03)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		
		SS.WorldPanel.DrawPanels(panelUnique, self, 0.03)
		
		render.PopFilterMin()
		render.PopFilterMag()
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
