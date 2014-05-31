--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

include("shared.lua")

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SA.Refundables = nil

local MatTeamColor = Material("jaanus/teamcolor")
local TexTeamColor = surface.GetTextureID("jaanus/teamcolor")
local RTTexture = GetRenderTarget("SassWristColor", 128, 128)
local UpdateTeamColor = true
local DrawnViewModel = false

local nextFire = CurTime()
function SWEP:PrimaryAttack()

	if CurTime() < nextFire then return end
	
	nextFire = CurTime() + 0.1
	
	if( GAMEMODE.REFUNDMODE and SA.Refundables ) then
		if( table.Count(SA.Refundables) > 0 ) then
			local unitsToSell = {}
			
			for refundable, _ in pairs( SA.Refundables ) do
				if( Unit:ValidUnit( refundable ) ) then
					table.insert( unitsToSell, refundable )
				elseif ( ValidBuilding( refundable ) ) then
					
					if( refundable:GetClass() ~= "building_wall" ) then
						RunConsoleCommand( "sa_sell", refundable:EntIndex() )
					end
	
				end
				
			end
			
			-- ??? // Chewgum
			--[[
			local unitSellCount, u = #unitsToSell
			
			if( unitSellCount > 0 ) then
				local unitSellIndex = 1
				while( unitSellIndex - 1 < unitSellCount ) do
					local sell = {}
					for i = 1, math.min( 7, unitSellCount - unitSellIndex + 1 ) do
						table.insert( sell, unitsToSell[ unitSellIndex ]:UnitIndex() )
						unitSellIndex = unitSellIndex + 1
					end
					
					RunConsoleCommand("sa_sellunits", unpack( sell ) )
				end
			end
			]]
			
			if (#unitsToSell > 0) then
				local args = {}
				
				for k, unit in pairs(unitsToSell) do
					table.insert(args, unit:UnitIndex())
				end
				
				RunConsoleCommand("sa_sellunits", unpack(args))
			end
		end
		
		return
		
	end
	
	if( vgui.CursorVisible() or GAMEMODE.Selecting or GAMEMODE.Ghosting ) then return end
	
	local Trace = {}
	Trace.start = LocalPlayer():GetShootPos()
	Trace.endpos = Trace.start + (LocalPlayer():GetAimVector() * 4096)
	Trace.mask = CHECK_MASK + CONTENTS_GRATE
	
	local tr = util.TraceLine(Trace)
	
	if(not tr.Hit or tr.HitSky) then
		return
	end
	
	GAMEMODE.Selecting = true
	GAMEMODE:StartSelection(tr.HitPos)
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() +0.2)
	
	if( GAMEMODE.REFUNDMODE ) then return end
	
	local e = LocalEmpire()
	if( e and e:NumSelectedUnits() > 0 ) then
		
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.nextOrderSound = self.nextOrderSound or CurTime()
		if( CurTime() < self.nextOrderSound ) then return end
		
		local OrderSound = SA.Sounds.GetUnitOrderSound()
		local SoundPath = OrderSound[ 1 ]
		local SoundDur = OrderSound[ 2 ]
		
		self:EmitSound( SoundPath )
		self.nextOrderSound = CurTime() + SoundDur
	end
end

function SWEP:ViewModelDrawn()
	
	if( DrawnViewModel ) then return end
	if( GAMEMODE.REFUNDMODE ) then
		
		render.SetStencilEnable( true );
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
		render.SetStencilWriteMask( 0 )
		render.SetStencilReferenceValue( 2 )
			
		render.SetBlend( 0 )
			
			render.MaterialOverride( SA.MaterialWhite )
			DrawnViewModel = true --Prevent Recursion
			LocalPlayer():GetViewModel():DrawModel()
			DrawnViewModel = false
			render.MaterialOverride()
			
		render.SetBlend( 1 )
		 
		render.SetStencilEnable( false )
		
	end
	
end

hook.Add( "PreDrawEffects", "SA.RefundVisionPre", function()
	
	if( not GAMEMODE.REFUNDMODE ) then return end
	
	local LE = LocalEmpire()
	if( not LE ) then return end
	
	render.SetStencilEnable( true )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilWriteMask( 3 )
	render.SetStencilReferenceValue( 7 )
	
	render.SetBlend( 0 )
	
	render.MaterialOverride( SA.MaterialWhite )
	
	for _, ent in pairs( ents.FindByClass( "building_*" ) ) do
		
		if( (ent.Refundable or ent.Repairable) and ent:GetEmpire() == LE and ent:IsBuilt() ) then
			if( SA.Refundables and SA.Refundables[ ent ] ) then
				render.SetStencilReferenceValue( 7 )
			else
				render.SetStencilReferenceValue( 6 )
			end
			ent:DrawBuilding()
		end
		
	end
	
	for _, unit in pairs(unit.GetAll()) do
		if ( (unit.Refundable or unit.Repairable) and unit:GetEmpire() == LE ) then
			if( SA.Refundables and SA.Refundables[ unit ] ) then
				render.SetStencilReferenceValue( 7 )
			else
				render.SetStencilReferenceValue( 6 )
			end
		
			if (Unit:ValidUnit(unit) and IsValid(unit.Entity)) then
				unit:Draw()
			end
		end
		
	end
	
	render.MaterialOverride()
	
	render.SetBlend( 1 )
	
	render.SetStencilEnable( false )
	
end )

local MatWhite = CreateMaterial( "RefundOverlay", "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$model"] = 1
} )

