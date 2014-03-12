MINIGAME.Time = 60

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

function MINIGAME:Finish(timeLimit, winner)
	self.BaseClass.Finish(self, timeLimit)
	
	if (IsValid(winner)) then
		self:AnnounceWin(winner)
	end
	
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

function MINIGAME:CanPlayerSuicide(player)
	return false
end