--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Attackable = true
ENT.Building = true
ENT.Refundable = true
ENT.AutomaticFrameAdvance = true

function ValidBuilding( bldg )
	
	return bldg and bldg:IsValid() and not bldg.Destroyed
	
end

function ENT:SetupDataTables()
    self:DTVar("Int", 0, "iEmpireID")
    self:DTVar("Int", 1, "iLevel")
    self:DTVar("Bool", 0, "bDestroyed")
	self:DTVar("Bool", 1, "bBuilt")

    -- Init to invalid empire ID (Do here b/c someone overrode ENT.Init and didn't call baseclass constructor!
    self.iEmpireIDLast = 0
    self.empOwner      = nil
end

function ENT:Think()
    if SERVER then
        if (self.Plummeted) then
            self:SetPos(self:GetPos() - Vector(0,0,2))
            if self.Connected then
                for k,v in pairs(self.Connected) do
                    if v:IsValid() then
                        v:SetPos(v:GetPos() - Vector(0,0,2))
                    end
                end
            end
        end
        self:SV_Think( CurTime() )
    end
end

function ENT:GetRandomPosInOBB()
	local mins, maxs = self:OBBMins(), self:OBBMaxs()
	return Vector( math.Rand( mins.x, maxs.x ), math.Rand( mins.y, maxs.y ), math.Rand( mins.z, maxs.z ) )
end

-- Somewhat inelegant, but much more reliable and little overhead.
function ENT:CheckForOwnershipChange()
    if self.dt.iEmpireID == self.iEmpireIDLast then return end

    self:_SetEmpireInternal( empire.GetByID(self.dt.iEmpireID), self.empOwner)
end

function ENT:OnOwnershipChanged( empOld, empNew )
end

function ENT:SetEmpire(empNew)
    self:_SetEmpireInternal(empNew, self:GetEmpire())
end

function ENT:GetEmpire()
    self:CheckForOwnershipChange() -- Make sure self.empOwner isn't stale
	
    return self.empOwner
end

function ENT:_SetEmpireInternal(empNew, empOld)
    if empOld == empNew then return end
   
    if empOld then empOld:GetBuildings()[self] = nil  end
    if empNew then empNew:GetBuildings()[self] = self end
    
    local iEmpireID = 0
	
    if empNew then iEmpireID = empNew:GetID() end
    
    self.dt.iEmpireID  = iEmpireID
    self.iEmpireIDLast = iEmpireID
    self.empOwner      = empNew

	self:OnOwnershipChanged( empOld, empNew )
	
end

function ENT:IsDestroyed()
    return self.dt.bDestroyed
end

function ENT:IsBuilt()
    return self.dt.bBuilt and not self:IsDestroyed()
end

function ENT:GetLevel()
    return self.dt.iLevel
end

function ENT:IsUpgradeable()
	if( not self:IsBuilt() ) then return false end
    local Levels = building.GetBuildingKey(self:GetType(), "Levels")
    if(Levels) then
        if(#Levels > self:GetLevel()) then
            return true
        end
    end
    return false
end