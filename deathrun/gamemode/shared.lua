---------------------------
--        Deathrun       -- 
-- Created by xAaron113x --
---------------------------

GM.Name 		= "Deathrun"
GM.Author 		= "xAaron113x"
GM.Email 		= "xaaron113x@gmail.com"
GM.Website 		= "aaron113.pw"
GM.TeamBased 	= false 

DeriveGamemode("ssbase")
DEFINE_BASECLASS("gamemode_ssbase") --for self.BaseClass

TEAM_RUNNERS = 1  
team.SetUp(TEAM_RUNNERS, "Runners", Color(87, 198, 255), false) 

