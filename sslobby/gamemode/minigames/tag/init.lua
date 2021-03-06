MINIGAME.Time = 120

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Start()
	print(self.Name .. " has started.")
	
	self.BaseClass.Start(self)
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Finish(timeLimit)
	self.BaseClass.Finish(self, timeLimit)
	
	print(self.Name .. " has finished.")
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:HasRequirements(players, teams)
	return teams > 1
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:CanPlayerSlap(player, target, nextSlap)
	if (target:Team() == player:Team()) then
		return false
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:PlayerSlap(player, target, nextSlap)
	timer.Simple(0, function()
		self:RemovePlayer(target)

		local won = self:AnnounceWin()
		
		if (won) then
			self:Finish()
		end
	end)
	
	return nextSlap
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:CanPlayerSuicide(player)
	return false
end