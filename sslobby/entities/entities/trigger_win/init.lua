ENT.Base = "base_brush"
ENT.Type = "brush"

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self.count = 0
	self.players = {}
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:KeyValue(key, value)
	self[key] = tonumber(value)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:StartTouch(entity)
	if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer()) then
		SS.Lobby.Minigame.Call("Finish", nil, entity)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:EndTouch(entity)
end