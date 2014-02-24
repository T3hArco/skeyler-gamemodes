AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );
include( 'shared.lua' );

function ENT:KeyValue(key, value)
	self[key] = tonumber(value)
end

function ENT:Initialize()
	self.Entity:PhysicsInit( 0 )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:DrawShadow( false )
	self.Entity:SetNotSolid( true )
end