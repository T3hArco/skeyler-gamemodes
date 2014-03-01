AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetAngles(self:GetAngles())
	self:SetUseType(SIMPLE_USE)
	
	self:DrawShadow(false)
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
		self.id = tonumber(value)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Use(player)
	player:ChatPrint("ADVERTISMENT ID:" .. tostring(self.id))
end