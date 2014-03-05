---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Start()
	print(self.Name .. " has started.")
	
	--Entity(1):SetPos(Vector(2.706645, 101.346146, 32.031250))
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Finish(timeLimit)
	self.BaseClass.Finish(self, timeLimit)
	
	print(self.Name .. " has finished.")
	
	--hook.Run("PlayerSelectSpawn", Entity(1))
end