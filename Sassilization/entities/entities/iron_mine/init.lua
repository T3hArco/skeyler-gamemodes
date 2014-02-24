--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:Setup("models/mrgiggles/sassilization/Ironmine.mdl")
end

function ENT:OnControl(Empire, Control)
	if(Control) then
		Empire:IncrMine()
		if( self.Shack ) then
			self.Shack:SetAngles(Angle(0, (self.Shack:GetPos() - self:GetPos()):Angle().y - 90, 0))
		end
	else
		Empire:DecrMine()
	end
end
