include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local backgroundTexture = surface.GetTextureID("skeyler/graphics/info_minigames")

local team_color_red = Color(220, 20, 20, 255)
local team_color_blue = Color(20, 20, 220, 255)
local team_color_green = Color(20, 220, 20, 255)
local team_color_yellow = Color(220, 220, 20, 255)

local color_text = Color(86, 98, 106)
local color_shadow = Color(0, 0, 0, 200)

local screenWidth, screenHeight = 32, 32
local cameraOffset = Vector(0.1, -screenWidth, screenHeight)
local cameraScale = 0.1

surface.CreateFont("minigame.screen", {font = "Arial", size = 80, weight = 800, blursize = 1, italic = true})
surface.CreateFont("minigame.screen.normal", {font = "Arial", size = 62, weight = 400, blursize = 1})
surface.CreateFont("minigame.screen.score", {font = "Arial", size = 72, weight = 600, blursize = 1, italic = true})
surface.CreateFont("minigame.screen.join", {font = "Arial", size = 18, weight = 400})

local panelUnique = "minigame_screen"

local function AddButton(teamID, x, y)
	local button = SS.WorldPanel.NewPanel(panelUnique, 0.1)
	button:SetPos(x, y)
	button:SetSize(36, 69)

	button.team = teamID
	
	function button:OnMousePressed()
		net.Start("ss.lbmgjt")
			net.WriteUInt(self.team, 8)
		net.SendToServer()
	end
	
	function button:Paint(screen, x, y, w, h)
		if (self.hovered) then
			draw.SimpleText("CLICK TO JOIN", "minigame.screen.join", x +w /2, y +h /2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

AddButton(TEAM_RED, 520, 170)
AddButton(TEAM_BLUE, 84, 241)
AddButton(TEAM_GREEN, 520, 241)
AddButton(TEAM_ORANGE, 84, 170)

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	local angles = self:GetAngles()
	
	self.cameraAngle = Angle(0, angles.y +90, angles.p +90)
	self.cameraPosition = self:GetPos() +self:GetForward() *0.1 +self:GetRight() *screenWidth +self:GetUp() *screenHeight
	
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))
	
	self.mousePosition = Vector(0, 0, 0)
	self.projectionPos = self:LocalToWorld(cameraOffset)
	self.intersectPoint = Vector(0, 0, 0)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:DrawBackground()
	draw.Texture(0, 0, 640, 640, color_white, backgroundTexture)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:DrawInformation()
	local current = SS.Lobby.Minigame:GetCurrentGame()

	if (current) then
		local minigame = SS.Lobby.Minigame:Get(current)
		
		if (minigame) then
			draw.SimpleText(string.upper(minigame.Name), "minigame.screen", 342, 1344, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			
			draw.DrawText(minigame.Description, "minigame.screen.normal", 342, 1454, color_text)
			
			local scores = SS.Lobby.Minigame:GetScores()
		
			draw.SimpleText(scores[TEAM_ORANGE], "minigame.screen.score", 364, 728, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_ORANGE], "minigame.screen.score", 362, 726, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText(scores[TEAM_BLUE], "minigame.screen.score", 364, 998, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_BLUE], "minigame.screen.score", 362, 996, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
			draw.SimpleText(scores[TEAM_GREEN], "minigame.screen.score", 1917, 988, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_GREEN], "minigame.screen.score", 1915, 986, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText(scores[TEAM_RED], "minigame.screen.score", 1917, 738, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_RED], "minigame.screen.score", 1915, 736, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

local DrawPanels = SS.WorldPanel.DrawPanels

function ENT:Draw()
	self:UpdateMouse()

	cam.Start3D2D(self.cameraPosition, self.cameraAngle, 0.1)
		self:DrawBackground()
		
		if (self:GetSelector() == 1) then
			DrawPanels(panelUnique, self, 0.1)
			
			self:DrawMouse()
		end
	cam.End3D2D()
	
	cam.Start3D2D(self.cameraPosition, self.cameraAngle, 0.028)
		self:DrawInformation()
	cam.End3D2D()
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:UpdateMouse()
	self.intersectPoint = intersectRayPlane(EyePos(), EyePos() +(LocalPlayer():GetAimVector() *2000), self.cameraPosition, self:GetForward())

	if (self.intersectPoint)then
		self.mousePosition = self:WorldToLocal(self.intersectPoint) -cameraOffset
	
		self.mousePosition.x = self.mousePosition.y
		self.mousePosition.y = -self.mousePosition.z
		
		SS.WorldPanel.SetMouseBounds(panelUnique, Vector(self.mousePosition.x, self.mousePosition.y, self.mousePosition.z))

		self.mousePosition = self.mousePosition /cameraScale
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

local cursor = Material("icon16/bullet_white.png", "alphatest")
local color_cursor = Color(169, 69, 69)

function ENT:DrawMouse()
	if (self.mousePosition and self.mousePosition.x > 0 and self.mousePosition.y > 0 and self.mousePosition.x < screenWidth *2 /cameraScale and self.mousePosition.y < screenHeight *2 /cameraScale) then
		draw.Material(self.mousePosition.x -5, self.mousePosition.y -5, 10, 10, color_cursor, cursor)
	end
end