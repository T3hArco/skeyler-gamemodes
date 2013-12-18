
AddCSLuaFile()
DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName			= "Bhop Player"

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

end

--
-- Called on spawn to give the player their default loadout
--
function PLAYER:Loadout()
	if(self.Player:IsBot()) then
		self.Player:Give("weapon_crowbar_fov") 
	else
		self.Player:Give("weapon_crowbar") 
		self.Player:Give("weapon_pistol")
		self.Player:Give("weapon_smg1") 
		self.Player:Give("weapon_fists") 
	end
	self.Player:Give("weapon_glock")
	if self.Player:IsSuperAdmin() then self.Player:Give("ss_mapeditor") end 
	self.Player:GiveAmmo(999, "Pistol", true) 
	self.Player:GiveAmmo(999, "Smg1", true) 
	
	self.Player:SetAmmo(999, "smg1") --just in case some wierd case sensativity
	self.Player:SetAmmo(999, "pistol") --same with this
	self.Player:SetAmmo(999, "buckshot") --lol
end


player_manager.RegisterClass( "player_bhop", PLAYER, "player_default" )