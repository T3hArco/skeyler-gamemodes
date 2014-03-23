--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

GM.SelectionPoints = {}
GM.SelectionSubZ = Vector(0, 0, 500)
GM.SelectionColor = Color(255, 0, 0, 60)
GM.SelectionMat = Material("cable/redlaser")

local maxDiam = 200

function GM:StartSelection(Pos)
	
	if( not LocalEmpire() ) then return end
	
	self.StartPos = Pos
	self.Selecting = true
	
	if( not self.SelectionSphere ) then
		self.SelectionSphere = ClientsideModel( "models/sassilization/viewtools/debug_sphere.mdl" )
		self.SelectionSphere:SetNoDraw( true )
	end
	
end

function GM:PreviewSelection()
	
	self:ClearPreviewSelection()
	
	self.PreviewSelect = {}
	local count = 1
	
	for i, unit in ipairs( unit.FindInSphere( self.Center, self.Diameter * 0.6 ) ) do
		
		if( unit:GetEmpire() == LocalEmpire() ) then
			
			local dist = unit:GetPos():Distance( self.Center )
			if( dist - unit.Size * 0.5 < self.Diameter * 0.5 ) then
				
				unit.PreviewSelect = true
				self.PreviewSelect[ count ] = unit
				count = count + 1	
			end
			
		end
		
	end
	
	if( input.IsKeyDown( KEY_LSHIFT ) ) then
		
		for unit, _ in pairs( LocalEmpire():GetSelectedUnits() ) do
			
			unit.PreviewSelect = true
			self.PreviewSelect[ count ] = unit
			count = count + 1
			
		end
		
	end
	
end

function GM:ClearPreviewSelection()
	
	if( not self.PreviewSelect ) then return end
	
	for _, unit in ipairs( self.PreviewSelect ) do
		
		if( unit ) then
			
			unit.PreviewSelect = false
			
		end
		
	end
	
	self.PreviewSelect = false
	
end

function GM:EndSelection()

	if !(GAMEMODE.Selecting) then return end
	
	if( not LocalEmpire() ) then return end
	
	if(self.StartPos and self.EndPos) then
		
		--local bAdd = input.IsKeyDown( KEY_LSHIFT ) and 1 or 0
		-- if( not bAdd ) then
			RunConsoleCommand("sa_deselect_units")
			LocalEmpire():DeselectAllUnits()
		-- end
		
		local unitSelectCount, unit = #self.PreviewSelect
		if( unitSelectCount > 0 ) then
			local unitSelectIndex = 1
			while( unitSelectIndex - 1 < unitSelectCount ) do
				local selection = {}
				for i = 1, math.min( 7, unitSelectCount - unitSelectIndex + 1 ) do
					unit = self.PreviewSelect[ unitSelectIndex ]
					if( Unit:ValidUnit( unit ) ) then
						unit:Select( true )
						table.insert( selection, unit:UnitIndex() )
					end
					unitSelectIndex = unitSelectIndex + 1
				end
				RunConsoleCommand("sa_select", unpack( selection ) )
			end
		end
		surface.PlaySound( SA.Sounds.SelectSound )
	end
	
	
	self.StartPos = false
	self.EndPos = false
	self.Selecting = false
	self:ClearPreviewSelection()

	GAMEMODE.Selecting = false
	
end

local deg_to_rad = math.pi/180;

local function getSelectable( ent )
	
	if( ent:IsUnit() and Unit:ValidUnit( ent:GetUnit() ) ) then
		return ent:GetUnit()
	end
	
	return false --TODO: Maybe return buildings?
	
end

function GM:UpdateSelection()
	
	if(not self.StartPos) then
		return
	end
	
	if( self.Selecting ) then
		local Trace = {}
		Trace.start = LocalPlayer():GetShootPos()
		Trace.endpos = Trace.start + (LocalPlayer():GetAimVector() * 4096)
		Trace.mask = MASK_SOLID_BRUSHONLY
		local tr = util.TraceLine(Trace)
		
		if(not tr.Hit or tr.HitSky) then
			return
		end
		
		self.EndPos = tr.HitPos
		self.Diameter = math.min( self.StartPos:Distance(self.EndPos), maxDiam );
		self.Center = self.StartPos + self.Diameter * 0.5 * (self.EndPos - self.StartPos):GetNormal();
		
		self:PreviewSelection()
	else
		local Trace = {}
		Trace.start = LocalPlayer():GetShootPos()
		Trace.endpos = Trace.start + (LocalPlayer():GetAimVector() * 4096)
		Trace.mask = MASK_SOLID
		local tr = util.TraceLine(Trace)
		if( IsValid( tr.Entity ) ) then
			self:ClearPreviewSelection()
			local selectable = getSelectable( tr.Entity )
			if( selectable ) then
				self.PreviewSelect = {selectable}
			end
		end
	end
	
end

local mat_sprite = Material( "sprites/glow01" );
-- local MaterialWhite = CreateMaterial( "WhiteMaterial", "UnlitGeneric", {	-- Necessary to assign color by vertex
	-- ["$basetexture"] = "color/white",
	-- ["$vertexcolor"] = 1,	-- Necessary to assign color by vertex
	-- ["$vertexalpha"] = 1,	-- Necessary to assign alpha to vertex
	-- ["$model"] = 1
-- } );

