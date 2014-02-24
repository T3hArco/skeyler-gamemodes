ENT.Type = "point"

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:KeyValue(key, value)
	if (key == "gamemode") then
		local data = string.Explode(" ", value)
		
		self.minigames = {}
		
		for k, v in pairs(data) do
			table.insert(self.minigames, tonumber(v))
		end
	else
		self[key] = tonumber(value)
	end
end