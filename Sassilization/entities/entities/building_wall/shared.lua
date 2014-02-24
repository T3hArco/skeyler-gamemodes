--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

include"wall.lua"

ENT.Type = "anim"
ENT.Base = "building_base"

function ENT:SetupDataTables()
    self.BaseClass.SetupDataTables(self)
    --Msg("Setup DT2 for: ", self, "\n")
    
    --self:DTVar("Int", 0, "iEmpireID")
    --self:DTVar("Int", 1, "iLevel")
    
    self:DTVar("Vector", 0, "vecDamageMask")
    self:DTVar("Int",    1, "intTowerSegmentCount")
    self:DTVar("Float",  0, "nTowerMin")
    self:DTVar("Float",  1, "nTowerMax")
	
end

-- Make this prettier
function math.ProjectPointOntoPlane(vecPlanePoint, vecPlaneNormal, vecPoint)
    return util.IntersectRayWithPlane( vecPoint, vecPlaneNormal, vecPlanePoint, vecPlaneNormal ) or
           util.IntersectRayWithPlane( vecPoint, -vecPlaneNormal, vecPlanePoint, vecPlaneNormal )
end

local vecZero = VECTOR_ZERO
local nSegmentSize  = SA.WallSpacing
function ENT:GetNearestSegment( vecPos )
    
	if( not self.Walls ) then return end
	
    local vecDamagePos = self:WorldToLocal(vecPos)
 	local vecHitPos    = math.ProjectPointOntoPlane(vecZero, Vector(0, 1, 0), vecDamagePos)
    if( not vecHitPos ) then return end
    
    -- Bail if not between wall segments
    local nMinPosX  = self.dt.nTowerMin
    local nMaxPosX  = self.dt.nTowerMax
    -- if vecHitPos.x < nMinPosX then return end
    -- if vecHitPos.x > nMaxPosX then return end
    
	local index = math.Clamp( math.floor((vecHitPos.x - nMinPosX) / nSegmentSize) + 1, 1, self.WallCount )
	local dis, nearest
	for i=1, self.WallCount do
		local seg = self.Walls[ i ]
		local tempDis = math.abs(i - index)
		if( seg and not seg.Destroyed and (not dis or tempDis < dis) ) then
			dis = tempDis
			nearest = seg
		end
	end
	
	return nearest
	
end

if SERVER then
    util.AddNetworkString( "SetWallHidden" )
end

function ENT:HideWallSegment( Segment )
    if SERVER then
        self.tblPointsSet[Segment:GetIndex()] = nil
        self:SV_PhysWallCreate(self.tblPointsSet, self.tblDontRotateList)
        Segment.Hidden = true
        for k,v in pairs(player.GetAll()) do
            net.Start("SetWallHidden")
                net.WriteEntity(self)
                net.WriteInt(Segment.index, 8)
                net.WriteBit(true)
            net.Send(v)
        end
    end
end

function ENT:UnHideWalls( HiddenWalls )
    for k,v in pairs(HiddenWalls) do
        if v.Hidden then
            self.tblPointsSet[v:GetIndex()] = v:GetPos()
            self:SV_PhysWallCreate(self.tblPointsSet, self.tblDontRotateList)
            v.Hidden = false
            for i,d in pairs(player.GetAll()) do
                net.Start("SetWallHidden")
                    net.WriteEntity(self)
                    net.WriteInt(v.index, 8)
                    net.WriteBit(false)
                net.Send(d)
            end
        end
    end
end