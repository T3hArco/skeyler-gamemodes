----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

function UNIT:DoAttack( enemy, dmginfo )
	
	timer.Simple(0.2, function()
		local rock = ents.Create("projectile_rock")
		rock:SetEmpire(self:GetEmpire())
		rock:SetPos(self:GetPos() + (self:GetUp() * 20) + (self:GetForward() * 20))
		rock.LaunchDir = ((enemy:GetPos() - self:GetPos()):GetNormal() + (self:GetUp() * 1))
		rock.power = self:GetPos():Distance(enemy:GetPos()) * 1.191
		rock.damage = dmginfo
		rock:Spawn() 
	end)
	
end

function UNIT:Think()
	
	self.BaseClass.Think( self )
	
end