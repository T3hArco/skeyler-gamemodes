----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

EFFECT.RenderGroup	= RENDERGROUP_BOTH
local WallModel 	= NULL

function EFFECT:Init()
	
	if( WallModel == NULL ) then
		MsgN("Creating WallModel")
		WallModel = ClientsideModel( building.GetBuildingKey( "wall", "Model" ) )
		WallModel:SetNoDraw( true )
		WallModel:SetRenderMode( RENDERMODE_TRANSALPHA )
	end

	if(GHOST_WALL_EFFECT) then
		self:SetModel( "models/mrgiggles/sassilization/brick_small.mdl" )
		self:SetSolid( SOLID_NONE )
		self.Color = LocalEmpire():GetColor()
		self:SetNoDraw( true )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self.Alive = true
		GHOST_WALL_EFFECT = self
	else return end
	
end

function EFFECT:Think()
	
	return self.Alive
	
end

function EFFECT:CreateWallMesh( Positions )
	
	self.Walls = self.Walls or {}
	
	local num = #Positions
	self.WallCount = num
--	MsgN(num)
	--Get rid of extra baggage (Instead of creating a new table, we're going to reuse the old one)
	if( num < #self.Walls ) then
		
		for i=num + 1, #self.Walls do
			
			self.Walls[ i ] = nil
			
		end
		
	end
	
	--Wall Direction Normal
	local pos1 = Positions[ 1 ]
	local pos2 = Positions[ num ]
	local ang = Angle( 0, math.atan2( (pos2.y - pos1.y), (pos2.x - pos1.x) ) * 180 / math.pi, 0 )
	self:SetPos( pos1:MidPoint( pos2 ) )
	self:SetAngles( ang )
	ang:RotateAroundAxis( ang:Up(), 90 )
	
	--Build Walls
	for i = 1, num do
		
		local wall = self.Walls[ i ] or {}
		wall.pos = Positions[ i ]
		wall.ang = ang
		WallModel:SetPos( wall.pos )
		WallModel:SetAngles( wall.ang )
		WallModel:SetupBones()
		wall.mins, wall.maxs = WallModel:GetRenderBounds()
		self.Walls[ i ] = wall
		
	end
	
	--Update Bounds
	local mins, maxs = self:GetMeshOBB()
	self:SetRenderBounds( mins, maxs )
	
end

function EFFECT:GetMeshOBB()
	local min = Vector(999999, 999999, 999999)
	local max = Vector(0)
	for i = 1, self.WallCount do
		local mins, maxs = self.Walls[ i ].mins, self.Walls[ i ].maxs
		min.x = math.min( mins.x, min.x )
		min.y = math.min( mins.y, min.y )
		min.z = math.min( mins.z, min.z )
		max.x = math.max( maxs.x, max.x )
		max.y = math.max( maxs.y, max.y )
		max.z = math.max( maxs.z, max.z )
	end
	return min, max
end

function EFFECT:Render()
	
	if( self.Walls ) then
		
		--render.SetColorModulation( self.Color.r / 255, self.Color.g / 255, self.Color.b / 255 )
		WallModel:SetColor( self.Color )
		for _, wall in pairs( self.Walls ) do
			
			WallModel:SetPos( wall.pos )
			WallModel:SetAngles( wall.ang )
			WallModel:SetupBones()

			WallModel:DrawModel()
			
		end
		
		--render.SetColorModulation( 1, 1, 1 )
		
	end
	
end