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

	timer.Simple(0.1, function()
		if (IsValid(self)) then
			local trigger, distance, triggers = false, false, SS.Lobby.Link:GetTriggers()

			for k, entity in pairs(triggers) do
				local triggerDistance = self:GetPos():Distance(entity:LocalToWorld(entity:OBBCenter()))
				
				if (distance == false or triggerDistance <= distance) then
					trigger, distance = entity, triggerDistance
				end
			end
		
			if (trigger and trigger.id) then
				self:SetTriggerID(trigger.id)
			end
		end
	end)
	
	self:SetStatus(STATUS_LINK_READY)
	
	--self:SetStatus(STATUS_LINK_UNAVAILABLE)
end

------------------------------------------------
--
------------------------------------------------

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
