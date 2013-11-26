AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
        self.Entity:SetModel("models/weapons/w_eq_flashbang.mdl")
        self.Entity:PhysicsInit( SOLID_VPHYSICS )
        self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
        self.Entity:SetSolid( SOLID_VPHYSICS )
        self.Entity:DrawShadow( false )

        self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
        
        local phys = self.Entity:GetPhysicsObject()
        
        if (phys:IsValid()) then
                phys:Wake()
        end
        
        self.timer = CurTime() + 3
end

function ENT:Think()
        if self.timer <= CurTime() then
                self.Entity:EmitSound(Sound("Flashbang.Explode"))
                for id,ply in pairs(player.GetAll()) do
                        local tracedata = {}
                        tracedata.start = self:GetPos()
                        tracedata.endpos = ply:GetShootPos()
                        tracedata.filter = self
                        local trace = util.TraceLine(tracedata)
                
                        if (trace.Entity != NULL and trace.Entity:IsPlayer() and self:GetPos():Distance(trace.Entity:GetPos()) < 1024) then
                                umsg.Start("flashbang_flash", ply)
                                        umsg.Long(CurTime())
                                        umsg.Long(CurTime() + 6)
                                umsg.End()
                        end
                end
                self.Entity:Remove()
        end
end