AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetNotSolid(true)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:KeyValue(key, value)
	if (key == "width") then
		self:SetWidth(value)
	end
	
	if (key == "height") then
		self:SetHeight(value)
	end
	
	-- advert id
	if (key == "location") then
	end
end