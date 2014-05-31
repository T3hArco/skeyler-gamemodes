local dusties = {"one","two"}

local matRefract = Material( "models/spawn_effect" )
local matLight	 = Material( "models/spawn_effect2" )

function EFFECT:Init(data)
	
	local ent = data:GetEntity()
	if not ent or not ent:IsValid() then 
		Msg( "Rivera effect failed, entity does not exists ", ent, "\n" )
		return
	end
	
	local Pos = data:GetOrigin() + Vector( 0, 0, 8 )
	local Norm = data:GetNormal()
	local DieTime = data:GetMagnitude() + CurTime()
	
	self.LifeTime = DieTime
	self.Time = DieTime - ent.StartBuildTime
	
	self.ParentEntity = ent
	self:SetModel( ent:GetModel() )	
	self:SetPos( ent:GetPos() )
	self:SetAngles( ent:GetAngles() )
	self:SetColor( color_white )
	self:SetNoDraw( false )
	self:SetParent( ent )
	
	self.ParentEntity.RenderOverride = self.RenderParent
	self.ParentEntity.SpawnEffect = self
	
	self.Col = ent:GetColor()
	self.Col.a = 100
	
	local LightColor = render.GetLightColor(Pos) * 255
		LightColor.r = math.Clamp( LightColor.r, 70, 255 )
		
	self.emitter = ParticleEmitter(Pos)
		local particle = self.emitter:Add("jaanus/build_sprites/dust_"..dusties[math.random(1,2)], Pos)
		particle:SetVelocity(Norm)
		particle:SetDieTime(math.Rand(1.0, 2.0))
		particle:SetStartAlpha(255)
		particle:SetStartSize(math.Rand( 16, 32))
		particle:SetEndSize(math.Rand( 32, 64))
		particle:SetRoll(math.Rand( 0, 360))
		particle:SetColor( self.Col.r, self.Col.g, self.Col.b )
	
end

function EFFECT:Think()
	
	if ( not self.ParentEntity or not self.ParentEntity:IsValid()) then
		self:CleanUp()
		return false
	end
	
	if self.LifeTime < CurTime() or self.ParentEntity:IsBuilt() then
		self:CleanUp()
		return false
	end
	
	return true
	
end

local RandPos = Vector(0)
local RandVel = Vector(-6)

