-- Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModel		= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel		= "models/weapons/w_toolgun.mdl"
SWEP.AnimPrefix		= "python"

SWEP.UseHands			= true

SWEP.ShootSound			= Sound( "Airboat.FireGunRevDown" )

SWEP.Primary = 
{
	ClipSize 	= -1,
	DefaultClip = -1,
	Automatic = false,
	Ammo = "none"
}

SWEP.Secondary = 
{
	ClipSize 	= -1,
	DefaultClip = -1,
	Automatic = false,
	Ammo = "none"
}

SWEP.CanHolster			= true
SWEP.CanDeploy			= true

function SWEP:Initialize()
	self.Primary = 
	{
		-- Note: Switched this back to -1.. lets not try to hack our way around shit that needs fixing. -gn
		ClipSize 	= -1,
		DefaultClip = -1,
		Automatic = false,
		Ammo = "none"
	}
	
	self.Secondary = 
	{
		ClipSize 	= -1,
		DefaultClip = -1,
		Automatic = false,
		Ammo = "none"
	}
end 

function SWEP:Precache() 
	util.PrecacheModel( SWEP.ViewModel )
	util.PrecacheModel( SWEP.WorldModel ) 
	util.PrecacheSound( self.ShootSound )
end 