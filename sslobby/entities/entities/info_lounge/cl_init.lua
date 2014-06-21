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

local info = {}

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
	
--	http.Fetch("http://skeyler.com/blog.php", function(body, length, headers, code)

--	end)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Draw()
	local dot = self:GetForward():Dot((self:GetPos() -EyePos()):GetNormal())
	
	if (dot <= 0) then
		cam.Start3D2D(self.newsPosition, self.newsAngle, 0.05)
			draw.Texture(0, 0, 1280, 1280, color_white, newsTexture)

			if info.news then
				draw.DrawText(info.news, "font_news", 195, 360, Color(0,0,0,255), TEXT_ALIGN_LEFT)
			end
			
		cam.End3D2D()
	else
		cam.Start3D2D(self.rulesPosition, self.rulesAngle, 0.05)
			draw.Texture(0, 0, 1280, 1280, color_white, rulesTexture)

			if info.rules then
				draw.DrawText(info.rules, "font_rules", 195, 360, Color(0,0,0,255), TEXT_ALIGN_LEFT)
			end
			
		cam.End3D2D()
	end
end

local NewsMenu = {}

function NewsMenu.Open(news, rules)
	if NewsMenu.DermaFrame then
		NewsMenu.Close()
	end
	NewsMenu.DermaFrame = vgui.Create( "DFrame" )
	NewsMenu.DermaFrame:SetSize( ScrW()*0.4, ScrH()*0.5 )
	NewsMenu.DermaFrame:Center()
	NewsMenu.DermaFrame:SetVisible( true )
	NewsMenu.DermaFrame:MakePopup()
	NewsMenu.DermaFrame:SetDraggable( false )
	NewsMenu.DermaFrame:ShowCloseButton( true )
	NewsMenu.DermaFrame:SetTitle("THERE'S NO WORD WRAP, BE CAREFUL ABOUT HOW LONG EACH LINE IS")

	local TextEntry = vgui.Create( "DTextEntry", NewsMenu.DermaFrame )	-- create the form as a child of frame
		TextEntry:SetPos( NewsMenu.DermaFrame:GetWide()*0.025, NewsMenu.DermaFrame:GetTall()*0.1 )
		TextEntry:SetSize( NewsMenu.DermaFrame:GetWide()*0.45, NewsMenu.DermaFrame:GetTall()*0.7 )
		TextEntry:SetText( info.news )
		TextEntry:SetMultiline(true)
		TextEntry.OnEnter = function( self )
			TextEntry:SetText( self:GetValue() )	-- print the form's text as server text
		end

	local TextEntry2 = vgui.Create( "DTextEntry", NewsMenu.DermaFrame )	-- create the form as a child of frame
		TextEntry2:SetPos( NewsMenu.DermaFrame:GetWide()*0.525, NewsMenu.DermaFrame:GetTall()*0.1 )
		TextEntry2:SetSize( NewsMenu.DermaFrame:GetWide()*0.45, NewsMenu.DermaFrame:GetTall()*0.7 )
		TextEntry2:SetText( info.rules )
		TextEntry2:SetMultiline(true)

	local button = vgui.Create( "DButton", NewsMenu.DermaFrame )
		button:SetSize( NewsMenu.DermaFrame:GetWide()*0.45, NewsMenu.DermaFrame:GetTall()*0.1 )
		button:SetPos( NewsMenu.DermaFrame:GetWide()*0.025, NewsMenu.DermaFrame:GetTall()*0.85 )
		button:SetText( "Save News" )
		button:SetToolTip( "Saves the current text to the server." )
		button.DoClick = function( button )
			net.Start( "updateNews" )
				net.WriteString("news")
				net.WriteString(TextEntry:GetValue())
			net.SendToServer()
		end

	local button = vgui.Create( "DButton", NewsMenu.DermaFrame )
		button:SetSize( NewsMenu.DermaFrame:GetWide()*0.45, NewsMenu.DermaFrame:GetTall()*0.1 )
		button:SetPos( NewsMenu.DermaFrame:GetWide()*0.525, NewsMenu.DermaFrame:GetTall()*0.85 )
		button:SetText( "Save Rules" )
		button:SetToolTip( "Saves the current text to the server." )
		button.DoClick = function( button )
			net.Start( "updateNews" )
				net.WriteString("rules")
				net.WriteString(TextEntry2:GetValue())
			net.SendToServer()
		end

end

function NewsMenu.Close()
	NewsMenu.DermaFrame:Remove()
end


net.Receive("rulesNewsEdit", function(len)
	NewsMenu.Open()
end)

net.Receive("setNewsRules", function(len)
	local news = net.ReadString()
	local rules = net.ReadString()
	info.news = news
	info.rules = rules
end)