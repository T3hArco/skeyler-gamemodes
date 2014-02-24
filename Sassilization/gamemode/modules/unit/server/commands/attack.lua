----------------------------------------
--	Sassilization
--  Shared Unit Module
--	http://sassilization.com
--	By Spacetech & Sassafrass
----------------------------------------

local CMD = {}

function CMD:Init( Target )
	
	self.target = Target
	
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
	end

	Unit.Enemy = self.target

	self:Pursue(Unit)
	
end

function CMD:Think( Unit )
	if( not IsValid( self.target ) or self.target:GetHealth() <= 0 ) then
		self:Finish( Unit )
		return
	end

	Unit.Enemy = self.target
	if( self.target == Unit.Enemy and Unit.Enemy ) then
		if(IsValid(Unit.Enemy)) then
			if (Unit:IsTargetInRange(self.target)) then
				Unit:Attack( Unit.Enemy )
			else
				self:Pursue(Unit)
			end
		else
			self:Finish( Unit )
		end
	end
end

function CMD:Finish( Unit )

	Unit.Enemy = nil
	Unit.Hull:SetMoving( false )
	Unit.Hull:GetPhysicsObject():Sleep()
	Unit:GetCommandQueue():Pop()
	Unit:SetCommand( nil )
	
end

function CMD:Pursue( Unit )
	if( not IsValid( self.target ) or self.target:GetHealth() <= 0 ) then
		self:Finish( Unit )
		return
	end
	
	local targetPos = self.target:NearestAttackPoint( Unit:GetPos() )
	
	-- We want to run the furthest position from the unit that would bring us into range (instead of just running to the unit)
	self.pos = targetPos +(Unit:GetPos() -targetPos):GetNormal() *math.min(Unit.Range *0.95, Unit:GetPos():Distance(targetPos))
	
	Unit.Hull:SetMoving( true )
end

function CMD.__tostring( self )
	return "CommandAttack"
end

SA.RegisterCommand( COMMAND.ATTACK, CMD )