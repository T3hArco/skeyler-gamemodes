--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

ENT.Type = "anim"
ENT.Base = "projectile_base"

function ENT:SetEmpire(e)
	self.Empire = e
end

function ENT:GetEmpire()
	return self.Empire
end