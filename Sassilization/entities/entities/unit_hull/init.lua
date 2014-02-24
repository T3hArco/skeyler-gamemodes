----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

-- AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Unit = true
ENT.Attackable = true

function ENT:Initialize()
	self:SetModel("models/roller.mdl")
	
	local Size = self.Size * 0.5
	local Mins = Vector( -Size, -Size, -Size )
	local Maxs = Vector( Size, Size, Size )
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInitSphere( Size )
	self:SetCollisionBounds( Mins, Maxs )
	
	self:DrawShadow(false)
	self:SetNoDraw(true) -- The rollermine model is visible when doing gravitate :: FIX? // Chewgum
	
	self.SpeedSqr = self.Speed ^ 2
	self.SizeSqr = self.Size * self.Size
	
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	self.Phys = self:GetPhysicsObject()
	
	if (IsValid(self.Phys)) then
		self.Phys:EnableDrag(true)
		self.Phys:EnableMotion(true)
		self.Phys:EnableCollisions(true)
		self.Phys:EnableGravity(true)
		self.Phys:SetDamping( 0, 90 )
		self.Phys:SetDragCoefficient( 10 )
		self.Phys:SetMaterial("ice") -- gmod_silent
		--self.Phys:SetInertia( Vector(100,100,100) )
		self.Phys:SetMass( 50 )
		self.Phys:SetBuoyancyRatio( 0.025 )
		--self.Phys:Wake()
	end
	
	self:SetMoving( false )
end

function ENT:GetEmpire()
	if (Unit:ValidUnit(self.Unit)) then
		return self.Unit:GetEmpire()
	end
end

function ENT:PhysicsCollide( data, physobj )
	if (IsValid(data.HitEntity) and data.HitEntity.GetEmpire and data.HitEntity:GetEmpire() == self:GetEmpire()) then return end
	
	if (data.Speed > 100 && data.DeltaTime > 0.2 ) then
		self.nextFallDamage = self.nextFallDamage or CurTime()
		
		if( CurTime() < self.nextFallDamage ) then return end
		
		self.nextFallDamage = CurTime() + 0.1
		self:EmitSound( "Rubber.BulletImpact" )
		
		if( Unit:ValidUnit( self.Unit ) ) then
			local dmginfo = {}
			dmginfo.damage = data.Speed * 0.025
			dmginfo.dmgtype = DMG_FALL
			self.Unit:Damage( dmginfo )
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end

function ENT:PerformMiracle(ID)
	MsgN("PerformMiracle", ID)
end

function ENT:Select( Empire, Bool )
	
	if(self.Killed) then
		return
	end
	
	Empire:SelectUnit( self, Bool )
	
end

function ENT:Think()
	if( not Unit:ValidUnit( self.Unit ) ) then return end

	local phys = self:GetPhysicsObject()
	if( phys:IsValid() ) then
		self.Unit:HullPhysicsSimulate( self, phys )
	else
		return
	end
	
	self.Unit.v_Pos = self:GetPos()
	self.Unit:SetVelocity( self:GetVelocity() )
	
	-- self.Unit:Think()
	
	if( self:WaterLevel() > 2 ) then
		
		local dmginfo = {}
			dmginfo.damage = 1
			dmginfo.type = DMG_DROWN
		self.Unit:Damage( dmginfo )
		
	end
	
	self:NextThink(CurTime() + 0.1)
	
	return true
	
end

--[[
hook.Add( "ShouldCollide", "unit_hull.ShouldCollide", function( ent1, ent2 )
	
	if( not ent1 or not ent2 ) then return end
	
	if( Unit:ValidUnit( ent1.Unit ) and Unit:ValidUnit( ent2.Unit ) ) then
		
		return false
		
	end
	
end )
]]

function ENT:StartTouch(Ent)
	--MsgN("StartTouch", Ent)
end

function ENT:Touch(Ent)
	--MsgN("Touch", Ent)
end

function ENT:EndTouch(Ent)
	--MsgN("EndTouch", Ent)
end

function ENT:OnTakeDamage(DmgInfo)
end

function ENT:OnRemove()
end
