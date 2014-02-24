----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

include("shared.lua")

function ENT:RenderOverride()
	self:DrawBuilding()
	
	-- run the sequence here
	
	self.Model:FrameAdvance(FrameTime())
end