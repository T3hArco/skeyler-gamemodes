----------------------------------------
--	Sassilization
--  Shared Unit Module
--	http://sassilization.com
--	By Spacetech & Sassafrass
----------------------------------------

local CMD = {}

CMD.move = true

function CMD:Init( TargetPos )
	
	self.pos = TargetPos
	
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
		
		--if (Unit.Enemy) then
		--	Unit.Enemy = nil
			
		--	Unit:GetCommandQueue():Pop()
		--	Unit:SetCommand( nil )
		--end
	end
end

function CMD:Finish( Unit )
	
	Unit.Hull:SetMoving( false )
	Unit.Hull:GetPhysicsObject():Sleep()
	Unit:GetCommandQueue():Pop()
	Unit:SetCommand( nil )
	
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
	return "Move Units"
end

SA.RegisterCommand( COMMAND.MOVE, CMD )