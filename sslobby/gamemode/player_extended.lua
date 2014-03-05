--------------------------------------------------
--
--------------------------------------------------

local slapSound = Sound("ambient/voices/citizen_punches2.wav")

function PLAYER_META:Slap(target)
	local direction = (self:GetPos() -target:GetPos()):GetNormal()
	
	target:SetVelocity(direction *128)
	target:EmitSound(slapSound)
	
	self.nextSlap = CurTime() +0.5
	
	local minigame = SS.Lobby.Minigame:GetCurrentGame()
	
	minigame = SS.Lobby.Minigame:Get(minigame)
	
	if (minigame) then
		local hasPlayer = minigame:HasPlayer(self)
		
		if (hasPlayer) then
			self.nextSlap = SS.Lobby.Minigame.Call("PlayerSlap", self, target, self.nextSlap)
		end
	end
end

--------------------------------------------------
--
--------------------------------------------------

function PLAYER_META:CanSlap(target)
	self.nextSlap = self.nextSlap or 0
	
	local minigame = SS.Lobby.Minigame:GetCurrentGame()
	
	minigame = SS.Lobby.Minigame:Get(minigame)
	
	if (minigame) then
		local hasPlayer = minigame:HasPlayer(self)
		
		if (hasPlayer) then
			self.nextSlap = SS.Lobby.Minigame.Call("CanPlayerSlap", self, target, self.nextSlap)
		end
	end
	
	return self.nextSlap <= CurTime()
end