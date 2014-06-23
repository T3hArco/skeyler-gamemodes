----------------------------------------
--    Sassilization
--    http://sassilization.com
--    By Sassafrass / Spacetech
----------------------------------------

include("shared.lua")

local nSegmentSize  = SA.WallSpacing
local iSegsPerFloat = 24 -- Rest is given to mantissa and we can't use it

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Foundation = false

local renderConvar = CreateClientConVar( "sass_buildingdistance", 640, true, true )

function ENT:Initialize()
    
    self:UpdateRenderBounds()
    self.Color = self:GetColor()
	
end

function ENT:OnOwnershipChanged( empOld, empNew )
	
	self.Color = empNew:GetColor()
	
end

function ENT:OnRemove()
    
	if( not self.Walls ) then return end
	
	for _, segment in pairs( self.Walls ) do
		if( IsValid( segment ) ) then
			segment:Remove()
		end
	end
	
	if( IsValid( self.entTower1 ) ) then
		self.entTower1.ConnectedWalls[ self ] = nil
	end
	
	if( IsValid( self.entTower2 ) ) then
		self.entTower2.ConnectedWalls[ self ] = nil
	end
	
end


function ENT:Think()
	if not self.Walls then return end
	
    if (not self.vecLastDamageMask) or
       (self.vecLastDamageMask:Distance(self.dt.vecDamageMask) ~= 0) then
        if self.dt.vecDamageMask:Length() > 0 then
            local nBoundMax = self.dt.intTowerSegmentCount
            local bBailout  = false
            
            for i = 1, 3 do
                local iMaskValOld = self.vecLastDamageMask and self.vecLastDamageMask[(i == 1) and "x" or ((i == 2) and "y" or "z")] or 0
                local iMaskVal    =                            self.dt.vecDamageMask [(i == 1) and "x" or ((i == 2) and "y" or "z")]
                local iOffset     = (i - 1) * iSegsPerFloat
                
                for j = 0, iSegsPerFloat - 1 do
                    local iSegmentPos = iOffset + j + 1
                    if iSegmentPos > nBoundMax then bBailout = true; break end
                    
                    local iMask = bit.lshift(1, j)
					
                    if ((bit.band(iMaskVal, iMask)) == iMask) and
                       ((bit.band(iMaskValOld, iMask)) ~= iMask) then
                        if !self.Walls[iSegmentPos] then
                            bBailout = true
                            break
                        end

						self.Walls[iSegmentPos]:Destroy(building.BUILDING_DESTROY)

                        if( iSegmentPos > 1 ) then
                            self.Walls[iSegmentPos - 1]:UpdateModel()
                        end
                        if( iSegmentPos < nBoundMax ) then
                            self.Walls[iSegmentPos + 1]:UpdateModel()
                        end
                    end
                end
                
                if bBailout then break end
            end
        end
        
        self.vecLastDamageMask = self.dt.vecDamageMask
    end
    for k,v in pairs(self.Walls) do
        if v.Plummeted then
            v:SetPos(v:GetPos() - Vector(0,0,0.2))
        end
    end
end

function ENT:SetAllSegmentsDraw()
    for k,v in pairs(self.Walls) do
        v.NoDraw = false
    end
end

function ENT:UpdateRenderBounds()
	if( not self.Walls ) then return end
    self:SetRenderBounds(self:GetWallOBB())
end

function ENT:GetWallOBB()
    local min = Vector(999999, 999999, 999999);
	local max = Vector(0)
	for i = 1, self.WallCount do
		local mins, maxs = self.Walls[ i ].Model:GetRenderBounds()
		mins = self:WorldToLocal( self.Walls[ i ].Model:LocalToWorld( mins ) )
		maxs = self:WorldToLocal( self.Walls[ i ].Model:LocalToWorld( maxs ) )
		min.x = math.min( mins.x, min.x )
		min.y = math.min( mins.y, min.y )
		min.z = math.min( mins.z, min.z )
		max.x = math.max( maxs.x, max.x )
		max.y = math.max( maxs.y, max.y )
		max.z = math.max( maxs.z, max.z )
	end
	return min, max
end

