include("shared.lua")

local textureButton = surface.GetTextureID("elevator/button")
local textureButtonArrow = surface.GetTextureID("elevator/button_arrow")
local textureButtonPushed = surface.GetTextureID("elevator/button_selected")

surface.CreateFont("ss.elevator.number", {font = "Tahoma", size = 12, antialias = false})

------------------------------------------------
--
------------------------------------------------

function ENT:Initialize()
	local angles = self:GetAngles()
	
	self.cameraAngle =  Angle(0, angles.y +90, angles.p +90)
	self.cameraPosition = self:GetPos() +self:GetForward() *0.2 -self:GetRight() *self.mins.y +self:GetUp() *self.maxs.z
	
	self:SetRenderBounds(self.mins, self.maxs) 
	
	timer.Simple(0.5,function()
		local id = self:GetElevatorID()
		local elevators = ents.FindByClass("info_elev")
		local buttonPosition = self:GetPos()

		for k, elevator in pairs(elevators) do
			local elevatorID = elevator:GetID()
			
			if (elevatorID == id) then
				local position = elevator:GetPos()

				if (position.z > buttonPosition.z) then
					self.rotation = 1
				else
					self.rotation = 0
				end
			end
		end
	end)
end

------------------------------------------------
--
------------------------------------------------

function ENT:Draw()
	local id = self:GetElevatorID()
	local pressed = self:GetPressed()
	local angles = self:GetAngles()
	local inside = math.Round(angles.y) == -180
	
	cam.Start3D2D(self.cameraPosition, self.cameraAngle, 0.1)
		surface.SetDrawColor(255, 255, 255, 255)

		surface.SetTexture(pressed and textureButtonPushed or textureButton)
		surface.DrawTexturedRect(24, 24, 32, 32)
		
		if (inside) then
			surface.SetTexture(textureButtonArrow)
			surface.DrawTexturedRectRotated(40, 40, 32, 32, (self.rotation == 1 and 90 or -90))
		end
		
		draw.SimpleText(id, "ss.elevator.number", 40, 39, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

------------------------------------------------
--
------------------------------------------------

function ENT:Use(player, x, y, scale)
	net.Start("ss.lbelcall")
		net.WriteEntity(self)
	net.SendToServer()
end

------------------------------------------------
--
------------------------------------------------

local nextUse = 0

hook.Add("KeyPress", "ss.elevator.press", function(player, key)
	if (key == IN_USE) then
		if (nextUse <= CurTime()) then
			local buttons = ents.FindByClass("elev_caller")
	
			local trace = {}
			trace.start = player:EyePos()
			trace.endpos = trace.start +player:GetAimVector() *64
			trace.mask = MASK_SOLID_BRUSHONLY
			
			trace = util.TraceLine(trace)
			
			for k, button in pairs(buttons) do
				local x, y = button:GetCursorPosition(player, 10, trace.HitPos)
				
				if (x and y) then
					button:Use(player, x, y, 10)
				end
			end
			
			nextUse = CurTime() +0.1
		end
	end
end)