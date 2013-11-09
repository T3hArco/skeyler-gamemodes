

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "USP .45"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.IconLetter			= "a"
	
	killicon.AddFont( "weapon_usp", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel 			= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_usp.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound 		= Sound("Weapon_USP.Single")
SWEP.Primary.Damage 		= 20
SWEP.Primary.Recoil 		= 1
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.0155
SWEP.Primary.ClipSize 		= 12
SWEP.Primary.Delay 		= 0.16
SWEP.Primary.DefaultClip 	= 12
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 		= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector (4.4777, 0, 2.752)
SWEP.IronSightsAng 		= Vector (-0.2267, -0.0534, 0)
