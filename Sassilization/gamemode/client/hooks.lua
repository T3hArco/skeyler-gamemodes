--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

surface.CreateFont("Tab", {
	font = "Constantia",
	size = 22, 
	weight = 500
})

surface.CreateFont("TabSelected", {
	font = "Constantia",
	size = 24, 
	weight = 500
})

surface.CreateFont("TabLarge", {
	font = "Tahoma",
	size = 13, 
	weight = 1000,
	antialiased = false,
	shadow = true
})

surface.CreateFont("DefaultSmallDropShadow", {
	font = "Tahoma",
	size = 11, 
	weight = 100,
	antialiased = false,
	shadow = true
})

GM = GM or GAMEMODE

GM.BuildingTextures = {
	city = "sassilization/bottombar/building_icons/city_icon",
	walltower = "sassilization/bottombar/building_icons/wall_icon",
	gate = "sassilization/bottombar/building_icons/gate_icon",
	tower = "sassilization/bottombar/building_icons/tower_icon",
	workshop = "sassilization/bottombar/building_icons/workshop_icon",
	shieldmono = "sassilization/bottombar/building_icons/shieldmono_icon",
	shrine = "sassilization/bottombar/building_icons/shrine_icon"
}

GM.UnitTextures = {
	swordsman = "sassilization/bottombar/unit_icons/swordsman_icon",
	scallywag = "sassilization/bottombar/unit_icons/scallywag_icon",
	archer = "sassilization/bottombar/unit_icons/archer_icon",
	ballista = "sassilization/bottombar/unit_icons/ballista_icon",
	catapult = "sassilization/bottombar/unit_icons/catapult_icon"	
}

GM.ButtonClick = Sound("buttons/button1.wav")
GM.ButtonRelease = Sound("UI/buttonclickrelease.wav")
GM.ButtonRollover = Sound("UI/buttonrollover.wav")

function GM:OnBuildingMenuOpen()
	
	if( not self.BottomBar ) then return end
	if( self.MenuOpen ) then return end
	
	self.Ghosting = true
	self.BottomBar:SelectTab( "Buildings" )
	self.BottomBar:Slide(true)
	self:ItemSelect( self.BottomBar:GetItem(), true )
	self:CreateGhost()
	--RestoreCursorPosition()
	gui.SetMousePos( ScrW() / 2, ScrH() / 2 )
	ShowMouse()

	self.MenuOpen = true
	
end

function GM:OnUnitMenuOpen()
	
	if( not self.BottomBar ) then return end
	if( self.MenuOpen ) then return end
	
	self.Ghosting = true
	self.BottomBar:SelectTab( "Units" )
	self.BottomBar:Slide(true)
	self:ItemSelect( self.BottomBar:GetItem() )
	self:CreateGhost()
	--RestoreCursorPosition()
	gui.SetMousePos( ScrW() / 2, ScrH() / 2 )
	ShowMouse()

	self.MenuOpen = true
	
end

function GM:OnBuildingMenuClose()
	
	if( not self.BottomBar ) then return end
	
	self.Ghosting = false
	self:RemoveGhost()
	self.BottomBar:Slide(false)
	RememberCursorPosition()
	gui.SetMousePos( ScrW() / 2, ScrH() / 2 )
	HideMouse()

	self.MenuOpen = false
	
end

function GM:OnUnitMenuClose()
	
	if( not self.BottomBar ) then return end
	
	self.Ghosting = false
	self:RemoveGhost()
	self.BottomBar:Slide(false)
	RememberCursorPosition()
	gui.SetMousePos( ScrW() / 2, ScrH() / 2 )
	HideMouse()

	self.MenuOpen = false
	
end

function GM:OnContextMenuOpen()
	return false
end

function GM:OnContextMenuClose()
	return false
end

function GM:Think()
	if( self.Ghosting ) then
		if( self.Ghost.Building and not buildingMenu and not unitMenu ) then
			gamemode.Call( "OnBuildingMenuClose" )
		elseif( not self.Ghost.Building and not unitMenu and not buildingMenu ) then
			gamemode.Call( "OnUnitMenuClose" )
		end
	end
	if !unitMenu and !buildingMenu and !TabOpen then
		HideMouse()
	end
	if !self.BottomBar then
		self.BottomBar = vgui.Create("sa_bottombar")
	end
end

