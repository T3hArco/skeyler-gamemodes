AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

resource.AddFile( "materials/elevator/button_selected.vmt" )
resource.AddFile( "materials/elevator/button_selected.vtf" )
resource.AddFile( "materials/elevator/button_arrow.vmt" )
resource.AddFile( "materials/elevator/button_arrow.vtf" )
resource.AddFile( "materials/elevator/button.vmt" )
resource.AddFile( "materials/elevator/button.vtf" )

function ENT:Initialize()
	
	self:PhysicsInit( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetSolid( SOLID_BBOX )
	self:SetAngles( self:GetAngles() )
	
	self:SetNoDraw( false )
	self:DrawShadow( false )
	
end

concommand.Add( "elev_ctrl", function( pl, cmd, args )
	
	if !(IsValid( pl ) and pl:IsPlayer()) then return end
	
	local ent = Entity( args[1] )
	if !(IsValid( ent ) and ent.floors) then return end
	if !(ent.contents[ pl:EntIndex() ]) then return end
	if (pl.GetRank and pl:GetRank() < ent.access_rank) then return end
	
	local level = tonumber( args[2] )
	if !(ent.floors[ level ]) then return end
	ent:Call( level, nil, true )
	
end )