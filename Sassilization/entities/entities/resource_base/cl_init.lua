--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	self:DrawModel()
end
