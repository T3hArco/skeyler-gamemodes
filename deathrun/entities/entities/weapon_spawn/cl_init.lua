-------------------------
-- Sassilization SMG
-- Spacetech
-------------------------

include("shared.lua")

ENT.AddPos = false
ENT.SpriteColor = Color(50, 100, 150, 255)
ENT.ShineMat = Material("effects/blueflare1")
ENT.PickupMat = Material("effects/select_ring")

local Size = false

local QuadSize = 50
local CircleSize = 75

-- Based on Rambos powerup
-- ^ <3
function ENT:Draw()
	self.Entity:SetAngles(Angle(0, RealTime() * 50, 0))
	
	self.Entity:DrawModel()
	
	Size = (math.sin(5 * CurTime()) * 20) + CircleSize
	render.SetMaterial(self.ShineMat)
	render.DrawSprite(self.Entity:GetPos(), Size, Size, self.SpriteColor)
	
	render.SetMaterial(self.PickupMat)
	render.DrawQuadEasy(self.Entity:GetPos(), vector_up, QuadSize, QuadSize, self.SpriteColor)
end

function ENT:DrawTranslucent()
	self:Draw()
end
