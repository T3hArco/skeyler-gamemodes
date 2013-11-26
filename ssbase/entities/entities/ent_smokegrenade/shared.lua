ENT.Type                        = "anim"
ENT.PrintName           = ""
ENT.Author                      = ""
ENT.Contact                     = ""
ENT.Purpose                     = ""
ENT.Instructions        = ""

function ENT:OnRemove()
end

--[[function ENT:PhysicsUpdate()
end]]

--[[function ENT:PhysicsCollide(data, phys)
        if data.Speed > 50 then
                self.Entity:EmitSound(Sound("SmokeGrenade.Bounce"))
        end
        local impulse = -data.Speed * data.HitNormal * 0.2 + (data.OurOldVelocity * -0.3)
        phys:ApplyForceCenter(impulse)
end]]