---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Start()
	print(self.Name .. " has started.")
	
	self:SpawnIce()
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Finish(timeLimit)
	self.BaseClass.Finish(self, timeLimit)
	
	self:RemoveIce()
	
	print(self.Name .. " has finished.")
	
	--hook.Run("PlayerSelectSpawn", Entity(1))
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:PlayerDeath(victim, inflictor, attacker)
	timer.Simple(0.1, function()
		local alive = 0
		
		for k, player in pairs(self.players) do
			if (IsValid(player) and player:Alive()) then
				alive = alive +1
			end
		end
		
		if (alive <= 0) then
			self:Finish()
			self:AnnounceWin(victim)
		end
	end)
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