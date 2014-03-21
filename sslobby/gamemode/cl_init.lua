include("shared.lua")
include("player_class/player_sslobby.lua")
include("cl_scoreboard.lua") 

include("modules/sh_link.lua")
include("modules/cl_link.lua")
include("modules/sh_chairs.lua")
include("modules/cl_chairs.lua")
include("modules/cl_worldpicker.lua")
include("modules/sh_minigame.lua")
include("modules/cl_minigame.lua")
include("modules/cl_worldpanel.lua")
include("modules/sh_leaderboard.lua")
include("modules/cl_leaderboard.lua")
include("modules/sh_sound.lua")

SS.Lobby.ScreenDistance = CreateClientConVar("sslobby_screendistance", "2048", true)
SS.Lobby.MusicVolume = CreateClientConVar("sslobby_musicvolume", "20", true)

---------------------------------------------------------
--
---------------------------------------------------------

function GM:InitPostEntity()
	local music = SS.Lobby.Sound.New("lobby_music", LocalPlayer(), "skeyler/lounge/lobby01.mp3", false)
end

---------------------------------------------------------
--
---------------------------------------------------------

function GM:HUDPaint()
	self.BaseClass:HUDPaint()
end