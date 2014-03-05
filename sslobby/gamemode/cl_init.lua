include("shared.lua")
include("player_class/player_lobby.lua")
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

--surface.PlaySound("sassilization/lobby_music.mp3")

local camHeight =1778

function GM:HUDPaint()
	self.BaseClass:HUDPaint()
	
--[[
render.RenderView({
        x = 0,
        y = 0,
        w = 0,
        h = 0,
        dopostprocess = false,
        drawhud = false,
        drawmonitors = false,
        drawviewmodel = false,
        ortho = true,
        ortholeft = -camHeight/2,
        orthobottom = camHeight/2,
        orthoright = camHeight/2,
        orthotop = -camHeight/2,
        origin = EyePos(),
        angles = Angle(90, 0, 0),
        aspectratio = 1,
        znear = 288,
        zfar = 100000
    })
	]]
end