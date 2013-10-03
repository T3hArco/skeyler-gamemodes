---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

GM.Levels = {} 

function GM:AddLevel(id, name, gravity, staytime, award, kill) 
	GM.Levels[id] = {id=id, name=name, gravity=gravity, staytime=staytime, award=award, kill=kill} 
end 

LEVEL_EASY = 1 
LEVEL_NORMAL = 2 
LEVEL_NIGHTMARE = 3 

GM:AddLevel(LEVEL_EASY, "Easy", 0.925, 0.5, 0.5)
GM:AddLevel(LEVEL_NORMAL, "Normal", 1, 0.2, 1) 
GM:AddLevel(LEVEL_NIGHTMARE, "Hard", 1, 0.2, 1.2, true) 