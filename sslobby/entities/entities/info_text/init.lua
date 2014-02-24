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
end

------------------------------------------------
--
------------------------------------------------

function ENT:KeyValue(key, value)
	if (key == "textsize")then
		self:SetTextSize(value)
	elseif (key == "text")then
		self:SetText(string.upper(value))
	end
end