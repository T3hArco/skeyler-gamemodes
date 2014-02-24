----------
-- Lobby
----------

include("shared.lua")

surface.CreateFont("font_news", {
	font 		= "Arial",
	size 		= 48,
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
surface.CreateFont("font_rules", {
	font 		= "Arial",
	size 		= 54,
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

local texBulletin = surface.GetTextureID( "sassilization/leaderboards/bulletin" )
local texRules = surface.GetTextureID( "sassilization/leaderboards/rules" )
local writez = Material("engine/writeZ")
local info = {}

function Vertex( pos, u, v, normal )

	return { pos = pos, u = u, v = v, normal = normal }
	
end
function MeshQuad( v1, v2, v3, v4, t )

	return 
	{		
		Vertex( v1, 0, 0 ),
		Vertex( v2, (v1-v2):Length() * t, 0 ),
		Vertex( v4, 0, (v1-v4):Length() * t ),
		Vertex( v2, (v1-v2):Length() * t, 0 ),
		Vertex( v3, (v3-v4):Length() * t, (v2-v3):Length() * t ),
		Vertex( v4, 0, (v1-v4):Length() * t ),
	}	
end
local function BuildRect(vMins, vMaxs)
	local t = 0.1

	local p1 = Vector(vMins.x, vMins.y, vMins.z)
	local p2 = Vector(vMins.x, vMaxs.y, vMins.z)
	local p3 = Vector(vMaxs.x, vMaxs.y, vMins.z)
	local p4 = Vector(vMaxs.x, vMins.y, vMins.z)

	local p5 = Vector(vMins.x, vMins.y, vMaxs.z)
	local p6 = Vector(vMins.x, vMaxs.y, vMaxs.z)
	local p7 = Vector(vMaxs.x, vMaxs.y, vMaxs.z)
	local p8 = Vector(vMaxs.x, vMins.y, vMaxs.z)

	local Vertices = {}
	table.Add( Vertices, MeshQuad( p5, p6, p7, p8, t, 32 ) )
	table.Add( Vertices, MeshQuad( p4, p3, p2, p1, t, 32 ) )
	table.Add( Vertices, MeshQuad( p8, p7, p3, p4, t, 32 ) )
	table.Add( Vertices, MeshQuad( p6, p5, p1, p2, t, 32 ) )
	table.Add( Vertices, MeshQuad( p5, p8, p4, p1, t, 32 ) )
	table.Add( Vertices, MeshQuad( p7, p6, p2, p3, t, 32 ) )

	return Vertices
end

local function WrapString( tbl, str, wide, wrap )
	wrap = wrap or 0
	local wlen = wide
	local txt = ""
	local words = string.Explode( " ", str )
	local size = 0
	local spacer = surface.GetTextSize( " " )
	local pos = 0
	local w, h = surface.GetTextSize( str )
	for i, word in pairs( words ) do
		w, h = surface.GetTextSize( word )
		if size+w+spacer < wlen then
			pos = pos + string.len(word) + 1
			size = size+w+spacer
			txt = txt.." "..word
			if i == #words then
				return table.insert( tbl, txt )
			end
		elseif w > wlen then
			local available = wlen - size
			local len = ""
			for i=1, string.len(word) do
				len = string.sub( word, 1, i )
				w, h = surface.GetTextSize( len )
				if w > available then
					txt = txt.." "..len
					pos = pos + string.len( len )
					table.insert( tbl, txt )
					return WrapString( tbl, string.sub( str, pos + 1 ), wide, wrap + 1 )
				end
			end
			return
		else
			table.insert( tbl, txt )
			return WrapString( tbl, string.sub( str, pos + 1 ), wide, wrap + 1 )
		end
	end
end

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

file.CreateDir("lounge")

local function saveNews( news )
	file.Write( "lounge/news.txt", news )
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
--ENT:RetrieveData()
function ENT:Initialize()
	local bounds = Vector(1, 1, 1) * 128
	
	self.Entity:SetRenderBounds(bounds * -1, bounds)
	self.occlusionmesh = Mesh()
	self.occlusionmesh:BuildFromTriangles(BuildRect(Vector(0,-32,-32), Vector(0,32,32)))
	
end

function ENT:Think()
	
	self.nextUpdate = self.nextUpdate or CurTime()
	if CurTime() < self.nextUpdate then return end
	self.nextUpdate = CurTime() + 30
	--self:RetrieveData()
	
end

local function DrawText( txt, x, y, col )
	if !txt then return end
	col = col or Color(0,0,0,255)
	surface.SetTextPos( x+1, y+1 )
	surface.SetTextColor( 0, 0, 0, 100 )
	surface.DrawText( txt )
	surface.SetTextPos( x, y )
	surface.SetTextColor( col.r, col.g, col.b, col.a )
	surface.DrawText( txt )
end

function ENT:Draw()
	
	local ang = self:GetAngles()
	if( self:GetForward():Dot((self:GetPos() - EyePos()):GetNormal()) < 0 ) then
		cam.Start3D2D(self:GetPos()+self:GetForward()*0.1+self:GetRight()*32+self:GetUp()*32,Angle( 0, ang.y+90, ang.p+90 ),0.05)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetTexture( texBulletin )
			surface.DrawTexturedRect( 0,0,1280,1280 )
			if info.news then
				surface.SetFont( "font_news" )
				local w, h = surface.GetTextSize("")
				for i, line in pairs( info.news ) do
					DrawText( line, 175, 380 + i*h*1.05 )
				end
			end
		cam.End3D2D()
	else
		cam.Start3D2D(self:GetPos()+self:GetForward()*-0.1-self:GetRight()*32+self:GetUp()*32,Angle( 0, ang.y-90, ang.p+90 ),0.05)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetTexture( texRules )
			surface.DrawTexturedRect( 0,0,1280,1280 )
			if info.rules then
				surface.SetFont( "font_rules" )
				local w, h = surface.GetTextSize("")
				for i, line in pairs( info.rules ) do
					DrawText( line, 175, 210 + i*h*1.05 )
				end
			end
		cam.End3D2D()
	end
	
	render.SetMaterial(writez)
	
	local matWorld = Matrix()
	matWorld:Translate( self.Entity:GetPos() )
	matWorld:Rotate( self.Entity:GetAngles() )
	
	cam.PushModelMatrix( matWorld )
		self.occlusionmesh:Draw()
	cam.PopModelMatrix()
	
end
--[[
hook.Add( "ShutDown", "bulletin.cachenews", function()
	if (!info.news) then return end
	saveNews(newsToStr(info.news))
end )]]