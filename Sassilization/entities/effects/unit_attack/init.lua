function EFFECT:Init( data )

	local attackPos = data:GetOrigin()
	local attackingUnitNWEnt = data:GetEntity()
	local attackingUnit = attackingUnitNWEnt.unit
	
	if( not IsValid( attackingUnitNWEnt ) ) then return end
	if( not Unit:ValidUnit( attackingUnit ) ) then return end
	
	attackingUnit:Attack( math.atan2( ( attackPos.y - attackingUnit:GetPos().y ), ( attackPos.x - attackingUnit:GetPos().x ) ) )
	
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end