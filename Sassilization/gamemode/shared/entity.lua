--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

function GM.EntityMeta:GetType()
	if( not IsValid( self ) ) then return end
	if(self.CachedType) then
		return self.CachedType
	end
	if(self:IsBuilding()) then
		return building.CalcBuildingType(self)
	end
	return unit.CalcUnitType(self)
end

function GM.EntityMeta:IsUnit()
	if( not IsValid( self ) ) then return end
	return tobool( self.Unit )
end

function GM.EntityMeta:IsShrine()
	if( not IsValid( self ) ) then return end
	return self:GetClass() == "building_shrine"
end

function GM.EntityMeta:IsBuilding()
	if( not IsValid( self ) ) then return end
	return string.sub(self:GetClass(), 1, 9) == "building_"
end

function GM.EntityMeta:IsWall()
	if( not IsValid( self ) ) then return end
	return self:GetClass() == "building_wall"
end

function GM.EntityMeta:IsWallTower()
	if( not IsValid( self ) ) then return end
	return self:GetClass() == "building_walltower"
end

function GM.EntityMeta:IsGate()
	if( not IsValid( self ) ) then return end
	return string.find(self:GetClass(), "gate") ~= nil
end

function GM.EntityMeta:IsResource()
	if( not IsValid( self ) ) then return end
	return self.Base == "resource_base"
end