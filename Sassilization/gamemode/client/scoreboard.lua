surface.CreateFont("ScoreboardHeader",
{
	size = ScreenScale(40),
	weight = 400,
	antialias = true,
	font = "Eccentric Std"
})

surface.CreateFont("ScoreboardSub",
{
	size = ScreenScale(9),
	weight = 400,
	antialias = true,
	italic = true,
	font = "Constantia"
})

surface.CreateFont("ScoreboardList",
{
	size = ScreenScale(8),
	weight = 400,
	antialias = true,
	italic = true,
	font = "Constantia"
})

surface.CreateFont("ScoreboardPlayer",
{
	size = ScreenScale(10),
	weight = 700,
	antialias = true,
	italic = true,
	font = "Constantia"
})

local renderConvar = CreateClientConVar( "sass_buildingdistance", 640, true, true )

function GM:ScoreboardShow()
	TabOpen = true
	surface.SetFont("ScoreboardHeader")
	local distw, disth = surface.GetTextSize("Sassilization")
	local windowWidth = distw + distw/1.2
	local tabHeightBuffer = (disth/3)*2
	local curheight = disth + disth/3
	local headerheight = curheight
	surface.SetFont("ScoreboardList")
	local distw, disth = surface.GetTextSize("Ping")
	local curheight = curheight + disth*1.5
	menuheight = curheight
	tabheight = menuheight + tabHeightBuffer
	for k,v in pairs(player.GetAll()) do
		if v.allies == nil then
			v.allies = {}
		end
		v.predictedHeight = 0
		surface.SetFont("ScoreboardPlayer")
		local distw, disth = surface.GetTextSize(v:GetName())
		tabheight = tabheight + disth*2
	end
	--Set height for the whole tab menu before it makes it

	DermaFrame = vgui.Create( "DFrame" )
	DermaFrame:SetSize( windowWidth, tabheight )
	DermaFrame:SetPos( ScrW()/2 - DermaFrame:GetWide()/2, ScrH()/2 - DermaFrame:GetTall()/2 )
	DermaFrame:SetVisible( true )
	DermaFrame:SetDraggable( false )
	DermaFrame:ShowCloseButton( false )
	DermaFrame:SetTitle(" ")
	selected = 1
	nameheight = 0

	surface.SetFont("ScoreboardSub")

	RenderDistanceSlider = vgui.Create("DNumSlider", DermaFrame)
	local distw, disth = surface.GetTextSize("Render Distance:")
	RenderDistanceSlider:SetPos((DermaFrame:GetWide()/3)*2 + (distw)/2, tabheight - (tabHeightBuffer/4)*3 )
	RenderDistanceSlider:SetMin(100)
	RenderDistanceSlider:SetMax(2560)
	RenderDistanceSlider:SetDecimals(0)
	RenderDistanceSlider:SetValue(renderConvar:GetFloat())
	RenderDistanceSlider:SetConVar("sass_buildingdistance")
	RenderDistanceSlider.Paint = function()
		RenderDistanceSlider:SetText("")
		RenderDistanceSlider.TextArea:SetValue("")
		surface.SetFont("ScoreboardSub")
		surface.SetTextColor( 255,255,255,255 )
		surface.SetTextPos( 0, 0 ) 
		surface.DrawText( math.Round(RenderDistanceSlider:GetValue()) )
	end

	EnableHintsBox = vgui.Create("DCheckBox", DermaFrame)
	surface.SetFont("ScoreboardSub")
	local distw, disth = surface.GetTextSize("Disable Hints")
	EnableHintsBox:SetPos(DermaFrame:GetWide()/3 + (distw - 5)/2, tabheight - (tabHeightBuffer/4)*3 + EnableHintsBox:GetTall()/5 )
	EnableHintsBox:SetConVar("sass_disablehints")
	EnableHintsBox.Paint = function()
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, EnableHintsBox:GetWide(), EnableHintsBox:GetTall() )
		if EnableHintsBox:GetChecked() then
			surface.DrawLine( 0, 0, EnableHintsBox:GetWide(), EnableHintsBox:GetTall())
			surface.DrawLine( 0, EnableHintsBox:GetTall(), EnableHintsBox:GetWide(), 0)
		end
	end


	for k,v in pairs(player.GetHumans()) do
		if (v:GetEmpire()) then
			v.but = true
			local AllyPlayerBox = vgui.Create("DButton", DermaFrame)
			AllyPlayerBox:SetSize(15, 15)
			AllyPlayerBox:SetText("")
			surface.SetFont("ScoreboardList")
			local distw, disth = surface.GetTextSize("Allies")
			surface.SetFont("ScoreboardPlayer")
			local distw2, disth2 = surface.GetTextSize("Hello") -- Do this to get the height of the space between each player
			AllyPlayerBox:SetPos(DermaFrame:GetWide()*0.05 + AllyPlayerBox:GetWide()/2, nameheight + menuheight + disth2 - AllyPlayerBox:GetTall()/2)
			AllyPlayerBox.Paint = function()
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawOutlinedRect( 0, 0, AllyPlayerBox:GetWide(), AllyPlayerBox:GetTall() )
				if v == LocalPlayer() or v.alliance then
					surface.DrawLine( 0, 0, AllyPlayerBox:GetWide(), AllyPlayerBox:GetTall())
					surface.DrawLine( 0, AllyPlayerBox:GetTall(), AllyPlayerBox:GetWide(), 0)
				end
				if v.request then
					if v.request == "Outgoing" then
						surface.SetDrawColor( 255, 0, 0, 255 )
						surface.DrawRect( AllyPlayerBox:GetWide()*0.2, AllyPlayerBox:GetTall()*0.2, AllyPlayerBox:GetWide()*0.6, AllyPlayerBox:GetTall()*0.6 )
					elseif v.request == "Incoming" then
						surface.SetDrawColor( 0, 255, 0, 255 )
						surface.DrawRect( AllyPlayerBox:GetWide()*0.2, AllyPlayerBox:GetTall()*0.2, AllyPlayerBox:GetWide()*0.6, AllyPlayerBox:GetTall()*0.6 )
					end
				end
			end
			AllyPlayerBox.DoClick = function( self )
				LocalPlayer():ConCommand("sa_requestalliance " .. v:UserID())
			end

			local MutePlayerBox = vgui.Create("DCheckBox", DermaFrame)
			surface.SetFont("ScoreboardList")
			local distw, disth = surface.GetTextSize("Mute")
			surface.SetFont("ScoreboardPlayer")
			local distw2, disth2 = surface.GetTextSize("Hello")
			MutePlayerBox:SetPos(DermaFrame:GetWide()*0.9 + MutePlayerBox:GetWide()/2, nameheight + menuheight + disth2 - MutePlayerBox:GetTall()/2)
			MutePlayerBox:SetChecked(v:IsMuted())
			MutePlayerBox.OnChange = function()
				v:SetMuted(MutePlayerBox:GetChecked())
			end
			MutePlayerBox.Paint = function()
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawOutlinedRect( 0, 0, MutePlayerBox:GetWide(), MutePlayerBox:GetTall() )
				if MutePlayerBox:GetChecked() then
					surface.DrawLine( 0, 0, MutePlayerBox:GetWide(), MutePlayerBox:GetTall())
					surface.DrawLine( 0, MutePlayerBox:GetTall(), MutePlayerBox:GetWide(), 0)
				end
			end

			surface.SetFont("ScoreboardPlayer")
			local distw, disth = surface.GetTextSize(v:Nick())
			nameheight = nameheight + disth*2
		end
	end
	timer.Create("updaters", 1, 0, function()
		tabheight = menuheight + tabHeightBuffer
		for k,v in pairs(player.GetAll()) do
			surface.SetFont("ScoreboardPlayer")
			local distw, disth = surface.GetTextSize(v:Nick())
			tabheight = tabheight + disth*2
		end
		
		DermaFrame:SetSize(windowWidth, tabheight )
		DermaFrame:SetPos( ScrW()/2 - DermaFrame:GetWide()/2, ScrH()/2 - DermaFrame:GetTall()/2 )
		nameheight = 0
		for k,v in pairs(player.GetHumans()) do
			if (v:GetEmpire()) then
				if !v.but then
					local AllyPlayerBox = vgui.Create("DButton", DermaFrame)
					AllyPlayerBox:SetSize(15, 15)
					AllyPlayerBox:SetText("")
					surface.SetFont("ScoreboardList")
					local distw, disth = surface.GetTextSize("Allies")
					surface.SetFont("ScoreboardPlayer")
					local distw2, disth2 = surface.GetTextSize("Hello")
					AllyPlayerBox:SetPos(DermaFrame:GetWide()*0.05 + AllyPlayerBox:GetWide()/2, nameheight + menuheight + disth2 - AllyPlayerBox:GetTall()/2)
					AllyPlayerBox.Paint = function()
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.DrawOutlinedRect( 0, 0, AllyPlayerBox:GetWide(), AllyPlayerBox:GetTall() )
						if v == LocalPlayer() then
							surface.DrawLine( 0, 0, AllyPlayerBox:GetWide(), AllyPlayerBox:GetTall())
							surface.DrawLine( 0, AllyPlayerBox:GetTall(), AllyPlayerBox:GetWide(), 0)
						end
						if v.request then
							if v.request == "Outgoing" then
								surface.SetDrawColor( 255, 0, 0, 255 )
								surface.DrawRect( AllyPlayerBox:GetWide()*0.2, AllyPlayerBox:GetTall()*0.2, AllyPlayerBox:GetWide()*0.6, AllyPlayerBox:GetTall()*0.6 )
							elseif v.request == "Incoming" then
								surface.SetDrawColor( 0, 255, 0, 255 )
								surface.DrawRect( AllyPlayerBox:GetWide()*0.2, AllyPlayerBox:GetTall()*0.2, AllyPlayerBox:GetWide()*0.6, AllyPlayerBox:GetTall()*0.6 )
							end
						end
					end

					local MutePlayerBox = vgui.Create("DCheckBox", DermaFrame)
					surface.SetFont("ScoreboardList")
					local distw, disth = surface.GetTextSize("Mute")
					surface.SetFont("ScoreboardPlayer")
					local distw2, disth2 = surface.GetTextSize("Hello")
					MutePlayerBox:SetPos(DermaFrame:GetWide()*0.9 + MutePlayerBox:GetWide()/2, nameheight + menuheight + disth2 - MutePlayerBox:GetTall()/2)
					MutePlayerBox:SetChecked(v:IsMuted())
					MutePlayerBox.OnChange = function()
						v:SetMuted(MutePlayerBox:GetChecked())
					end
					MutePlayerBox.Paint = function()
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.DrawOutlinedRect( 0, 0, MutePlayerBox:GetWide(), MutePlayerBox:GetTall() )
						if MutePlayerBox:GetChecked() then
							surface.DrawLine( 0, 0, MutePlayerBox:GetWide(), MutePlayerBox:GetTall())
							surface.DrawLine( 0, MutePlayerBox:GetTall(), MutePlayerBox:GetWide(), 0)
						end
					end
				end

				surface.SetFont("ScoreboardPlayer")
				local distw, disth = surface.GetTextSize(v:Nick())
				nameheight = nameheight + disth*2
			end
		end
		surface.SetFont("ScoreboardSub")
		local distw, disth = surface.GetTextSize("Render Distance:")
		RenderDistanceSlider:SetPos((DermaFrame:GetWide()/3)*2 + (distw)/2, tabheight - (tabHeightBuffer/4)*3 )
		local distw, disth = surface.GetTextSize("Disable Hints")
		EnableHintsBox:SetPos(DermaFrame:GetWide()/3 + (distw - 5)/2, tabheight - (tabHeightBuffer/4)*3 + EnableHintsBox:GetTall()/5 )
	end)

	function DermaFrame:Paint()
		if input.IsMouseDown( MOUSE_LEFT ) then
			if !self.Cursor then
				self.Cursor = true
				ShowMouse()
				vgui.GetWorldPanel():SetCursor("none")
			end
		end

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(Material("sassilization/tab_bg.png"))
		local texW, texH = 116, 128
		local wideTiles = math.ceil(self:GetWide()/texW)
		local tallTiles = math.ceil(self:GetTall()/texH)
		--Tiling it this way instead of using UV because for some reason UV isn't tiling correctly and just streches the texture in a weird manner. //Hateful
		for i = 1,wideTiles do
			surface.DrawTexturedRect( (i-1)*texW, 0, texW, texH )
			for d = 1,tallTiles do
				surface.DrawTexturedRect( (i-1)*texW, (d)*texH, texW, texH )
			end
		end

		surface.SetMaterial(Material("sassilization/tab_border.png"))
		surface.DrawTexturedRect( 0, 0, self:GetWide(), 5 )
		surface.DrawTexturedRectRotated( self:GetWide()/2, self:GetTall(), self:GetWide(), 10, 180 )
		surface.DrawTexturedRectRotated( 0, self:GetTall()/2, self:GetTall(), 7.5, 270 )
		surface.DrawTexturedRectRotated( self:GetWide(), self:GetTall()/2, self:GetTall(), 5, 90 )

		if !self.Cursor then
			surface.SetFont("ScoreboardSub")
			surface.SetTextColor( 150, 150, 45, 255 )
			local distw, disth = surface.GetTextSize("Click to show your cursor.")
			surface.SetTextPos( DermaFrame:GetWide()/2 - (distw)/2, tabheight - disth - 5) 
			surface.DrawText( "Click to show your cursor." )
		end

		surface.SetFont("ScoreboardHeader")
		surface.SetTextColor( 255,255,255,255 )
		local distw, disth = surface.GetTextSize("Sassilization")
		local curheight = disth + disth/3
		surface.SetTextPos( self:GetWide()/2 - distw/2, disth/6 ) 
		surface.DrawText( "Sassilization" )

		surface.SetFont("ScoreboardSub")
		local logoHeight = disth
		local distw, disth = surface.GetTextSize("Created by Sassafrass/Spacetech/Luapineapple/Hatefuleagle")
		surface.SetTextPos( self:GetWide()/2 - distw/2, disth/6 + logoHeight )
		surface.SetTextColor( 255,255,255,255 )
		surface.DrawText( "Created by Sassafrass/Spacetech/Luapineapple/Hatefuleagle" )

		surface.SetFont("ScoreboardSub")
		surface.SetTextColor( 255,255,255,255 )
		local distw, disth = surface.GetTextSize("Render Distance: ")
		surface.SetTextPos( (DermaFrame:GetWide()/3)*2 - (distw)/2, tabheight - (tabHeightBuffer/4)*3) 
		surface.DrawText( "Render Distance: " )

		surface.SetFont("ScoreboardSub")
		surface.SetTextColor( 255,255,255,255 )
		local distw, disth = surface.GetTextSize("Disable Hints")
		surface.SetTextPos( DermaFrame:GetWide()/3 - (distw+10)/2, tabheight - (tabHeightBuffer/4)*3) 
		surface.DrawText( "Disable Hints" )

		surface.SetFont("ScoreboardList")
		surface.SetTextColor( 255,255,255,255 )
		surface.SetTextPos( self:GetWide()*0.05, curheight) 
		surface.DrawText( "Allies" )

		surface.SetTextColor( 255,255,255,255 )
		surface.SetTextPos( self:GetWide()*0.15, curheight) 
		surface.DrawText( "Name" )

		surface.SetTextColor( 255,255,255,255 )
		surface.SetTextPos( self:GetWide()*0.6, curheight) 
		surface.DrawText( "Gold" )

		surface.SetTextColor( 255,255,255,255 )
		surface.SetTextPos( self:GetWide()*0.7, curheight) 
		surface.DrawText( "Cities" )

		local distw, disth = surface.GetTextSize("Ping")
		surface.SetTextPos( self:GetWide()*0.8, curheight ) 
		surface.DrawText( "Ping" )

		local distw, disth = surface.GetTextSize("Mute")
		surface.SetTextPos( self:GetWide()*0.9, curheight )
		surface.DrawText( "Mute" )

		local curheight = curheight + disth*1.5

		surface.SetDrawColor(100,100,100,255)
		surface.DrawLine(self:GetWide()*0.05, curheight, self:GetWide()*0.95, curheight)

		menuheight = curheight


		allianceCount = 0

		for k,v in pairs(player.GetHumans()) do
			if (v:GetEmpire()) then
				v.predictedHeight = curheight

				surface.SetFont("ScoreboardList")
				local distw, disth = surface.GetTextSize("Color")
				surface.SetDrawColor( v:GetEmpire():GetColor() )
				surface.SetFont("ScoreboardPlayer")
				local distw2, disth2 = surface.GetTextSize("Hello")
				surface.DrawRect(self:GetWide()*0.05, curheight + disth2/4, self:GetWide()*0.9, (disth2/4)*6)

				surface.SetFont("ScoreboardPlayer")
				local distw, disth = surface.GetTextSize("Hello")
				surface.SetTextPos( self:GetWide()*0.15, curheight + disth/2 )
				surface.SetTextColor( 255,255,255,255 )
				surface.DrawText( v:Nick() )

				surface.SetFont("ScoreboardList")
				local distw, disth = surface.GetTextSize("Gold")
				surface.SetFont("ScoreboardPlayer")
				local distw2, disth2 = surface.GetTextSize(v:GetEmpire():GetGold())
				surface.SetTextPos( self:GetWide()*0.6 + distw/2 - distw2/2, curheight + disth2/2 ) 
				surface.DrawText( v:GetEmpire():GetGold() )
				
				surface.SetFont("ScoreboardList")
				local distw, disth = surface.GetTextSize("Cities")
				surface.SetFont("ScoreboardPlayer")
				local distw2, disth2 = surface.GetTextSize(v:GetEmpire():GetCities())
				surface.SetTextPos( self:GetWide()*0.7 + distw/2 - distw2/2, curheight + disth2/2 ) 
				surface.DrawText( v:GetEmpire():GetCities() )
		
				surface.SetFont("ScoreboardList")
				local distw, disth = surface.GetTextSize("Ping")
				surface.SetFont("ScoreboardPlayer")
				local distw2, disth2 = surface.GetTextSize(v:Ping())
				surface.SetTextPos( self:GetWide()*0.8 + distw/2 - distw2/2, curheight + disth2/2 ) 
				surface.DrawText( v:Ping() )

				if v.allies then
					if !v.allyNum then
						allianceCount = allianceCount + 1
						v.allyNum = allianceCount
					end
					v.highestGold = v:GetEmpire():GetGold()
					v.drawColor = v:GetEmpire():GetColor()
					for i,d in pairs(v.allies) do
						if d:GetEmpire():GetGold() > v.highestGold then
							v.highestGold = d:GetEmpire():GetGold()
							v.drawColor = d:GetEmpire():GetColor()
						end
					end
					for i,d in pairs(v.allies) do
						d.allyNum = v.allyNum
						if d != v then
							if IsValid(d) then
								surface.SetFont("ScoreboardList")
								local distw, disth = surface.GetTextSize("Allies")
								surface.SetFont("ScoreboardPlayer")
								local distw2, disth2 = surface.GetTextSize("Hello")
								//surface.SetDrawColor( v.drawColor )
								/*
								surface.DrawOutlinedRect(self:GetWide()*0.05 + 15/2, curheight + disth2 - 5, v.allyNum*(self:GetWide()*0.015), 10)
								surface.DrawOutlinedRect(self:GetWide()*0.05 + 15/2, curheight + disth2, v.allyNum*(self:GetWide()*0.015), d.predictedHeight - curheight)
								surface.DrawOutlinedRect(self:GetWide()*0.05 + 15/2, d.predictedHeight + disth2 - 5, v.allyNum*(self:GetWide()*0.015), 10)
								*/
								surface.SetDrawColor( 255,255,255,255 )
								surface.DrawLine( (self:GetWide()*0.05 + 15/2) - v.allyNum*(self:GetWide()*0.015), curheight + disth2, (self:GetWide()*0.05 + 15/2), curheight + disth2 )
								surface.DrawLine( (self:GetWide()*0.05 + 15/2) - v.allyNum*(self:GetWide()*0.015), curheight + disth2, (self:GetWide()*0.05 + 15/2) - v.allyNum*(self:GetWide()*0.015), d.predictedHeight + disth2 )
								surface.DrawLine( (self:GetWide()*0.05 + 15/2) - v.allyNum*(self:GetWide()*0.015), d.predictedHeight + disth2, (self:GetWide()*0.05 + 15/2), d.predictedHeight + disth2 )
								
							end
						end
					end
				end

				curheight = curheight + disth2*2
				surface.SetDrawColor(100,100,100,255)
				surface.DrawLine(self:GetWide()*0.05, curheight, self:GetWide()*0.95, curheight)
			end
		end
	end
end

function GM:ScoreboardHide()
	TabOpen = false
	DermaFrame:Close()
	timer.Destroy("updaters")
	vgui.GetWorldPanel():SetCursor("blank")
	HideMouse()
end

function GM:HUDDrawScoreBoard()
end