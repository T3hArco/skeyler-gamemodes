----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local pcall = pcall
local ipairs = ipairs

hook.Add("PostDrawTranslucentRenderables", "unit.RenderUnits", function()
	local ok, err = true
	
	local unitsToDraw = {}
	local count = 1
	for _, unit in ipairs( unit.GetAll() ) do
		if( unit:ShouldDraw() ) then
			unitsToDraw[count] = unit
			count = count + 1
		end
	end
	
	ok, err = pcall( DrawUnitCircles, unitsToDraw )
	
	if not ok then
		ErrorNoHalt("Error DrawUnitcircles: ", err, "\n")
	end
	
	for _, u in ipairs( unitsToDraw ) do
			ok, err = pcall(u.Draw, u)
	end
	
	if not ok then
		ErrorNoHalt("Error unit.Draw: ", err, "\n")
	end
end)

local function RunSequence( Model, Anim )
	
	if(Model.Anim ~= Anim) then
		if(RealTime() < Model.NextAnim) then return end
		local Sequence = Model:LookupSequence(Anim)
		if(Sequence >= 0) then
			Model.Anim = Anim
			Model:SetCycle(0)
			Model:SetSequence(Sequence)
		else
			ErrorNoHalt("Invalid Sequence | ", Anim, "\n")
		end
	end
end

local CircleModel = ClientsideModel( "models/sassilization/flatcircle.mdl" )
CircleModel:SetNoDraw( true )
local CircleModelScale = Vector( 1, 1, 1 )

MaterialWhite = CreateMaterial( "WhiteMaterial1", "VertexLitGeneric", {
    ["$basetexture"] = "color/white",
    ["$vertexalpha"] = "1",
    ["$model"] = "1",
} )

function DrawUnitCircles( units )
	local time = RealTime()
	local offset = math.sin( time * 4 )
	local unit
	local count = #units
	
	--TODO: Cull the units table and only draw for units which are visible
	
	render.SetStencilEnable( true )
	render.ClearStencil()
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilReferenceValue( 4 )
	render.SetStencilWriteMask( 0 )
	
	render.SetBlend( 0 )
	render.MaterialOverride( MaterialWhite )
	
	for i = 1, count do
		unit = units[i]
		
		if (unit.PreviewSelect) then
			CircleModel:SetPos( unit:GetGroundPos() + VECTOR_UP * 0.1 )
			
			local ang = unit:GetGroundNormal():Angle()
			
			ang.p = ang.p + 90
			
			CircleModel:SetAngles(ang)

			local mat = Matrix()
			mat:Scale( CircleModelScale * unit.Size * 1.05 )
			CircleModel:EnableMatrix( "RenderMultiply", mat )
		
			CircleModel:SetupBones()
			CircleModel:DrawModel()
		end
	end
	
	render.MaterialOverride()
	render.SetBlend( 1 )
	
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilTestMask( 4 )
	
	for i = 1, count do
		
		unit = units[i]
		if(unit.PreviewSelect) then
			unit:DrawPreviewCircle( unit:GetGroundPos(), time, offset )
		end
		
	end
	
	render.ClearStencil()
	render.SetStencilEnable( true )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilReferenceValue( 4 )
	render.SetStencilWriteMask( 4 )
	
	render.SetBlend( 0 )
	render.MaterialOverride( MaterialWhite )
	
	for i = 1, count do
		unit = units[i]
		
		if (unit:GetSelected()) then
			CircleModel:SetPos( unit:GetGroundPos() + VECTOR_UP * 0.1 )
			
			local ang = unit:GetGroundNormal():Angle()
			
			ang.p = ang.p + 90
			
			CircleModel:SetAngles( ang )

			local mat = Matrix()
			mat:Scale( CircleModelScale * unit.Size * 0.7 )
			CircleModel:EnableMatrix( "RenderMultiply", mat )
	
			CircleModel:SetupBones()
			CircleModel:DrawModel()
		end
	end
	
	render.MaterialOverride()
	render.SetBlend( 1 )
	
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilTestMask( 4 )
	
	for i = 1, count do
		
		unit = units[i]
		if(unit:GetSelected()) then
			
			unit:DrawSelectedCircle( unit:GetGroundPos() )
			
		end
		
	end

	render.SetStencilEnable( false )
	
	for i = 1, count do
		units[i]:DrawCircle()
	end
end

hook.Add("RenderScene", "unit.SetupDrawableUnits", function()
	
	local units = unit.GetAll()
	local count = #units
	
	for i=1, count do
		
		units[i].b_ShouldDraw = false
		
	end
	
end )

-- local function PostDrawUnits()

	-- local ok, err = true
	
	-- for _, unit in ipairs( unit.GetAll() ) do
		
		-- if( unit:ShouldDraw() ) then
			-- ok, err = pcall(unit.PostDraw, unit)
			-- unit.b_ShouldDraw = false
		-- end
		
		-- if not ok then
			-- ErrorNoHalt(err, "\n")
		-- end
		
	-- end
	
-- end
-- hook.Add("PostDrawOpaqueRenderables", "unit.PostDrawUnits", PostDrawUnits)

local function RenderScene()
	-- local time = CurTime()
	local ft = FrameTime()
	local SAUnit = Unit
	for id, Unit in ipairs(unit.GetAll()) do
		if( SAUnit:ValidUnit( Unit ) and IsValid(Unit.Entity) ) then
			RunSequence(Unit.Entity, Unit.Anim)
			Unit.Entity:FrameAdvance( ft )
			Unit.Entity:SetRenderOrigin( Unit:GetPos() )
			if( Unit:IsNetworked() ) then
				
				-- Unit.lastRender = Unit.lastRender or time
				-- local dt = Unit.lastRender - time
				-- if( Unit.lastPos and Unit.lastPos ~= Unit:GetHullPos() ) then
					Unit:SetPos( Lerp( 0.15, Unit:GetPos(), Unit:GetHullPos() - Unit.RenderOrigin ) )
					-- Unit:SetPos( Unit:GetHullPos() - Unit.RenderOrigin )

					Unit:SetAngles(Unit:GetDirAng())
					-- Unit.lastPos = Unit:GetHullPos()
				-- else
					-- Unit.lastPos = Unit:GetHullPos()
					-- Unit:SetPos( Lerp( 0.05, Unit:GetPos(), Unit:GetHullPos() - Unit.RenderOrigin ) )
					-- Unit:SetPos( Unit:GetHullPos() - Unit.RenderOrigin )
					-- Unit:SetAngles( Unit:GetDirAng() )
				-- end
				
				local vel = Unit:GetVelocity()
				Unit:SetPos( Unit:GetPos() + vel * dt )
				
				vel.z = 0
				
				local len = vel:Length()
				
				if (Unit.Jumping) then
					Unit.Anim = "jump"
					Unit.Entity:SetPlaybackRate( 1 )
				else
					if ( len > 1 ) then
						Unit.Anim = Unit:GetMoveAnim()
						Unit.Entity:SetPlaybackRate( len / 30 )
					else
						Unit.Anim = "idle"
						Unit.Entity:SetPlaybackRate( 1 )
					end
				end
				
				-- Unit.lastRender = time
				
			end
		end
	end
end

hook.Add( "RenderScene", "unit.RenderScene", function()

	local ok, err = pcall(RenderScene)
	
	if not ok then
		ErrorNoHalt(err, "\n")
	end
	
end )