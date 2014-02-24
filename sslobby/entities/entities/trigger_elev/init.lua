ENT.Base = "base_brush"
ENT.Type = "brush"

local STATE_IDLE = 1
local STATE_WAITING = 2
local STATE_MOVING = 3

//plats/elevator_move_loop1.wav
//plats/elevator_large_start1.wav
//plats/elevator_stop2.wav

function ENT:Initialize()
	
	self.center = self:LocalToWorld(self:OBBCenter())
	self.contents = {}
	self.floors = {}
	self.cart = {
		level = 1,
		speed = 16,
		direction = 0,
		state = STATE_IDLE,
		destinations = {}
	}
	self:SetTrigger( true )
	
	local prop = ents.Create( "elev_sound" )
	prop:Spawn()
	prop:Activate()
	prop.shaft = self
	self.cart.soundEnt = prop
	
end

hook.Add( "PlayerInitialSpawn", "elev.Setup", function( pl )

	for _, self in pairs( ents.FindByClass( "trigger_elev" ) ) do
		
			for _, floor in pairs( self.floors ) do
				if(!floor.controller)then
					print("Elevator Broken")
					return
				end
			end

		
	end
	
	for _, ent in pairs( ents.FindByClass( "elev_caller" ) ) do
		
		ent:CalcDirOptions()
		umsg.Start( "elev_caller.Setup", pl )
			umsg.Short( ent:EntIndex() )
			umsg.Short( ent.access_rank )
			umsg.Short( ent.dirOptions )
			umsg.Bool( ent.pressed )
			umsg.Short( ent.pressed )
		umsg.End()
		
	end
	
	for _, self in pairs( ents.FindByClass( "trigger_elev" ) ) do
		
		umsg.Start( "elev_controller.Setup", pl )
			
			umsg.Short( self:EntIndex() )
			umsg.Short( table.Count( self.floors ) )
			for _, floor in pairs( self.floors ) do
				umsg.Short( floor.controller:EntIndex() )
				umsg.Short( floor.floor_num )
				umsg.Bool( floor.caller.pressed )
			end
			
		umsg.End()
		
	end
	
end )

function ENT:KeyValue(key, value)
	
	self[key] = tonumber(value)
	
end

function ENT:Think()
	
	self:MoveCart()
	
end

function ENT:MoveCart()
	
	local cart = self.cart
	
	if cart.state == STATE_WAITING then return end
	
	if table.Count( cart.destinations ) == 0 then
		if cart.state == STATE_IDLE then return end
	end
	
	local next, level = self:GetNextDestination( cart )
	if cart.state == STATE_IDLE then
		if cart.position == next then
			
			cart.direction = tonumber( cart.destinations[ level ] ) or 0
			self:Send( level )
			
		elseif next then
			
			cart.state = STATE_MOVING
			
			local rf, players = RecipientFilter(), {}
			for _, ent in pairs( self.contents ) do
				if ent:IsPlayer() then
					table.insert( players, ent )
					rf:AddPlayer( ent )
				end
			end
			umsg.Start( "elev_sound", rf )
				umsg.Short( table.Count( self.floors ) )
				for _, floor in pairs( self.floors ) do
					umsg.Short( floor.soundEnt:EntIndex() )
					umsg.Short( 1 )
				end
			umsg.End()
			
			local rf = RecipientFilter()
			for _, pl in pairs( player.GetAll() ) do
				if !table.HasValue( players, pl ) then
					rf:AddPlayer( pl )
				end
			end
			umsg.Start( "elev_sound", rf )
				umsg.Short( 1 )
				umsg.Short( self.cart.soundEnt:EntIndex() )
				umsg.Short( 1 )
			umsg.End()
			
		end
	elseif cart.state == STATE_MOVING then
		if !next then
			
			cart.state = STATE_IDLE
			return
			
		elseif cart.position > next then
			
			cart.direction = -1
			cart.position = math.Max( cart.position - cart.speed, next )
			
		elseif cart.position < next then
			
			cart.direction = 1
			cart.position = math.Min( cart.position + cart.speed, next )
			
		end
		if cart.position == next then
			
			self:Send( level )
			
		end
	end
	
	cart.soundEnt:SetPos( Vector( self.center.x, self.center.y, cart.position ) )
	
end

function ENT:Call( level, dir, cart )
	
	if !self.floors[ level ] then return end
	if !self.cart.position then
		self.cart.destinations[ level ] = dir
		self.cart.position = self.floors[ level ].position
		return
	end
	
	if cart and !dir then
		dir = self.floors[ level ].dirOptions
		if dir == 0 then
			dir = true
		end
	end
	
	if (	self.cart.state == STATE_WAITING			and
		self.floors[ level ].position == self.cart.position	and
		(dir == true || self.cart.direction == dir)		) then
		self.floors[ level ].autoClose = CurTime()+ 4
		self.floors[ level ].caller.pressed = self.cart.destinations[ level ]
		return
	end
	
	if cart then
		umsg.Start( "elev_controller.Press" )
			umsg.Short( self:EntIndex() )
			umsg.Short( level )
			umsg.Bool( dir )
		umsg.End()
	end
	
	self.cart.destinations[ level ] = dir
	
end

