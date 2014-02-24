--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

util.AddNetworkString("sa_shmngtct")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.neighbors = {}
	
	self:Setup("shieldmono")
	self:Materialize()
	self:SetRecharge(CurTime())
end

function ENT:OnBuilt(Empire)
	Empire:IncrShields()
end

function ENT:OnDestroy(Info, Empire, Attacker)
	if (Empire) then
		Empire:DecrShields()
	end
end

function ENT:Protect(position)
	self:SetRecharge(CurTime())
	
	self:EmitSound("sassilization/spells/blockmiracle.wav")
	
	local effect = EffectData()
		effect:SetOrigin(self:GetPos() +Vector(0, 0, self:OBBMaxs().z))
		effect:SetStart(position)
	util.Effect("shield", effect, true, true)
end