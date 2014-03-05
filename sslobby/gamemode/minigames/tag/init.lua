---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Start()
	print(self.Name .. " has started.")
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

function MINIGAME:PlayerSlap(player, target, nextSlap)
	self:RemovePlayer(target)
	self:RespawnPlayer(target)
	
	if (#self.players <= 1) then
		self:Finish()
	end
	
	return nextSlap
end