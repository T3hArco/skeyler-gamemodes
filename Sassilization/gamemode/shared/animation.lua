function GM:HandlePlayerJumping( ply, velocity )
	
	-- airwalk more like hl2mp, we airwalk until we have 0 velocity, then it's the jump animation
	-- underwater we're alright we airwalking
	if not ply.m_bJumping and not ply:OnGround() and ply:WaterLevel() <= 0 then
	
		if not ply.m_fGroundTime then
			ply.m_fGroundTime = CurTime()
			
		elseif (CurTime() - ply.m_fGroundTime) > 0 and velocity:Length2D() < 0.5 then
			ply.m_bJumping = true
			ply.m_bFirstJumpFrame = false
			ply.m_flJumpStartTime = 0
		end
	end
	
	if ply.m_bJumping then
	
		if ply.m_bFirstJumpFrame then
			ply.m_bFirstJumpFrame = false
			ply:AnimRestartMainSequence()
		end
		
		if ( ply:WaterLevel() >= 2 ) or
			( (CurTime() - ply.m_flJumpStartTime) > 0.2 and ply:OnGround() ) then
			ply.m_bJumping = false
			ply.m_fGroundTime = nil
			ply:AnimRestartMainSequence()
		end
		
		if ply.m_bJumping then
			ply.CalcIdeal = ACT_MP_JUMP
			return true
		end
	end
	
	return false
end

function GM:HandlePlayerDucking( ply, velocity )

	if ply:Crouching() then
		local len2d = velocity:Length2D()
		
		if len2d > 0.5 then
			ply.CalcIdeal = ACT_MP_CROUCHWALK
		else
			ply.CalcIdeal = ACT_MP_CROUCH_IDLE
		end
		
		return true
	end
	
	return false
end

function GM:HandlePlayerSwimming( ply )

	if ply:WaterLevel() >= 2 then
		if ply.m_bFirstSwimFrame then
			ply:AnimRestartMainSequence()
			ply.m_bFirstSwimFrame = false
		end
		
		ply.m_bInSwim = true
	else
		ply.m_bInSwim = false
		if not ply.m_bFirstSwimFrame then
			ply.m_bFirstSwimFrame = true
		end
	end
	
	return false
end

function GM:HandlePlayerDriving( ply )

	if ply:InVehicle() then
		local pVehicle = ply:GetVehicle()
		
		if ( pVehicle.HandleAnimation ~= nil ) then
		
			local seq = pVehicle:HandleAnimation( ply )
			if ( seq ~= nil ) then
				ply.CalcSeqOverride = seq
				return true
			end
			
		else
		
			local class = pVehicle:GetClass()
			
			if ( class == "prop_vehicle_jeep" ) then
				ply.CalcSeqOverride = ply:LookupSequence( "drive_jeep" )
			elseif ( class == "prop_vehicle_airboat" ) then
				ply.CalcSeqOverride = ply:LookupSequence( "drive_airboat" )
			elseif ( class == "prop_vehicle_prisoner_pod" and pVehicle:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" ) then
				-- HACK
				ply.CalcSeqOverride = ply:LookupSequence( "drive_pd" )
			else
				ply.CalcSeqOverride = ply:LookupSequence( "sit_rollercoaster" )
			end
			
			return true
		end
	end
	
	return false
end

/*---------------------------------------------------------
   Name: gamemode:UpdateAnimation( )
   Desc: Animation updates (pose params etc) should be done here
---------------------------------------------------------*/
function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed )	
	local len2d = velocity:Length2D()
	local rate = 1.0
	
	if len2d > 0.5 then
			rate =  ( len2d / maxseqgroundspeed )
	end
	
	rate = math.min(rate, 2)
	
	ply:SetPlaybackRate( rate )
	
	if ( ply:InVehicle() ) then
		local Vehicle =  ply:GetVehicle()
		
		-- We only need to do this clientside..
		if ( CLIENT ) then
			--
			-- This is used for the 'rollercoaster' arms
			--
			local Velocity = Vehicle:GetVelocity()
			ply:SetPoseParameter( "vertical_velocity", Velocity.z * 0.01 ) 

			-- Pass the vehicles steer param down to the player
			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
			steer = steer * 2 - 1 -- convert from 0..1 to -1..1
			ply:SetPoseParameter( "vehicle_steer", steer  ) 
		end
		
	end
end

function GM:CalcMainActivity( ply, velocity )	
	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1
	
	if self:HandlePlayerDriving( ply ) or
		self:HandlePlayerJumping( ply, velocity ) or
		self:HandlePlayerDucking( ply, velocity ) or
		self:HandlePlayerSwimming( ply ) then
		
	else
		local len2d = velocity:Length2D()
		
		if len2d > 210 then
			ply.CalcIdeal = ACT_MP_RUN
		elseif len2d > 0.5 then
			ply.CalcIdeal = ACT_MP_WALK
		end
	end
	
	-- a bit of a hack because we're missing ACTs for a couple holdtypes
	local weapon = ply:GetActiveWeapon()
	
	if ply.CalcIdeal == ACT_MP_CROUCH_IDLE and
		IsValid(weapon) and
		( weapon:GetHoldType() == "knife" or weapon:GetHoldType() == "melee2" ) then
		
		ply.CalcSeqOverride = ply:LookupSequence("cidle_" .. weapon:GetHoldType())
	end
	
	return ply.CalcIdeal, ply.CalcSeqOverride
end

local IdleActivity = ACT_HL2MP_IDLE
local IdleActivityTranslate = {}
	IdleActivityTranslate [ ACT_MP_STAND_IDLE ] 				= IdleActivity
	IdleActivityTranslate [ ACT_MP_WALK ] 						= IdleActivity+1
	IdleActivityTranslate [ ACT_MP_RUN ] 						= IdleActivity+2
	IdleActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= IdleActivity+3
	IdleActivityTranslate [ ACT_MP_CROUCHWALK ] 				= IdleActivity+4
	IdleActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= IdleActivity+5
	IdleActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= IdleActivity+5
	IdleActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= IdleActivity+6
	IdleActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= IdleActivity+6
	IdleActivityTranslate [ ACT_MP_JUMP ] 						= ACT_HL2MP_JUMP_SLAM
	
-- it is preferred you return ACT_MP_* in CalcMainActivity, and if you have a specific need to not tranlsate through the weapon do it here
function GM:TranslateActivity( ply, act )
	local act = act
	local newact = act -- ply:TranslateWeaponActivity( act )
	
	-- select idle anims if the weapon didn't decide
	if ( act == newact ) then
		return IdleActivityTranslate[ act ]
	else
		return newact
	end
end

function GM:DoAnimationEvent( ply, event, data )
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
	
		if ply:Crouching() then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE )
		end
		
		return ACT_VM_PRIMARYATTACK
	
	elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
	
		-- there is no gesture, so just fire off the VM event
		return ACT_VM_SECONDARYATTACK
		
	elseif event == PLAYERANIMEVENT_RELOAD then
	
		if ply:Crouching() then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND )
		end
		
		return ACT_INVALID
		
	elseif event == PLAYERANIMEVENT_JUMP then
	
		ply.m_bJumping = true
		ply.m_bFirstJumpFrame = true
		ply.m_flJumpStartTime = CurTime()
		
		ply:AnimRestartMainSequence()
		
		return ACT_INVALID
		
	elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
	
		ply:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
		
		return ACT_INVALID
	end

	return nil
end