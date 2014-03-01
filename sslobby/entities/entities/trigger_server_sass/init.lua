ENT.Base = "base_brush"
ENT.Type = "brush"

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:KeyValue(key, value)
	--if(key == "id" or key == "hammerid") then

	if (key == "location") then
		self.id = tonumber(value)
		
		SS.Lobby.Link:AddServerTrigger(self.id)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:StartTouch(entity)
	--if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer() and self.id) then
	--	SS.Lobby.Link:AddPlayer(self.id, entity)
	--end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:EndTouch(entity)
	--if (IsValid(entity) and entity.IsPlayer and entity:IsPlayer() and self.id) then
		--SS.Lobby.Link:RemovePlayer(self.id, entity)
	--end
end
