--------------------------------------------------
--
--------------------------------------------------

local slapSound = Sound("ambient/voices/citizen_punches2.wav")

function PLAYER_META:Slap(target)
	local direction = (target:GetPos() -self:GetPos()):GetNormal()
	
	target:SetVelocity(direction *256)
	target:EmitSound(slapSound, 100, math.random(65, 90))
	
	self.nextSlap = CurTime() +0.5
	
	local minigameSlap = SS.Lobby.Minigame:CallWithPlayer("PlayerSlap", self, target, self.nextSlap)
	
	if (minigameSlap != nil) then
		self.nextSlap = minigameSlap
	end
end

--------------------------------------------------
--
--------------------------------------------------

function PLAYER_META:CanSlap(target)
	self.nextSlap = self.nextSlap or 0
	
	local minigameSlap = SS.Lobby.Minigame:CallWithPlayer("CanPlayerSlap", self, target, self.nextSlap)
	
	if (minigameSlap != nil) then
		return minigameSlap
	end
	
	return self.nextSlap <= CurTime()
end