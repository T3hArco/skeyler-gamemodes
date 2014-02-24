--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.HouseID = 1

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:Initialize()
	
	self.Expansions = {}
	self.NextExpansion = false
	
	self:Setup("house", "models/mrgiggles/sassilization/house0"..self.HouseID..".mdl", true)
	
	local Effect = EffectData()
	Effect:SetEntity(self)
	util.Effect("materialize", Effect, true, true)
	
	--GAMEMODE:AddHouse( self )
	
end

function ENT:OnControl(Empire)

	Empire:IncrHouse()
	Empire:CalculateSupply()

end

function ENT:OnRemoveControl(Empire)

	Empire:DecrHouse()
	Empire:CalculateSupply()
	
end

function ENT:InitHouse(Parent)
	self.CParent = Parent

	self:UpdateControl()
	
	local Dir = (self:GetPos() - Parent:GetPos()):GetNormal():Angle()
	
	timer.Simple(60, function() if( IsValid(self) ) then self:Expand( Dir + Angle(0, math.random(-90, 90), 0) )end end )
	timer.Simple(90, function() if( IsValid(self) ) then self:Expand( Dir + Angle(0, math.random(-90, 90), 0) )end end )
	timer.Simple(120, function() if( IsValid(self) ) then self:Expand( Dir + Angle(0, math.random(-90, 90), 0) )end end )
end

function ENT:OnDestroy(Info, Empire, Attacker)

	self:SpawnUnits("peasant", math.random(1, 3))

	GAMEMODE:RemoveHouse( self )
	self:UpdateControl()

end
