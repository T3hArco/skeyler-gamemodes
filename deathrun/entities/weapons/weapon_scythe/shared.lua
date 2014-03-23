
if(SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if(CLIENT) then
	SWEP.PrintName			= "Scythe"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 3
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.DrawWeaponInfoBox 	= false
end

SWEP.Base = "weapon_base"

SWEP.ViewModel		= Model("models/weapons/v_sythe.mdl")
SWEP.WorldModel		= Model("models/weapons/w_sythe.mdl")
SWEP.ViewModelFlip	= false

SWEP.HoldType		= "melee"

SWEP.SoundSwing		= Sound("weapons/iceaxe/iceaxe_swing1.wav")

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Mins = Vector(-8, -8, -8)
SWEP.Maxs = Vector(8, 8, 8)

SWEP.SlashSound			= Sound("Weapon_Knife.Slash")
SWEP.HitSound			= Sound("Weapon_Knife.Hit")
SWEP.DeploySound		= Sound("Weapon_Knife.Deploy")
SWEP.HitSoundWall		= Sound("Weapon_Knife.HitWall")
SWEP.HitTable = {
	"prop_physics",
	"func_breakable"
}
	
function SWEP:Initialize()
	if(self.SetWeaponHoldType) then
		self:SetWeaponHoldType(self.HoldType)
	end
end

function SWEP:Precache()
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.4)
	
	local tr = util.TraceHull({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 75),
		mins = self.Mins,
		maxs = self.Maxs,
		filter = self.Owner
	})
	
	local EmitSound = self.SlashSound
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	
	-- local Decal = false
	
	if(tr.Hit) then
		if(IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or table.HasValue(self.HitTable, tr.Entity:GetClass()))) then
			-- Decal = "Blood"
			EmitSound = self.HitSound
			if(SERVER) then
				local dmginfo = DamageInfo()
				-- dmginfo:SetDamage(math.random(70, 85))
				dmginfo:SetDamage(40)
				dmginfo:SetDamageType(DMG_SLASH)
				dmginfo:SetInflictor(self.Owner)
				dmginfo:SetAttacker(self.Owner)
				tr.Entity:TakeDamageInfo(dmginfo)
			end
		else
			EmitSound = self.HitSoundWall
			-- if(tr.MatType == MAT_GLASS) then
				-- Decal = "Impact.Glass"
			-- else
				-- Decal = "Impact.Concrete"
			-- end
		end
	end
	
	if(IsFirstTimePredicted()) then
		if(EmitSound) then
			self.Weapon:EmitSound(EmitSound)
		end
		-- if(Decal) then
			-- print(tr.HitPos, tr.HitNormal)
			-- util.Decal(Decal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		-- end
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.1)
	
	if(CLIENT) then
		return
	end
	
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos  = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 75),
		filter = self.Owner
	})
	
	if(tr.Hit) then
		if(IsValid(tr.Entity)) then
			local HitEntity = tr.Entity
			if(HitEntity:IsButton()) then
				local Claimer = HitEntity:CheckClaimed()
				if(!Claimer) then
					self.Owner:ClaimButton(HitEntity)
				end
			end
		end
	end
end

function SWEP:Reload()
	return false
end

function SWEP:Deploy()
	self.Weapon:EmitSound(self.DeploySound)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:Holster()
	self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end
