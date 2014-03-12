MINIGAME.Time = 120

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Start()
	print(self.Name .. " has started.")
	
	self.BaseClass.Start(self)
	
	self:SpawnIce()
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Finish(timeLimit)
	self.BaseClass.Finish(self, timeLimit)
	
	self:RemoveIce()
	
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

function MINIGAME:DoPlayerDeath(victim, inflictor, dmginfo)
	timer.Simple(0, function()
		self:RemovePlayer(victim)
		
		local won = self:AnnounceWin()
		
		if (won) then
			self:Finish()
		end
	end)
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:CanPlayerSuicide(player)
	return false
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:RemoveIce()
	local ice = ents.FindByClass("info_minigame_ice")
	
	for k, entity in pairs(ice) do
		entity:Remove()
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:SpawnIce()
	self:RemoveIce()
	
	timer.Simple(0.1,function()
		local start = Vector(-7664, -5456, 0)
		local x, y = 0, 0
		
		for i = 1, 256 do
			local vector = Vector(start.x +x, start.y +y, start.z)
			
			local ice = ents.Create("info_minigame_ice")
			ice:SetPos(vector)
			ice:Spawn()
			
			x = x +64
			
			if (i % 16 == 0) then
				x, y = 0, y +64
			end
		end
	end)
end