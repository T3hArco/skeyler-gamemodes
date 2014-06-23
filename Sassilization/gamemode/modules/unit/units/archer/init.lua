----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local arrowspeed = 60
function UNIT:DoAttack( enemy, dmginfo )
	
	dmginfo.dmgtype = DMG_BULLET
	
	local arrowTime = enemy:LocalToWorld(dmginfo.dmgpos):Distance( self:GetPos() ) / arrowspeed
	
	local ed = EffectData()
		ed:SetOrigin( self:GetPos() + VECTOR_UP * 1.8 )
		ed:SetScale( arrowTime )
		ed:SetEntity( enemy.NWEnt and enemy.NWEnt or enemy )
		ed:SetStart( dmginfo.dmgpos )
	util.Effect( "arrow", ed, true, true )
	
	timer.Simple( arrowTime, function()
		if( IsValid( enemy ) ) then
			enemy:Damage( dmginfo )
		end
	end )
	
end