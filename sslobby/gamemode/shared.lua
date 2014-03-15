DeriveGamemode("ssbase")

GM.Name 		= "Lobby"
GM.Author 		= "Skeyler Development Team"
GM.Email 		= ""
GM.Website 		= "http://skeyler.com/"
GM.TeamBased 	= false 

SS.Lobby = {}

TEAM_JOINING = 0
TEAM_READY = 1
TEAM_RED = 2
TEAM_BLUE = 3
TEAM_GREEN = 4
TEAM_ORANGE = 5

team.SetUp(TEAM_JOINING, "Joining", Color(20, 20, 20, 255))
team.SetUp(TEAM_READY, "Ready", Color(224, 224, 224, 255))
team.SetUp(TEAM_RED, "Red", Color(255, 85, 85, 255))
team.SetUp(TEAM_BLUE, "Blue", Color(69, 192, 255, 255))
team.SetUp(TEAM_GREEN, "Green", Color(143, 230, 101, 255))
team.SetUp(TEAM_ORANGE, "Orange", Color(255, 191, 54, 255))

--------------------------------------------------
--
--------------------------------------------------

function GM:ShouldCollide(entity1, entity2)
	local class = entity1:GetClass()
	
	if (entity2:IsPlayer() and (class == "info_entry" or class == "info_entry_team")) then
		return !entity1:PlayerHasAccess(entity2)
	end
end