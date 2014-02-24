--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
include("shared.lua")

util.PrecacheSound("sassilization/templeComplete.wav")

function ENT:Initialize()
	self:SetLevel(1)
	self:Setup("shrine")
	self.nextready = CurTime() + 10000
end

function ENT:OnBuilt( Empire )
	
	self:EmitSound( "sassilization/templeComplete.wav" )
	
	self.nextready = CurTime()
	
end

function ENT:OnControl( Empire )

	Empire:IncrShrine()

end

function ENT:OnRemoveControl( Empire )

	Empire:DecrShrine()

end

function ENT:IsReady()
	return self.nextready <= CurTime()
end

function ENT:SetNextReady( time )
	self.nextready = time
end

function ENT:OnDestroy(Info, Empire, Atacker)
end

function ENT:SacrificeUnit( Unit )

	if self:IsBuilt() then

		Unit:Kill(UNIT_SHRINED, self:GetEmpire())
		
		self:GetEmpire():AddCreed( Unit:GetCreedValue() )
		
		local Effect = EffectData()
			Effect:SetEntity(self)
			Effect:SetOrigin(self:GetPos() + Vector(math.Rand(-0.2, 0.2), math.Rand(-0.2, 0.2), 5))
		util.Effect("spirit", Effect, true, true)

	end

end