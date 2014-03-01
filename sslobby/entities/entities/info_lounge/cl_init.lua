include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

surface.CreateFont("font_news", {
	font 		= "Arial",
	size 		= 48,
	weight 		= 600
})

surface.CreateFont("font_rules", {
	font 		= "Arial",
	size 		= 54,
	weight 		= 600
})

local newsTexture = surface.GetTextureID("skeyler/graphics/info_news")
local rulesTexture = surface.GetTextureID("skeyler/graphics/info_rules")

--[[
local function newsToStr( news )
	local str = ""
	for k,v in pairs( news ) do
		str=str..v
	end
	str = str:gsub( "\t", "" )
	str = str:gsub( "\n", "" )
	str = str:gsub( "\r", "" )
	str = str:gsub( " ", "" )
	return str
end


function ENT:RetrieveData()
	http.Fetch("http://sassilization.com/bulletin/news.txt", function(body, length, headers, code)
		surface.SetFont("font_news")
		
		local strings = {}
		
		for k, str in pairs( string.Explode("\n", body)) do
			WrapString(strings, str, 990)
		end
		
		info.news = strings
		
		local news = newsToStr(strings)

		if(file.Exists( "lounge/news.txt", "DATA") and news == file.Read("lounge/news.txt", "DATA")) then
			return
		end
		
		saveNews(news)
		
		--local ed = EffectData()
		--ed:SetOrigin( self:GetPos() + self:GetUp() * 42 )
		--util.Effect("bubble_news", ed)
	end, function(code)
		info.news = {"No News!"}
	end)
	
	-- The timer has to be here or gmod will crash because WrapString.
	timer.Simple(2,function()
		http.Fetch("http://sassilization.com/bulletin/rules.txt", function(body, length, headers, code)
			surface.SetFont("font_rules")
			
			local strings = {}
			
			for k, str in pairs(string.Explode("\n", body)) do
				WrapString(strings, str, 990)
			end

			info.rules = strings
		end, function(code)
			info.rules = {"No Rules!"}
		end)
	end)
end
]]

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	local bounds = Vector(128, 128, 128)
	local angles = self:GetAngles()
	local position = self:GetPos()
	
	self.newsAngle = Angle(0, angles.y +90, angles.p +90)
	self.newsPosition = position +self:GetForward() *0.1 +self:GetRight() *32 +self:GetUp() *32
	
	self.rulesAngle = Angle(0, angles.y -90, angles.p +90)
	self.rulesPosition = position+ self:GetForward() *-0.1 -self:GetRight() *32 +self:GetUp() *32
	
	self:SetRenderBounds(bounds *-1, bounds)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Draw()
	local dot = self:GetForward():Dot((self:GetPos() -EyePos()):GetNormal())
	
	if (dot <= 0) then
		cam.Start3D2D(self.newsPosition, self.newsAngle, 0.05)
			draw.Texture(0, 0, 1280, 1280, color_white, newsTexture)
			
			--[[if info.news then
				surface.SetFont( "font_news" )
				local w, h = surface.GetTextSize("")
				for i, line in pairs( info.news ) do
					DrawText( line, 175, 380 + i*h*1.05 )
				end
			end]]
			
		cam.End3D2D()
	else
		cam.Start3D2D(self.rulesPosition, self.rulesAngle, 0.05)
			draw.Texture(0, 0, 1280, 1280, color_white, rulesTexture)

			--[[if info.rules then
				surface.SetFont( "font_rules" )
				local w, h = surface.GetTextSize("")
				for i, line in pairs( info.rules ) do
					DrawText( line, 175, 300 + i*h*1.05 )
				end
			end]]
			
		cam.End3D2D()
	end
end