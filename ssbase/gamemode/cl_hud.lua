---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

HUD_DO_NOT_DRAW = {}
function GM:HUDAddShouldNotDraw(name) 
	HUD_DO_NOT_DRAW[name] = true 
end 

function GM:HUDShouldDraw(name) 
	if HUD_DO_NOT_DRAW[name] then return false end 

	if self.GUIBlur and name == "CHudCrosshair" then return false end 
	return true 
end 

surface.CreateFont("HUD_Money", {font="Helvetica LT Std Cond", size=18, weight=800})
surface.CreateFont("HUD_HP_Percent", {font="Helvetica LT Std Cond", size=22, weight=800})
surface.CreateFont("HUD_HP", {font="Helvetica LT Std Cond", size=15, weight=1000})
surface.CreateFont("HUD_CENTER", {font="Helvetica LT Std Cond", size=18, weight=1000})
surface.CreateFont("HUD_Level", {font="Helvetica LT Std Cond", size=20, weight=900})
surface.CreateFont("HUD_Level_Blue", {font="Helvetica LT Std Cond", size=22, weight=1000})
surface.CreateFont("HUD_Timer", {font="Century Gothic", size=40, weight=1000}) 
surface.CreateFont("HUD_Timer_Small", {font="Century Gothic", size=24, weight=1000}) 

surface.CreateFont("HUD_WEPS", {font="HalfLife2", size=80, weight=550})
surface.CreateFont("PLAYER_TEXT", {font="Arvil Sans", size=120, weight=400})
surface.CreateFont("PLAYER_TEXT_BLUR", {font="Arvil Sans", size=120, weight=400, blursize=8, antialias=false}) 

HUD_LEFT = Material("skeyler/vgui/hud/hud_box_left.png", "noclamp smooth") 
HUD_CENTER = Material("skeyler/vgui/hud/hud_box_center.png", "noclamp smooth") 
HUD_RIGHT = Material("skeyler/vgui/hud/hud_box_ammo.png", "noclamp smooth") 
HUD_RIGHT_CIRCLE = Material("skeyler/vgui/hud/hud_box_ammo_circle.png", "noclamp smooth") 
HUD_HP = Material("skeyler/vgui/hud/hud_bar_health.png", "noclamp smooth") 
HUD_XP = Material("skeyler/vgui/hud/hud_bar_xp.png", "noclamp smooth") 
HUD_AMMO = Material("skeyler/vgui/hud/hud_bar_ammo.png", "noclamp smooth") 
HUD_BAR_CENTER = Material("skeyler/vgui/hud/hud_bar_center.png", "noclamp smooth") 
HUD_COIN = Material("skeyler/vgui/skeyler_coin02.png", "noclamp smooth") 


GM.HudAlpha = 0 
GM.HUDHPSmooth = 0 
GM.HUDHP = 0
GM.HUDVelFrac = 1 
GM.HUDVel = 0 

local weaponImgs = {
	ar2 = "l", 
	pistol = "d", 
	smg = "a", 
	crossbow = "g", 
	shotgun = "b",
	rpg = "i", 
	grenade = "k", 
	bugbait = "k", 
	melee = "c", 
	revolver = "e", 
	physgun = "m", 
}

function GetWeaponIcon(wep) 

end 
 
local w, h, Text, tw, th, tw2, th2, wep, frac = ScrW(), ScrH(), "", 0, 0, 0, 0, 0, 0 

