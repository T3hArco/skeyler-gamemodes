MINIGAME.Time = 70

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Initialize()
	self.BaseClass.Initialize(self)
	
	local entity = ents.FindByClass("info_minigame_headsup")[1]

	if (IsValid(entity)) then
		local position = entity:GetPos()
		local min, max = Vector(-472, -472, 0), Vector(472, 472, 0)
		
		self.spawnOrigin = {position, min, max}
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:Start()
	print(self.Name .. " has started.")
	
	self.nextDrop = CurTime() +1
	self.bombVelocity = 0.1
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

function MINIGAME:Think()
	if (self.nextDrop <= CurTime() and self.spawnOrigin) then
		local data = self.spawnOrigin
		
		self.bombVelocity = math.Clamp(self.bombVelocity -0.5, -15, 0)
	
		for i = 4, math.random(10, 16) do
			local position = Vector(data[1].x +math.random(data[2].x, data[3].x), data[1].y +math.random(data[2].y, data[3].y), data[1].z)
			
			local entity = ents.Create("info_minigame_bomb")
			entity:SetPos(position)
			entity:Spawn()

			timer.Simple(0, function()
				local physicsObject = entity:GetPhysicsObject()
		
				if (IsValid(physicsObject)) then
					physicsObject:SetVelocity(Vector(0, 0, self.bombVelocity))
				end
			end)
		end
		
		self.nextDrop = CurTime() +5
	end
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

function MINIGAME:HasRequirements(players, teams)
	return true
	--return teams >= 2
end