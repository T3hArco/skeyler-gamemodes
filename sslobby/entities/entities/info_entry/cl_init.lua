----------
-- Lobby
----------

include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local no_entry = Material("overlays/vip_entry")

function ENT:Initialize()
	self.MatPos = self:GetPos() + self:GetUp() * 54
	self.MatDir = self:GetForward()
	self.MatColor = Color(255, 255, 255, 255)
	self:SetRenderBounds(Vector(1, 1, 1) * -64, Vector(1, 1, 1) * 64)
end

function ENT:HasPermission()
	return player.HasFlag && player.HasFlag(LocalPlayer(), self:GetFlag("perm"))
end

function ENT:Draw()
	--if(self:HasPermission()) then
	--	return
	--end
	
	local Distance = LocalPlayer():EyePos():Distance(self.MatPos)
	
	if(Distance >= 500) then
		return
	end
	
	self.MatColor.a = 255 * (500 - Distance) / 500
	
	render.SetMaterial(no_entry)
	render.DrawQuadEasy(self.MatPos, self.MatDir, 64, 64, self.MatColor)
end
