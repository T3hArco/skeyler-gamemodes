ENT.Type = "point"

function ENT:Initialize()
end

function ENT:KeyValue(key, value)
	self[key] = tonumber(value)
end