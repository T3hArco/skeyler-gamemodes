--taken from my Berserker Pack, which was taken from GMDM

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/

	
function EFFECT:Init(data)
	
	self.LifeTime = 5
	
	local pos = data:GetOrigin()
	
	local trace = {}
	trace.start = pos
	trace.endpos = pos + VECTOR_UP * - 30
	trace.mask = MASK_SOLID_BRUSHONLY
	local tr = util.TraceLine( trace )
	if( tr.HitWorld ) then
		util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
	end
	
	local emitter = ParticleEmitter( pos )
	
		local particle = emitter:Add( "effects/blood_core", pos )
			particle:SetVelocity( data:GetNormal() * math.Rand( 5, 20 ) )
			particle:SetDieTime( math.Rand( 1.0, 2.0 ) )
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( math.Rand( 16, 32 ) )
			particle:SetEndSize( math.Rand( 8, 16 ) )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetColor( 40, 0, 0 )
				
	emitter:Finish()

end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )
	
	self.LifeTime = self.LifeTime - .01
	return (self.LifeTime > 0)
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render() end



