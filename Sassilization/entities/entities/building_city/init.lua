--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self.Expansions = {}
	self.NextExpansion = false
	self:Setup("city")
end

function ENT:OnBuilt(Empire)

	if(Empire) then

		Empire:IncrCity()
		Empire:CalculateSupply()

	end

	self:UpdateControl()
	
	self.NextExpansion = CurTime() + math.random(10, 30)
	
	timer.Simple(math.random(60, 90), function() if( IsValid(self) ) then self:Expand(self:RandomYaw()) end end)
	timer.Simple(math.random(60, 90), function() if( IsValid(self) ) then self:Expand(self:RandomYaw()) end end)
	timer.Simple(math.random(60, 90), function() if( IsValid(self) ) then self:Expand(self:RandomYaw()) end end)
	timer.Simple(math.random(60, 90), function() if( IsValid(self) ) then self:Expand(self:RandomYaw()) end end)
	
end

function ENT:OnThink()

	if(self.NextExpansion and self.NextExpansion <= CurTime()) then
		self:Expand(self:RandomYaw())
		self.NextExpansion = CurTime() + math.random(30, 60)
	end

end

function ENT:OnControl( Empire )

	if( self:IsBuilt() ) then
		Empire:IncrCity()
		Empire:CalculateSupply()
	end

end

function ENT:OnRemoveControl(Empire)
	
	if( self:IsBuilt() ) then
		Empire:DecrCity()
		Empire:CalculateSupply()
	end
	
end

function ENT:OnDestroy(Info, Empire, Attacker)

	if(Info ~= building.BUILDING_SELL) then
		self:SpawnUnits("peasant", math.random(3, 5))
	end

	self:UpdateControl()

end