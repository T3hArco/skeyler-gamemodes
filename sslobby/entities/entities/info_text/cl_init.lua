include("shared.lua")

surface.CreateFont("ss.infoText.1", {
	font 		= "Calibri",
	size 		= 50,
	weight 		= 600
})

surface.CreateFont("ss.infoText.2", {
	font 		= "Calibri",
	size 		= 140,
	weight 		= 400,
	blursize 	= 1
})

surface.CreateFont("ss.infoText.3", {
	font 		= "Calibri",
	size 		= 160,
	weight 		= 600
})

surface.CreateFont("ss.infoText.4", {
	font 		= "Calibri",
	size 		= 250,
	weight 		= 600
})

surface.CreateFont("ss.infoText.5", {
	font 		= "Calibri",
	size 		= 300,
	weight 		= 600
})

------------------------------------------------
--
------------------------------------------------

function ENT:Initialize()
	self.upDown = math.Rand(1, 3) -- up/down max
	self.offset = math.Rand(0, 6) -- offset
	
	local angles = self:GetAngles()
	
	self.camAngles = Angle(angles.r, angles.y +90, angles.p +90)
end

------------------------------------------------
--
------------------------------------------------

function ENT:Draw()
	local position = self:GetPos()
	local distance = LocalPlayer():EyePos():Distance(position)
	
	if (distance <= 750) then
		local alpha = 255 *(750 -distance) /750
		local angles = self:GetAngles()
		local text, font = self:GetText(), "ss.infoText." .. self:GetTextSize()
		
		local color_text = Color(255, 255, 255, alpha)
		local color_shadow = Color(0, 0, 0, alpha)
		
		local camPosition = position +self:GetForward() *(0.1 +math.sin(CurTime() +self.offset)) +self:GetRight() +self:GetUp() *(math.cos(CurTime() +self.offset)) *self.upDown

		cam.Start3D2D(camPosition, self.camAngles, 0.1)
			draw.SimpleText(text, font, 2, 2, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(text, font, 0, 0, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end
