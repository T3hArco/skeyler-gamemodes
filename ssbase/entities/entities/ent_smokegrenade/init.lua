AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

        self.Entity:SetModel("models/weapons/w_eq_smokegrenade.mdl")
        self.Entity:PhysicsInit( SOLID_VPHYSICS )
        self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
        self.Entity:SetSolid( SOLID_VPHYSICS )
        self.Entity:DrawShadow( false )
        
        // Don't collide with the player
        self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
        
        local phys = self.Entity:GetPhysicsObject()
        
        if (phys:IsValid()) then
                phys:Wake()
        end
        
        self.timer = CurTime() + 3
end

function ENT:Think()
        if (self.timer < CurTime()) then
                self.Entity:EmitSound(Sound("BaseSmokeEffect.Sound"))
                self.Entity:SetNWBool("Bang", true)
                self.timer = CurTime() + 999
                timer.Simple(49, function(ent) if (ent && ent:IsValid()) then ent:Remove() end end, self)
        end
end