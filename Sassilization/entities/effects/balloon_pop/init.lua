function EFFECT:Init( data )

	local vOffset = data:GetOrigin()
	local Col = data:GetStart()
	
	sound.Play( "weapons/ar2/npc_ar2_altfire.wav", vOffset, 160, 130 )

	local Low = vOffset - Vector(32, 32, 32 )
	local High = vOffset + Vector(32, 32, 32 )
	
	local NumParticles = 16

	local emitter = ParticleEmitter( vOffset, true )

	for i=0, NumParticles do

		local Pos = Vector( math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1) )

		local particle = emitter:Add( "particles/balloon_bit", vOffset + Pos * 8 )
		if (particle) then

			particle:SetVelocity( Pos * 400 )

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 5 )

			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )

			local Size = math.Rand( 1, 3 )
			particle:SetStartSize( Size )
			particle:SetEndSize( Size )

			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-2, 2) )

			particle:SetAirResistance( 400 )
			particle:SetGravity( Vector(0,0,-300) )

			local RandDarkness = math.Rand( 0.8, 1.0 )
			Col.r = Col.r * RandDarkness
			Col.g = Col.g * RandDarkness
			Col.b = Col.b * RandDarkness
			
			particle:SetColor( Col )

			particle:SetCollide( true )

			particle:SetAngleVelocity( Angle( math.Rand( -160, 160 ), math.Rand( -160, 160 ), math.Rand( -160, 160 ) ) ) 

			particle:SetBounce( 1 )
			particle:SetLighting( true )

		end

	end

	emitter:Finish()

end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end