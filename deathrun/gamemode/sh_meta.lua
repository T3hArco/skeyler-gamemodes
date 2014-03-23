---------------------------
--        Deathrun       -- 
-- Created by xAaron113x --
---------------------------

local oldalive = PLAYER_META.Alive 
function PLAYER_META:Alive() 
	if self:Team() == TEAM_DEATH or self:Team() == TEAM_RUNNER then 
		return true 
	end 
	return false  
end 