function GM:HUDPaint()
if self.GUIBlur then 
		self.HudAlpha = math.Approach(self.HudAlpha, 0, 5) 
	else 
		self.HudAlpha = math.Approach(self.HudAlpha, 255, 5) 
		if self.HudAlpha <= 0 then return end 
	end 

	if LocalPlayer():Alive() then 
		self.HUDHPSmooth = math.min(LocalPlayer():GetMaxHealth(), math.Approach(self.HUDHPSmooth, LocalPlayer():Health(), 5)) 
		self.HUDHP = math.ceil(LocalPlayer():Health()/100*100)
		if self.HUDShowVel then 
			self.HUDVel = LocalPlayer():GetVelocity():Length2D()
			self.HUDVelFrac = math.Approach(self.HUDVelFrac, math.min(1200, self.HUDVel)/1200, 0.01) 
		end 
	else 
		self.HUDHPSmooth = math.Approach(self.HUDHPSmooth, 0, 1) 
		self.HUDHP = 0 
		if self.HUDShowVel then self.HUDVelFrac = math.Approach(1, self.HUDVelFrac, 0.01)  end 
	end 

	if self.HUDShowTimer then 
		/* Top HUD (Timer) */
		Text = "00:00:00.00"
		if LocalPlayer():GetNetworkedInt("STimer_TotalTime", 0) != 0 then 
			Text = FormatTime(LocalPlayer():GetNetworkedInt("STimer_TotalTime", 0)) 
		elseif LocalPlayer():GetNetworkedInt("STimer_StartTime", 0) != 0 then 
			Text = FormatTime(CurTime()-LocalPlayer():GetNetworkedInt("STimer_StartTime", 0))
		end 

		surface.SetFont("HUD_Timer") 
		tw, th = surface.GetTextSize(Text) 
		surface.SetTextColor(0, 0, 0, self.HudAlpha) 
		surface.SetTextPos(w/2-tw/2+1, 40+1) 
		surface.DrawText(Text) 
		surface.SetTextColor(255, 255, 255, self.HudAlpha) 
		surface.SetTextPos(w/2-tw/2, 40) 
		surface.DrawText(Text) 
		
		Text = FormatTime(LocalPlayer():GetNetworkedInt("STimer_PB", 0)) 

		surface.SetFont("HUD_Timer_Small") 
		tw = surface.GetTextSize(Text) 
		surface.SetTextColor(0, 0, 0, self.HudAlpha) 
		surface.SetTextPos(w/2-tw/2+1, 40+th+1) 
		surface.DrawText(Text) 
		surface.SetTextColor(253, 189, 77, self.HudAlpha) 
		surface.SetTextPos(w/2-tw/2, 40+th) 
		surface.DrawText(Text) 
	end 

	/* Left HUD */
	surface.SetDrawColor(255, 255, 255, self.HudAlpha) 
	surface.SetMaterial(HUD_LEFT) 
	surface.DrawTexturedRect(45, h-165, 512, 256) 

	surface.SetDrawColor(255, 255, 255, self.HudAlpha*0.85) 
	
	draw.RoundedBox(4, 179, h -118, (self.HUDHPSmooth/LocalPlayer():GetMaxHealth()) *173, 13, Color(255, 85, 85, 255))
	
	--render.SetScissorRect(175, h-121, 179+(172*(self.HUDHPSmooth/LocalPlayer():GetMaxHealth())), h-89, true)
	--surface.SetMaterial(HUD_HP) 
	--surface.DrawTexturedRect(175, h-122, 256, 32)
	--render.SetScissorRect(175, h-121, 179+(172*(self.HUDHPSmooth/LocalPlayer():GetMaxHealth())), h-89, false)

	surface.SetMaterial(HUD_XP) 
	surface.DrawTexturedRect(176, h-106, 128, 16)

	Text = tostring(self.HUDHP).."%"
	surface.SetTextColor(255, 255, 255, self.HudAlpha) 
	surface.SetFont("HUD_HP_Percent") 
	tw, th = surface.GetTextSize(Text) 
	surface.SetTextPos(179, h-119-th) 
	surface.DrawText(Text) 

	surface.SetTextColor(147, 147, 147, self.HudAlpha) 
	surface.SetFont("HUD_HP") 
	surface.SetTextPos(355, h-120)
	surface.DrawText("HP") 

	surface.SetTextPos(309, h-105)
	surface.DrawText("EXP") 

	--surface.SetMaterial(HUD_COIN) 
	--surface.SetDrawColor(255, 255, 255, self.HudAlpha) 
	--surface.DrawTexturedRect(187, h-82, 12, 17) 
	draw.SimpleRect(187, h -72, 5, 5, Color(69, 192, 255, 255))
	draw.SimpleRect(187 +5, h -77, 5, 5, Color(69, 192, 255, 220))
	draw.SimpleRect(187, h -82, 5, 5, Color(69, 192, 255, 140))

	Text = FormatNum(LocalPlayer():GetMoney())
	surface.SetFont("HUD_Money") 
	tw, th = surface.GetTextSize(Text) 
	surface.SetTextPos(205, h-73-th/2)
	surface.SetTextColor(110, 110, 110, self.HudAlpha) 
	surface.DrawText(Text) 

	surface.SetFont("HUD_Level_Blue") 
	surface.SetTextColor(102, 167, 201, self.HudAlpha) 
	tw, th = surface.GetTextSize(" "..tostring(LocalPlayer():GetLevel())) 
	surface.SetTextPos(378-tw, h-76-th/2) 
	surface.DrawText(" "..tostring(LocalPlayer():GetLevel())) 

	surface.SetFont("HUD_Level")
	surface.SetTextColor(195, 195, 195, self.HudAlpha) 
	tw2, th2 = surface.GetTextSize("lvl") 
	surface.SetTextPos(378-tw-tw2, h-73-th2/2)
	surface.DrawText("lvl") 

	/* Center HUD */
	if self.HUDShowVel and w > 800 then -- Get a better computer if you can only handle 800x600
		surface.SetFont("HUD_CENTER") 
		tw = surface.GetTextSize("VELOCITY") 
		surface.SetTextPos((w/2)-99, h-115)
		surface.SetTextColor(0, 0, 0, self.HudAlpha) 
		surface.DrawText("VELOCITY")
		surface.SetTextPos((w/2)-100, h-116)
		surface.SetTextColor(255, 255, 255, self.HudAlpha) 
		surface.DrawText("VELOCITY") 

		Text = tostring(math.floor(self.HUDVel)) 
		tw = surface.GetTextSize(Text) 
		surface.SetTextPos((w/2)+90-tw, h-115)
		surface.SetTextColor(0, 0, 0, self.HudAlpha) 
		surface.DrawText(Text) 
		surface.SetTextPos((w/2)+90-tw, h-116)
		surface.SetTextColor(255, 255, 255, self.HudAlpha) 
		surface.DrawText(Text) 

		surface.SetDrawColor(255, 255, 255, self.HudAlpha)
		surface.SetMaterial(HUD_CENTER) 
		surface.DrawTexturedRect((w/2)-121, h-106, 256, 64) 

		render.SetScissorRect((w/2)-100, h-86, (w/2)-100+(190*self.HUDVelFrac), h-74, true)
		surface.SetDrawColor(255, 255, 255, self.HudAlpha*0.85)
		surface.SetMaterial(HUD_BAR_CENTER) 
		surface.DrawTexturedRect((w/2)-103, h-89, 256, 32) 
		render.SetScissorRect((w/2)-100, h-86, (w/2)-100+(190*self.HUDVelFrac), h-74, false) 
	end 

	/* Right HUD (Ammo) */
	wep = LocalPlayer():GetActiveWeapon() 
	
	if (IsValid(wep)) then
		surface.SetDrawColor(255, 255, 255, self.HudAlpha)
		surface.SetMaterial(HUD_RIGHT_CIRCLE) 
		surface.DrawTexturedRect(w -(256 -46), h-173, 256, 256) 
		
		surface.SetDrawColor(255, 255, 255, self.HudAlpha) 
		surface.SetMaterial(HUD_RIGHT) 
		surface.DrawTexturedRect(w -(256 +131), h-106, 256, 64) 
		
		Text = "" 
		
		if !wep or !wep:IsValid() or !wep.Clip1 or wep:Clip1() == -1 or GetPrimaryClipSize(wep) == 0 then 
			if GetPrimaryClipSize(wep) then 
				Text = tostring(GetPrimaryClipSize(wep)).." / "
			else 
				Text = "0 / " 
			end 
			frac = math.Approach(frac, 1, 0.01)
			if wep and wep:IsValid() then 
				Text = Text..tostring(LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())) 
			else 
				Text = Text.."0"
			end 
		else 
			Text = tostring(wep:Clip1()).." / "..tostring(LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()))
			frac = math.Approach(frac, wep:Clip1()/GetPrimaryClipSize(wep), 0.01) 
		end 
		
		render.SetScissorRect(w -(256 +108)*frac, h-87, w-162, h-74, true)
		surface.SetDrawColor(255, 255, 255, self.HudAlpha*0.85) 
		surface.SetMaterial(HUD_AMMO) 
		surface.DrawTexturedRect(w -(256 +108), h-87, 256, 16)
		render.SetScissorRect(w -(256 +108)*frac, h-87, w-162, h-74, false)
		
		surface.SetFont("HUD_CENTER") 
		surface.SetTextColor(255, 255, 255, self.HudAlpha) 
		surface.SetTextPos(w-364, h-116) 
		surface.DrawText(Text) 
		
		Text = "a"
		if LocalPlayer():Alive() and LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon().GetHoldType and weaponImgs[LocalPlayer():GetActiveWeapon():GetHoldType()] then 
			Text = weaponImgs[LocalPlayer():GetActiveWeapon():GetHoldType()] 
		end 
		surface.SetFont("HUD_WEPS") 
		tw, th = surface.GetTextSize(Text) 
		surface.SetTextColor(35, 35, 35, self.HudAlpha) 
		surface.SetTextPos(w-125-tw/2, h-95-th/2)
		surface.DrawText(Text) 
		
		Text = "None" 
		if LocalPlayer():Alive() and LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon().GetPrintName then 
			Text = LocalPlayer():GetActiveWeapon():GetPrintName() 
		end 
		
		surface.SetFont("HUD_CENTER") 
		surface.SetTextColor(35, 35, 35, self.HudAlpha) 
		tw, th = surface.GetTextSize(Text) 
		surface.SetTextPos(w-125-tw/2, h-60-th/2) 
		surface.DrawText(Text) 
	end