function GM:RenderScreenspaceEffects()
	
	if(self.Navigation) then
		self.Navigation:RenderScreenspaceEffects()
	end
	
end

function GM:PreDrawTranslucentRenderables()
	
end

function GM:PostDrawTranslucentRenderables()
	self:UpdateSelection()
	
	if(not self.SelectionSphere) then return end
	
	if(self.Selecting and self.StartPos and self.EndPos and self.SelectionPoints) then
		local radius = self.Diameter*0.5
		
		self.SelectionSphere:SetPos( self.Center )
		self.SelectionSphere:SetModelScale(radius, 0)
		
		render.SuppressEngineLighting( true )
		render.SetBlend( self.SelectionColor.a / 255 )
		render.SetColorModulation( self.SelectionColor.r / 1020, self.SelectionColor.g / 1020, self.SelectionColor.b / 1020 )
		render.CullMode( MATERIAL_CULLMODE_CW )
			self.SelectionSphere:DrawModel()
		render.CullMode( MATERIAL_CULLMODE_CCW )
		render.SetColorModulation( self.SelectionColor.r, self.SelectionColor.g, self.SelectionColor.b )
			self.SelectionSphere:DrawModel()
		render.SetColorModulation( 1, 1, 1 )
		render.SetBlend( 1 )
		render.SuppressEngineLighting( false )
	end
end

-- function GM:DrawSphere(center, radius, col)
	
	-- render.SetMaterial( MaterialWhite )
	
	-- radius = math.abs( radius )
	
	-- local pos = EyePos()
	-- local dis = center:Distance(pos) - radius
	-- local Divs1 = math.Round( math.Clamp( 2048 / dis, 5, 16 ) )
	-- local Incr1 = 90 / Divs1
	-- local Incr2 = 180 / Divs1
	
	-- local ang = (center - pos):Angle()
	-- ang.p = ang.p - 90
	
	-- local mat = Matrix()
	-- mat:Translate( center )
	-- mat:Rotate( ang )
	-- mat:Scale( Vector(radius, radius, radius) )
	
	-- render.SuppressEngineLighting( true )
	-- render.SetModelLighting( false )
	
	-- cam.PushModelMatrix( mat )
		
		-- if( dis > 0 ) then
			-- --Draw the outside hemisphere
			-- for phi = 0, Divs1-1 do
				-- mesh.Begin( MATERIAL_TRIANGLE_STRIP, Divs1 * 4 )
				-- for thet = -Divs1, Divs1 do
					-- mesh.Color( col.r, col.g, col.b, 20 )
					-- mesh.TexCoord( 0, 0, 0 )
					-- mesh.Position( Vector(	math.sin (deg_to_rad * thet * Incr2) * math.cos (deg_to_rad * (phi + 1) * Incr1),
											-- math.cos (deg_to_rad * thet * Incr2) * math.cos (deg_to_rad * (phi + 1) * Incr1),
											-- math.sin (deg_to_rad * (phi + 1) * Incr1) ))
					-- mesh.AdvanceVertex()
					-- mesh.Color( col.r, col.g, col.b, 20 )
					-- mesh.Position( Vector(	math.sin (deg_to_rad * thet * Incr2) * math.cos (deg_to_rad * phi * Incr1),
											-- math.cos (deg_to_rad * thet * Incr2) * math.cos (deg_to_rad * phi * Incr1),
											-- math.sin (deg_to_rad * phi * Incr1) ))
					-- mesh.AdvanceVertex()
				-- end
				-- mesh.End()
			-- end
		-- end
		
		-- --Draw the inside sphere
		-- for phi = -Divs1, Divs1-1 do
			-- mesh.Begin( MATERIAL_TRIANGLE_STRIP, Divs1 * 4 )
			-- for thet = -Divs1, Divs1 do
				-- mesh.Color( col.r*0.25, col.g*0.25, col.b*0.25, 60 )
				-- mesh.Position( Vector(	math.sin (deg_to_rad * thet * Incr2) * math.cos (deg_to_rad * phi * Incr1),
										-- math.cos (deg_to_rad * thet * Incr2) * math.cos (deg_to_rad * phi * Incr1),
										-- math.sin (deg_to_rad * phi * Incr1) ))
				-- mesh.AdvanceVertex()
				-- mesh.Color( col.r*0.25, col.g*0.25, col.b*0.25, 60 )
				-- mesh.Position( Vector(	math.sin (deg_to_rad * thet * Incr2) * math.cos (deg_to_rad * (phi + 1) * Incr1),
										-- math.cos (deg_to_rad * thet * Incr2) * math.cos (deg_to_rad * (phi + 1) * Incr1),
										-- math.sin (deg_to_rad * (phi + 1) * Incr1) ))
				-- mesh.AdvanceVertex()
			-- end
			-- mesh.End()
		-- end
		
	-- cam.PopModelMatrix()
	
	-- render.SuppressEngineLighting( false )
	-- render.SetModelLighting( true )

-- end
