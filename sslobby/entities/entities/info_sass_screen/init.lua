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

concommand.Add("ias",function()
	local tbl = {}
	
	for k,v in pairs(ents.FindByClass("info_sass_screen")) do
		local p,a=v:GetPos(),v:GetAngles()
		
		table.insert(tbl,{p,a})
		
		v:Remove()
	end
	
	for i = 1, 4 do
	local v = tbl[i]
	local n=ents.Create("info_sass_screen")
		n:SetPos(v[1])
		n:SetAngles(v[2])
		n:Spawn()
	end
end)