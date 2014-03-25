---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

ENT.Type = "anim"
ENT.Base = "base_anim"

local Laser = Material("skeyler/solidbeam.png")
local Col = Color(0, 255, 0, 255)

function ENT:Initialize() 
end 

function ENT:Think() 
	local Min, Max = self:GetCollisionBounds()
	self:SetRenderBounds(Min, Max) 
end 

function ENT:Draw() 
	local Min, Max = self:GetCollisionBounds()
	Min=self:GetPos()+Min 
	Max=self:GetPos()+Max

	local Pos = self:GetPos()
	local Z = Pos.z

	local C1, C2, C3, C4 = Vector(Min.x, Min.y, Z), Vector(Min.x, Max.y, Z), Vector(Max.x, Max.y, Z), Vector(Max.x, Min.y, Z) 
	
	render.SetMaterial(Laser)
	render.DrawBeam(C1, C2, 5, 0, 1, Col) 
	render.DrawBeam(C2, C3, 5, 0, 1, Col)
	render.DrawBeam(C3, C4, 5, 0, 1, Col)
	render.DrawBeam(C4, C1, 5, 0, 1, Col)
end 