----------
-- Lobby
----------

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:KeyValue(key, value)
	self[key] = tonumber(value)
	
	if (key == "width") then
		self:SetWidth(value)
	end
	
	if (key == "height") then
		self:SetHeight(value)
	end
	
	print(key)
end

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetNotSolid(true)
end
