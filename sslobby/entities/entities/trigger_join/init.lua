ENT.Base = "base_brush"
ENT.Type = "brush"

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:KeyValue(key, value)
	--self[key] = tonumber(value)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:StartTouch(entity)
	if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
		SS.Lobby.Minigame:AddPlayer(entity)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:EndTouch(entity)
	if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
		SS.Lobby.Minigame:RemovePlayer(entity)
	end
end