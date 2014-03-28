----------------------------------------
--    Sassilization
--    http://sassilization.com
--    By Sassafrass / Spacetech
----------------------------------------

local mt = {}
local WALL = {}
mt.__index = WALL
mt.__tostring = function( self ) return "Wall"; end

net.Receive( "wall.SetWallTowers", function( len )
    wall = net.ReadEntity()
    wall.entTower1 = net.ReadEntity()
    wall.entTower2 = net.ReadEntity()
end )

function ENT:CreateWall( positions )
    
    if( self.Walls ) then return end
    
    if( CLIENT ) then
        self.positions = positions
    else
        self.positions = positions
    end
    
    self.Walls = {}
    self.WallCount = #self.positions
    local dy = self.positions[ 1 ].y - self.positions[ self.WallCount ].y
    local dx = self.positions[ 1 ].x - self.positions[ self.WallCount ].x
    local ang = Angle( 0, math.deg( math.atan2( dy, dx ) ) + 90, 0 )
    
    local segPrev

    timer.Simple(0.1, function() --Doing this timer so the net call to update the first/last tower are actually set before doing anything. // Hateful
     
        for i, pos in ipairs( self.positions ) do

            if !self.entTower2 or !self.entTower1 then return end
        
            local seg = self:CreateWallSegment( i, pos, ang )
            self.Walls[ i ] = seg
            
            if( segPrev ) then
                segPrev:SetNext( seg )
                seg:SetPrev( segPrev )
                self.lastWall = seg
                self.lastTower = self.entTower1
                if pos:Distance(self.entTower2:GetPos()) < pos:Distance(self.entTower1:GetPos()) then
                    self.lastTower = self.entTower2
                end
                if i == (#self.positions) then
                    seg.lastTower = self.lastTower
                end
            else
                self.firstWall = seg
                self.firstTower = self.entTower1
                if pos:Distance(self.entTower2:GetPos()) < pos:Distance(self.entTower1:GetPos()) then
                    self.firstTower = self.entTower2
                end
                seg.firstTower = self.firstTower
            end
            
            if( CLIENT ) then
                seg:SetupNormal()
            end
            
            segPrev = seg
            
        end
        
        if( CLIENT ) then
            self:UpdateRenderBounds()
        end

    end )
    
end

function ENT:CreateWallSegment( index, vecPos, vecAng )
    
    local seg = {}
    setmetatable( seg, mt )
    
    seg.index = index
    seg:Init( self, vecPos, vecAng )
    
    return seg
    
end

AccessorFunc( WALL, "n_Health", "Health", FORCE_NUMBER )
AccessorFunc( WALL, "a_Ang", "Angles" )
AccessorFunc( WALL, "v_Pos", "Pos" )
AccessorFunc( WALL, "wall_Next", "Next" )
AccessorFunc( WALL, "wall_Prev", "Prev" )
AccessorFunc( WALL, "e_Parent", "Parent" )

    
function WALL:Init( parent, pos, ang )
    
    if( CLIENT ) then
        self.Model = ClientsideModel( building.GetBuildingKey( "wall", "Model" ) )
        self.Model:SetNoDraw( true )
        self.NoDraw = false
        self.Color = parent:GetColor()
        self:SetColor( self.Color )
    end
    
    self:SetPos( pos )
    self:SetParent( parent )
	self:SetAngles( ang )
    self:SetHealth( building.GetBuildingKey( "wall", "Health" ) )
    timer.Simple(1, function()
        self:UpdateModel()
    end)
    
end

if SERVER then
    util.AddNetworkString( "SetWallPlummeted" )

    function WALL:Plummet()
        if self.Plummeted then return end
        self.Plummeted = true
        for k,v in pairs(player.GetAll()) do
            net.Start("SetWallPlummeted")
                net.WriteEntity(self:GetParent())
                net.WriteInt(self.index, 8)
                net.WriteBit(true)
            net.Send(v)
        end
        if self.gate and self.gate:IsValid() then
            self.gate.Plummeted = true
        end
        if self:GetParent():IsValid() then
            timer.Simple(0.5, function()
                if self:GetNext() then
                    if !self:GetNext():IsDestroyed() then
                        self:GetNext():Plummet()
                    end
                end
                if self:GetPrev() then
                    if !self:GetPrev():IsDestroyed() then
                        self:GetPrev():Plummet()
                    end
                end
                if self:GetParent().lastWall == self or self:GetParent().firstWall == self then

                    if self:GetParent().lastWall == self and self:GetParent().lastTower and self:GetParent().lastTower:IsValid() then
                        self:GetParent().lastTower:Plummet()
                    end

                    if self:GetParent().firstWall == self and self:GetParent().firstTower and self:GetParent().firstTower:IsValid() then
                        self:GetParent().firstTower:Plummet()
                    end
                end
            end)
            timer.Simple(1, function()
                if self.gate and self.gate:IsValid() then
                    for i,d in pairs(self.gate.HiddenWalls) do
                        if !d:IsDestroyed() then
                            self:GetParent():DestroyWallSegment( d )
                        end
                        d:Plummet()
                    end
                    self.gate:Destroy( building.BUILDING_DESTROY )
                end
                if !self:IsDestroyed() then
                    self:Destroy( building.BUILDING_DESTROY )
                end
            end)
        end
    end
end

function WALL:GetIndex()
    return self.index
end

if( CLIENT ) then
    
    function WALL:SetupNormal()
        local startpos = self:GetPrev() and self:GetPrev():GetPos() or self:GetPos()
        local endpos = self:GetNext() and self:GetNext():GetPos() or self:GetPos()
        self.v_Normal = (endpos - startpos):Angle():Up()
    end
    
    function WALL:GetNormal()
        return self.v_Normal
    end
    
    function WALL:SetPos( pos )
        self.v_Pos = pos
        self.Model:SetPos( pos )
    end

    function WALL:GetPos()
        return self.v_Pos
    end
    
    function WALL:SetAngles( ang )
        self.Model:SetAngles( ang )
    end
    
    function WALL:GetAngles()
        return self.Model:GetAngles()
    end
    
    function WALL:SetParent( p )
        self.Model:SetParent( p )
    end
	
    function WALL:SetColor( c )
        self.Color.r = c.r
        self.Color.g = c.g
        self.Color.b = c.b
        self.Color.a = c.a
        self.Model:SetColor( c )
    end
    
    function WALL:GetColor()
        return self.Color
    end
end

function WALL:IsDestroyed()
    return self.Destroyed
end

local wallHalfWidth = SA.WallWidth * 0.5
local wallHalfLength = SA.WallSpacing * 0.5
local wallHeight = SA.WallHeight
function WALL:GetRandomPosInOBB()
	return self:GetParent():WorldToLocal( self:GetPos() ) + Vector( math.Rand( -wallHalfWidth, wallHalfWidth ), math.Rand( -wallHalfLength, wallHalfLength ), math.Rand( 0, wallHeight ) )
end

function WALL:LocalToWorld(vPos)
    
    local vWorldPos = Vector( vPos.x, vPos.y, vPos.z )
    
    vWorldPos:Rotate(self:GetAngles())
    vWorldPos = vWorldPos + self:GetPos()
    
    return vWorldPos
    
end

function WALL:WorldToLocal(vWorldPos)
    
    local aRot = self:GetAngles()
    local vWorldPos=vWorldPos-self:GetPos()
    vWorldPos:Rotate(Angle(0,-aRot.y,0))
    vWorldPos:Rotate(Angle(-aRot.p,0,0))
    vWorldPos:Rotate(Angle(0,0,-aRot.r))
    return Vector( vWorldPos.x,-vWorldPos.y,vWorldPos.z )
    
end

if( SERVER ) then
    function WALL:Damage( dmginfo )
        
        self:SetHealth( self:GetHealth() - dmginfo.damage )
        Msg( "Wall damaged ", self:GetHealth(), "\n" )
        if( self:GetHealth() <= 0 ) then
            
            self:Destroy( building.BUILDING_DESTROY, dmginfo.attacker:GetEmpire() )
            
        end
        
    end
end

local destroyedWallSegmentModels = {
    "models/props_debris/concrete_debris128Pile001a.mdl",
    "models/props_debris/concrete_debris128Pile001b.mdl"
}

function WALL:Destroy(Info, AttackingEmpire)
    if( self.Destroyed ) then return end
    self.Destroyed = true
    
    if( CLIENT ) then
        if( Info == building.BUILDING_SELL ) then
            local Effect = EffectData()
            CL_DISSOLVE_ENT = self.Model
            Effect:SetEntity(self:GetParent())
            util.Effect("dissolve", Effect, true, true)
            self.NoDraw = true
        elseif( Info == building.BUILDING_DESTROY ) then

            if !self.Plummeted then  
                local Effect = EffectData()
                    Effect:SetOrigin(self:GetPos() + self:GetNormal() * 6)
                    Effect:SetRadius(self.Model:OBBMaxs().z * 0.5)
                    Effect:SetScale(10)
                    Effect:SetMagnitude(GIB_STONE)
                util.Effect("gib_structure", Effect, true, true)
            end
            
            self.Model:SetModel( table.Random( destroyedWallSegmentModels ) )
            self.Model:SetModelScale( 0.085, 0 )
            self.Model:SetColor( color_white )
            self.Model:SetPos( self:GetPos() + self:GetNormal() )
            local ang = self:GetNormal():Angle()
                ang.p = ang.p + 90
            self.Model:SetAngles( ang )
        end
    elseif( SERVER ) then
        if self:GetParent():IsValid() then
            self:GetParent():DestroyWallSegment( self )
            if self:GetParent().DestroyGold then
                if( self:GetParent():GetEmpire() ) then
                    self:GetParent():GetEmpire():AddGold(-self:GetParent().DestroyGold)
                end
                if( ValidEmpire(AttackingEmpire) ) then
                    AttackingEmpire:AddGold(self:GetParent().DestroyGold)
                    AttackingEmpire:AddGold(self:GetParent().DestroyBonus or 8)
                end
            end
        end
    end
    
end

function WALL:UpdateModel()

    if( not IsValid( self.Model ) ) then return end
    if( self:IsDestroyed() ) then return end

    if self:GetNext() == nil then
        nextSegDestroyed = true
        if self.lastTower and self.lastTower:IsValid() and !self.lastTower.Destroyed then
            nextSegDestroyed = nil
        end
    else
        nextSegDestroyed = self:GetNext() and self:GetNext():IsDestroyed()
    end
    if self:GetPrev() == nil then
        prevSegDestroyed = true
        if self.firstTower and self.firstTower:IsValid() and !self.firstTower.Destroyed then
            prevSegDestroyed = nil
        end
    else
        prevSegDestroyed = self:GetPrev() and self:GetPrev():IsDestroyed()
    end
    if( nextSegDestroyed and
        prevSegDestroyed ) then
        self.Model:SetModel( "models/mrgiggles/sassilization/wall_destroyed02.mdl" )
    elseif( nextSegDestroyed ) then
        self.Model:SetModel( "models/mrgiggles/sassilization/wall_destroyed01.mdl" )
    elseif( prevSegDestroyed ) then
        self.Model:SetModel( "models/mrgiggles/sassilization/wall_destroyed01.mdl" )
        local ang = self.Model:GetAngles()
        ang.y = ang.y + 180
        self.Model:SetAngles(ang)
    end

end

function WALL:LocalToWorld(vPos)
    
    local vWorldPos = Vector( vPos.x, vPos.y, vPos.z )
    
    vWorldPos:Rotate(self:GetAngles())
    vWorldPos = vWorldPos + self:GetPos()
    
    return vWorldPos
    
end

function WALL:WorldToLocal(vWorldPos)
    
    local aRot = self:GetAngles()
    local vWorldPos=vWorldPos-self:GetPos()
    vWorldPos:Rotate(Angle(0,-aRot.y,0))
    vWorldPos:Rotate(Angle(-aRot.p,0,0))
    vWorldPos:Rotate(Angle(0,0,-aRot.r))
    return Vector( vWorldPos.x,-vWorldPos.y,vWorldPos.z )
    
end

--WALL SHAPE
local verts = {}
local width, height = 4, 5
table.insert( verts, VECTOR_RIGHT * width )
table.insert( verts, VECTOR_RIGHT * width * 0.9 + VECTOR_UP * height )
table.insert( verts, VECTOR_RIGHT * width * 0.7 + VECTOR_UP * height )
table.insert( verts, VECTOR_RIGHT * width * 0.6 + VECTOR_UP * height * 3 )
table.insert( verts, VECTOR_RIGHT * width * 0.4 + VECTOR_UP * height * 3 )
table.insert( verts, VECTOR_RIGHT * width * 0.4 + VECTOR_UP * height * 2.8 )
table.insert( verts, -VECTOR_RIGHT * width * 0.4 + VECTOR_UP * height * 2.8 )
table.insert( verts, -VECTOR_RIGHT * width * 0.4 + VECTOR_UP * height * 3 )
table.insert( verts, -VECTOR_RIGHT * width * 0.6 + VECTOR_UP * height * 3 )
table.insert( verts, -VECTOR_RIGHT * width * 0.7 + VECTOR_UP * height )
table.insert( verts, -VECTOR_RIGHT * width * 0.9 + VECTOR_UP * height )
table.insert( verts, -VECTOR_RIGHT * width )
--END WALL SHAPE

local function addPoint( strip, i, pos, norm, tang, v )
    
    local scale = 20
    
    local u = pos:Dot( tang )
    
    strip[ i ] = Vertex( pos, u / scale, v, norm )
    
end

function WALL:AddStrip( Positions, v, v1, v2 )
    
    local strip = {}
    local j = 1;
    local norm, tang;
    
    for i = 1, #Positions do
        
        local pos = self:WorldToLocal( Positions[ i ] )
        tang = (verts[ v+1 ] - verts[ v ]):GetNormal()
        norm = -VECTOR_FORWARD:Cross( tang )
        tang = VECTOR_FORWARD
        
        addPoint( strip, j, pos + verts[ v+1 ], norm, tang, v2 )
        j = j + 1;
        addPoint( strip, j, pos + verts[ v ], norm, tang, v1 )
        j = j + 1;
        
    end
    
    table.insert( self.TriangleStrips, strip )
    
end

function WALL:CreateWallMesh( Positions )
    
    self.TriangleStrips = self.TriangleStrips or {}
    
    local num = #Positions
    self.StripCount = num
    
    --Get rid of extra baggage (Instead of creating a new table, we're going to reuse the old one)
    if( num < #self.TriangleStrips ) then
        
        for i=num + 1, #self.TriangleStrips do
            self.TriangleStrips[ i ] = nil
        end
        
    end
    
    --Wall Direction Normal
    local pos1 = Positions[ 1 ]
    local pos2 = Positions[ num ]
    self:SetPos( pos1:MidPoint( pos2 ) )
    self:SetAngles( Angle( 0, math.atan2( (pos2.y - pos1.y), (pos2.x - pos1.x) ) * 180 / math.pi, 0 ) )
    
    --Build Strips
    --There's a stupid bug with meshes where the depth test fails.  Any surface that's infront of another surface must be drawn first or
    --it will show through the other surface
    self:AddStrip( Positions, 10, 0.6640625, 0.6210937 ) --Metal sidebar
    self:AddStrip( Positions, 02, 0.6640625, 0.6210937 ) --Metal sidebar
    self:AddStrip( Positions, 06, 0.1562500, 0.0000000 ) --Top walkway
    self:AddStrip( Positions, 03, 0.5468750, 0.1640625 )
    self:AddStrip( Positions, 04, 0.2109375, 0.1640625 )
    self:AddStrip( Positions, 05, 0.2617187, 0.2109375 )
    self:AddStrip( Positions, 07, 0.2617187, 0.2109375 )
    self:AddStrip( Positions, 08, 0.2109375, 0.1640625 )
    self:AddStrip( Positions, 09, 0.5468750, 0.1640625 )
    self:AddStrip( Positions, 11, 1.0000000, 0.6210937 )
    self:AddStrip( Positions, 01, 1.0000000, 0.6210937 )
    
end

function WALL:GetMeshOBB()
    local min = Vector(999999, 999999, 999999)
    local max = Vector(0)
    for i, strip in ipairs( self.TriangleStrips ) do
        for j, vert in ipairs( strip ) do
            min.x = math.min( vert.pos.x, min.x )
            min.y = math.min( vert.pos.y, min.y )
            min.z = math.min( vert.pos.z, min.z )
            max.x = math.max( vert.pos.x, max.x )
            max.y = math.max( vert.pos.y, max.y )
            max.z = math.max( vert.pos.z, max.z )
        end
    end
    return min, max
end

if( CLIENT ) then
    WALL.WallMaterial = Material( "sassilization/wall" )
end

function WALL:Compile()
    local mesh = Mesh()
    local tblTriangles = {}
    
    local iTriCount = (#self.positions - 1) * 2
    for _, tblStrip in ipairs( self.TriangleStrips ) do
        for i = 1, iTriCount do
            local iIdx0 = 1 + math.floor(i / 2) * 2
            local iIdx1 = math.ceil( i / 2) * 2
            local iIdx2 = 2 + i
            
            --if _ == 3 then
            --    MsgN(iIdx0, iIdx1, iIdx2)
            --end
            
            tblTriangles[#tblTriangles + 1] = tblStrip[iIdx0]
            tblTriangles[#tblTriangles + 1] = tblStrip[iIdx1]
            tblTriangles[#tblTriangles + 1] = tblStrip[iIdx2]
        end
    end
    
    --MsgN("TriCount: ", #tblTriangles, " : ", #tblTriangles / 3, "\n")
    mesh:BuildFromTriangles(tblTriangles)
    return mesh
end

function WALL:Draw()
    
    if( self.TriangleStrips ) then
        local matrix = Matrix()
        local r, g, b, a = self:GetColor()
        matrix:SetTranslation(self:GetPos())
        matrix:Rotate(self:GetAngles())
        render.SetMaterial( self.WallMaterial );
        
        -- local sun = util.GetSunInfo()
        -- if( not sun ) then return end
        
        cam.PushModelMatrix(matrix)
            
            for i, strip in ipairs( self.TriangleStrips ) do
                
                mesh.Begin( MATERIAL_TRIANGLE_STRIP, (self.StripCount - 1) * 2)
                    
                    for j, vert in ipairs( strip ) do
                        
                        -- local lightc = render.GetLightColor( self:LocalToWorld(vert.pos) + VECTOR_UP * 6 ) * 1.7
                        -- lightc = lightc * ((self:LocalToWorld(vert.normal) - self:GetPos()):Dot( sun.direction ) * 0.15 + 0.65)
                        -- mesh.Color( math.Clamp( lightc.x * r, 0, 255 ), math.Clamp( lightc.y * g, 0, 255 ), math.Clamp( lightc.z * b, 0, 255 ), 255 )
                        mesh.Position( vert.pos )
                        mesh.Normal( vert.normal )
                        mesh.TexCoord( 0, vert.u, vert.v )
                        mesh.AdvanceVertex()
                        
                        if( j == self.StripCount * 2 ) then
                            break
                        end
                        
                    end
                    
                mesh.End()
                
            end
            
        cam.PopModelMatrix()
        
    end
    
end