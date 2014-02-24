----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

EFFECT.RenderGroup     = RENDERGROUP_BOTH

function EFFECT:Init()
	
	if(GHOST_WALL_EFFECT) then
		self:SetModel( "models/mrgiggles/sassilization/brick_small.mdl" )
		self:SetSolid( SOLID_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self.Alive = true
		GHOST_WALL_EFFECT = self
	else return end
	
end

function EFFECT:Think()
	
	return self.Alive
	
end

local function addPoint( strip, i, pos, norm, tang, v )
	
	local scale = 20
	
	local u = pos:Dot( tang )
	
	strip[ i ] = Vertex( pos, u / scale, v, norm )
	
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

function EFFECT:AddStrip( Positions, v, v1, v2 )
	
	local strip = self.TriangleStrips[ v ] or {}
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
	
	self.TriangleStrips[ v ] = strip
	
end

function EFFECT:CreateWallMesh( Positions )
	
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
	self:AddStrip( Positions, 01, 1.0000000, 0.6250000 )
	self:AddStrip( Positions, 02, 0.6640625, 0.6250000 )
	self:AddStrip( Positions, 03, 0.5468750, 0.1640625 )
	self:AddStrip( Positions, 04, 0.2109375, 0.1640625 )
	self:AddStrip( Positions, 05, 0.2617187, 0.2109375 )
	self:AddStrip( Positions, 06, 0.1562500, 0.0000000 )
	self:AddStrip( Positions, 07, 0.2617187, 0.2109375 )
	self:AddStrip( Positions, 08, 0.2109375, 0.1640625 )
	self:AddStrip( Positions, 09, 0.5468750, 0.1640625 )
	self:AddStrip( Positions, 10, 0.6640625, 0.6250000 )
	self:AddStrip( Positions, 11, 1.0000000, 0.6250000 )
	
	--Update Bounds
	local mins, maxs = self:GetMeshOBB()
	self:SetRenderBounds( mins, maxs )
	
end

function EFFECT:GetMeshOBB()
	local min = Vector(999999, 999999, 999999)
	local max = Vector()
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

local WallMaterial = Material( "sassilization/wall" )

function EFFECT:Render()
	
	if( self.TriangleStrips ) then
		
		local matrix = Matrix()
		local r, g, b, a;
		matrix:SetTranslation(self:GetPos())
		matrix:Rotate(self:GetAngles())
		render.SetMaterial( WallMaterial );
		
		local sun = util.GetSunInfo()
		if( not sun ) then return end
		
		cam.PushModelMatrix(matrix)
			
			for i, strip in ipairs( self.TriangleStrips ) do
				
				mesh.Begin( MATERIAL_TRIANGLE_STRIP, (self.StripCount - 1) * 2 )
					
					for j, vert in ipairs( strip ) do
						
						local lightc = render.GetLightColor( self:LocalToWorld(vert.pos) + VECTOR_UP * 6 ) * 2
						lightc = lightc * ((self:LocalToWorld(vert.normal) - self:GetPos()):Dot( sun.direction ) * 0.25 + 0.75) * 255
						mesh.Color( math.Clamp( lightc.x, 0, 255 ), math.Clamp( lightc.y, 0, 255 ), math.Clamp( lightc.z, 0, 255 ), 150 )
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