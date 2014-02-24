include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self.spinner_left = ClientsideModel("models/sam/spinner.mdl")
	self.spinner_middle = ClientsideModel("models/sam/spinner.mdl")
	self.spinner_right = ClientsideModel("models/sam/spinner.mdl")
end

function ENT:Draw()
	self:DrawModel()
	self:FrameAdvance(FrameTime())
end

function ENT:Spin(randomLeft, randomMiddle, randomRight, wasWin)
	self.startLeft = math.random(-5048, -1024)
	self.startMiddle = math.random(-5048, -1024)
	self.startRight = math.random(-5048, -1024)
	
	self.randomLeft = randomLeft
	self.randomMiddle = randomMiddle
	self.randomRight = randomRight
	
	self.wasWin = wasWin
	
	self.stopLeft = false
	self.stopMiddle = false
	self.stopRight = false
end

local offsets = {
	15, -- Clock.
	12, -- Sassilization.
	10, -- Lemon.
	9, 	-- Strawberry.
	3, 	-- Melon.
	-4 	-- Cherry.
}

function ENT:Think()
	if (!self.startLeft or !self.startMiddle or !self.startRight) then return end
	
	if (!IsValid(self.spinner_left) or !IsValid(self.spinner_right) or !IsValid(self.spinner_middle)) then
		self.spinner_left = ClientsideModel("models/sam/spinner.mdl")
		self.spinner_middle = ClientsideModel("models/sam/spinner.mdl")
		self.spinner_right = ClientsideModel("models/sam/spinner.mdl")
	else
		local targetLeft 	= 256 +offsets[self.randomLeft]   +64 *self.randomLeft
		local targetMiddle 	= 256 +offsets[self.randomMiddle] +64 *self.randomMiddle
		local targetRight 	= 256 +offsets[self.randomRight]  +64 *self.randomRight
		
		self.startLeft 	 = math.Approach(self.startLeft,   targetLeft,   12)
		self.startMiddle = math.Approach(self.startMiddle, targetMiddle, 12)
		self.startRight	 = math.Approach(self.startRight,  targetRight,  12)
		
		local angles = self:GetAngles()
		local position = self:GetPos() +angles:Up() *57.5 -angles:Forward() *0.1 +angles:Right() *3.45
		
		local angles_spin = angles
		
		angles_spin = angles_spin +Angle(self.startLeft, 0, 0)
		
		self.spinner_left:SetPos(position)
		self.spinner_left:SetAngles(angles_spin)
		
		local position = self:GetPos() +angles:Up() *57.5 -angles:Forward() *0.1 -angles:Right() *0.1
		
		local angles_spin = angles
		
		angles_spin = angles_spin +Angle(self.startMiddle, 0, 0)
		
		self.spinner_middle:SetPos(position)
		self.spinner_middle:SetAngles(angles_spin)
		
		local position = self:GetPos() +angles:Up() *57.5 -angles:Forward() *0.1 -angles:Right() *3.4
		
		local angles_spin = angles
		
		angles_spin = angles_spin +Angle(self.startRight, 0, 0)
		
		self.spinner_right:SetPos(position)
		self.spinner_right:SetAngles(angles_spin)
		
		if (self.startLeft >= targetLeft and !self.stopLeft) then
			surface.PlaySound("testslot/stop.mp3")
			
			self.stopLeft = true
		end
		
		if (self.startMiddle >= targetMiddle and !self.stopMiddle) then
			surface.PlaySound("testslot/stop.mp3")
			
			self.stopMiddle = true
		end
		
		if (self.startRight >= targetRight and !self.stopRight) then
			surface.PlaySound("testslot/stop.mp3")
			
			self.stopRight = true
		end
		
		if (self.wasWin and self.startLeft >= targetLeft and self.startMiddle >= targetMiddle and self.startRight >= targetRight) then
			surface.PlaySound("testslot/jackpot.mp3")
			
			self.wasWin = nil
		end
	end
end

net.Receive("ss_pullslotmc", function(bits)
	local randomLeft = net.ReadUInt(4)
	local randomMiddle = net.ReadUInt(4)
	local randomRight = net.ReadUInt(4)
	local entity = net.ReadEntity()
	
	local wasWin = false
	local winCount = 0
	local winRequired = 0

	for k, data in pairs(entity.winDefines) do
		if (data.slots[1] > 0) then
			winRequired = winRequired +1
			
			if (randomLeft == data.slots[1]) then
				winCount = winCount +1
			end
		end
		
		if (data.slots[2] > 0) then
			winRequired = winRequired +1
			
			if (randomMiddle == data.slots[2]) then
				winCount = winCount +1
			end
		end
		
		if (data.slots[3] > 0) then
			winRequired = winRequired +1
			
			if (randomRight == data.slots[3]) then
				winCount = winCount +1
			end
		end
		
		if (winCount >= winRequired) then
			wasWin = true
		end
	end

	if (IsValid(entity)) then
		entity:Spin(randomLeft, randomMiddle, randomRight, wasWin)
	end
end)