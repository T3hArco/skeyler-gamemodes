
AddCSLuaFile()
DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName			= "Deathrun Player"

PLAYER.WalkSpeed 			= 250		-- How fast to move when not running
PLAYER.RunSpeed				= 250		-- How fast to move when running
PLAYER.CrouchedWalkSpeed 	= 0.6
PLAYER.DuckSpeed			= 0.4		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.01		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 268.4     -- How powerful our jump should be
PLAYER.AvoidPlayers			= false

--
-- Called serverside only when the player spawns
--
function PLAYER:Spawn()
	if self.Player:Team() == TEAM_DEATH then 
		self.Player:SetModel("models/player/death.mdl") 
	else 
		hook.Call("PlayerSetModel", GAMEMODE, self.Player) 
	end 

	self.Player:SetHull(Vector(-16, -16, 0), Vector(16, 16, 62)) 
	self.Player:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45)) 
	self.Player:SetViewOffset(Vector(0, 0, 64)) 
	self.Player:SetViewOffsetDucked(Vector(0, 0, 47)) 
end

--
-- Called on spawn to give the player their default loadout
--
function PLAYER:Loadout()
	self.Player:StripWeapons()
	self.Player:StripAmmo() 

	if self.Player:Team() == TEAM_RUNNER then 
		self.Player:Give("weapon_crowbar") 
	elseif self.Player:Team() == TEAM_DEATH then 
		self.Player:Give("weapon_scythe") 
	end 
end


player_manager.RegisterClass( "player_deathrun", PLAYER, "player_default" )