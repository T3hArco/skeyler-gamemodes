ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.mins = Vector(-0.1, -4, -5)
ENT.maxs = Vector(0.1, 4, 5)

------------------------------------------------
--
------------------------------------------------

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Pressed")
	self:NetworkVar("Int", 0, "ElevatorID")
end

------------------------------------------------
--
------------------------------------------------

function ENT:GetCursorPosition(player, scale, position)
	player = player or LocalPlayer()
	scale = scale or 1
	
	local trace = {}
	
	if (!position) then
		trace.start = player:EyePos()
		trace.endpos = trace.start +player:GetAimVector() *64
		trace.mask = MASK_SOLID_BRUSHONLY
		trace = util.TraceLine(trace)
	end
	
	trace.HitPos = trace.HitPos or position
	trace.HitPos = self:WorldToLocal(trace.HitPos)
	
	if (trace.HitPos.x < self.mins.x) then return end
	if (trace.HitPos.x > self.maxs.x) then return end
	if (trace.HitPos.y < self.mins.y) then return end
	if (trace.HitPos.y > self.maxs.y) then return end
	if (trace.HitPos.z < self.mins.z) then return end
	if (trace.HitPos.z > self.maxs.z) then return end
	
	return (trace.HitPos.y +self.maxs.y) *scale, (trace.HitPos.z +self.mins.z) *-scale
end