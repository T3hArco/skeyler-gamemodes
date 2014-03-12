AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

AccessorFunc(ENT, "m_eIndicator", "Indicator")

------------------------------------------------
--
------------------------------------------------

function ENT:Initialize()
	self:DrawShadow(false)
	
	local id = self:GetID()
	local doors = ents.FindByClass("func_door")
	
	self.doors = {}
	
	for k, door in pairs(doors) do
		if (door.id == id) then
			table.insert(self.doors, door)
		end
	end
end

------------------------------------------------
--
------------------------------------------------

function ENT:KeyValue(key, value)
	if (key == "hammerid") then
		self:SetID(value)
	end
end

------------------------------------------------
--
------------------------------------------------

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

------------------------------------------------
--
------------------------------------------------

function ENT:OpenDoors()
	for i = 1, #self.doors do
		local door = self.doors[i]
		
		door:Fire("Unlock", nil, 0)
		door:Fire("Open", nil, 0)
		
		local indicator = self:GetIndicator()
		
		indicator:SetGreen()
	end
end

------------------------------------------------
--
------------------------------------------------

function ENT:CloseDoors()
	for i = 1, #self.doors do
		local door = self.doors[i]
		
		door:Fire("Close", nil, 0)
		
		local indicator = self:GetIndicator()

		indicator:SetRed()
	end
end