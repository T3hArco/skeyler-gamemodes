AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	
	self:PhysicsInit( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetSolid( SOLID_BBOX )
	self:SetAngles( self:GetAngles() )
	
	self:SetNoDraw( false )
	self:DrawShadow( false )
	self.props = {}
	self.lights = {}
	self.sprites = {}
	
end

function ENT:SetupIndicators( dir )
	
	self.SetupIndicators = function() end
	if dir == 0 then
		
		local prop = ents.Create( "prop_dynamic" )
		prop:SetPos( self:GetPos() + self:GetUp() * 5 )
		prop:SetAngles( self:GetAngles() + Angle( -90, 0, 0 ) )
		prop:SetModel( "models/props/cs_office/light_inset.mdl" )
		prop:Spawn()
		prop:Activate()
		prop:SetMoveType( MOVETYPE_NONE )
		self.props[ prop:EntIndex() ] = prop
		
		prop = ents.Create( "env_lightglow" )
		prop:SetPos( self:GetPos() + self:GetUp() * 5 + self:GetForward() * 2 )
		prop:SetKeyValue( "rendercolor", "151 226 255" )
		prop:SetKeyValue( "VerticalGlowSize", "5" )
		prop:SetKeyValue( "HorizontalGlowSize", "10" )
		prop:SetKeyValue( "MinDist", "0" )
		prop:SetKeyValue( "MaxDist", "350" )
		prop:SetKeyValue( "OuterMaxDist", "2000" )
		prop:SetKeyValue( "GlowProzySize", "4" )
		prop:Spawn()
		prop:Activate()
		self.lights[ 1 ] = prop
		
		prop = ents.Create( "env_sprite" )
		prop:SetPos( self:GetPos() + self:GetUp() * 5 + self:GetForward() )
		prop:SetKeyValue( "rendercolor", "151 226 255" )
		prop:SetKeyValue( "rendermode", "3" )
		prop:SetKeyValue( "scale", ".25" )
		prop:SetKeyValue( "spawnflags", "1" )
		prop:SetKeyValue( "model", "sprites/light_glow02.spr" )
		prop:Spawn()
		prop:Activate()
		self.sprites[ 1 ] = prop
		
		prop = ents.Create( "prop_dynamic" )
		prop:SetPos( self:GetPos() + self:GetUp() * -6.5 )
		prop:SetAngles( self:GetAngles() + Angle( -90, 0, 0 ) )
		prop:SetModel( "models/props/cs_office/light_inset.mdl" )
		prop:Spawn()
		prop:Activate()
		prop:SetMoveType( MOVETYPE_NONE )
		self.props[ prop:EntIndex() ] = prop
		
		prop = ents.Create( "env_lightglow" )
		prop:SetPos( self:GetPos() + self:GetUp() * -6.5 + self:GetForward() * 2 )
		prop:SetKeyValue( "rendercolor", "151 226 255" )
		prop:SetKeyValue( "VerticalGlowSize", "5" )
		prop:SetKeyValue( "HorizontalGlowSize", "10" )
		prop:SetKeyValue( "MinDist", "0" )
		prop:SetKeyValue( "MaxDist", "350" )
		prop:SetKeyValue( "OuterMaxDist", "2000" )
		prop:SetKeyValue( "GlowProzySize", "4" )
		prop:Spawn()
		prop:Activate()
		self.lights[ -1 ] = prop
		
		prop = ents.Create( "env_sprite" )
		prop:SetPos( self:GetPos() + self:GetUp() * -6.5 + self:GetForward() )
		prop:SetKeyValue( "rendercolor", "151 226 255" )
		prop:SetKeyValue( "rendermode", "3" )
		prop:SetKeyValue( "scale", ".25" )
		prop:SetKeyValue( "spawnflags", "1" )
		prop:SetKeyValue( "model", "sprites/light_glow02.spr" )
		prop:Spawn()
		prop:Activate()
		self.sprites[ -1 ] = prop
		
	else
		
		local prop = ents.Create( "prop_dynamic" )
		prop:SetPos( self:GetPos() )
		prop:SetAngles( self:GetAngles() + Angle( -90, 0, 0 ) )
		prop:SetModel( "models/props/cs_office/light_inset.mdl" )
		prop:Spawn()
		prop:Activate()
		prop:SetMoveType( MOVETYPE_NONE )
		self.props[ prop:EntIndex() ] = prop
		
		prop = ents.Create( "env_lightglow" )
		prop:SetPos( self:GetPos() + self:GetForward() * 2 )
		prop:SetKeyValue( "rendercolor", "151 226 255" )
		prop:SetKeyValue( "VerticalGlowSize", "20" )
		prop:SetKeyValue( "HorizontalGlowSize", "20" )
		prop:SetKeyValue( "MinDist", "0" )
		prop:SetKeyValue( "MaxDist", "350" )
		prop:SetKeyValue( "OuterMaxDist", "2000" )
		prop:SetKeyValue( "GlowProzySize", "4" )
		prop:Spawn()
		prop:Activate()
		self.lights[ 0 ] = prop
		
		prop = ents.Create( "env_sprite" )
		prop:SetPos( self:GetPos() + self:GetForward() )
		prop:SetKeyValue( "rendercolor", "151 226 255" )
		prop:SetKeyValue( "rendermode", "3" )
		prop:SetKeyValue( "scale", ".25" )
		prop:SetKeyValue( "spawnflags", "1" )
		prop:SetKeyValue( "model", "sprites/light_glow02.spr" )
		prop:Spawn()
		prop:Activate()
		self.sprites[ 0 ] = prop
		
	end
	
end

function ENT:Indicate( dir )
	
	if !dir then
		for _, light in pairs( self.lights ) do
			light:SetKeyValue( "rendercolor", "151 226 255" )
		end
		for _, sprite in pairs( self.sprites ) do
			sprite:SetKeyValue( "rendercolor", "151 226 255" )
		end
		return
	end
	
	if dir == 0 then
		for _, light in pairs( self.lights ) do
			light:SetKeyValue( "rendercolor", "255 026 054" )
		end
		for _, sprite in pairs( self.sprites ) do
			sprite:SetKeyValue( "rendercolor", "255 026 054" )
		end
		return
	elseif self.lights[ 0 ] then
		self.lights[ 0 ]:SetKeyValue( "rendercolor", "255 026 054" )
		self.sprites[ 0 ]:SetKeyValue( "rendercolor", "255 026 054" )
		return
	else
		for _, light in pairs( self.lights ) do
			light:SetKeyValue( "rendercolor", "151 226 255" )
		end
		for _, sprite in pairs( self.sprites ) do
			sprite:SetKeyValue( "rendercolor", "151 226 255" )
		end
		self.lights[ dir ]:SetKeyValue( "rendercolor", "255 026 054" )
		self.sprites[ dir ]:SetKeyValue( "rendercolor", "255 026 054" )
		return
	end
	
end