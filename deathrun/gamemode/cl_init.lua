---------------------------
--        Deathrun       -- 
-- Created by xAaron113x --
--------------------------- 

include("shared.lua")
include("sh_meta.lua") 
include("sh_library.lua") 
include("player_class/player_deathrun.lua")

SS.Scoreboard.SortRight = true 

timer.Create("HullstuffSadface",5,0,function()
	if(LocalPlayer() && LocalPlayer():IsValid() && LocalPlayer().SetHull && LocalPlayer().SetHullDuck) then
		if(LocalPlayer().SetViewOffset && LocalPlayer().SetViewOffsetDucked && !viewset) then
			LocalPlayer():SetViewOffset(Vector(0, 0, 64))
			LocalPlayer():SetViewOffsetDucked(Vector(0, 0, 47))
			viewset = true
		end
		LocalPlayer():SetHull(Vector(-16, -16, 0), Vector(16, 16, 62))
		LocalPlayer():SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45))
	end
end)
