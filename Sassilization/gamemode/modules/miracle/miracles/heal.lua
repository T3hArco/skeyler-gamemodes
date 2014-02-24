miracle.unique = "heal"

miracle.cost = 2
miracle.delay = 12
miracle.sound = Sound("sassilization/spells/healcast.wav")

if (SERVER) then
	function miracle:Execute(player, empire, hitPos, shrine, level)
		local effect= EffectData()
			effect:SetStart(hitPos)
			effect:SetScale(50)
			effect:SetMagnitude(0.15)
		util.Effect("cast_heal", effect)
		
		local entities = ents.FindInSphere(hitPos, 40 *level /3)

		for k, entity in pairs(entities) do
			if (entity:IsUnit() and (entity.Unit:GetEmpire() == empire or Allied(empire, entity.Unit:GetEmpire()))) then -- or if ally
				entity.Unit.Paralyzed = false
				entity.Unit.Gravitated = false
				entity.Unit.Blasted = false
				entity.Unit.Decimated = false
				entity.Unit.OnFire = false
				
				entity.Unit:SetHealth(entity.Unit:GetMaxHealth())
				
				local effect = EffectData()
					effect:SetScale(entity:GetUnit():UnitIndex())
					effect:SetMagnitude(1)
				util.Effect("heal", effect, 1, 1)
			end
		end
	end
end