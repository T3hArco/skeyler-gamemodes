----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	
	self:SetModel("models/Roller.mdl")
	
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self.Phys = self:GetPhysicsObject()
	if(self.Phys:IsValid()) then
		ErrorNoHalt( "Test" )
		self.Phys:EnableMotion(true)
		self.Phys:EnableCollisions(false)
		self.Phys:SetMaterial("ice") -- "gmod_silent"
	end	
	self:DrawShadow(false)
	
end

function ENT:SetUnit( Unit )
	
	self.unit = Unit
	self.unitHull = Unit.Hull
	self.dt.UnitID = Unit:UnitIndex()
	
end

function ENT:Think()
	
	if( IsValid( self.unitHull ) and Unit:ValidUnit( self.unit ) ) then
		if( self.unitHull:GetPos():Distance(self:GetPos()) > 0.1 ) then
			self:SetPos( self.unitHull:GetPos() )
		end
		if( self.unitHull:GetVelocity():Distance(self:GetVelocity()) > 0.1 ) then
			self:SetVelocity( self.unitHull:GetVelocity() )
		end
		self.dt.Dir = math.deg( math.atan2( self.unit:GetDir().y, self.unit:GetDir().x ) )
	end
	
	self:NextThink( CurTime() + 0.1 )
	
	return true
	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:OnRemove()
end