end  
 
function GM:PostDrawTranslucentRenderables()
	for k, ply in pairs(player.GetAll()) do
		if (ply != LocalPlayer() and ply:Alive()) then
			local index = ply:LookupBone("ValveBiped.Bip01_Head1")
		
			if (index and index > -1) then
				local offset = Vector(0, 0, 15 )
				local ang = LocalPlayer():EyeAngles()
				local pos = ply:GetBonePosition(index) + offset + ang:Up()
			
				ang:RotateAroundAxis( ang:Forward(), 90 )
				ang:RotateAroundAxis( ang:Right(), 90 )
			
				local d = (ply:GetPos()-LocalPlayer():GetPos()):Length()
				local a = 0
				if(d <= 800) then
					if((d-300)<0) then
						a = 255
					else
						a = math.Round(math.min(255,((500-(d-300))/500)*255))
					end
				end
				if(a != 0) then
					ply.name_pixvis = ply.name_pixvis or util.GetPixelVisibleHandle()
					
					if (util.PixelVisible(ply:EyePos(), 16, ply.name_pixvis) > 0) then
						cam.IgnoreZ(true)
							cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.05 )
								local n = ply:Nick()
								draw.SimpleText( n, "PLAYER_TEXT_BLUR", 0, 0, Color(0,0,0,a), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
								draw.SimpleText( n, "PLAYER_TEXT", 4, 4, Color(0,0,0,(a/255)*180), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
								draw.SimpleText( n, "PLAYER_TEXT", 0, 0, Color(255,255,255,a), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
							cam.End3D2D()
						cam.IgnoreZ(false)
					end
				end
			end
		end
	end
end