MINIGAME.Time = 60
MINIGAME.Weapons = {"weapon_frag", "weapon_smg1", "weapon_pistol", "weapon_shotgun"}

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

function MINIGAME:PlayerLoadout(player)
	for k, weapon in pairs(self.Weapons) do
		player:Give(weapon)
	end
	
	player:GiveAmmo(2, "grenade")
	player:GiveAmmo(500, "smg1")
	player:GiveAmmo(500, "pistol")
	player:GiveAmmo(1, "SMG1_Grenade")
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