AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

resource.AddFile( "sound/elevator_chime.mp3" )

function ENT:Initialize()
	
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
	
	self:SetNoDraw( false )
	self:DrawShadow( false )
	
end