----------
-- Lobby
----------

ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:KeyValue(key, value)
	--if(key == "id" or key == "hammerid") then
	--	self.ID = tonumber(value)
	--	Connector:RegisterServer(self.ID + 4, self)
	--end
end

function ENT:StartTouch(Ent)
	if(Ent:IsPlayer() and self.ID) then
		Connector:AddPlayer(self.ID, Ent)
	end
end

function ENT:EndTouch(Ent)
	if(Ent:IsPlayer() and self.ID) then
		Connector:RemovePlayer(self.ID, Ent)
	end
end
