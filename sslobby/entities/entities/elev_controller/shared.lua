ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author = "Sassafrass"
ENT.Contact = "http://sassilization.com"

ENT.Purpose = ""
ENT.Instructions = ""
ENT.PrintName = ""

ENT.Spawnable	= false
ENT.AdminSpawnable = false
ELEV = ELEV or {}
ELEV.controllers = {}

ENT.mins = Vector( -0.1, -8, -12 )
ENT.maxs = Vector( 0.1, 8, 12 )

function ENT:GetCursorPos( pl, scale, pos )
	
	pl = pl or LocalPlayer()
	scale = scale or 1
	
	local tr = {}
	
	if !pos then
		tr.start = pl:EyePos()
		tr.endpos = tr.start + pl:GetAimVector() * 50
		tr.mask = MASK_SOLID_BRUSHONLY
		tr = util.TraceLine( tr )
	end
	
	tr.HitPos = tr.HitPos or pos
	tr.HitPos = self:WorldToLocal( tr.HitPos )
	
	if tr.HitPos.x < self.mins.x then return end
	if tr.HitPos.x > self.maxs.x then return end
	if tr.HitPos.y < self.mins.y then return end
	if tr.HitPos.y > self.maxs.y then return end
	if tr.HitPos.z < self.mins.z then return end
	if tr.HitPos.z > self.maxs.z then return end
	
	return (tr.HitPos.y + self.maxs.y) * scale, (tr.HitPos.z + self.mins.z) * -scale
	
end