--Using this rather than Q/E for players who happen to be on a different keyboard layout from QWERTY (Specifically because Arco wanted AZERTY support.) //Hateful
hook.Add("PlayerBindPress", "menu.PlayerBindPress", function(ply, bind, pressed)
	if string.find(bind, "+menu") then
		if pressed then
			buildingMenu = true
			gamemode.Call( "OnBuildingMenuOpen" )
		else
			buildingMenu = false
			if unitMenu then
				gamemode.Call( "OnUnitMenuClose" )
				gamemode.Call( "OnBuildingMenuClose" )
				gamemode.Call( "OnUnitMenuOpen" )
			end
		end
		
		return true
	end
	if string.find(bind, "+use") then
		if pressed then
			unitMenu = true
			gamemode.Call( "OnUnitMenuOpen" )
		else
			unitMenu = false
			if buildingMenu then
				gamemode.Call( "OnUnitMenuClose" )
				gamemode.Call( "OnBuildingMenuClose" )
				gamemode.Call( "OnBuildingMenuOpen" )
			end
		end
		
		return true
	end
end)

function GM:PostRenderVGUI()
	if (not self.RenderedVGUI) then
		self.RenderedVGUI = true
	end
end

vgui.GetWorldPanel():SetCursor("blank")

hudScaler = hudScaler or nil

if (IsValid(hudScaler)) then
	hudScaler:Remove()
end

-- hudScaler = vgui.Create( "DFrame" )
-- hudScaler:SetPos( 50,50 )
-- hudScaler:SetSize( 200, 250 )
-- hudScaler:SetTitle( "Testing Derma Stuff" )
-- hudScaler:SetVisible( true )
-- hudScaler:SetDraggable( true )
-- hudScaler:ShowCloseButton( true )
 
local hudScale = CreateClientConVar( "sass_hud_scale1", 1, true, true )

-- local NumSlider = vgui.Create( "DNumSlider", hudScaler )
-- NumSlider:SetPos( 25,50 )
-- NumSlider:SetWide( 150 )
-- NumSlider:SetText( "HUD Scale" )
-- NumSlider:SetMin( 1 ) -- Minimum number of the slider
-- NumSlider:SetMax( 2 ) -- Maximum number of the slider
-- NumSlider:SetDecimals( 2 ) -- Sets a decimal. Zero means it's a whole number
-- NumSlider:SetConVar( "sass_hud_scale1" ) -- Set the convar

-- local ApplyBtn = vgui.Create( "DButton", hudScaler )
-- ApplyBtn:SetPos( 25, 170 )
-- ApplyBtn:SetWide( 150 )
-- ApplyBtn:SetText( "Apply" )
-- ApplyBtn.DoClick = function()
	-- GAMEMODE:UpdateHUDScale( hudScale:GetFloat() )
-- end

-- hudScaler:MakePopup()

SA.HUD = SA.HUD or {}
SA.HUD.Scale = hudScale:GetFloat()
SA.HUD.FONTS = SA.HUD.FONTS or {}

function GM:UpdateHUDScale( scale )
	scale = math.Clamp( scale, 1, 2 )
	
	surface.CreateFont("ShrineName" .. scale, {
		font 	= "Georgia",
		size 	= 14 * scale,
		weight 	= 700,
		shadow 	= true
	})
	
	SA.HUD.FONTS["ShrineName"] = "ShrineName" .. scale
	
	surface.CreateFont("GoldBarFont" .. scale, {
		font 	= "Georgia",
		size 	= 16 * scale,
		weight 	= 700,
		shadow 	= true
	})
	
	SA.HUD.FONTS["GoldBarFont"] = "GoldBarFont" .. scale
	
	surface.CreateFont("ResourceFont" .. scale, {
		font 	= "Georgia",
		size 	= 20 * scale,
		weight 	= 1200,
		shadow 	= true
	})
	
	SA.HUD.FONTS["ResourceFont"] = "ResourceFont" .. scale
	
	surface.CreateFont("NoteFont" .. scale, {
		font 	= "Georgia",
		size 	= 20 * scale,
		weight 	= 1200,
		shadow 	= true
	})
	
	SA.HUD.FONTS["NoteFont"] = "NoteFont" .. scale
	
	SA.HUD.Scale = scale
end

GM:UpdateHUDScale( hudScale:GetFloat() )

local tex = Material("sassilization/hud2.png")
local creedIcon = surface.GetTextureID("sassilization/topbar/creed_icon")

include("gui/goldbar.lua")
include("gui/resourcebar.lua")
--include("gui/creedbar.lua") This is the old bottom shrine/miralce hud. // Chewgum
include("gui/shrine.lua")

function GM:HUDPaint()
	local localEmpire = LocalEmpire()
	
	if (localEmpire) then
		local sw, sh = ScrW(), ScrH()
		
		surface.SetMaterial(tex)
		surface.SetDrawColor(color_white)
		
		self:DrawGoldBar(localEmpire, sw, sh, SA.HUD.Scale)
		self:DrawResourceBar(localEmpire, sw, sh, SA.HUD.Scale)
		self:DrawShrineHud(localEmpire, sw, sh, SA.HUD.Scale)
		self:DrawCrosshair(localEmpire)
		
		--	self:DrawCreedBar(localEmpire, sw, sh, SA.HUD.Scale) This is the old bottom shrine/miralce hud. // Chewgum
	end
