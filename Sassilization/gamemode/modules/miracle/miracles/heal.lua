miracle.unique = "heal"

miracle.cost = 2
miracle.delay = 12
miracle.id = 20
miracle.sound = Sound("sassilization/spells/healcast.wav")

if (SERVER) then
	function miracle:Execute(player, empire, hitPos, shrine, level)
		local effect= EffectData()
			effect:SetStart(hitPos)
			effect:SetScale(50)
			effect:SetMagnitude(0.15)
		util.Effect("cast_heal", effect)
		
		local entities = ents.FindInSphere(hitPos, 40 *level /3)

		local entities2 = ents.FindInSphere(hitPos + Vector(0,0,50), 40 *level /3)

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

		for k, entity in pairs(entities2) do
			if (entity:IsUnit() and entity.Unit:GetEmpire() != empire and !Allied(empire, entity.Unit:GetEmpire())) then -- check ally
				entity.Unit.Decimated = true
				
				timer.Simple(0.1, function()
					if (IsValid(entity)) then
						entity.Unit.OnFire = true
						entity.Unit:Burn(3 +level)
					end
				end)
				
				timer.Simple(3 +level, function()
					if (IsValid(entity)) then
						entity.Unit.Decimated = false
						entity.Unit.OnFire = false
					end
				end)
			end
		end
	end
end