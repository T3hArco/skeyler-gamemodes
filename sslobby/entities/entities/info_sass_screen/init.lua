AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

------------------------------------------------
--
------------------------------------------------

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetNotSolid(true)

	self:SetTriggerID(self.id)
	self:SetStatus(STATUS_LINK_UNAVAILABLE)
end

------------------------------------------------
--
------------------------------------------------

function ENT:KeyValue(key, value)
	if (key == "location") then
		self.id = tonumber(value)
		
		SS.Lobby.Link:AddServerTrigger(self.id)
	end
end

------------------------------------------------
--
------------------------------------------------

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end