end

local ConvarCrosshairHints = CreateClientConVar( "sass_crosshair_showhints", 1, true, true )
local tex_crosshair = surface.GetTextureID( "sassilization/indicator" )
local HUDHintTextColor = Color( 255, 255, 255, 200 )
local HUDHintTextColorActive = Color( 255, 255, 255, 255 )

function GM:DrawCrosshair(localEmpire)
	if( GAMEMODE.Selecting ) then return end
	if( GAMEMODE.Ghosting ) then return end
	if( vgui.CursorVisible() ) then return end
	
	local size = 16
	local lActive = false
	local rActive = false
	local leftAction = ""
	local rightAction = ""
	
	surface.SetTexture( tex_crosshair )
	if( GAMEMODE.REFUNDMODE ) then
		surface.SetDrawColor( 255, 0, 0, 200 )
		
		leftAction = "Sell"
		//rightAction = "Repair"
		
		if( SA.Refundables and table.Count(SA.Refundables) > 0 ) then
			
			lActive = true
			size = 24
			
		end
		
		if( SA.Repairables and table.Count(SA.Repairables) > 0 ) then
			
			rActive = true
			size = 24
			
		end
		
	else
		surface.SetDrawColor( 255, 255, 255, 200 )
		
		if (localEmpire:NumSelectedUnits() > 0) then
			local pl = LocalPlayer()
			local tr = pl:GetEyeTraceNoCursor()
			
			if (tr.Entity:IsShrine() and (tr.Entity:GetEmpire() == localEmpire or IsAllied(tr.Entity:GetEmpire(), localEmpire))) then
				rightAction = "Sacrifice"
			elseif (input.IsKeyDown(KEY_LALT)) then
				rightAction = "Move"
				
				if (IsValid(tr.Entity) and tr.Entity:IsBuilding()) then
					if (tr.Entity:GetEmpire() != localEmpire) and !IsAllied(tr.Entity:GetEmpire(), localEmpire) then
						rightAction = "Attack"
					end
				else
					local units, count = unit.FindInSphere(tr.HitPos, 15)
					
					if (count > 0) then
						local friendly = true
						
						for i = 1, count do
							local unit = units[i]
							
							if (unit and unit:GetEmpire() != localEmpire and !IsAllied(unit:GetEmpire(), localEmpire)) then
								friendly = false
							end
						end
						
						if (!friendly) then
							rightAction = "Attack"
						end
					end
				end
			else
				rightAction = "Move and Attack"
			end
			if( LocalPlayer():KeyDown( IN_SPEED ) ) then
				rightAction = "+" .. tostring(rightAction)
			end
			
		end
		
		--leftAction = "Select"
		
		leftAction = "" -- Sorta annoying, don't you think?
	end
	
	surface.DrawTexturedRect( ScrW() * 0.5 - size * 0.5, ScrH() * 0.5 - size * 0.5, size, size )
	
	if( ConvarCrosshairHints:GetBool() ) then
		draw.SimpleText(leftAction, lActive and "BudgetLabel" or "DefaultSmallDropShadow", ScrW() *0.5 -size *0.5 -2, ScrH() *0.5, lActive and HUDHintTextColorActive or HUDHintTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText(rightAction, rActive and "BudgetLabel" or "DefaultSmallDropShadow", ScrW() *0.5 +size *0.5 +2, ScrH() *0.5, rActive and HUDHintTextColorActive or HUDHintTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

function surface.DrawTexturedRectUVEx(posx, posy, width, height, u1, v1, u2, v2)
	surface.DrawPoly({
		{
			x = posx,
			y = posy,
			u = u1,
			v = v1
		},
		
		{
			x = posx + width,
			y = posy,
			u = u2,
			v = v1
		},
		
		{
			x = posx + width,
			y = posy + height,
			u = u2,
			v = v2
		},
		
		{
			x = posx,
			y = posy + height,
			u = u1,
			v = v2
		}
	})
end

function GM:PlayerBindPress(pl, bind, pressed)
	if (bind == "+use") then return true end
	--if (bind == "+walk") then return true end
end

function GM:HUDShouldDraw(Name)
	if(Name == "CHudHealth") then
		return false
	elseif(Name == "CHudCrosshair") then
		return false
	elseif(Name == "CHudWeaponSelection") then
		return false
	end
	
	return true
end

net.Receive("SendPing", function( len )
	local ent = net.ReadEntity()
	local pos = net.ReadVector()
	local ang = net.ReadAngle()
	local effect = EffectData()
		effect:SetStart(pos)
		effect:SetAngles(ang)
		effect:SetEntity(ent)
	util.Effect("ping_arrow", effect, true, true)
end)