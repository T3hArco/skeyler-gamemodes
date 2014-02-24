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
	self.dirOptions = 1		--1 = Up, 0 = Both, -1 = Down (This will later be calculated)
	
end

function ENT:CalcDirOptions()
	
	if !self.floor then return end
	if !self.floor.shaft then return end
	self.CalcDirOptions = function() end
	
	local shaft = self.floor.shaft
	local level = self.floor.floor_num
	local up, down
	
	for lvl, flr in pairs( shaft.floors ) do
		if lvl < level then
			down = true
		elseif lvl > level then
			up = true
		end
	end
	
	self.dirOptions = (up and down) and 0 or ((up and 1) or (down and -1))
	self.floor.dirOptions = self.dirOptions
	self.indicator = self.floor.indicator
	self.indicator:SetupIndicators( self.dirOptions )
	
end

function ENT:Press( dir )
	
	self.pressed = dir
	self.floor.shaft:Call( self.floor.floor_num, self.pressed )
	
	umsg.Start( "elev_caller.Press" )
		umsg.Short( self:EntIndex() )
		umsg.Bool( self.pressed )
		umsg.Short( self.pressed )
	umsg.End()
	
end

concommand.Add( "elev_call", function( pl, cmd, args )
	
	if !(IsValid( pl ) and pl:IsPlayer()) then return end
	local ent = Entity( args[1] )
	if !(IsValid( ent ) and ent.floor) then return end
	if (pl.GetRank and pl:GetRank() < ent.access_rank) then return end
	local check = ent:GetCursorPos( pl )
	if !check then return end
	
	local pressDir = tonumber( args[2] or 0 )
	if ent.dirOptions > 0 then
		
		if pressDir < 0 then return end
		ent:Press( 1 )
		
	elseif  ent.dirOptions < 0 then
		
		if pressDir > 0 then return end
		ent:Press( -1 )
		
	elseif ent.pressed then
		
		if ent.pressed < 0 then
			ent:Press( pressDir > 0 and 0 or -1 )
		elseif ent.pressed > 0 then
			ent:Press( pressDir < 0 and 0 or 1 )
		end
		
	else
		
		ent:Press( pressDir )
		
	end
	
end )