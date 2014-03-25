---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

local TIMES = {} 

function PLAYER_META:InitTimer() 
	self.STimer = {} 
	self.STimer.StartTime = CurTime()  
	self.STimer.EndTime = false 
	self.STimer.TotalTime = false 
	self.STimer.Finished = false 
end 

function PLAYER_META:StartTimer() 
	if self:IsTimerRunning() then return end 
	if !self:HasTimer() then 
		self:InitTimer() 
	else 
		self:ResumeTimer() 
	end 
	self:SetNetworkedInt("STimer_StartTime", self:GetStartTime()) 
	if self:HasFinishedTimer() then 
		self:SetNetworkedInt("STimer_EndTime", self:GetEndTime()) 
		self:SetNetworkedInt("STimer_TotalTime", self:GetTotalTime()) 
	end 
	self:SaveTimer()
end 

function PLAYER_META:SetPB(time)
	self:SetNetworkedInt("STimer_PB", time) 
end

-- They completed whatever they were doing
function PLAYER_META:EndTimer() 
	if !self:HasTimer() then return end 
	self.STimer.EndTime = CurTime() 
	self.STimer.TotalTime = (self:GetEndTime()-self:GetStartTime()) 
	self.Finished = true 
	self:SaveTimer()

	self:SetNetworkedInt("STimer_EndTime", self:GetEndTime()) 
	self:SetNetworkedInt("STimer_TotalTime", self:GetTotalTime())
end 

function PLAYER_META:HasFinishedTimer() 
	return (self.STimer and self.STimer.Finished)
end 

function PLAYER_META:HasTimer() 
	return tobool(((self.STimer and self.STimer.StartTime) or TIMES[self:SteamID()] ))
end 

function PLAYER_META:IsTimerRunning() 
	if self.STimer and self.STimer.StartTime and !self.STimer.EndTime and !self.STimer.TotalTime then 
		return true 
	end 
	return false 
end 

function PLAYER_META:PauseTimer() 
	if !self:HasTimer() then return end 
	self.STimer.EndTime = CurTime() 
	self:SaveTimer()

	self:SetNetworkedInt("STimer_StartTime", 0)
	self:SetNetworkedInt("STimer_EndTime", 0) 
	self:SetNetworkedInt("STimer_TotalTime", 0)
end 

function PLAYER_META:ResetTimer() 
	self.STimer = false 
	TIMES[self:SteamID()] = false 

	self:SetNetworkedInt("STimer_StartTime", 0)
	self:SetNetworkedInt("STimer_EndTime", 0) 
	self:SetNetworkedInt("STimer_TotalTime", 0)
end 

function PLAYER_META:ResumeTimer() 
	if TIMES[self:SteamID()] then self.STimer = TIMES[self:SteamID()] end 
	if !self:HasTimer() or self:HasFinishedTimer() or !self:GetEndTime() then return end 
	self.STimer.StartTime = (CurTime()-(self:GetEndTime()-self:GetStartTime()))
	self.STimer.EndTime = false 
end 

function PLAYER_META:GetTotalTime(String) 
	local Return = false 
	if self:HasFinishedTimer() then 
		Return = self.STimer.TotalTime 
	else 
		Return = (CurTime()-self:GetStartTime())
	end 

	if String then 
		return tostring(Return) 
	else 
		return Return 
	end 
end 

function PLAYER_META:GetStartTime(String) 
	if !self.STimer then return false end 
	if self.STimer.StartTime then 
		if String then 
			return tostring(self.STimer.StartTime) 
		else 
			return self.STimer.StartTime 
		end  
	else 
		return false  
	end 
end 

function PLAYER_META:GetEndTime(String) 
	if self.STimer.EndTime then 
		if String then 
			return tostring(self.STimer.EndTime) 
		else 
			return self.STimer.EndTime 
		end  
	else 
		return false  
	end 
end 

function PLAYER_META:SaveTimer() 
	TIMES[self:SteamID()] = self.STimer
end 


	