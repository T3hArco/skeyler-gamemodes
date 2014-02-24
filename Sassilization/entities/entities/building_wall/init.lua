----------------------------------------
--    Sassilization
--    http://sassilization.com
--    By Sassafrass / Spacetech
----------------------------------------

AddCSLuaFile"shared.lua"
AddCSLuaFile"cl_init.lua"
AddCSLuaFile"wall.lua"
include"shared.lua"
include("wall_sv.lua")

AccessorFunc( ENT, "vNormal", "Normal" )

function ENT:Initialize()
    self:Setup("walltower", "models/mrgiggles/sassilization/brick_small.mdl", true)
end

function ENT:OnBuilt()

end

--WALLs have custom territory influence.
--use the Nav to create a path from wall_tower1 to wall_tower2,
function ENT:SetupTerritoryLineInfo( pos1, pos2 )

	if( not Nav ) then return end

	local nodeStart = Nav:GetClosestNode( pos1 )
	local nodeFinish = Nav:GetClosestNode( pos2 )
	if( nodeStart == nodeFinish ) then return end

	Nav:SetStart( nodeStart )
	Nav:SetEnd( nodeFinish )
	Nav:FindPath(

		function(Nav, FoundPath, Path)

			if( not self:GetEmpire() ) then return end
			if( not FoundPath ) then return end
			if( #Path <= 1 ) then return end

			local empID = self:GetEmpire():GetID()
			local lineInfo = {}
			local lineInfoCount = 0

			for _, node in pairs( Path ) do

				lineInfoCount = lineInfoCount + 1
				lineInfo[lineInfoCount] = {node, empID, 132}

			end

			self.TerritoryLineInfo = lineInfo

		end

	)
	
end

local nWallPhysW   = SA.WallWidth
local nWallPhysL   = SA.WallSpacing
local nWallPhysH   = SA.WallHeight

function ENT:NearestAttackPoint( pos )
	
	if( not self:GetNormal() ) then
		Error( "Wall has no normal\n" )
	end
	local nSeg = self:GetNearestSegment( pos )
	if( not nSeg ) then
		return self:GetPos()
	end
	local posOnWall = nSeg:GetPos() + nWallPhysH * 0.2 * VECTOR_UP
	
	local localPos = self:WorldToLocal( pos )
	local normal = self:GetNormal()
	if (localPos.y < 0) then
		posOnWall = posOnWall + nWallPhysW * 0.5 * normal
	else
		posOnWall = posOnWall - nWallPhysW * 0.5 * normal
	end
	-- if (localPos.x < 0) then
		-- posOnWall.x = posOnWall.x - nWallPhysL * 0.5 * normal.y
		-- posOnWall.y = posOnWall.y + nWallPhysL * 0.5 * normal.x
	-- else
		-- posOnWall.x = posOnWall.x + nWallPhysL * 0.5 * normal.y
		-- posOnWall.y = posOnWall.y - nWallPhysL * 0.5 * normal.x
	-- end
	debugoverlay.Line( posOnWall, posOnWall + VECTOR_UP * 20, 1, color_white )
	return posOnWall
	-- local wallSegment = self:GetWallSegmentAt( pos )
	
end

function ENT:Damage( dmginfo )
	
	if( self.Destroyed ) then
		return
	end
    
	local totalHealth = 0
    self:OnDamaged( dmginfo.damage, totalHealth, dmginfo.attacker )
	
	if( dmginfo.dmgtype == DMG_SLASH ) then
		self:EmitSound( SA.Sounds.GetBuildingHitSound() )
	elseif( dmginfo.dmgtype == DMG_BULLET ) then
		self:EmitSound( SA.Sounds.GetArrowHitBuildingSound() )
	end
	
	local seg = self:GetNearestSegment( self:LocalToWorld(dmginfo.dmgpos) )
	if( seg ) then
		Msg( "found closest seg\n" )
		seg:Damage( dmginfo )
	end
	
end

function ENT:OnThink()
    --self:WallUpdateControl()
    --if self.entTower1 and (not self.entTower1:IsValid()) then self:Remove(); return end
    --if self.entTower2 and (not self.entTower2:IsValid()) then self:Remove(); return end
    
    -- if self.tblConvexParts then
        -- local physSelf  = self:GetPhysicsObject()
        -- for _, tblConvex in pairs(self.tblConvexParts) do
            -- for _, tblTriangle in pairs(tblConvex) do
                -- for _, vecVert in pairs(tblTriangle) do
                    -- debugoverlay.Cross(physSelf:LocalToWorld(vecVert), 2.5, 1.75, Color(255,255,255,255),true)
                -- end
            -- end
        -- end
    -- end
    --[[
    local vecTower1    = self.entTower1:GetPos()
    local vecTower2    = self.entTower2:GetPos()
    local vecTowerNrml = self:LocalToWorld(Vector(0, 1, 0)) - self:GetPos()
    local vecCenterPos = (vecTower1 + vecTower2) * 0.5
    debugoverlay.Line(vecCenterPos, vecCenterPos + vecTowerNrml * 10, 2.5, 1.75, Color(255,255,255,255),true)
    
    if self.vecIntersect then
        debugoverlay.Cross(self.vecIntersect, 2.5, 1.75, Color(255,0,0,255),true)
    end
    --]]
    return 2
end

util.AddNetworkString( "wall.SpawnNewWall" )
util.AddNetworkString( "wall.SetWallTowers" )
function ENT:SetTowers( WallTower1, WallTower2, Positions )
    //return
    if( not (IsValid( WallTower1 ) and IsValid( WallTower2)) ) then
        self:Remove()
        return
    end
    
	WallTower1.ConnectedWalls[ self ] = true
	WallTower2.ConnectedWalls[ self ] = true
	
    self.entTower1 = WallTower1
    self.entTower2 = WallTower2

    net.Start( "wall.SetWallTowers" )
    	net.WriteEntity(self)
    	net.WriteEntity(self.entTower1)
    	net.WriteEntity(self.entTower2)
    net.Broadcast()
	
	self:CreateWall( Positions )
    
    local pos1 = Positions[1]
    local pos2 = Positions[#Positions]
	
	self.dt.intTowerSegmentCount = #Positions
    self:SetPos( pos1:MidPoint( pos2 ) )
    self:SetAngles( Angle( 0, math.atan2( (pos2.y - pos1.y), (pos2.x - pos1.x) ) * 180 / math.pi, 0 ) )
    self.vecWallDirection = (pos2 - pos1):GetNormal()
	self:SetNormal( self.vecWallDirection:Cross(VECTOR_UP) )
	
	Msg( "total segments: ", #Positions, "\n" )
	
	for _, p in pairs( Positions ) do
		debugoverlay.Line( p, p+Vector( 0, 0, 10 ), 10, color_white, true )
	end
	
	assert(#Positions < (24 * 3))
	self.OptimizedPositions = table.Copy( Positions )
    local OptimizedPositions = self.OptimizedPositions
	
    local NumPositions = GAMEMODE:OptimizeWallPositions( OptimizedPositions )
	
	for _, p in pairs( OptimizedPositions ) do
		debugoverlay.Line( p, p+Vector( 0, 0, 20 ), 10, Color( 255, 0, 0, 255 ), true )
	end

	self:SetupTerritoryLineInfo( Positions[1], Positions[#Positions] )
	
    timer.Simple( 0.1, function()
        net.Start( "wall.SpawnNewWall" )
			-- 3 UBytes
            net.WriteEntity(self)
            net.WriteEntity(WallTower1)
            net.WriteEntity(WallTower2)
			-- UByte
            net.WriteUInt( #Positions, 8 )
            for i = 1, #Positions do
                net.WriteVector( Positions[ i ] ) -- Send directly. Currently the max # of segs is 15 (imposed in enumerations.lua via SA.MAX_WALL_DISTANCE), so that's only 135 bytes.
            end
		net.Broadcast()
		
		local nBounds1   = self:WorldToLocal(pos1)
			  nBounds1.x = nBounds1.x - SA.WallSpacing * 0.5 -- Offset min/max bound by 0.5 due to 
		local nBounds2   = self:WorldToLocal(pos2)
			  nBounds2.x = nBounds2.x + SA.WallSpacing * 0.5
		self.dt.nTowerMin   = math.min(nBounds1.x, nBounds2.x)
		self.dt.nTowerMax   = math.max(nBounds1.x, nBounds2.x)
		
		--local physPositions = table.Copy( OptimizedPositions )
		--physPositions[ 1 ] = self:LocalToWorld( nBounds1 )
		--physPositions[ NumPositions ] = self:LocalToWorld( nBounds2 )
		--self.vecWallRootPoint = physPositions[ 1 ]
		
		self:SV_PhysWallCreate(Positions)
    end )
	
end

function ENT:UpdateControl()
    self:WallUpdateControl()
end

function ENT:OnControl()
    self:WallUpdateControl()
end

util.AddNetworkString( "wall.SellWall" )
function ENT:SellWall()
	
	Msg( "selling wall\n" )
	if( self.Destroyed or not self.Walls ) then return 0 end
	self.Destroyed = true
	self.dt.bDestroyed = true
	
	--Calculate the refund value TODO:
	local Count = 0
	for _, wall in pairs( self.Walls ) do
		Count = Count + 1
	end
	------------
	
	--Tell clients the wall is sold
	net.Start( "wall.SellWall" )
		-- UByte
		net.WriteUInt( self:EntIndex(), 8 )
	net.Broadcast()
	
	--Disable collisions
	self:SetSolid( SOLID_NONE )
	local phys = self:GetPhysicsObject()
	if( phys:IsValid() ) then
		phys:EnableCollisions( false )
	end
	
	--Play destroy sound
	self:EmitSound("sassilization/units/buildingbreak0"..math.random(1, 2)..".wav", 70)
	
	--Remove the wall
    timer.Simple( 0.5, function() SafeRemoveEntity(self) end )
	
	Msg( "wall sold ", Count, "\n" )
	
	return Count
	
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS -- Insures everyone hears about its creation!
end