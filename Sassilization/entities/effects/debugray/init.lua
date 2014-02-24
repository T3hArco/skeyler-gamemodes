local laserMat = Material( "cable/blue_elec" )
local glowSpr = Material( "effects/energyball" )

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Position = data:GetOrigin()
	self.Direction = data:GetStart():GetNormal()
	self.Magnitude = data:GetMagnitude()
	
	self.LifeSpan = CurTime() + self.Magnitude
	
	self.Entity:SetRenderBoundsWS( self.Position, self.Position + self.Direction * 100 )
	
	self.Alpha = 255
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	
	self.Alpha = self.Alpha - FrameTime() * 120
	
	if (self.Alpha < 0) then return false end
	return true

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	if ( self.Alpha < 1 ) then return end
	
	-- set material
	
	for i=0, self.Magnitude do
		
		render.SetMaterial( laserMat );
		
		render.DrawBeam( self.Position, self.Position + self.Direction * 100, 4, 0, 0, Color( 255, 255, 255, 255 ) )
		
		render.SetMaterial( glowSpr );
		
		render.DrawSprite( self.Position, 4, 4, Color( 255, 255, 255, 255 ) )
		
	end
	
end
