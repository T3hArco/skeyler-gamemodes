----------------------------------------
--	Nuclear Warfare
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

/*
local LOADED = game.SinglePlayer()
local loadingScreen


surface.CreateFont("Loading", {
	font = "coolvetica",
	size = 24,
	weight = 500
})

net.Receive( "load.empires", function()
	if (not LOADED) then
		loadingScreen:AddMessage( "Empires" )
	end
end )

net.Receive( "load.structs.walls", function()
	if (not LOADED) then
		loadingScreen:AddMessage( "City Walls" )
	end
end )

net.Receive( "load.structs.houses", function()
	if (not LOADED) then
		loadingScreen:AddMessage( "City Houses" )
	end
end )

net.Receive( "load.structs.ownership", function()
	if (not LOADED) then
		loadingScreen:AddMessage( "Building Ownership" )
	end
end )

net.Receive( "load.units", function()
	if (not LOADED) then
		loadingScreen:AddMessage( "Units" )
	end
end )

net.Receive( "load.territories", function()
	if (not LOADED) then
		loadingScreen:AddMessage( "Territories" )
	end
end )

net.Receive( "loaded", function()
	if (not LOADED) then
		loadingScreen:AddMessage( "Loaded Successfully" )
		LOADED = true
	end
end)

if (LOADED) then
	loadingScreen = nil
	return
end

local PANEL = {}

function PANEL:Init()
	
	self:SetZPos( 9999 )
	self:SetSize( ScrW(), ScrH() )
	self:SetPos( 0, 0 )
	self.color = 255
	self.alpha = 255
	self:MouseCapture( true )
	self:DoModal()
	self.messages = {"Loading..."}
	
end

function PANEL:Think()
	
	local sw, sh = ScrW(), ScrH()
	local w, h = self:GetSize()
	if (w ~= sw or h ~= sh) then
		self:SetSize( sw, sh )
	end
	
	if (LOADED and self.alpha <= 25) then
		self:Remove()
		loadingScreen = nil
	end
	
end

function PANEL:AddMessage( msg )
	
	table.insert( self.messages, 1, msg )
	
end

function PANEL:Paint()
	
	local w, h = self:GetSize()
	surface.SetDrawColor( self.color, self.color, self.color, self.alpha )
	surface.DrawRect( 0, 0, w, h )
	
	if (self.color > 5) then
		self.color = Lerp( 2*FrameTime(), self.color, 0 )
	else
		self.color = 0
		if (LOADED) then
			self.alpha = Lerp( 4*FrameTime(), self.alpha, 0 )
		end
	end
	
	surface.SetFont( "Loading" )
	surface.SetTextColor( 255, 255, 255, math.max(self.alpha-(56/self.alpha)*self.alpha,0) )
	
	for k, v in ipairs( self.messages ) do
		local width, height = surface.GetTextSize( v )
		surface.SetTextPos( w - width - 10, h - (height+5)*k - 10 )
		surface.DrawText( v )
	end
	
end

vgui.Register( "LoadingScreen", PANEL, "Panel" )

loadingScreen = vgui.Create( "LoadingScreen" )
*/