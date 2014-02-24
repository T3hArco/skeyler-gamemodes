--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

ENT.Type = "anim"
ENT.Base = "building_base"

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
	
	self:DTVar("Int", 2, "m_iRecharge")
end

function ENT:SetRecharge(recharge)
	self.dt.m_iRecharge = recharge
end

function ENT:GetRecharge()
	return self.dt.m_iRecharge
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:CountNeighbors()
	local count = 0
	
	for k, v in pairs(self.neighbors) do
		if (IsValid(v) and v:IsBuilt()) then
			count = count +1
		else
			self.neighbors[k] = nil
		end
	end
	
	return count
end

function ENT:CollectNeighbors()
	self:ClearNeighbors()
	
	local nearby = ents.FindInSphere(self:GetPos(), 50)
	
	for _, entity in pairs(nearby) do
		if (entity:GetClass() == "building_shieldmono" and entity:IsBuilt()) then
			self:AddNeighbor(entity)
		end
	end
end

function ENT:AddNeighbor(entity)
	if (!IsValid(entity) and entity:GetClass() == "building_shieldmono") then return end
	
	self.neighbors[entity] = entity
	entity.neighbors[self] = self
end

function ENT:ClearNeighbors()
	for k, v in pairs(self.neighbors) do
		if (IsValid(v) and v.neighbors) then
			v.neighbors[self] = nil
		end
	end
	
	self.neighbors = {}
end

function ENT:CanProtect()
	self:CollectNeighbors()
	
	local diff = CurTime() -self:GetRecharge() +math.Min(self:CountNeighbors(), 3)
	
	return diff > 5
end