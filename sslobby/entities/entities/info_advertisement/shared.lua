----------
-- Lobby
----------

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Width")
	self:NetworkVar("Int", 1, "Height")
end