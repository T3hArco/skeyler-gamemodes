include("shared.lua")

local texture = surface.GetTextureID("sassilization/adverts2/advert000")
local textureWide = surface.GetTextureID("sassilization/adverts2/advert000_wide")

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Draw()
	local width, height = self:GetWidth(), self:GetHeight()
	
	if (!self.setup) then
		if (width) then
			if (width > 64) then
				self.texture = textureWide
			else
				self.texture = texture
			end
		end
		
		self.CamPos = self:GetPos() +self:GetForward() *0.2 +self:GetRight() *width *0.5 +self:GetUp() *height *0.5
	
		local angles = self:GetAngles()
		self.CamAng = Angle(0, angles.y +90, angles.p +90)
		
		self.Bounds = Vector(1, 1, 1) *math.Max(width, height) *0.36
		self:SetRenderBounds(self.Bounds *-1, self.Bounds)
	
		self.setup = true
	else
		cam.Start3D2D(self.CamPos, self.CamAng, 1)
			surface.SetDrawColor(color_white)
			surface.SetTexture(self.texture)
			surface.DrawTexturedRect(0, 0, width , height)
		cam.End3D2D()
	end
end
