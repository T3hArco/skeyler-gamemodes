include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

surface.CreateFont("ss.leaderboard", {font = "Arvil Sans", size = 152, weight = 400, blursize = 1})
surface.CreateFont("ss.leaderboard.shadow", {font = "Arvil Sans", size = 152, weight = 400, blursize = 4, antialias = false})

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	local angles = self:GetAngles()
	self.width = 128
	self.height = 64

	self.weekly = self:GetClass() == "info_weeklyleaderboard"
	self.cameraAngle = Angle(0, angles.y +90, angles.p +90)
	self.cameraPosition = self:GetPos() +self:GetForward() *0.1 +self:GetRight() *self.width *0.5 +self:GetUp() *self.height *0.5
end

---------------------------------------------------------
--
---------------------------------------------------------

local color_text = Color(39, 207, 255, 255)
local color_shadow = Color(0, 0, 0, 120)

function ENT:Draw()
	local distance = LocalPlayer():EyePos():Distance(self.cameraPosition)
	local maxDistance = SS.Lobby.ScreenDistance:GetInt()
	
	if (distance <= maxDistance) then
		if (!self.setup) then
			local boundsMin, boundsMax = self:WorldToLocal(self.cameraPosition), self:WorldToLocal(self.cameraPosition + self.cameraAngle:Forward()*(self.width) + self.cameraAngle:Right()*(self.height) + self.cameraAngle:Up())

			self:SetRenderBounds(boundsMin, boundsMax)
		
			self.setup = true
		else
			cam.Start3D2D(self.cameraPosition, self.cameraAngle, 0.1)
				if (self.texture) then
					draw.Texture(0, 0, 1280, 640, color_white, self.texture)
				end
			cam.End3D2D()
			
			cam.Start3D2D(self.cameraPosition, self.cameraAngle, 0.02)
				self:PaintLeaderboard()
			cam.End3D2D()
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:PaintLeaderboard()
	if (self.weekly) then
		local leaderBoard = SS.Lobby.LeaderBoard.Get(LEADERBOARD_WEEKLY)
		
		if (leaderBoard) then
			local spacing = 0
			
			for i = 1, 5 do
				local data = leaderBoard[i]
				
				if (data) then
					draw.SimpleText(data.name, "ss.leaderboard.shadow", 3680, 662 +spacing, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.name, "ss.leaderboard", 3680, 662 +spacing, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				
					draw.SimpleText(data.games, "ss.leaderboard.shadow", 5300, 662 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.games, "ss.leaderboard", 5300, 662 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					
					draw.SimpleText(data.wins, "ss.leaderboard.shadow", 5930, 662 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.wins, "ss.leaderboard", 5930, 662 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					
					spacing = spacing +195
				end
			end
		end
		
		local leaderBoard = SS.Lobby.LeaderBoard.Get(LEADERBOARD_MONTHLY)
		
		if (leaderBoard) then
			local spacing = 0
			
			for i = 1, 10 do
				local data = leaderBoard[i]
				
				if (data) then
					draw.SimpleText(data.name, "ss.leaderboard.shadow", 280, 662 +spacing, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.name, "ss.leaderboard", 280, 662 +spacing, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				
					draw.SimpleText(data.games, "ss.leaderboard.shadow", 2506, 662 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.games, "ss.leaderboard", 2506, 662 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					
					draw.SimpleText(data.wins, "ss.leaderboard.shadow", 3156, 662 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.wins, "ss.leaderboard", 3156, 662 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					
					spacing = spacing +195
				end
			end
		end
		
		local leaderBoard = SS.Lobby.LeaderBoard.Get(LEADERBOARD_DAILY)
		
		if (leaderBoard) then
			local spacing = 0
			
			for i = 1, 3 do
				local data = leaderBoard[i]
				
				if (data) then
					draw.SimpleText(data.name, "ss.leaderboard.shadow", 3680, 2046 +spacing, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.name, "ss.leaderboard", 3680, 2046 +spacing, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				
					draw.SimpleText(data.games, "ss.leaderboard.shadow", 5300, 2046 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.games, "ss.leaderboard", 5300, 2046 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					
					draw.SimpleText(data.wins, "ss.leaderboard.shadow", 5930, 2046 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.wins, "ss.leaderboard", 5930, 2046 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					
					spacing = spacing +195
				end
			end
		end
	else
		local leaderBoard = SS.Lobby.LeaderBoard.Get(LEADERBOARD_ALLTIME_10)
		
		if (leaderBoard) then
			local spacing = 0
			
			for i = 1, 10 do
				local data = leaderBoard[i]
				
				if (data) then
					draw.SimpleText(data.name, "ss.leaderboard.shadow", 278, 662 +spacing, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.name, "ss.leaderboard", 278, 662 +spacing, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

					draw.SimpleText(data.empires, "ss.leaderboard.shadow", 4432, 662 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.empires, "ss.leaderboard", 4432, 662 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					
					draw.SimpleText(data.games, "ss.leaderboard.shadow", 5330, 662 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.games, "ss.leaderboard", 5330, 662 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					
					draw.SimpleText(data.wins, "ss.leaderboard.shadow", 5976, 662 +spacing, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(data.wins, "ss.leaderboard", 5976, 662 +spacing, Color(69, 69, 69), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					
					spacing = spacing +195
				end
			end
		end
	end
end