function ENT:UnoptimizePositions(tblPointsCompressed)
	local tblPointsUncompressed = {}
	local vecPosPrev            = tblPointsCompressed[1]
	for i = 2, #tblPointsCompressed do
		local vecPosCur  = tblPointsCompressed[i]
		local vecDiffXY  = vecPosPrev - vecPosCur
		      vecDiffXY.z = 0
		local nDistance  = vecDiffXY:Length()
		local vecDirNrml = (vecPosCur - vecPosPrev):GetNormal()
		
		table.insert(tblPointsUncompressed, vecPosCur)
		for i = 1, math.floor(nDistance / SA.WallSpacing) do
			table.insert(tblPointsUncompressed, vecPosPrev + vecDirNrml * SA.WallSpacing * i) -- Might need a tiny shift here...
		end
		
		vecPosPrev = vecPosCur
	end
	table.insert(tblPointsUncompressed, lastPos )
	
	Msg("Decompress - Total segments: ", #tblPointsUncompressed, "\n")
	assert(#tblPointsUncompressed < (3 * iSegsPerFloat))
	return tblPointsUncompressed
end

net.Receive( "wall.SpawnNewWall", function( len )
    
    --local tower1 = um:ReadEntity() --Parent towers
    --local tower2 = um:ReadEntity()
    --Use this instead of the ent index, there appears to be some differences between client and server sometimes //Hateful
    local wallEnt = net.ReadEntity()
    local wallTower1 = net.ReadEntity()
    local wallTower2 = net.ReadEntity()
    local count = net.ReadUInt(8)
    
    if( count == 0 ) then return end
	
    local positions = {}
    
    for i = 1, count do
        positions[ i ] = net.ReadVector()
    end

    if count == 2 then
        wallEnt:UnoptimizePositions(positions)
    end
   
    if( IsValid( wallEnt ) ) then
        timer.Simple( 0.5, function()
            if( IsValid( wallEnt ) ) then
                if wallEnt:GetClass() == "building_wall" then
                    wallEnt:CreateWall( positions )
                    if IsValid( wallTower1 ) then
                        wallEnt.entTower1 = wallTower1
                        wallTower1:AddConnectedWall( wallEnt )
                    end
                    if IsValid( wallTower2 ) then
                        wallEnt.entTower2 = wallTower2
                        wallTower2:AddConnectedWall( wallEnt )
                    end
                end
            end
        end )
    else
        --Assume we received the message before the entity was created clientside
        hook.Add( "OnEntityCreated", "wall.CatchWallCreate"..tostring(wallEntID), function( ent )
			if( not( ent == wallEnt or ent == wallTower1 or ent == wallTower2 ) ) then return end
			
			-- TESTING !! THIS SHOULD NEVER HAPPEN // Chewgum
			if (!IsValid( wallEnt ) or !IsValid( wallTower1 ) or !IsValid( wallTower2 )) then
				ErrorNoHalt("SOME WALL IS INVALID!?!??!!")
				MsgN("wallEnt:", tostring(wallEnt), "wallTower1:", tostring(wallTower1), "wallTower2:", tostring(wallTower2))
			end
			
			if( IsValid( wallEnt ) and IsValid( wallTower1 ) and IsValid( wallTower2 ) ) then
				hook.Remove( "OnEntityCreated", "wall.CatchWallCreate"..tostring(wallEntID) )
				timer.Simple( 0.5, function()
					wallEnt:CreateWall( positions )
					wallEnt.entTower1 = wallTower1
					wallEnt.entTower2 = wallTower2
					wallTower1:AddConnectedWall( wallEnt )
					wallTower2:AddConnectedWall( wallEnt )
				end )
			end
        end )
    end
    
end )

function ENT:Draw()
    if( (EyePos()-self:GetPos()):LengthSqr() > renderConvar:GetFloat()*1000 ) then
        return
    end
	self:DrawBuilding()
end

function SetWallHidden(len)
    ent = net.ReadEntity()
    ent.hidewall = net.ReadInt(8)
    num = net.ReadBit()
    if num == 1 then
        num = true
    else
        num = false
    end
    if ent.Walls then
        for k,v in pairs(ent.Walls) do
            if k == ent.hidewall then
                v.Hidden = num
            end
        end
    end
end
net.Receive("SetWallHidden", SetWallHidden)

function SetWallPlummeted(len)
    ent = net.ReadEntity()
    ent.selWall = net.ReadInt(8)
    num = net.ReadBit()
    if num == 1 then
        num = true
    else
        num = false
    end
    if ent.Walls then
        for k,v in pairs(ent.Walls) do
            if k == ent.selWall then
                if ent:IsValid() then
                    v.Plummeted = num
                end
            end
        end
    end
end
net.Receive("SetWallPlummeted", SetWallPlummeted)

function ENT:DrawBuilding()
	
	if( not self.Walls ) then return end
	
	render.SetColorModulation( self.Color.r / 255, self.Color.g / 255, self.Color.b / 255 )
	for _, wall in pairs( self.Walls ) do
		if( not wall.NoDraw ) then
            if !wall.Hidden then
                wall.Model:DrawModel()
            end
		end
	end
	render.SetColorModulation( 1, 1, 1 )
	
end

net.Receive( "wall.SellWall", function( len )
	
    local wallEntID = net.ReadUInt(8)
	local wallEnt = Entity( wallEntID )
	
	-- Msg( "selling wall\n" )
	
	if( not IsValid( wallEnt ) ) then return end
	if( not wallEnt.Walls ) then return end
	
	for _, wall in pairs( wallEnt.Walls ) do
		
		wall:Destroy( building.BUILDING_SELL )
		
	end
	
	-- Msg( "wall sold\n" )
	
end )

--[[	
local WallMaterial = Material( "sassilization/wall" )

function ENT:Draw()
    if not self.objVWall then return end
    
    -- local sun = util.GetSunInfo()
    -- if not sun then return end
    
    local vecWallDir = self.dt.vecWallDirection
    --MsgN(vecWallDir)
    
    if (not self.vecLastDamageMask) or (self.vecLastDamageMask:Distance(self.dt.vecDamageMask) ~= 0) then
        local vecMaskDiff = self.dt.vecDamageMask
        if self.vecLastDamageMask then vecMaskDiff = vecMaskDiff - self.vecLastDamageMask end
        
        self.vecLastDamageMask = self.dt.vecDamageMask
        --MsgN("Update due to damage mask")
        
        -- These should always be positive
        assert(vecMaskDiff.x >= 0)
        assert(vecMaskDiff.y >= 0)
        assert(vecMaskDiff.z >= 0)
        
        if self.vecLastDamageMask:Length() > 0 then
            if not self.tblClipCache then
                self.tblClipCache = {}
            end
            
            self.iClipCount = 0
            
            local vecWallRoot   = self.dt.vecWallRootPoint
            local nBoundMin     = self.dt.vecTowerBounds.x
            local nBoundMax     = self.dt.vecTowerBounds.y
            local bBailout      = false
            local bUnclosedClip = false
            local tblClipStretch
            
            --MsgN('---', self.vecLastDamageMask)
            -- \fixme Minor bug where it renders once too often for proper when clipping bound min. No visual side effect, so priority low (Fixed?)
            -- \fixme Need to counter rotate clipping plane so that it clips nicely upwards. Visual bug, priority moderate (since you can have phantom wall segments floating about)
            -- \note Ironically this makes it match the phys mesh correctly in some cases
            self.bUnclosedClip = false
            
            for i = 1, 3 do
                local iMaskVal = self.vecLastDamageMask[(i == 1) and "x" or ((i == 2) and "y" or "z")]
                local iOffset  = (i - 1) * iSegsPerFloat
                
                for j = 0, iSegsPerFloat - 1 do
                    local nSegmentPos = (iOffset + j) * nSegmentSize + nBoundMin
                    if nSegmentPos > nBoundMax then bBailout = true; break end
                    
                    local iMask = 1 << j
                    if (iMaskVal & iMask) == iMask then
                        if not self.bUnclosedClip then
                            self.bUnclosedClip = true
                            
                            self.iClipCount = self.iClipCount + 1
                            self.tblClipCache[self.iClipCount] = (-vecWallDir):Dot(self:LocalToWorld(Vector(nSegmentPos, 0, 0)))
                            debugoverlay.Line(self:LocalToWorld(Vector(nSegmentPos, 0, 0)), self:LocalToWorld(Vector(nSegmentPos, 0, 0)) + vecWallDir * 3, 8, Color(255,0,0,255),true)
                            debugoverlay.Line(self:LocalToWorld(Vector(nSegmentPos, 0, 0)), self:LocalToWorld(Vector(nSegmentPos, 0, 0)) + Vector(0,0,3), 8, Color(255,0,0,255),true)
                            --Msg("Mask @ ", nSegmentPos,"\n")
                        end
                    elseif self.bUnclosedClip then
                        self.bUnclosedClip = false
                        debugoverlay.Line(self:LocalToWorld(Vector(nSegmentPos, 0, 0)), self:LocalToWorld(Vector(nSegmentPos, 0, 0)) - vecWallDir * 3, 8, Color(0,255,0,255),true)
                        debugoverlay.Line(self:LocalToWorld(Vector(nSegmentPos, 0, 0)), self:LocalToWorld(Vector(nSegmentPos, 0, 0)) + Vector(0,0,3), 8, Color(0,255,0,255),true)
                        self.iClipCount = self.iClipCount + 1
                        self.tblClipCache[self.iClipCount] = (vecWallDir):Dot(self:LocalToWorld(Vector(nSegmentPos, 0, 0)))
                        nClipStretch = nil
                        --Msg("End stretch @ ", nSegmentPos,"\n")
                    end
                end
                
                self.tblClipCache[self.iClipCount + 1] = nil
                --Msg("Unclose: ", bUnclosedClip,"\n")
                --Msg("Passes: ", math.floor(self.iClipCount / 2) + (bUnclosedClip and 0 or 1),"\n")
                
                if bBailout then break end
            end
        end
    end
    
    self.iClipCount = self.iClipCount or 0
    
    --self.objVWall:Draw()
    
    local nR, nG, nB, nA = self:GetColor()
    local vecPos = self:GetPos()
    local angDir = self:GetAngles()
    
    local matrix = Matrix()
    matrix:SetTranslation(vecPos)
    matrix:Rotate(angDir)
    
    render.SetMaterial(WallMaterial)
    
    --render.SuppressEngineLighting(true)
    --    --render.SetLightingOrigin(vecPos)
    --    render.SetBlend(0.5)
    --    render.MaterialOverride("debug/white")
    --    render.SetColorModulation(1, 0, 0)
    --    render.SetModelLighting( BOX_TOP, .8, 0, 0 )
        --render.SetColorModulation(nR / 255, nG / 255, nB / 255)
            cam.PushModelMatrix(matrix)
                if self.iClipCount == 0 then
                    --self.objVWall:Draw()
                    self.meshVWall:Draw()
                else
                    render.EnableClipping(true)
                        local tblClipDists = self.tblClipCache
                        for i = 1, math.floor(self.iClipCount / 2) + (bUnclosedClip and 0 or 1) do
                            local nClipRevDist = tblClipDists[    (i - 1) * 2]
                            local nClipFwdDist = tblClipDists[1 + (i - 1) * 2]
                            
                            if nClipRevDist then render.PushCustomClipPlane( vecWallDir, nClipRevDist) end
                            if nClipFwdDist then render.PushCustomClipPlane(-vecWallDir, nClipFwdDist) end
                            
                            --self.objVWall:Draw()
                            self.meshVWall:Draw()
                            
                            if nClipRevDist then render.PopCustomClipPlane() end
                            if nClipFwdDist then render.PopCustomClipPlane() end
                        end
                    render.EnableClipping(false)
                end
            cam.PopModelMatrix()
    --        render.SetBlend(1)
    --    render.MaterialOverride(0)
    --    render.SetColorModulation(1, 1, 1)
    --render.SuppressEngineLighting(false)
    
    --render.DrawSprite(self.objVWall.positions[1] + Vector(0,0,15), 10, 10, Color(255,255,255,255))
end]]