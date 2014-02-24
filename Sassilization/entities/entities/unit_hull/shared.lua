--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.AutomaticFrameAdvance = false

AccessorFunc( ENT, "Unit", "Unit" )

-- function ENT:SetupDataTables()
-- end

function ENT:IsMoving()
	return self.Moving
end

function ENT:SetMoving(Moving)
	self.Moving = Moving
end