local RefundVisionColor = 1
local RefundPPTable = {}
hook.Add( "RenderScreenspaceEffects", "SA.RefundVision", function()
	
	local IN_REFUND = LocalPlayer():KeyDown( IN_RELOAD )
	
	if( not IN_REFUND or IsValid( GAMEMODE.Ghost.Ent ) ) then
		GAMEMODE.REFUNDMODE = false
	else
		GAMEMODE.REFUNDMODE = true
	end

	if( IN_REFUND ) then
		RefundVisionColor = Lerp( 3 * FrameTime(), RefundVisionColor, 0 )
	else
		RefundVisionColor = Lerp( 3 * FrameTime(), RefundVisionColor, 1 )
	end
	
	if (RefundVisionColor >= 0.99) then return end

	RefundPPTable[ "$pp_colour_addr" ] = 0
	RefundPPTable[ "$pp_colour_addg" ] = 0
	RefundPPTable[ "$pp_colour_addb" ] = 0
	RefundPPTable[ "$pp_colour_brightness" ] = 0
	RefundPPTable[ "$pp_colour_contrast" ] = 1
	RefundPPTable[ "$pp_colour_colour" ] = RefundVisionColor
	RefundPPTable[ "$pp_colour_mulr" ] = 0
	RefundPPTable[ "$pp_colour_mulg" ] = 0
    RefundPPTable[ "$pp_colour_mulb" ] = 0
	
    // tell the stencil buffer we're only going to draw
    // where the refundable models are not.
    render.SetStencilEnable( true )
    render.SetStencilReferenceValue( 0 )
    render.SetStencilTestMask( 3 )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
     
    // draw greyscale
    DrawColorModify( RefundPPTable )
	
    render.SetStencilReferenceValue( 7 )
	
	MatWhite:SetFloat( "$alpha", 0.4 )
	MatWhite:SetVector( "$color", Vector( 1, 0, 0 ) )
	
	render.SetMaterial( MatWhite )
    render.DrawScreenQuad()
	
    // don't need this anymore
    render.SetStencilEnable( false )
 
end )

hook.Add( "OnEmpireCreated", "WristBand.OnEmpireCreated", function( Empire )
	
	UpdateTeamColor = true
	timer.Simple(10, function()
		--Redoing this after 10 seconds because it doesn't seem like everything is loaded sometimes immediately.
		--Just a hacky work-around to make sure a players wrist band is showing the correct color.
		UpdateTeamColor = true
	end)
	
end )

hook.Add( "HUDPaint", "sass.staff_command.SetupRTTexture", function()
	if (!LocalPlayer():KeyDown(IN_ATTACK) and GAMEMODE.Selecting) then
		GAMEMODE:EndSelection()
	end
	
	if(not RTTexture) then return end
	if(not UpdateTeamColor) then return end
	
	UpdateTeamColor = false
	
	local OldRT = render.GetRenderTarget()
	
	render.SetRenderTarget(RTTexture)
	render.SetViewPort(0, 0, 128, 128)
	
	cam.Start2D()
		local vecCol = LocalPlayer():GetPlayerColor()
		surface.SetTexture( TexTeamColor )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( 0, 0, 128, 128 )
		surface.SetDrawColor( vecCol.x * 255 * 0.5, vecCol.y * 255 * 0.5, vecCol.z * 255 * 0.5, 150 )
		surface.DrawRect( 0, 0, 128, 128 )
	cam.End2D()
	
	render.SetRenderTarget(OldRT)
	render.SetViewPort(0, 0, ScrW(), ScrH())
	
	MatTeamColor:SetTexture("$basetexture", RTTexture)
	
end )

function SWEP:ClearRefundables( bNewTable )
	
	SA.Refundables = bNewTable and {} or nil
	
end

function SWEP:AddRefundable( refundable )
	
	SA.Refundables[ refundable ] = true
	
end

function SWEP:Think()
	if( GAMEMODE.REFUNDMODE ) then
		self:ClearRefundables( true )
		
		local tr = self.Owner:GetEyeTrace()
		local trEnt = tr.Entity
		
		if( IsValid(trEnt) ) then
			local Empire = LocalEmpire()
			
			if( not Empire ) then return end
			
			if(trEnt.Refundable and not trEnt:IsEffectActive( EF_NODRAW ) and trEnt:GetEmpire() == Empire and !trEnt.DamageSell) then
				if(trEnt:IsBuilding() and trEnt:IsBuilt()) then
					self:AddRefundable( trEnt )
					
					if( trEnt:GetClass() == "building_walltower" ) then
						for w, _ in pairs( trEnt.ConnectedWalls ) do
							self:AddRefundable( w )
						end
						for k,v in pairs(trEnt.ConnectedGates) do
							if v:IsValid() then
								self:AddRefundable( v )
							end
						end
					elseif (trEnt:GetClass() == "building_gate") then
						if trEnt.Connected then
							for k,v in pairs(trEnt.Connected) do
								self:AddRefundable( v )
							end
						end
					end
					
					return
				end
			end
		else
			for k, unit in pairs(unit.GetAll()) do
				if (unit.Refundable and unit.GetSelected and unit:GetSelected()) then
					self:AddRefundable(unit)
				end
			end
		end
	else
		self:ClearRefundables( false )
	end
end

if( game.SinglePlayer() ) then
	
	hook.Add( "Tick", "staff_command.Tick", function()
		
		if( GAMEMODE.Selecting or GAMEMODE.Ghosting ) then return end
		if( vgui.CursorVisible() ) then return end
		if( not input.IsMouseDown( MOUSE_LEFT ) ) then return end
		if( not IsValid( LocalPlayer() ) ) then return end
		
		LocalPlayer():GetActiveWeapon():PrimaryAttack()
		
	end )
	
end