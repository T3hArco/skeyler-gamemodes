

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "Glock"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.IconLetter			= "c"
	
	killicon.AddFont( "weapon_glock", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_glock18.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_Glock.Single" )
SWEP.Primary.Recoil			= 1.8
SWEP.Primary.Damage			= 16
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.03
SWEP.Primary.ClipSize		= 16
SWEP.Primary.Delay			= 0.05
SWEP.Primary.DefaultClip	= 21
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector( 4.3, -2, 2.7 )

hook.Add("PlayerPostThink","POSTFRAMESHIT",function(ply)
	if(IsValid(ply:GetActiveWeapon()) && ply:GetActiveWeapon().glock) then
		ply:GetActiveWeapon():FireMOAR()
	end
end)

function SWEP:CSSGlockShoot( dmg, recoil, numbul, cone, anim )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			// Aim Cone
	bullet.Tracer	= 4									// Show a tracer on every x bullets 
	bullet.Force	= 5									// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	local owner = self.Owner --faster than getting info from damageinfo cause c++ calls
	local slf = self --faster than getting info from damageinfo cause c++ calls
	bullet.Callback = function(a,b,c)
		if(SERVER && b.HitPos) then
			local tracedata = {}
			tracedata.start = b.StartPos
			tracedata.endpos = b.HitPos + (b.Normal*2)
			tracedata.filter = a
			tracedata.mask = MASK_PLAYERSOLID
			local trace = util.TraceLine(tracedata)
				
			if(IsValid(trace.Entity) && trace.Entity:GetClass() == "func_button") then
				trace.Entity:TakeDamage(dmg,owner,slf)
				trace.Entity:TakeDamage(dmg,owner,slf)
					--[[if(game.GetMap() == "bhop_lost_world" && tonumber(trace.Entity:GetSaveTable().spawnflags) == 513 && trace.Entity:GetSaveTable().m_toggle_state == 1) then
						trace.Entity:TriggerOutput("OnPressed",owner)
						trace.Entity:SetSaveValue("m_toggle_state",0)
						timer.Simple(trace.Entity:GetSaveTable().m_flWait,function()
							if(trace.Entity && trace.Entity:IsValid()) then
								trace.Entity:SetSaveValue("m_toggle_state",1)
							end
						end)
					elseif((game.GetMap() != "bhop_infog_final" || !GAMEMODE:IsInArea(owner,Vector(5269, -1280, 141), Vector(5567, -1084, 341))) && trace.Entity:GetSaveTable().m_toggle_state == 1) then
						trace.Entity:TriggerOutput("OnDamaged",owner)
						trace.Entity:SetSaveValue("m_toggle_state",0)
						timer.Simple(trace.Entity:GetSaveTable().m_flWait,function()
							if(trace.Entity && trace.Entity:IsValid()) then
								trace.Entity:SetSaveValue("m_toggle_state",1)
							end
						end)
					end]]
			elseif(IsValid(trace.Entity) && trace.Entity:GetClass() == "func_breakable") then
				if(game.GetMap() == "kz_bhop_yonkoma" && trace.Entity.TriggerOutput) then
					trace.Entity:TriggerOutput("OnBreak",owner)
				end
			end
		end
	end
	self.Owner:FireBullets( bullet )
	if(anim) then
		if(self:GetDTInt(0) == 1) then
			self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) 		// View model animation
		else	
			self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
		end
	end
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (game.SinglePlayer() && SERVER) || ( !game.SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )
	
	end

end

function SWEP:Initialize()
	self.glock = true
end

function SWEP:FireMOAR()
	if(self.shootnext && self.NextShoot < CurTime() && self.shotsleft > 0) then
		self:GlockShoot(false)
	end
end

function SWEP:GlockShoot(showanim)
	if(self:GetDTInt(0) == 1) then
		self.shootnext = false
	end
	if ( !self:CanPrimaryAttack() ) then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )
	
	// Shoot the bullet
	self:CSSGlockShoot( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone, showanim )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
	if(self:GetDTInt(0) == 1 && self.shotsleft > 0 && !self.shootnext) then
		self.shootnext = true
		self.shotsleft = self.shotsleft - 1
	end
	self.NextShoot = CurTime() + 0.04
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	if(self:GetDTInt(0) == 1) then
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
		self.shotsleft = 3
		self.NextShoot = CurTime() + 0.04
	else
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	end
	
	self:GlockShoot(true)
end

function SWEP:SecondaryAttack()

	if (CLIENT || self.NextSecondaryAttack > CurTime() ) then return end
	
	if(self:GetDTInt(0) == 1) then
		self:SetDTInt(0,0)
		self.Owner:PrintMessage(HUD_PRINTCENTER,"Switched to semi-automatic.")
	else
		self:SetDTInt(0,1)
		self.Owner:PrintMessage(HUD_PRINTCENTER,"Switched to burst-fire.")
	end
	
	self.NextSecondaryAttack = CurTime() + 0.3
	
end
