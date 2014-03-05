include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local no_entry = Material("overlays/vip_entry")

--------------------------------------------------
--
--------------------------------------------------

function ENT:Initialize()
	local bounds = Vector(512, 512, 512)
	
	self.color = Color(255, 255, 255)
	
	self:SetRenderBounds(bounds *-1, bounds)
end

--------------------------------------------------
--
--------------------------------------------------

function ENT:Draw()
	local hasAccess = self:PlayerHasAccess(LocalPlayer())
	
	if (!hasAccess) then
		local position = self:GetPos() +self:GetUp() *54
		local distance = LocalPlayer():EyePos():Distance(position)
		
		if (distance <= 500) then
			local direction = self:GetForward()
			
			self.color.a = 255 *(500 -distance) /500
			
			render.SetMaterial(no_entry)
			render.DrawQuadEasy(position, direction, 64, 64, self.color)
			render.DrawQuadEasy(position, direction *-1, 64, 64, self.color)
		end
	end
end