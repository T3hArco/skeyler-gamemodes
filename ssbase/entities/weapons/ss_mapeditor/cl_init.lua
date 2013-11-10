
include('shared.lua')


SWEP.PrintName			= "Skeyler MapEditor"		-- 'Nice' Weapon name (Shown on HUD)	
SWEP.Slot				= 0	
SWEP.SlotPos			= 0	
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/gmod_tool" ) 

SWEP.First = false 

function SWEP:PrimaryAttack() 
	if self.NextRun and self.NextRun >= CurTime() then return end 
	self.NextRun = CurTime()+0.1 

	self.Owner:ChatPrint("ATTACK") 
	
	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end

	self:ShootEffects(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted()) 

	if self.First != false then 
		self.Owner:ChatPrint("Min = Vector("..math.min(self.First.x, trace.HitPos.x)..", "..math.min(self.First.y, trace.HitPos.y)..", "..math.min(self.First.z, trace.HitPos.z)..")")
		self.Owner:ChatPrint("Max = Vector("..math.max(self.First.x, trace.HitPos.x)..", "..math.max(self.First.y, trace.HitPos.y)..", "..math.min(self.First.z, trace.HitPos.z)..")") 
		self.First = false  
	else 
		self.First = trace.HitPos 
	end 
end


--[[---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end

	self:ShootEffects(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted()) 
end

function SWEP:ShootEffects(hitpos, hitnormal, entity, physbone, bFirstTimePredicted)

	self.Weapon:EmitSound( self.ShootSound	)
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 	-- View model animation
	
	-- There's a bug with the model that's causing a muzzle to 
	-- appear on everyone's screen when we fire this animation. 
	self.Owner:SetAnimation( PLAYER_ATTACK1 )			-- 3rd Person Animation
	
	if ( !bFirstTimePredicted ) then return end
	
	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetNormal( hitnormal )
		effectdata:SetEntity( entity )
		effectdata:SetAttachment( physbone )
	util.Effect( "selection_indicator", effectdata )	
	
	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self.Weapon )
	util.Effect( "ToolTracer", effectdata )

end
