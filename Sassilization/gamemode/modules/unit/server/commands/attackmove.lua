----------------------------------------
--	Sassilization
--  Shared Unit Module
--	http://sassilization.com
--	By Spacetech & Sassafrass
----------------------------------------

local CMD = {}

CMD.attack = true
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
	end
	
	Unit:Think()

end

function CMD:Think( Unit )
	if( Unit:CanAttack() ) then
		Unit:UpdateView()
		Unit.Enemy = Unit:UpdateEnemy()
	end
	
	if( self.target == Unit.Enemy and Unit.Enemy ) then
		if(IsValid(Unit.Enemy) and self.target:GetHealth() > 0) then
			Unit:Attack( Unit.Enemy )
			--self.pos = nil
		else
			self:Finish( Unit )
			Unit.Enemy = Unit:UpdateEnemy()
		end
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
	return "Move and Attack"
end

SA.RegisterCommand( COMMAND.ATTACKMOVE, CMD )