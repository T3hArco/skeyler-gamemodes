miracle.unique = "plummet"

miracle.cost = 10
miracle.delay = 25
miracle.id = 22
miracle.sound = Sound("sassilization/spells/plummetcast.wav")

if (SERVER) then
	function miracle:Execute(player, empire, hitPos, shrine, level)
		local entities = ents.FindInSphere(hitPos, 2)

		for k, entity in pairs(entities) do
			if ((entity:GetClass() == "building_wall" or entity:GetClass() == "building_walltower") and entity:GetEmpire() != empire and !Allied(empire, entity:GetEmpire())) then -- allies check
				if entity:GetClass() == "building_wall" then
					local seg = entity:GetNearestSegment(hitPos)
					seg:Plummet()
				else
					entity:Plummet()
				end
			end
		end
	end
end