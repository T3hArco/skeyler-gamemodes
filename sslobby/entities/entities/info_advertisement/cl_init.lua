include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local texture = surface.GetTextureID("skeyler/graphics/ad_default")
local textureWide = surface.GetTextureID("skeyler/graphics/ad_default_wide")

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	local angles = self:GetAngles()
	
	self.cameraAngle = Angle(0, angles.y +90, angles.p +90)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Draw()
	local width, height = self:GetWidth(), self:GetHeight()
	
	self.cameraPosition = self:GetPos() +self:GetForward() *0.2 +self:GetRight() *width *0.5 +self:GetUp() *height *0.5
	
	local distance = LocalPlayer():EyePos():Distance(self.cameraPosition)
	local maxDistance = SS.Lobby.ScreenDistance:GetInt()
	
	if (distance <= maxDistance) then
		if (!self.setup) then
			if (width) then
				self.texture = width > 64 and textureWide or texture
			end

			local boundsMin, boundsMax = self:WorldToLocal(self.cameraPosition), self:WorldToLocal(self.cameraPosition + self.cameraAngle:Forward()*(width) + self.cameraAngle:Right()*(height) + self.cameraAngle:Up())

			self:SetRenderBounds(boundsMin, boundsMax)
		
			self.setup = true
		else
			cam.Start3D2D(self.cameraPosition, self.cameraAngle, 1)
				draw.Texture(0, 0, width, height, color_white, self.texture)
			cam.End3D2D()
		end
	end
end