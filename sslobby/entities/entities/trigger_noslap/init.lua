----------
-- Lobby
----------

ENT.Type = "brush"
ENT.Base = "base_brush"

function ENT:StartTouch(Ent)
	if(Ent:IsPlayer()) then
		Ent.NoSlap = true
	end
end

function ENT:EndTouch(Ent)
	if(Ent:IsPlayer()) then
		Ent.NoSlap = false
	end
end