function EFFECT:Render()
	
	self.lastRender = self.lastRender or CurTime()
	if( self.lastRender > CurTime() ) then return end
	self.lastRender = CurTime() + 0.05
	
	RandPos.x = math.Rand(-16,16)
	RandPos.y = math.Rand(-16,16)
	local particle = self.emitter:Add("jaanus/build_sprites/dust_"..dusties[math.random(1,2)], self:GetPos() + RandPos)
	if particle then
		RandVel.x = math.Rand(-15, 15)
		RandVel.y = math.Rand(-15, 15)
		particle:SetVelocity(RandVel)
		particle:SetDieTime(1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(10)
		particle:SetEndSize(0)
		particle:SetColor( self.Col.r, self.Col.g, self.Col.b, 255 )
	end
	
end

function EFFECT:CleanUp()
	if( self.emitter ) then
		self.emitter:Finish()
	end
	if( self.ParentEntity ) then
		self.ParentEntity.StartBuildTime = nil
		self.ParentEntity.RenderOverride = nil
		self.ParentEntity.SpawnEffect = nil
	end
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:RenderOverlay( entity )
	
	local Fraction = (self.LifeTime - CurTime()) / self.Time
	local ColFrac = (Fraction-0.5) * 2
	
	Fraction = math.Clamp( Fraction, 0, 1 )
	ColFrac =  math.Clamp( ColFrac, 0, 1 )
	
	// Change our model's alpha so the texture will fade out
	//entity:SetColor( 255, 255, 255, 1 + 254 * (ColFrac) )
	
	// Place the camera a tiny bit closer to the entity.
	// It will draw a big bigger and we will skip any z buffer problems
	local EyeNormal = entity:GetPos() - EyePos()
	local Distance = EyeNormal:Length()
	EyeNormal:Normalize()
	
	local Pos = EyePos() + EyeNormal * Distance * 0.01
	
	// Start the new 3d camera position
	-- local bClipping = self:StartClip( entity, 1.2 )
	cam.Start3D( Pos, EyeAngles() )
		
		// If our card is DX8 or above draw the refraction effect
		if ( render.GetDXLevel() >= 80 ) then
			
			// Update the refraction texture with whatever is drawn right now
			render.UpdateRefractTexture()
			
			matRefract:SetFloat( "$refractamount", Fraction * 0.01 )
			
			// Draw model with refraction texture
			render.MaterialOverride( matRefract )
				entity:DrawBuilding()
			render.MaterialOverride( 0 )
			
		end
	
	// Set the camera back to how it was
	cam.End3D()
	-- render.PopCustomClipPlane()
	-- render.EnableClipping( bClipping )
	
end

RiveraWhite = Material( "models/shadertest/shader3" )

function EFFECT:RenderParent()
	
	local bClipping, normal, dis, lerped = self.SpawnEffect:StartClip( self, 1 )
		--[[
		render.SetStencilEnable( true )
			
			render.SetStencilFailOperation( STENCILOPERATION_ZERO )
			render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
			render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
			render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
			render.SetStencilReferenceValue( 1 )
			render.SetStencilWriteMask( 5 )
			
			render.SetBlend( 0 )
				
				render.CullMode( MATERIAL_CULLMODE_CW )
					cam.IgnoreZ( true )
						self:DrawBuilding()
					cam.IgnoreZ( false )
				render.CullMode( MATERIAL_CULLMODE_CCW )
				-- render.EnableClipping( false )
					-- self:DrawBuilding()
				-- render.EnableClipping( true )
				
				-- render.SetStencilPassOperation( STENCILOPERATION_ZERO )
				-- render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
				
				-- render.CullMode( MATERIAL_CULLMODE_CW )
					-- cam.IgnoreZ( true )
						-- self:DrawBuilding()
					-- cam.IgnoreZ( false )
				-- render.CullMode( MATERIAL_CULLMODE_CCW )
				
			render.SetBlend( 1 )
			
		render.SetStencilEnable( false )
		]]
		
		self:DrawBuilding()
		
	render.PopCustomClipPlane()
	render.PushCustomClipPlane(normal * -1, dis * -1)
		-- render.CullMode( MATERIAL_CULLMODE_CW )
		render.MaterialOverride( RiveraWhite )
			-- cam.IgnoreZ( true )
				self:DrawBuilding()
			-- cam.IgnoreZ( false )
		render.MaterialOverride( 0 )
		-- render.CullMode( MATERIAL_CULLMODE_CCW )
		
	render.PopCustomClipPlane()
	render.EnableClipping( bClipping )
	
	self.SpawnEffect:RenderOverlay( self )
	
	--[[
	render.SetStencilEnable( true )
		
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.SetStencilPassOperation( STENCILOPERATION_KEEP )
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilReferenceValue( 1 )
		render.SetStencilTestMask( 5 )
		
		-- render.EnableClipping( false )
			
			-- cam.IgnoreZ( true )
				render.SetMaterial( RiveraWhite )
				-- render.DrawQuadEasy( lerped, self:GetUp(), 128, 128, color_white, 45 )
				render.DrawScreenQuad()
			-- cam.IgnoreZ( false )
			
		-- render.EnableClipping( true )
		
	render.SetStencilEnable( false )
	]]
	
end

function EFFECT:StartClip( model, spd )
	
	local mn, mx = 0, model:OBBMaxs().z
	local Up = model:GetUp() * -1
	local Bottom =  model:GetPos() + Vector( 0, 0, mn )
	local Top = model:GetPos() + Vector( 0, 0, mx )
	
	local Fraction = (self.LifeTime - CurTime()) / self.Time
	Fraction = math.Clamp( Fraction / spd, 0, 1 )
	
	local Lerped = LerpVector( Fraction, Top, Bottom )
	
	local normal = Up 
	local distance = normal:Dot( Lerped )
	
	local bEnabled = render.EnableClipping( true )
	render.PushCustomClipPlane( normal, distance )
	
	return bEnabled, normal, distance, Lerped
	
end