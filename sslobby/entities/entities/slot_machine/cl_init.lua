include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self.spinner_left = ClientsideModel("models/sam/spinner.mdl")
	self.spinner_middle = ClientsideModel("models/sam/spinner.mdl")
	self.spinner_right = ClientsideModel("models/sam/spinner.mdl")
end

---------------------------------------------------------
--
---------------------------------------------------------

surface.CreateFont("ss.slot.machine", {font = "Arvil Sans", size = 120, weight = 400, blursize = 1})

local baseTexture = Material("models/sam/slotmachine/spinner")
local sheetTexture = CreateMaterial("ss_slot_machine_sheet", "UnlitGeneric", {
	["$basetexture"] = baseTexture:GetString("$basetexture"),
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1"
})

local sheet = {}

sheet[1] = {startU = 0.4, 	startV = 0.68, 	endU = 0.8, 	endV = 0.99} 	-- Clock.
sheet[2] = {startU = 0, 	startV = 0, 	endU = 0.38, 	endV = 0.3} 	-- Sassilization.
sheet[3] = {startU = 0.79, 	startV = 0, 	endU = 0.39, 	endV = 0.32} 	-- Lemon.
sheet[4] = {startU = 0, 	startV = 0.3, 	endU = 0.4, 	endV = 0.68} 	-- Strawberry.
sheet[5] = {startU = 0, 	startV = 0.68, 	endU = 0.4, 	endV = 0.99} 	-- Melon.
sheet[6] = {startU = 0.4, 	startV = 0.3, 	endU = 0.77, 	endV = 0.68} 	-- Cherry.

function ENT:Draw()
	self:DrawModel()
	self:FrameAdvance(FrameTime())
	
	local angles = self:GetAngles()
	
	self.cameraAngle = Angle(angles.p, angles.y +90, angles.r +90)
	self.cameraPosition = self:GetPos() +(self:GetRight() *9.6) +(self:GetUp() *75) -(self:GetForward() *1)
	
	cam.Start3D2D(self.cameraPosition, self.cameraAngle, 0.1)
		surface.SetMaterial(sheetTexture)
		surface.SetDrawColor(color_white)
		
		local x, y = 0, 0
		
		for i = 1, #self.winDefines do
			local slots = self.winDefines[i]
			
			local info
			
			if (slots.slots[1] > 0) then
				info = sheet[slots.slots[1]]
				
				surface.DrawTexturedRectUV(x, y, 16, 16, info.startU, info.startV, info.endU, info.endV)
				
				x = x +18
			end
			
			if (slots.slots[2] > 0) then
				info = sheet[slots.slots[2]]

				surface.DrawTexturedRectUV(x, y, 16, 16, info.startU, info.startV, info.endU, info.endV)
				
				x = x +18
			end
			
			
			if (slots.slots[3] > 0) then
				info = sheet[slots.slots[3]]
			
				surface.DrawTexturedRectUV(x, y, 16, 16, info.startU, info.startV, info.endU, info.endV)
				
				x = x +18
			end

			x = x +18
			
			if (x >= 110) then
				y = y +18
				x = 0
			end
		end
	cam.End3D2D()
	
	cam.Start3D2D(self.cameraPosition, self.cameraAngle, 0.01)
		local x, y = 70, 70
		
		for i = 1, #self.winDefines do
			local slots = self.winDefines[i]
			
			local info
			
			if (slots.slots[1] > 0) then
				x = x +120
			end
			
			if (slots.slots[2] > 0) then
				x = x +420
			end
			
			
			if (slots.slots[3] > 0) then
				x = x +170
			end
			
			draw.SimpleText("= " .. slots.win, "ss.slot.machine", x+2, y +12, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText("= " .. slots.win, "ss.slot.machine", x, y +8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			if (x >= 1010) then
				y = y +180
				x = -160
			end
		end
	cam.End3D2D()
end

---------------------------------------------------------
--
---------------------------------------------------------

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
	
	self:EmitSound("lounge/slotmachine/lever.mp3")
	
	timer.Simple(0.2, function()
		self:EmitSound("lounge/slotmachine/spinning.mp3")
	end)
end

---------------------------------------------------------
--
---------------------------------------------------------

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
			self:EmitSound("lounge/slotmachine/stop.mp3")
			
			self.stopLeft = true
		end
		
		if (self.startMiddle >= targetMiddle and !self.stopMiddle) then
			self:EmitSound("lounge/slotmachine/stop.mp3")
			
			self.stopMiddle = true
		end
		
		if (self.startRight >= targetRight and !self.stopRight) then
			surface.PlaySound("lounge/slotmachine/stop.mp3")
			
			self.stopRight = true
		end
		
		if (self.wasWin and self.startLeft >= targetLeft and self.startMiddle >= targetMiddle and self.startRight >= targetRight) then
			self:EmitSound("lounge/slotmachine/jackpot.mp3")
			
			self.wasWin = nil
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

net.Receive("ss_pullslotmc", function(bits)
	local randomLeft = net.ReadUInt(4)
	local randomMiddle = net.ReadUInt(4)
	local randomRight = net.ReadUInt(4)
	local entity = net.ReadEntity()
	
	local wasWin = false

	for k, data in pairs(entity.winDefines) do
		local winCount, winRequired = 0, 0
		
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