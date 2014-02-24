----------
-- Lobby
----------

include("shared.lua")

function ENT:HasPermission()
	return LocalPlayer():Team() > TEAM_READY
end
