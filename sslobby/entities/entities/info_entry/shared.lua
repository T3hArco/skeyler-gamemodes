----------
-- Lobby
----------

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:GetFlag()
	return self:GetNWString( "perm" )
end
