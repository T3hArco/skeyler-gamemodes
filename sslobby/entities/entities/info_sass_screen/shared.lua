ENT.Type = "anim"
ENT.Base = "base_anim"

------------------------------------------------
--
------------------------------------------------

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "TriggerID")
	self:NetworkVar("Int", 1, "Status")
end