miracle.unique = "paralyze"

miracle.cost = 3
miracle.delay = 8
miracle.id = 21
miracle.sound = Sound("sassilization/spells/paralysiscast.wav")

if (SERVER) then
	function miracle:Execute(player, empire, hitPos, shrine, level)
		local effect = EffectData()
			effect:SetStart(hitPos)
			effect:SetScale(40 +20 *level /3)
			effect:SetMagnitude(0.15)
		util.Effect("cast_paralyze", effect)
		
		local entities = ents.FindInSphere(hitPos, 20 +20 *level /3)

		local entities2 = ents.FindInSphere(hitPos + Vector(0,0,50), 20 +20 *level /3)

		for k, entity in pairs(entities) do
			if (entity:IsUnit() and entity.Unit:GetEmpire() != empire and !Allied(empire, entity.Unit:GetEmpire())) then -- check ally
				entity.Unit.Paralyzed = true
				entity:SetNWBool( "paralyzed", true )
				entity:SetAnimation("idle")

				local physObject = entity:GetPhysicsObject()
						entity.Unit.Hull:SetMoving( false )
						entity.Unit.Hull:GetPhysicsObject():Sleep()
						entity.Unit:GetCommandQueue():Pop()
						entity.Unit:SetCommand( nil )
				
				local effect = EffectData()
					effect:SetScale(entity:GetUnit():UnitIndex())
					effect:SetMagnitude( 3 +3 *level /3)
				util.Effect("paralyze", effect, 1, 1)
				
				timer.Simple(3 +3 *level /3, function()
					if (IsValid(entity)) then
						entity.Unit.Paralyzed = false
					end
				end)
			end
		end

		for k, entity in pairs(entities2) do
			if (entity:IsUnit() and entity.Unit:GetEmpire() != empire and !Allied(empire, entity.Unit:GetEmpire())) then -- check ally
				entity.Unit.Paralyzed = true
				entity:SetNWBool( "paralyzed", true )
				entity:SetAnimation("idle")

				local physObject = entity:GetPhysicsObject()
						entity.Unit.Hull:SetMoving( false )
						entity.Unit.Hull:GetPhysicsObject():Sleep()
						entity.Unit:GetCommandQueue():Pop()
						entity.Unit:SetCommand( nil )
				
				local effect = EffectData()
					effect:SetScale(entity:GetUnit():UnitIndex())
					effect:SetMagnitude( 3 +3 *level /3)
				util.Effect("paralyze", effect, 1, 1)
				
				timer.Simple(3 +3 *level /3, function()
					if (IsValid(entity)) then
						entity.Unit.Paralyzed = false
					end
				end)
			end
		end
	end
end