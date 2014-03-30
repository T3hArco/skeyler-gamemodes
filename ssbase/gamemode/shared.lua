---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

DeriveGamemode("base") 

GM.Name 		= "SSBase"
GM.Author 		= "Skeyler Servers"
GM.Email 		= "info@skeyler.com"
GM.Website 		= "skeyler.com"
GM.TeamBased 	= false 

GM.VIPBonusHP = false 
GM.HUDShowVel = false 
GM.HUDShowTimer = false 
SS = {}
PLAYER_META = FindMetaTable("Player")
ENTITY_META = FindMetaTable("Entity")
TEAM_SPEC = TEAM_SPECTATOR

team.SetUp(TEAM_SPEC, "Spectator", Color(150, 150, 150), false) 

PLAYER_META.Alive2 = PLAYER_META.Alive2 or PLAYER_META.Alive 
function PLAYER_META:Alive() 
	if self:Team() == TEAM_SPEC then return false end 
	return self:Alive2() 
end 
 
-- Atlas chat shared config.
if (atlaschat) then

	-- We don't want rank icons or avatars.
	atlaschat.enableAvatars = atlaschat.config.New("Enable avatars?", "avatars", false, true, true, true, true)
	atlaschat.enableRankIcons = atlaschat.config.New("Enable rank icons?", "rank_icons", false, true, true, true, true)
end

function GM:CalcMainActivity( ply, velocity )	

	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1

	if ( self:HandlePlayerNoClipping( ply, velocity ) ||
		self:HandlePlayerDriving( ply ) ||
		self:HandlePlayerVaulting( ply, velocity ) ||
		self:HandlePlayerDucking( ply, velocity ) ||
		self:HandlePlayerSwimming( ply, velocity ) ) then

	else

		local len2d = velocity:Length2D()
		if ( len2d > 150 ) then ply.CalcIdeal = ACT_MP_RUN elseif ( len2d > 0.5 ) then ply.CalcIdeal = ACT_MP_WALK end

	end

	ply.m_bWasOnGround = ply:IsOnGround()
	ply.m_bWasNoclipping = ( ply:GetMoveType() == MOVETYPE_NOCLIP && !ply:InVehicle() )

	return ply.CalcIdeal, ply.CalcSeqOverride

end

function GM:DoAnimationEvent( ply, event, data )
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
	
		if ply:Crouching() then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, true )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE, true )
		end
		
		return ACT_VM_PRIMARYATTACK
	
	elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
	
		-- there is no gesture, so just fire off the VM event
		return ACT_VM_SECONDARYATTACK
		
	elseif event == PLAYERANIMEVENT_RELOAD then
	
		if ply:Crouching() then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH, true )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND, true )
		end
		
		return ACT_INVALID
		
	elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
	
		ply:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
		
		return ACT_INVALID
	end

	return nil
end