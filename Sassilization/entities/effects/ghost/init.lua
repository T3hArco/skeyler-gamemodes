----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

function EFFECT:Init()
	if(GAMEMODE.Ghost) then
		GAMEMODE.Ghost.Ent = self
	else return end
	
	self:SetModel( GAMEMODE.Ghost.OriginalModel );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetColor( Color( 255, 255, 255, 150 ) );
end

function EFFECT:Think()
	return GAMEMODE.Ghost.Ent == self
end

function EFFECT:Render()
	self:DrawModel()
end