----------------------------------------
--	Sassilization
--  Shared Unit Module
--	http://sassilization.com
--	By Spacetech & Sassafrass
----------------------------------------

local CMD = {}

CMD.move = true

function CMD:Init( TargetShrine )
	
	self.shrine = TargetShrine
	
end

function CMD:Start( Unit )
	
	assert( IsValid( Unit.Hull ) )
	
	if Unit.Gravitated or Unit.Paralyzed then 
		Unit.Hull:SetMoving( false )
		Unit.Hull:GetPhysicsObject():Sleep()
		Unit:GetCommandQueue():Pop()
		Unit:SetCommand( nil )
	elseif !Unit.Blasted then
		Unit.Hull:PhysWake()
		Unit.Hull:SetMoving( true )
	end
	
	Msg( "Started ", tostring( self ), "\n" )
	self.pos = self.shrine:GetPos()
	
end

function CMD:Finish( Unit )
	
	Msg( "Finished ", tostring( self ), "\n" )
	Unit.Hull:SetMoving( false )
	Unit.Hull:GetPhysicsObject():Sleep()
	Unit:GetCommandQueue():Pop()
	Unit:SetCommand( nil )
	
end

function CMD:Think( Unit )
	
	if( not self.shrine:IsShrine() ) then
		self:Finish( Unit )
		return
	end
	
	if( (Unit:GetPos() - self.pos):LengthSqr() < 240 ) then
		
		self:Finish( Unit )
		self.shrine:SacrificeUnit( Unit )
		
	end
	
end

function CMD:CountUnitsAtDestination()
	
	self.nextUnitAtDestCount = self.nextUnitAtDestCount or CurTime()
	if( CurTime() < self.nextUnitAtDestCount ) then
		return self.unitsAtDestination or 0 
	end
	
	self.nextUnitAtDestCount = CurTime() + 0.5
	
	self.unitsAtDestination = unit.NumUnitsInSphere( self.pos, 12 )
	return self.unitsAtDestination
	
end

function CMD.__tostring( self )
	return "CommandSacrifice"
end

SA.RegisterCommand( COMMAND.SACRIFICE, CMD )