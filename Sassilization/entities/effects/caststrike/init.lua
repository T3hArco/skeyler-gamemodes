-- Example Here 
/*
local effectdata = EffectData()
effectdata:SetStart	(self.Entity:GetPos()+  self.Entity:GetUp() * math.Rand(10, 230) +  self.Entity:GetRight() * 50 + self.Entity:GetForward() * math.Rand(-40,50))
effectdata:SetOrigin(self.Entity:GetPos()+  self.Entity:GetUp() * 30)
effectdata:SetEntity(self.Entity)
effectdata:SetAttachment( 1 )
effectdata:SetScale(16)
util.Effect( "storm_strike", effectdata ) 
*/


EFFECT.Mat = Material( "effects/tool_tracer" )

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Position = data:GetStart()			-- position passes, well duh, position
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Scale = data:GetScale()			-- use scale to pass radius
	self.Magnitude = data:GetMagnitude()	-- use magnitude to pass bomb lifespan
	
	self.LifeSpan = CurTime() + self.Magnitude
	
	-- Keep the start and end pos - we're going to interpolate between them
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()
	
	self.Alpha = 400

end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	self.Alpha = self.Alpha - FrameTime() * 960
	
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	if (self.Alpha < 0) then return false end
	return true

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	if ( self.Alpha < 1 ) then return end
	
	
		
	-- setup our variables
	local start_pos = self.StartPos
	local end_pos = self.EndPos
	local dir = ( self.EndPos - self.StartPos );
	local increment = dir:Length() / 12;
	local c = self.WeaponEnt:GetColor()
		c.a = 255
	dir:Normalize();
	
	-- set material
	render.SetMaterial(Material("trails/smoke"));
	
	-- start the beam with 14 points
	render.StartBeam( 14 );
	
	-- add start
	render.AddBeam(
		start_pos,				-- Start position
		self.Scale,					-- Width
		CurTime(),				-- Texture coordinate
		c		-- Color
	);
	
	--
	local i;
	for i = 1, 12 do
		
		local Arch = math.sin(math.rad(i * 15)) * (increment * 3 + math.random(1,18))
		local point = ( start_pos + dir * ( i * increment ) ) + Vector(math.random(1,18),math.random(1,18),Arch);

		-- texture coords
		local tcoord = CurTime() + ( 1 / 12 ) * i;
		
		-- add point
		render.AddBeam(
			point,
			self.Scale / 12 * i,
			tcoord,
			c
		);
		
	end
	
	-- add the last point
	render.AddBeam(
		end_pos,
		1,
		CurTime() + 1,
		c
	);
	
	-- finish up the beam
	render.EndBeam();
	
end
