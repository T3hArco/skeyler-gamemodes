ENT.Type = "brush"
ENT.Base = "base_brush"

------------------------------------------------
--
------------------------------------------------

function ENT:StartTouch(entity)
	if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
		entity.NoSlap = true
	end
end

------------------------------------------------
--
------------------------------------------------

function ENT:EndTouch(entity)
	if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
		entity.NoSlap = false
	end
end
