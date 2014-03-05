ENT.Type = "anim"
ENT.Base = "base_anim"

--------------------------------------------------
--
--------------------------------------------------

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Rank")
end

--------------------------------------------------
--
--------------------------------------------------

function ENT:PlayerHasAccess(player)
	local rank = self:GetRank()

	if (rank) then return player:GetRank() >= rank end
	
	return false
end