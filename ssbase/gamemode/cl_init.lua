---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

include("shared.lua")
include("sh_profiles.lua") 
include("cl_chatbox.lua") 
include("cl_hud.lua") 

GM:HUDAddShouldNotDraw("CHudHealth") 
GM:HUDAddShouldNotDraw("CHudSecondaryAmmo") 
GM:HUDAddShouldNotDraw("CHudAmmo") 
GM:HUDAddShouldNotDraw("CHudChat") 
-- GM:HUDAddShouldNotDraw("CHudCrosshair") 

GM.GUIBlurAmt = 0
GM.GUIBlurOverlay = Material("skeyler/blur_overlay") 

function GM:SetGUIBlur(bool) 
	self.GUIBlur = bool or false 
end 

function GM:RenderScreenspaceEffects() 
	if self.GUIBlurAmt > 0 or self.GUIBlur then 
		if self.GUIBlur then 
			self.GUIBlurAmt = math.Approach(self.GUIBlurAmt, 10, 0.2) 
		else 
			self.GUIBlurAmt = math.Approach(self.GUIBlurAmt, 0, 0.5) 
		end 
		DrawToyTown( self.GUIBlurAmt, ScrH() ) 
		surface.SetDrawColor(92, 92, 92, 160/10*self.GUIBlurAmt*0.50)
		surface.SetMaterial(self.GUIBlurOverlay) 
		surface.DrawTexturedRect(0, 0, 2480-(1920-ScrW()), 2480-(1080-ScrH())) 
	end 
end 

local MaxAmmo = {weapon_crowbar=0,weapon_physcannon=0,weapon_pysgun=0,weapon_pistol=18,gmod_tool=0,weapon_357=6,weapon_smg1=45,weapon_ar2=30,weapon_crossbow=1,weapon_frag=1,weapon_rpg=1,weapon_shotgun=6}
function GetPrimaryClipSize(wep) 
	if !wep or !wep:IsValid() then return false end 
	if MaxAmmo[wep:GetClass()] then 
		return MaxAmmo[wep:GetClass()] 
	elseif wep.Primary and wep.Primary.ClipSize then 
		return wep.Primary.ClipSize 
	end 
end 

local mag_left, mag_extra, mag_clip 
local function HUDAmmoCalc()
	local wep = LocalPlayer():GetActiveWeapon()  
	if(!wep or wep == "Camera" or !wep.Clip1 or wep:Clip1() == -1) then return 1, 1, "" end
	mag_left = wep:Clip1() 
	mag_extra = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()) 
	max_clip = MaxAmmo[wep:GetClass()] or wep.Primary.ClipSize 
	return mag_left, max_clip, tostring(mag_left).."/"..tostring(mag_extra) 
end 
