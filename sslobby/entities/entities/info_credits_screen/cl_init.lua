include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local texture = surface.GetTextureID("skeyler/graphics/info_developers")

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	local angles = self:GetAngles()
	local bounds = Vector(1, 1, 1) *math.Max(1280, 640) *0.36
	
	self.cameraAngle = Angle(0, angles.y +90, angles.p +90)
	self.cameraPosition = self:GetPos() +self:GetForward() *0.2 +self:GetRight() *128 *0.5 +self:GetUp() *71.25 *0.5

	self:SetRenderBounds(bounds *-1, bounds)
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Draw()
	local distance = LocalPlayer():EyePos():Distance(self.cameraPosition)
	local maxDistance = SS.Lobby.ScreenDistance:GetInt()
	
	if (distance <= maxDistance) then
		cam.Start3D2D(self.cameraPosition, self.cameraAngle, 0.1)
			draw.Texture(0, 0, 1280, 640, color_white, texture)
		cam.End3D2D()
	end
end