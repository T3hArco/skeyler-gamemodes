miracle.unique = "decimate"

miracle.cost = 5
miracle.delay = 8
miracle.sound = Sound("sassilization/spells/decimationcast.wav")

if (SERVER) then
	function miracle:Execute(player, empire, hitPos, shrine, level)
		local effect = EffectData()
			effect:SetStart(hitPos)
			effect:SetScale(80 +20 *level /3)
			effect:SetMagnitude(0.15)
		util.Effect("cast_decimate", effect)
		
		local entities = ents.FindInSphere(hitPos, 20 +8 *level /3)

		for k, entity in pairs(entities) do
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