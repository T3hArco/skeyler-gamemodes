--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

include("shared.lua")

local mins = Vector(-10, -10, -10)
local maxs = Vector(10, 10, 10)

function ENT:Initialize()
	
	self:SetRenderBounds( mins, maxs )
	
end

function ENT:Draw()
	
	if( Unit:ValidUnit( self.unit ) ) then
		self.unit.b_ShouldDraw = true
	end
	
end

function ENT:GetRandomPosInOBB()
	if( Unit:ValidUnit( self.unit ) ) then
		local size = self.unit.Size*0.5
		return Vector( math.Rand( -size, size ), math.Rand( -size, size ), math.Rand( 0, size*2 ) )
	else
		return Vector(0)
	end
end

function ENT:GetUnit()
	return self.unit
end

function ENT:Think()
	
	self:NextThink( CurTime() )
	
	if( not self.unit ) then
		local u = Unit:Unit( self.dt.UnitID )
		if( Unit:ValidUnit( u ) ) then
			self.unit = u
			self.unit:SetYaw( self.dt.Dir )
			self.unit:SetHullPos( self:GetPos() )
			self.unit:SetVelocity( self:GetVelocity() )
			self.unit:SetNetworked()
			self.unit:OnHull()
		end
	elseif( Unit:ValidUnit( self.unit ) ) then
		self.unit:SetYaw( self.dt.Dir )
		self.unit:SetHullPos( self:GetPos() )
		self.unit:SetVelocity( self:GetVelocity() )
		self.unit:SetNetworked()
	end
	
	return true
	
end