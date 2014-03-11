----------------------------------------
--	Nuclear Warfare
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local LOADED = game.SinglePlayer()
local loadingScreen

surface.CreateFont("Loading", {
	font = "coolvetica",
	size = 24,
	weight = 500
})

net.Receive( "PlayerLoadingFinish", function()
	local text = net.ReadString()
	LOADED = true
	self.Text = text
end)

net.Receive( "PlayerLoadingTime", function()
	local time = net.ReadInt()
	local string = "The game will start in: " .. math.Round(time - CurTime()) .. " seconds."
	self.Timer = string
end)

net.Receive( "PlayerLoadingList", function()
	local players = net.ReadTable()
	local string = "Waiting for all players to load: "
	for k,v in pairs(players) do
		if k == (#players - 1) then
			string = string + (v[1] .. " & ")
		elseif k != #players then
			string = string + (v[1] .. ", ")
		elseif k == #players then
			string = string + (v[1] .. ".")
		end
	end
	self.Text = string
end)

local PANEL = {}

function PANEL:Init()
	
	self:SetZPos( 9999 )
	self:SetSize( ScrW(), ScrH() )
	self:SetPos( 0, 0 )
	self.color = 255
	self.alpha = 255
	self:MouseCapture( true )
	self:DoModal()

	self.Text = "Waiting for all players to load: "
	self.Timer = "The game will start in: 0 seconds."
	self.startTime = 0
	
end

function PANEL:Think()
	
	local sw, sh = ScrW(), ScrH()
	local w, h = self:GetSize()
	if (w ~= sw or h ~= sh) then
		self:SetSize( sw, sh )
	end
	
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

	if self.alpha == 0 then
		self:Remove()
	end
	
	surface.SetFont( "Loading" )
	surface.SetTextColor( 255, 255, 255, math.max(self.alpha-(56/self.alpha)*self.alpha,0) )
	
	local width, height = surface.GetTextSize( self.Text )
	surface.SetTextPos( w/2 - width/2, h/2 )
	surface.DrawText( self.Text )

	local width, height = surface.GetTextSize( self.Timer )
	surface.SetTextPos( w/2 - width/2, h/2 - height )
	surface.DrawText( self.Timer )
	
end

vgui.Register( "LoadingScreen", PANEL, "Panel" )

loadingScreen = vgui.Create( "LoadingScreen" )