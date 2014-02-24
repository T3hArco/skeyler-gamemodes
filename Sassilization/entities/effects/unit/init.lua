----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

function EFFECT:Init()
	
	if(UNITDATA) then
		self.Unit = SA.UNITDATA
		self.Unit.Entity = self
	else return end
	
	self:SetModel( self.Unit.Model )
	
end

function EFFECT:Think()
	
	return self.Unit
	
end

function EFFECT:Render()
	
	self:DrawModel()
	
end