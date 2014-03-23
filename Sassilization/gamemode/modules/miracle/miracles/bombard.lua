miracle.unique = "bombard"

miracle.cost = 6
miracle.delay = 12
miracle.sound = Sound("sassilization/spells/bombardcast.wav")

if (SERVER) then
	function miracle:Execute(player, empire, hitPos, shrine, level)
		local gravitations = miracles.Get("gravitate").gravitations
		
		local effect = EffectData()
			effect:SetOrigin(hitPos +Vector(0, 0, 70))
			effect:SetMagnitude(3.6 +1.2 *level /3)
			effect:SetScale(38 +6 *level /3)
		util.Effect("cast_bombard", effect)
		
		for i = 1, math.random(math.Round(6 +8 *level /3), math.Round(8 +11 *level /3)) do
			local startpos = hitPos +Vector(math.random(-18, 18), math.random(-18, 18), math.random(68, 72))
			
			local trace = {}
			trace.start = hitPos
			trace.endpos = startpos
			trace.mask = MASK_SOLID_BRUSHONLY
			
			local tr1 = util.TraceLine(trace)
			
			trace.start = tr1.HitPos +tr1.HitNormal
			trace.endpos = trace.start +Vector(0, 0, -120)
			
			startpos = trace.start
			
			local tr2 = util.TraceLine(trace)
			local endpos = tr2.HitPos +Vector(0, 0, -10)
			
			timer.Simple(math.Rand(0, 1) +3, function()
				local gravitate = false
				
				for k, gravitation in pairs(gravitations) do
					if (startpos:Distance(gravitation) <= 120) then
						gravitate = gravitation
						
						break
					end
				end	
				
				local arrow = ents.Create("projectile_arrow")
				arrow:SetControl(empire)
				arrow:SetPos(startpos)
				arrow:SetAngles(Angle(180, 0, 0))
				arrow:Spawn()
				arrow:Activate()
				
				--arr:GetPredictedTarget() dont use ?
				--arr.Overlord = pl
				
				arrow.Gravitated = gravitate

				local dmginfo = {}
				dmginfo.damage = 5.5
				dmginfo.dmgtype = DMG_BULLET
				dmginfo.attacker = arrow
				
				arrow:Shoot(dmginfo, endpos:Angle())
				
				--arrow:SetSpawner( pl )
				
				-- This is the gravitate 'defence'.
				if (gravitate) then
					local direction = (arrow:GetPos() -gravitate)
					direction:Normalize()
					
					local power = 24 -arrow:GetPos():Distance(gravitate) *0.2
					
					function arrow:StartTouch() return end
					function arrow:PhysicsCollide() return end
					
					local physObject = arrow:GetPhysicsObject()
					
					if (IsValid(physObject)) then
						physObject:EnableMotion(true)
						physObject:EnableGravity(true)
						physObject:Wake()
						physObject:AddAngleVelocity(Vector(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
						physObject:SetVelocity(direction *math.random(10, 20) *power)
					end
				end
			end)
		end
	end
end