function ENT:Send( level )
	
	local floor = self.floors[ level ]
	if !floor then return end
	
	local cart = self.cart
	cart.level = level
	cart.position = floor.position
	cart.state = STATE_WAITING
	
	umsg.Start( "elev_controller.Press" )
		umsg.Short( self:EntIndex() )
		umsg.Short( level )
		umsg.Bool( false )
	umsg.End()
	
	for _, flr in pairs( self.floors ) do
		flr:TeleportToFloor( floor )
	end
	
	if cart.direction > 0 then
		if cart.destinations[ level ] == true then
			cart.destinations[ level ] = nil
			cart.direction = 0
		elseif cart.destinations[ level ] > 0 then
			cart.destinations[ level ] = nil
		elseif cart.destinations[ level ] == 0 then
			cart.destinations[ level ] = -1
		else
			cart.destinations[ level ] = nil
			cart.direction = -1
		end
	elseif cart.direction < 0 then
		if cart.destinations[ level ] == true then
			cart.destinations[ level ] = nil
			cart.direction = 0
		elseif cart.destinations[ level ] < 0 then
			cart.destinations[ level ] = nil
		elseif cart.destinations[ level ] == 0 then
			cart.destinations[ level ] = 1
		else
			cart.destinations[ level ] = nil
			cart.direction = 1
		end
	elseif cart.destinations[ level ] == 0 then
		cart.destinations[ level ] = -1
		cart.direction = 1
	else
		cart.destinations[ level ] = nil
		cart.direction = 0
	end
	
	floor.indicator:Indicate( cart.direction )
	floor.caller:Press( cart.destinations[ level ] )
	
	umsg.Start( "elev_sound" )
		umsg.Short( 1 )
		umsg.Short( cart.soundEnt:EntIndex() )
		umsg.Short( 2 )
	umsg.End()
	
	local rf, players = RecipientFilter(), {}
	for _, ent in pairs( self.contents ) do
		if ent:IsPlayer() then
			table.insert( players, ent )
			rf:AddPlayer( ent )
		end
	end
	umsg.Start( "elev_sound", rf )
		umsg.Short( table.Count( self.floors ) )
		for _, floor in pairs( self.floors ) do
			umsg.Short( floor.soundEnt:EntIndex() )
			umsg.Short( 2 )
		end
	umsg.End()
	
	floor:OpenDoors()
	
end

function ENT:GetNextDestination( cart )
	
	if cart.state == STATE_WAITING then return end
	if cart.state == STATE_IDLE and cart.direction == 0 then
		for level, dir in pairs( cart.destinations ) do
			local floor = self.floors[ level ]
			if floor then
				return floor.position, floor.floor_num
			end
		end
		return
	end
	
	local pos, lvl
	if cart.direction > 0 then
		for level, dir in pairs( cart.destinations ) do
			local floor = self.floors[ level ]
			if floor and (dir == true || dir >= 0 || floor.dirOptions != 0) then
				if floor.position > cart.position then
					if !pos then
						pos = floor.position
						lvl = floor.floor_num
					elseif floor.position < pos then
						pos = floor.position
						lvl = floor.floor_num
					end
				end
			end
		end
	elseif cart.direction < 0 then
		for level, dir in pairs( cart.destinations ) do
			local floor = self.floors[ level ]
			if floor and (dir == true || dir <= 0 || floor.dirOptions != 0) then
				if floor.position < cart.position then
					if !pos then
						pos = floor.position
						lvl = floor.floor_num
					elseif floor.position > pos then
						pos = floor.position
						lvl = floor.floor_num
					end
				end
			end
		end
	end
	
	if !pos then
		for level, dir in pairs( cart.destinations ) do
			local floor = self.floors[ level ]
			if floor then
				if !pos then
					pos = floor.position
					lvl = floor.floor_num
				elseif	math.abs( floor.position - cart.position ) <
					math.abs( pos - cart.position )	then
					pos = floor.position
					lvl = floor.floor_num
				end
			end
		end
	end
	
	return pos, lvl
	
end

function ENT:StartTouch( ent )
	
	if ent:GetClass() == "func_door" then
		if ent.floor then
			self.floors[ ent.floor.floor_num ] = ent.floor
			ent.floor.shaft = self
			if ent.floor.caller then
				ent.floor.caller.access_rank = self.access_rank
			end
			if ent.floor.controller then
				ent.floor.controller.shaft = self
				ent.floor.controller.access_rank = self.access_rank
			end
		end
		ent.shaft = self
		return
	end
	
	if (ent:IsPlayer() and !IsValid(ent:GetVehicle())) ||
			(	IsValid(ent:GetPhysicsObject())		and
				type(ent:GetPhysicsObject())!="IPhysicsObject"	and
				!IsValid(ent:GetParent())			and
				ent:GetClass() != "func_button"			) then
		self.contents[ ent:EntIndex() ] = ent
		ent.elevator = self
	end
	
	if ent:IsPlayer() then
		if ent:GetRank() < self.access_rank then
			ent.enteringlounge = true
			ent:Spawn()
			return
		else
			-- umsg.Start( "sndScape.Update", ent )
				-- umsg.Short( SNDSCAPE_ELEVATOR )
			-- umsg.End()
		end
	end
	
end

function ENT:EndTouch( ent )
	
	self.contents[ ent:EntIndex() ] = nil
	ent.elevator = nil
	
	-- if ent:IsPlayer() then
		-- umsg.Start( "sndScape.Update", ent )
			-- umsg.Short( SNDSCAPE_PREVIOUS )
		-- umsg.End()
	-- end
	
end

function ENT:AcceptInput( input, pl, ent )
	
end