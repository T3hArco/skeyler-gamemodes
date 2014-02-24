----------------------------------------
--    Sassilization
--    http://sassilization.com
--    By Sassafrass / Spacetech / LuaPineapple
----------------------------------------
local GM = GM or GAMEMODE
function GM:CalculateWallPositions(vecStart, vecEnd, vFilter)
    if (vecEnd - vecStart):Length() > SA.MAX_WALL_DISTANCE then return false end
    
    local tblWallPoints  = {}
    local tblTraceData   = {start  = nil,
	endpos = nil,
	mask   = MASK_SOLID,
	filter = vFilter}
	
    local vecTraceDirXY  = vecEnd - vecStart
	vecTraceDirXY.z = 0
	vecTraceDirXY:Normalize()

    local iWallSteps     = math.floor(((vecEnd - vecStart):Length() + SA.WallSpacing/2) / SA.WallSpacing)
    local tblTraceResult = nil
    local vecPrevPoint   = nil
    
    for i = 1, iWallSteps do
        if vecPrevPoint then
            tblTraceData.start  = vecPrevPoint + SA.WallUpVec
            tblTraceData.endpos = tblTraceData.start + vecTraceDirXY * SA.WallSpacing
            tblTraceResult = util.TraceLine(tblTraceData)
            
            --If something is in the way, don't allow this wall
            if tblTraceResult.Hit then return end
            
            tblTraceData.start = tblTraceResult.HitPos
        else
            tblTraceData.start = vecStart + SA.WallUpVec + vecTraceDirXY * SA.WallSpacing * ((i - 1) + 0.5)
        end
        
        tblTraceData.endpos = tblTraceData.start + VECTOR_ADD_DOWN
        tblTraceResult = util.TraceLine(tblTraceData)
        
        if not tblTraceResult.HitWorld then return false end
        if vecPrevPoint and (math.abs(tblTraceResult.HitPos.z - vecPrevPoint.z) > SA.WallUp) then return false end
        
        vecPrevPoint = tblTraceResult.HitPos - tblTraceResult.HitNormal
        tblWallPoints[#tblWallPoints + 1] = vecPrevPoint    
    end
    
    return tblWallPoints, #tblWallPoints
end

function GM:OptimizeWallPositions( Positions ) -- \todo This is utter crap, rewrite this!
    
    local wall, prevWall, nextWall
    local trim, count = true, 0
    while( trim ) do
        trim = false
        count = #Positions
        if( count > 2 ) then
            for i = 2, count - 1 do
                wall = Positions[ i ]
                prevWall = Positions[ i-1 ]
                nextWall = Positions[ i+1 ]
                if( math.abs( (wall-prevWall):GetNormal():Dot((nextWall-wall):GetNormal()) ) > 0.9999 ) then
                    table.remove( Positions, i )
                    trim = true
                    break
                end
            end
        end
    end
    
    return math.min(count, 250) -- CLAMP THIS!
    
end

function GM:CalculateWallTrace(Empire, Pos, Pos2, ExtraFilter)
    local Trace = {}
    Trace.start = Pos + SA.WallUpVec
    Trace.endpos = Pos2 + SA.WallUpVec
    Trace.filter = player.GetAll()
    if(ExtraFilter) then
        table.Add(Trace.filter, ExtraFilter)
    end
    return util.TraceLine(Trace).Fraction == 1
end

function GM:GetWallTowersInSphere( Pos, Radius, EmpireFilter )
    local Sphere = ents.FindInSphere(Pos, Radius)
    local walls = {}
    for _, ent in ipairs( Sphere ) do
        if( ent:IsWallTower() ) then
            if( not EmpireFilter or ent:GetEmpire() == EmpireFilter ) then
                table.insert( walls, ent )
            end
        end
    end
    return walls
end

function GM:GetWallsInSphere( Pos, Radius, EmpireFilter )
    local Sphere = ents.FindInSphere(Pos, Radius)
    local walls = {}
    for _, ent in ipairs( Sphere ) do
        if( ent:IsWall() ) then
            if( not EmpireFilter or ent:GetEmpire() == EmpireFilter ) then
                table.insert( walls, ent )
            end
        end
    end
    return walls
end

function GM:GetWallsAndWallTowersInSphere( Pos, Radius, EmpireFilter )
    local Sphere = ents.FindInSphere(Pos, Radius)
    local walltowers = {}
    local walls = {}
    for _, ent in ipairs( Sphere ) do
        
        if( not EmpireFilter or (ent.GetEmpire and ent:GetEmpire() == EmpireFilter) ) then
            if( ent:IsWall() ) then
                table.insert( walls, ent )
            elseif( ent:IsWallTower() ) then
                table.insert( walltowers, ent )
            end
        end
    end
    return walltowers, walls
end

function GM:NoInbetweenWall( Tower1, Tower2 )
    
    if( not Tower1.ConnectedWalls ) then return false end
    if( not Tower2.ConnectedWalls ) then return false end
    
    for wall, _ in pairs( Tower1.ConnectedWalls ) do
        
        if( IsValid( wall ) and not wall:IsDestroyed() and Tower2.ConnectedWalls[ wall ] ) then
            return false end
        
    end
    
    return true
    
end

local function angleBetween( v1, v2 )
    return math.acos( v1:GetNormal():Dot(v2:GetNormal()) )
end

function GM:ValidWallAngle( WallTower, Pos )
    
    if( not WallTower.ConnectedWalls ) then return false end
    
    local TowerPos = WallTower:GetPos()
    for wall, _ in pairs( WallTower.ConnectedWalls ) do
        
        if( IsValid( wall ) and not wall:IsDestroyed() ) then
            if( angleBetween( wall:GetPos() - TowerPos, Pos - TowerPos ) < 0.7 ) then
                return false
            end
        end
        
    end
    
    return true
    
end

local function CCWTest( a, b, c, d, e, f )
    return (c-a) * (f-b) - (d-b) * (e-a) > 0
end

local function SegmentIntersect( vecA, vecB, vecC, vecD )
    if( CCWTest( vecA.x, vecA.y, vecC.x, vecC.y, vecD.x, vecD.y ) == CCWTest( vecB.x, vecB.y, vecC.x, vecC.y, vecD.x, vecD.y ) ) then
        return false
    elseif( CCWTest( vecA.x, vecA.y, vecB.x, vecB.y, vecC.x, vecC.y ) == CCWTest( vecA.x, vecA.y, vecB.x, vecB.y, vecD.x, vecD.y ) ) then
        return false
    else
        return true
    end
end

function GM:QuickWallIntersectionTest( Walls, vecSegStart, vecSegEnd )
    
    --Returns true if no intersecting walls, false if any wall intersects the segment
    --TODO: Use sweeping line algorithm for faster segment intersection test? http://compgeom.cs.uiuc.edu/~jeffe/teaching/373/notes/x06-sweepline.pdf
    
    for _, wall in pairs( Walls ) do
        if( wall.positions ) then
            local vecWallStart = wall.positions[ 1 ]
            local vecWallEnd = wall.positions[ #wall.positions ]
            if( SegmentIntersect( vecWallStart, vecWallEnd, vecSegStart, vecSegEnd ) ) then
                --The walls intersect on the XY Plane
                --TODO: Do Z-Axis check at intersection position (so we can have walls going over walls in certain cases such as ramps and bridges)
                return false
            end
        end
    end
    
    return true    
    
end

function GM:CalculateInbetweenWall(Empire, Pos, WallTowers, Walls)
    
    local Distance, WallTower1, WallTower2
    local PotentialWallTowers = {}
    local NumberWallTowers = #WallTowers
    local ent, ent2
    --This is an O(N^2) algorithm, which is very expensive.. Can this be optimized?
    for i, ent in ipairs(WallTowers) do
        local pos1, pos2 = ent:GetPos()
        for j=i, NumberWallTowers do
            ent2 = WallTowers[j]
            if(i ~= j) then
                
                pos2 = ent2:GetPos()
                local midpoint = pos1:MidPoint(pos2)
                --Check to see if we're near the middle
                if( Pos:Distance( midpoint ) < 10 ) then
                    
                    if( self:NoInbetweenWall( ent, ent2 ) and self:ValidWallAngle( ent, midpoint ) and self:ValidWallAngle( ent2, midpoint ) ) then
                        local dis = pos1:Distance(pos2)
                        if( not Distance or dis < Distance ) then
                            --if( self:CalculateWallTrace( Empire, pos1, pos2, {ent, ent2} ) ) then
                                table.insert( PotentialWallTowers, {ent, ent2} )
                                Distance = dis
                            --end
                        end
                    end
                    
                end
            end
        end
    end

    for i=#PotentialWallTowers, 1, -1 do
        
        local pair = PotentialWallTowers[ i ]
        
        --Check for wall intersection
        if( self:QuickWallIntersectionTest( Walls, pair[1]:GetPos(), pair[2]:GetPos() ) ) then
            
            Positions, Cost = self:CalculateWallPositions( pair[1]:GetPos(), pair[2]:GetPos(), pair )
            if( Positions ) then
                
                WallTower1 = pair[1]
                WallTower2 = pair[2]
                --self:OptimizeWallPositions( Positions )
                break
                
            end
            
        end
        
    end
    
    if( WallTower1 and WallTower2 ) then
        --print( "Found Inbetween", "\n" );
        return true, WallTower1, WallTower2, Positions, Cost
        --return false
    end
    
    return false
    
end

function GM:CalculateNewWall(Empire, Pos, WallTowers, Walls)
    
    local Distance, WallTower1, WallTower2
    local PotentialWallTowers = {}
    local Positions, Cost
    Distance = false
    
    for _, ent in ipairs(WallTowers) do
        if( self:ValidWallAngle( ent, Pos ) ) then
            local CurrentDistance = Pos:Distance( ent:GetPos() )
            if(not Distance or CurrentDistance < Distance) then
                --if( self:CalculateWallTrace( Empire, Pos, ent:GetPos(), {ent} ) ) then
                    table.insert( PotentialWallTowers, ent )
                    Distance = CurrentDistance
                --end
            end
        end
    end
    
    if(Distance and Distance <= SA.MIN_WALL_DISTANCE) then
        --print( "Another wall is too close\n" )
        return false
    end
    
    for i=#PotentialWallTowers, 1, -1 do
        
        local wall = PotentialWallTowers[ i ]
        
        --Check for wall intersection
        if( self:QuickWallIntersectionTest( Walls, Pos, wall:GetPos() ) ) then
            
            Positions, Cost = self:CalculateWallPositions( Pos, wall:GetPos(), wall )
            if( Positions ) then
                WallTower1 = wall
                --self:OptimizeWallPositions( Positions )
                break
            end
            
        end
        
    end
    
    if( not WallTower1 ) then
        --print( "Found no wall in range\n" )
        return true
    end
    
    --print( "Found nearest wall\n" )
    return true, WallTower1, Positions, Cost
    
end

function GM:ValidateConnectedWall(Wall, Connection)
    if(not IsValid(Connection)) then
        return
    end
    if(not Connection:IsWall()) then
        return
    end
    if(Wall:IsWallTower()) then
        local Yaw = math.Round((Wall:GetPos() - Connection:GetPos()):Angle().y)
        local WYaw =  math.Round(Wall:GetAngles().y)
        if(Yaw + 90 == WYaw or Yaw - 90 == WYaw    or Yaw - 270 == WYaw or Yaw + 270 == WYaw) then
            return true
        end
        return false
    elseif(Wall:GetAngles().y ~= Connection:GetAngles().y) then
        return false
    end
    return true
end

function GM:CalculateGateSides(Pos, Wall, Dir)
    local Trace = {}
    Trace.start = Pos + SA.WallUpVec
    Trace.endpos = Trace.start + (Wall:GetRight() * SA.WallSpacing * Dir)
    Trace.filter = {Wall}
    
    local tr = util.TraceLine(Trace)
    
    if(not IsValid(tr.Entity)) then
        return
    end
    
    local Inner, Outer, Tower
    
    if(self:ValidateConnectedWall(Wall, tr.Entity)) then
        Inner = tr.Entity
        
        Trace.start = Inner:GetPos() + SA.WallUpVec
        Trace.endpos = Trace.start + (Inner:GetRight() * SA.WallSpacing * Dir)
        table.insert(Trace.filter, Inner)
        
        tr = util.TraceLine(Trace)
        
        if(self:ValidateConnectedWall(Wall, tr.Entity)) then
            Outer = tr.Entity
            
            Trace.start = Outer:GetPos() + SA.WallUpVec
            Trace.endpos = Trace.start + (Outer:GetRight() * SA.WallSpacing * Dir)
            table.insert(Trace.filter, Outer)
            
            tr = util.TraceLine(Trace)
            
            if(self:ValidateConnectedWall(Wall, tr.Entity)) then
                Tower = tr.Entity
            else
                return
            end
        else
            return
        end
    else
        return
    end
    
    return Inner, Outer, Tower
end

function GM:CalculateGate(Empire, Wall, Pos)
    local seg = Wall:GetNearestSegment( Pos )

    if !seg then return end

    if !seg:GetNext() or !(seg:GetNext()):GetNext() or !Wall.entTower1 or !seg:GetPrev() or !(seg:GetPrev()):GetPrev() or !Wall.entTower2 then return end

    if seg.Hidden or seg:GetNext().Hidden or (seg:GetNext()):GetNext().Hidden or seg:GetPrev().Hidden or (seg:GetPrev()):GetPrev().Hidden then return end

    local InnerRight, OuterRight, TowerRight = seg:GetNext(), (seg:GetNext()):GetNext(), Wall.entTower1
    local InnerLeft, OuterLeft, TowerLeft = seg:GetPrev(), (seg:GetPrev()):GetPrev(), Wall.entTower2
    
    if(not InnerRight or not InnerLeft) then
        return
    end
    
    return true, {seg, OuterLeft, InnerLeft, InnerRight, OuterRight}, {TowerLeft, TowerRight}
end