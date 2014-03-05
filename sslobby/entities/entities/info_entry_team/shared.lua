ENT.Type = "anim"
ENT.Base = "info_entry"

--------------------------------------------------
--
--------------------------------------------------

function ENT:PlayerHasAccess(player)
	return player:Team() > TEAM_READY
end