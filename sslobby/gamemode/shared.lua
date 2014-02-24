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
TEAM_YELLOW = 5

team.SetUp(TEAM_JOINING, "Joining", Color(20, 20, 20, 255))
team.SetUp(TEAM_READY, "Ready", Color(80, 80, 80, 255))
team.SetUp(TEAM_RED, "Red", Color(200, 20, 20, 255))
team.SetUp(TEAM_BLUE, "Blue", Color(20, 20, 200, 255))
team.SetUp(TEAM_GREEN, "Green", Color(20, 200, 20, 255))
team.SetUp(TEAM_YELLOW, "Yellow", Color(200, 200, 20, 255))