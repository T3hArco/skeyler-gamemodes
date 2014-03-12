MINIGAME.Time = 15

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Start()
	print(self.Name .. " has started.")
	
	self.BaseClass.Start(self)
	
	for k, player in pairs(self.players) do
		player.jumps = 0
		player.jumpVelocity = 0
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Finish(timeLimit)
	for k, player in pairs(self.players) do
		player.jumps = nil
		player.jumpVelocity = nil
	end
	
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

function MINIGAME:KeyPress(player, key)
	if (key == IN_JUMP and player:IsOnGround()) then
		player.jumps = player.jumps +1
		player.jumpVelocity = player.jumpVelocity +128
		
		local velocity = player:GetVelocity()
		local jumpVector = Vector(0, 0, velocity.z +player.jumpVelocity)

		player:SetVelocity(velocity +jumpVector)
		
		if (player.jumps >= 5) then
			self:Finish()
			self:AnnounceWin(player)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:CanPlayerSuicide(player)
	return false
end