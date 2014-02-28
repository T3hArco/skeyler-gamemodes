include("shared.lua")

local backgroundTexture = surface.GetTextureID("sassilization/leaderboards/minigamesBG")

local team_color_red = Color(220, 20, 20, 255)
local team_color_blue = Color(20, 20, 220, 255)
local team_color_green = Color(20, 220, 20, 255)
local team_color_yellow = Color(220, 220, 20, 255)

local color_text = Color(86, 98, 106)
local color_shadow = Color(0, 0, 0, 180)

surface.CreateFont("minigame.screen", {
	font 		= "Arial",
	size 		= 80,
	weight 		= 600,
	blursize	= 1,
	italic		= true
})

surface.CreateFont("minigame.screen.normal", {
	font 		= "Arial",
	size 		= 80,
	weight 		= 600,
	blursize	= 1
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
			draw.SimpleText(minigame.Name, "minigame.screen", 944, 546, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(minigame.Name, "minigame.screen", 942, 544, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			
			draw.SimpleText(minigame.Description, "minigame.screen", 424, 1646, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(minigame.Description, "minigame.screen", 422, 1644, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			
			local scores = SS.Lobby.Minigame:GetScores()
			
			draw.SimpleText(scores[TEAM_RED], "minigame.screen.normal", 758, 998, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_RED], "minigame.screen.normal", 756, 996, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
			draw.SimpleText(scores[TEAM_BLUE], "minigame.screen.normal", 1511, 998, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_BLUE], "minigame.screen.normal", 1509, 996, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText(scores[TEAM_GREEN], "minigame.screen.normal", 758, 1288, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_GREEN], "minigame.screen.normal", 756, 1286, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText(scores[TEAM_YELLOW], "minigame.screen.normal", 1511, 1288, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(scores[TEAM_YELLOW], "minigame.screen.normal", 1509, 1286, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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