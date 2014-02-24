----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local arrowspeed = 200
function UNIT:DoAttack( enemy, dmginfo )
	
	dmginfo.dmgtype = DMG_BULLET
	
	local arrowTime = enemy:LocalToWorld(dmginfo.dmgpos):Distance( self:GetPos() ) / arrowspeed
	
	local ed = EffectData()
		ed:SetOrigin( self:GetPos() + VECTOR_UP * 1.8 )
		ed:SetScale( CurTime() + arrowTime )
		ed:SetEntity( enemy.NWEnt and enemy.NWEnt or enemy )
		ed:SetStart( dmginfo.dmgpos )
	util.Effect( "ballista_arrow", ed, true, true )
	
	box = ents.FindInBox( self:GetPos() + VECTOR_UP * 1.8 - (self.NWEnt:GetRight() * 1.5), enemy:GetPos()  + ((enemy:GetPos() - self:GetPos()):GetNormal() * 4) + (self.NWEnt:GetRight() * 1.5) )
	
	timer.Simple( arrowTime, function()
		for k,v in pairs(box) do
			if IsValid(v) and v.Unit then
				if v.Unit:GetEmpire() != self:GetEmpire() then
					v.Unit:Damage( dmginfo )
				end
			elseif IsValid(v) and v.Building then
				if v:GetEmpire() != self:GetEmpire() then
					dmginfo.damage = 5
					v:Damage( dmginfo )
				end
			end
		end
	end )

end

function UNIT:Think()
	
	self.BaseClass.Think( self )
	
end