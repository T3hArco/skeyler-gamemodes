---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

GM.Levels = {} 

function GM:AddLevel(id, name, gravity, staytime, award, respawntime) 
	GM.Levels[id] = {id=id, name=name, gravity=gravity, staytime=staytime, award=award, respawntime=respawntime} 
end 

LEVEL_EASY = 1 
LEVEL_NORMAL = 2 
LEVEL_NIGHTMARE = 3 

GM:AddLevel(LEVEL_EASY, "Easy", 0.925, 0.8, 0.5, 0.7) --uses a different method to enable multihop
GM:AddLevel(LEVEL_NORMAL, "Normal", 1, 0.08, 1, 0.7) --allows jumping between two blocks but not multihop
GM:AddLevel(LEVEL_NIGHTMARE, "Hard", 1, 0.02, 1.2, 4) --blocks take ages to respawn = onehop (but they will have to wait a while in some cases for block to regen)