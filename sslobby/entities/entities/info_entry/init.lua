AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

--------------------------------------------------
--
--------------------------------------------------

function ENT:Initialize()
    self:PhysicsInitBox(self.min, self.max)
    self:SetCollisionBounds(self.min, self.max)
	self:DrawShadow(false)
	self:SetTrigger(true)
	
	-- Enable "ShouldCollide".
	self:SetCustomCollisionCheck(true)
	
	local physicsObject = self:GetPhysicsObject()
	
	if (IsValid(physicsObject)) then
		physicsObject:EnableMotion(false)
	end
end

--------------------------------------------------
--
--------------------------------------------------

function ENT:KeyValue(key, value)
	if (key == "boundingbox") then
		local data = string.Explode(",", value)
		
		self.min = Vector(0, 0, 0)
		self.max = Vector(0, 0, 0)
		
		for k, v in pairs(data) do
			if (k < 4) then
				if (k == 1) then self.min.x = tonumber(v)
				elseif (k == 2) then self.min.y = tonumber(v)
				elseif (k == 3) then self.min.z = tonumber(v) end
			else
				if (k == 4) then self.max.x = tonumber(v)
				elseif (k == 5) then self.max.y = tonumber(v)
				elseif (k == 6) then self.max.z = tonumber(v) end
			end
		end
	end
	
	if (key == "rank") then
		self:SetRank(tonumber(value))
	end
end