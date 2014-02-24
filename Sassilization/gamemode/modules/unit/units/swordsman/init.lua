----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local swingdelay = 0.3
function UNIT:DoAttack( enemy, dmginfo )
	
	timer.Simple( swingdelay, function()
		if( IsValid( enemy ) and IsValid( self ) and self:IsAlive() ) then
			enemy:Damage( dmginfo )
		end
	end )
	
end