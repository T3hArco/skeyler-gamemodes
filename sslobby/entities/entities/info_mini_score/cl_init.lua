include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local backgroundTexture = surface.GetTextureID("skeyler/graphics/info_minigames")

local team_color_red = Color(220, 20, 20, 255)
local team_color_blue = Color(20, 20, 220, 255)
local team_color_green = Color(20, 220, 20, 255)
local team_color_yellow = Color(220, 220, 20, 255)

local color_text = Color(86, 98, 106)
local color_shadow = Color(0, 0, 0, 200)

surface.CreateFont("minigame.screen", {
	font 		= "Arial",
	size 		= 80,
	weight 		= 800,
	blursize	= 1,
	italic		= true
})

surface.CreateFont("minigame.screen.normal", {
	font 		= "Arial",
	size 		= 62,
	weight 		= 400,
	blursize	= 1
})

surface.CreateFont("minigame.screen.score", {
	font 		= "Arial",
	size 		= 72,
	weight 		= 600,
	blursize	= 1,
	italic		= true
})

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))
	
	local angles = self:GetAngles()
	
	self.cameraAngle = Angle(0, angles.y +90, angles.p +90)
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
			
			draw.SimpleText(minigame.Description, "minigame.screen.normal", 342, 1444, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			
			local scores = SS.Lobby.Minigame:GetScores()
		
			draw.SimpleText(scores[TEAM_ORANGE], "minigame.screen.score", 364, 728, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_ORANGE], "minigame.screen.score", 362, 726, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText(scores[TEAM_BLUE], "minigame.screen.score", 364, 998, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_BLUE], "minigame.screen.score", 362, 996, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
			draw.SimpleText(scores[TEAM_RED], "minigame.screen.score", 1917, 988, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_RED], "minigame.screen.score", 1915, 986, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText(scores[TEAM_GREEN], "minigame.screen.score", 1917, 738, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_GREEN], "minigame.screen.score", 1915, 736, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Draw()
	local position = self:GetPos() +self:GetForward() *0.1 +self:GetRight() *32 +self:GetUp() *32
	
	cam.Start3D2D(position, self.cameraAngle, 0.1)
		local ok, err = pcall(self.DrawBackground, self)
	cam.End3D2D()
	
	if (!ok) then
		Error(err, "\n")
	end
	
	cam.Start3D2D(position, self.cameraAngle, 0.028)
		local ok, err = pcall(self.DrawInformation, self)
	cam.End3D2D()
	
	if (!ok) then
		Error(err, "\n")
	end
end