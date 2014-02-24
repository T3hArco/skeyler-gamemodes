miracle.unique = "blast"

miracle.cost = 2
miracle.delay = 3
miracle.sound = Sound("sassilization/spells/blastcast.wav")

if (SERVER) then
	function miracle:Execute(player, empire, hitPos, shrine, level)
		local gravitations = miracles.Get("gravitate").gravitations
		
		local effect = EffectData()
			effect:SetStart(hitPos)
			effect:SetOrigin(hitPos)
			effect:SetScale(1)
		util.Effect("Explosion", effect)
		
		table.insert(gravitations, 1, hitPos)
		
		timer.Simple(1, function() table.remove(gravitations, 1) end)
		
		local entities = ents.FindInSphere(hitPos +Vector(0, 0, 24), 64)

		for k, entity in pairs(entities) do
			if (entity:IsUnit() and entity.Paralyzed != 1 and entity.Gravitated != 1 and entity.Unit:GetEmpire() != empire and !Allied(empire, entity.Unit:GetEmpire())) then -- check ally
				local direction = (entity:GetPos() -hitPos)
				direction:Normalize()
				
				local power = (64 -entity:GetPos():Distance(hitPos)) /64
				
				entity.Unit.Blasted = direction
				
				local physObject = entity:GetPhysicsObject()
				
				if (IsValid(physObject)) then
					physObject:EnableMotion(true)
					physObject:Wake()
				end

				timer.Simple(0.1, function()
					if (IsValid(entity)) then
						local physObject = entity:GetPhysicsObject()
						entity.Unit.Hull:SetMoving( false )
						entity.Unit.Hull:GetPhysicsObject():Sleep()
						entity.Unit:GetCommandQueue():Pop()
						entity.Unit:SetCommand( nil )
						
						if (IsValid(physObject)) then
							physObject:EnableMotion(true)
							physObject:Wake()
							physObject:SetVelocity(direction *150 *power +Vector(0, 0, 20))
						end
					end
				end)

				timer.Simple(1, function()
					if (IsValid(entity)) then
						entity.Unit.Blasted = false
					end
				end)
			end
		end
	end
end