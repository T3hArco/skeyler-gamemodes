-------------------------
-- Sassilization SMG
-- Spacetech
-------------------------

if(SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
else
	SWEP.PrintName			= "Sass SMG"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 4
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.DrawWeaponInfoBox 	= false
end

SWEP.Base = "weapon_base"

SWEP.HoldType = "smg"

SWEP.ViewModel		= Model("models/weapons/v_sass_smg.mdl")
SWEP.WorldModel		= Model("models/weapons/w_sass_smg.mdl")
SWEP.ViewModelFlip	= false

SWEP.Primary.ClipSize		= 45
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Punch = 0.25
SWEP.Spread = 0.04
SWEP.ShootSound		= Sound("Weapon_M4A1.Single") -- Sound("Weapon_SMG1.Single")
SWEP.ReloadSound	= Sound("Weapon_M4A1.Clipout") -- Sound("Weapon_SMG1.Reload")

SWEP.IronSightsPos = Vector(-4.2, -8, 1.58)
SWEP.IronSightsAng = Vector(0, 0, 0)

function SWEP:Initialize()
	if(self.SetWeaponHoldType) then
		self:SetWeaponHoldType(self.HoldType)
	end
end

function SWEP:PrimaryAttack()
	if(!self:CanPrimaryAttack()) then
		return
	end
	
	self.Owner:FireBullets({
		Num = 1,
		Src = self.Owner:GetShootPos(),
		Dir = self.Owner:GetAimVector(),
		Spread = Vector(math.Rand(0, self.Spread), math.Rand(0, self.Spread), math.Rand(0, self.Spread)),
		Tracer = 1,
		Force = 5,
		Damage = 14,
		AmmoType = self.Primary.Ammo
	})
	
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	
	self.Owner:ViewPunch(Angle(math.Rand(0, self.Punch), math.Rand(0, self.Punch), math.Rand(0, self.Punch)))
	self.Weapon:EmitSound(self.ShootSound, 75, math.random(90, 110))
	
	self:TakePrimaryAmmo(1)
	
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.075)
end

/*
	garry's Ironsights stuff
	Semi edited
*/

local IRONSIGHT_TIME = 0.25

/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------*/
function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0

	if ( !bIron && fIronTime < CurTime() - IRONSIGHT_TIME ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then
	
		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )
		
		if (!bIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.IronSightsPos
	
	if ( self.IronSightsAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
	
end

function SWEP:SetIronsights( b )
	self.Weapon:SetNetworkedBool( "Ironsights", b )
end

SWEP.NextSecondaryAttack = 0
function SWEP:SecondaryAttack()
	if ( self.NextSecondaryAttack > CurTime() ) then return end
	self:SetIronsights(!self.Weapon:GetNetworkedBool( "Ironsights", false ))
	
	self.NextSecondaryAttack = CurTime() + 0.3
end
