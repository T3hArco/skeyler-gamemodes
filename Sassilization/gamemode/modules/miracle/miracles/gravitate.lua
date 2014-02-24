miracle.unique = "gravitate"

miracle.cost = 3
miracle.delay = 8
miracle.sound = Sound("sassilization/spells/gravitatecast.wav")

if (SERVER) then
	miracle.gravitations = {}
	
	function miracle:Execute(player, empire, hitPos, shrine, level)
		local gravitations = miracles.Get("gravitate").gravitations
		local effect = EffectData()
			effect:SetEntity(shrine)
			effect:SetStart(hitPos)
			effect:SetScale(24)
			effect:SetMagnitude(2)
		util.Effect("cast_gravitate", effect)
		
		table.insert(gravitations, 1, hitPos)
		
		timer.Simple(2 +2 *level /3, function() table.remove(gravitations, 1) end)
		
		local entities = ents.FindInSphere(hitPos +Vector(0, 0, 24), 64)

		for k, entity in pairs(entities) do
			if (entity:IsUnit() and entity:GetClass() != "scallywag" and entity.Unit:GetEmpire() != empire and !Allied(empire, entity.Unit:GetEmpire())) then -- check ally
				entity.Unit.Gravitated = true
				
				if (entity.trail) then  
					entity.trail:Remove()
					entity.trail = nil
				end
				
				entity.trail = util.SpriteTrail(entity, 0, Color(145, 44, 238, 80), false, 8, 0.01, 0.5, 0.5, "trails/laser.vmt") 
				
				local physObject = entity:GetPhysicsObject()
				
				if (IsValid(physObject)) then
					physObject:EnableMotion(true)
					physObject:Wake()
				end

				local physObject = entity:GetPhysicsObject()
				entity.Unit.Hull:SetMoving( false )
				entity.Unit.Hull:GetPhysicsObject():Sleep()
				entity.Unit:GetCommandQueue():Pop()
				entity.Unit:SetCommand( nil )

				timer.Create(tostring(entity.Unit), 0.1, 10, function()
					if entity.Unit then
						if entity.Unit.Gravitated then
							local physObject = entity:GetPhysicsObject()
							if entity.Unit:GetClass() == "catapult" or entity.Unit:GetClass() == "ballista" then
								upPush = 185
							else
								upPush = 150
							end
							physObject:SetVelocity(Vector(math.random(-10, 10), math.random(-10,10), upPush))
						else
							if (entity.trail) then  
								entity.trail:Remove()
								entity.trail = nil
							end
						end
					end
				end)

				timer.Simple(1, function()
					if (entity.trail) then  
						entity.trail:Remove()
						entity.trail = nil
					end  
					if (IsValid(entity)) then
						entity.Unit.Gravitated = false
					end
				end)
			end
		end
	end
end