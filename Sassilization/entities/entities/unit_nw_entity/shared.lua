--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.AutomaticFrameAdvance = false

function ENT:SetupDataTables()
    self:DTVar( "Int", 0, "UnitID" )
    self:DTVar( "Float", 0, "Dir" )
end