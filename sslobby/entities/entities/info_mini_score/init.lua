AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetNotSolid(true)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:KeyValue(key, value)
	if (key == "selector") then
		self:SetSelector(tonumber(value))
	end
end