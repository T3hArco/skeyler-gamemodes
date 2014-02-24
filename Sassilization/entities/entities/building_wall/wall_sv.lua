----------------------------------------
--    Sassilization
--    http://sassilization.com
--    By Sassafrass / Spacetech
--  Specific File By LuaPineapple
----------------------------------------

local nWallPhysW    = SA.WallWidth
local nWallPhysH    = SA.WallHeight
local iSegsPerFloat = 24 -- Rest is given to mantissa and we can't use it

-- Assume tblControlPoints are all planar WRT X axis (local)
-- \todo Implement use of tblDontRotateList to prevent tilting of cliped edges, minor
function ENT:SV_PhysWallCreate(tblPointsSet, tblDontRotateList)
    if not next(tblPointsSet) then
        timer.Simple(0, function()
            if self and self:IsValid() then self:Remove() end
        end)
        return
    end
    
    self:PhysicsInit(SOLID_VPHYSICS)
    
    local nDist             = SA.WallWidth
    local physSelf          = self:GetPhysicsObject()
    local aryPhysPointsList = {}
    
    for _, vecPoint in pairs(tblPointsSet) do
        local vecOffset     = physSelf:WorldToLocal(vecPoint)
        local aryBoxSegment = SA.CreateConvexMeshBox(Vector(-nDist * 0.5, -nWallPhysW * 0.5, 0),
                                                     Vector( nDist * 0.5,  nWallPhysW * 0.5, nWallPhysH))
        for _, tblPoint in pairs(aryBoxSegment) do
            tblPoint.pos = tblPoint.pos + vecOffset
            aryPhysPointsList[#aryPhysPointsList + 1] = tblPoint
            
            debugoverlay.Cross(physSelf:LocalToWorld(tblPoint.pos), 1, 8, Color(100,0,255,255),true)
        end
    end
    
    self.aryPhysPointsList = aryPhysPointsList
    self.tblPointsSet      = tblPointsSet
    
    physSelf:SetMass(500)
    physSelf:EnableCollisions( false )
    self:EnableCustomCollisions( false )
    self:PhysicsFromMesh( aryPhysPointsList )
    
    local physSelf = self:GetPhysicsObject()
    physSelf:EnableCollisions(true)
    self:EnableCustomCollisions(true)
    physSelf:EnableMotion(false)
end

-- \todo Finish this
function ENT:DestroyWallSegment( DamagedSegment )
    
    if( not DamagedSegment ) then return end
    
    -- self.vecIntersect = nil
    
    local iDamagedSegment = DamagedSegment:GetIndex() - 1
    if iDamagedSegment >= (iSegsPerFloat * 3) then Error("Walls: Wall is too long to represent with damage masking!.\n") end
    
    local strMaskComponent = (iDamagedSegment <  iSegsPerFloat     ) and "x" or (
                             (iDamagedSegment < (iSegsPerFloat * 2)) and "y" or "z")
    local vecDamageMask = self.dt.vecDamageMask * 1
    local iMaskValue    = bit.lshift(1, (iDamagedSegment % iSegsPerFloat))
    
    local nMinPosX  = self.dt.nTowerMin
    local nMaxPosX  = self.dt.nTowerMax
    
    --MsgN(vecDamageMask[strMaskComponent] & iMaskValue)
    if (bit.band(vecDamageMask[strMaskComponent], iMaskValue)) != 0 then
        Msg("Attempted to destory already destroyed idx: ", iDamagedSegment, "\n")
        return
    end
    
    vecDamageMask[strMaskComponent] = bit.bor(vecDamageMask[strMaskComponent], iMaskValue)
    self.dt.vecDamageMask = vecDamageMask
    
    --[[
        *CODE SNIP*
        Screw it.
    --]]
    
    self.tblPointsSet[DamagedSegment:GetIndex()] = nil
    self:SV_PhysWallCreate(self.tblPointsSet, self.tblDontRotateList)
    
    self.Destroyed = false
    for _, wall in pairs( self.Walls ) do
        if( not wall.Destroyed ) then return end
    end
    self.Destroyed = true
    Msg( "Wall completely destroyed\n" )
end

for _, e in pairs(ents.FindByClass("building_wall"     )) do e:Remove() end
for _, e in pairs(ents.FindByClass("building_walltower")) do e:Remove() end

concommand.Add("DevWallTestBreak", function (ply, strCCmd, tblParams)
    local vecPos = ply:GetEyeTrace().HitPos
    for _, e in pairs(ents.FindByClass("building_wall")) do
        local seg = e:GetNearestSegment( vecPos )
        if( seg ) then
            seg:Destroy( building.BUILDING_DESTROY )
        end
    end
end)

function ENT:SV_PhysWallGetOBB()
    assert(self.aryPhysPointsList)
    local vecMin = Vector(999999, 999999, 999999)
    local vecMax = -vecMin
    
    for _, tblPoint in pairs(self.aryPhysPointsList) do
        local vecVert = tblPoint.pos
        vecMin.x = math.min(vecVert.x, vecMin.x)
        vecMin.y = math.min(vecVert.y, vecMin.y)
        vecMin.z = math.min(vecVert.z, vecMin.z)
        vecMax.x = math.max(vecVert.x, vecMax.x)
        vecMax.y = math.max(vecVert.y, vecMax.y)
        vecMax.z = math.max(vecVert.z, vecMax.z)
    end
    
    return vecMin, vecMax
end
