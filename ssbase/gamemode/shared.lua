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