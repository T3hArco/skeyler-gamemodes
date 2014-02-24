--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:Setup("models/mrgiggles/sassilization/Farmpatch01.mdl")
end

function ENT:OnControl(Empire, Control)
	if(Control) then
		Empire:IncrFarm()
		self:SetModel("models/mrgiggles/sassilization/Farmpatch02.mdl")
	else
		Empire:DecrFarm()
		self:SetModel("models/mrgiggles/sassilization/Farmpatch01.mdl")
	end
end
