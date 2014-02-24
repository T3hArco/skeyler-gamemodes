ENT.Base = "base_brush"
ENT.Type = "brush"

local STATE_IDLE = 1
local STATE_WAITING = 2
local STATE_MOVING = 3

function ENT:Initialize()
	
	self.doors = {}
	self.open = 0
	self.autoClose = 0
	self.position = self:LocalToWorld(self:OBBCenter()).z
	self.contents = {}
	self:SetTrigger( true )
	
	local prop = ents.Create( "elev_sound" )
	prop:SetPos( self:LocalToWorld( self:OBBCenter() ) )
	prop:Spawn()
	prop:Activate()
	prop.floor = self
	self.soundEnt = prop
	
end

function ENT:KeyValue(key, value)
	
	self[key] = tonumber(value)
	
end

function ENT:Think()
	
	if self.open > 0 and CurTime() > self.autoClose then
		self:CloseDoors()
	end
	
end

function ENT:StartTouch( ent )
	
	if ent:GetClass() == "func_door" then
		ent.closed = true
		self.doors[ ent:EntIndex() ] = ent
		if ent.shaft then
			ent.shaft.floors[ self.floor_num ] = self
			self.shaft = ent.shaft
			if self.caller then
				self.caller.access_rank = self.shaft.access_rank
			end
			if self.controller then
				self.controller.shaft = self.shaft
				self.controller.access_rank = self.shaft.access_rank
			end
		end
		ent.floor = self
		return
	end
	
	if ent:GetClass() == "elev_caller" then
		self.caller = ent
		ent.floor = self
		ent:SetNotSolid( true )
		if self.shaft then
			ent.access_rank = self.shaft.access_rank
		end
	end
	
	if ent:GetClass() == "elev_controller" then
		self.controller = ent
		ent.floor = self
		ent:SetNotSolid( true )
		if self.shaft then
			ent.shaft = self.shaft
			ent.access_rank = self.shaft.access_rank
		end
	end
	
	if ent:GetClass() == "elev_indicator" then
		if ent:GetPos().z > self.position then
			self.indicator = ent
			ent.floor = self
			ent:SetNotSolid( true )
		end
	end
	
	if !(self.shaft and self.shaft.cart.position) then return end
	if (ent:IsPlayer() and !IsValid(ent:GetVehicle())) ||
			(	IsValid(ent:GetPhysicsObject())		and
				type(ent:GetPhysicsObject())!="IPhysicsObject"	and
				!IsValid(ent:GetParent())			and
				ent:GetClass() != "func_button"			) then
		self.contents[ ent:EntIndex() ] = ent
		if ent:IsPlayer() and !ent.jumpPower then
			ent.jumpPower = ent:GetJumpPower()
			ent:SetJumpPower( 150 )
		end
				
	end
	
end

function ENT:EndTouch( ent )
	
	self.contents[ ent:EntIndex() ] = nil
	if ent:IsPlayer() and ent.jumpPower then
		ent:SetJumpPower( ent.jumpPower )
		ent.jumpPower = nil
	end
	
end

function ENT:CloseDoors()
	
	self.shaft.cart.state = STATE_WAITING
	self.autoClose = CurTime() + 4
	for _, door in pairs( self.doors ) do
		if !door.closed then
			door.blocked = false
			door.closing = true
			door:Fire( "close" )
		end
	end
	
end

function ENT:OpenDoors(forced)
	
	self.shaft.cart.state = STATE_WAITING
	
	self.open = 4
	self.autoClose = CurTime() + 6
	for _, door in pairs( self.doors ) do
		timer.Simple( door:GetPos():Distance( self:LocalToWorld( self:OBBCenter() ) ) * 0.01, function()
			door:Fire( "unlock" )
			door:Fire( "open" )
			door.blocked = false
			door.closing = false
			door.closed = false
		end)
	end
	if !forced then
		umsg.Start( "elev_chime" )
			umsg.Short( self.soundEnt:EntIndex() )
		umsg.End()
	end
	
end

function ENT:ClosedDoors()
	
	for _, door in pairs( self.doors ) do
		if door.blocked then
			return
		end
	end
	
	self.open = 0
	self.shaft.cart.state = STATE_IDLE
	self.indicator:Indicate( nil )
	
end

function ENT:TeleportToFloor( floor )
	
	if floor.shaft != self.shaft then return end
	if floor == self then return end
	for _, ent in pairs( self.contents ) do
		if self.shaft.contents[ _ ] == ent then
			if (ent:IsPlayer() and !IsValid(ent:GetVehicle())) ||
				(	IsValid(ent:GetPhysicsObject())		and
					type(ent:GetPhysicsObject())!="IPhysicsObject"	and
					!IsValid(ent:GetParent())			and
					ent:GetClass() != "func_button"			) then
				local newpos = floor:LocalToWorld(floor:OBBCenter()) + ( ent:GetPos() - self:LocalToWorld(self:OBBCenter()) )
				ent:SetPos( newpos )
				ent:SetPos( newpos )
			end
		end
	end
	self.contents = {}
	
end

function ENT:AcceptInput( input, pl, ent )
	
	if input == "Close" then
		if !ent.blocked then
			ent:Fire( "lock" )
			ent.closed = true
			ent.closing = false
			ent.blocked = false
			self.open = self.open - 1
			if self.open <= 0 then
				self:ClosedDoors()
			end
		end
	end
	if input == "Blocked" then
		for _, door in pairs( self.doors ) do
			door.blocked = true
		end
		self:OpenDoors(true)
	end
	
end