-------------------------
-- Sassilization SMG
-- Spacetech
-------------------------

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:DrawShadow(false)
	
	self.Entity:SetCollisionBounds(Vector(-30, -30, -30), Vector(30, 30, 0))
	
	self.Entity:SetSolid(SOLID_BBOX)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	self.Entity:SetTrigger(true)
	self.Entity:SetNotSolid(true)
	
	self.Entity:SetModel(STGamemodes.WeaponSpawnModel or "models/weapons/w_sass_smg.mdl")
	
	timer.Simple(0.1, function()
		if(STValidEntity(self.Entity)) then
			self.Entity:SetPos(self.Entity:GetPos() + Vector(0, 0, 30))
		end
	end)
end

function ENT:StartTouch(Ent)
	if(!Ent or !Ent:IsValid()) then
		return
	end
	if(Ent:IsPlayer() and Ent:Alive()) then
		if(gamemode.Call("PlayerCanPickupWeapon", Ent)) then
			local Weapon = Ent:GetActiveWeapon()
			if(STValidEntity(Weapon)) then
				if(Weapon:GetClass() == STGamemodes.RunGun and Weapon:Clip1() < 45) then
					Ent:StripWeapon(STGamemodes.RunGun)
				end
			end
			if(!Ent:HasWeapon(STGamemodes.RunGun)) then
				Ent:Give(STGamemodes.RunGun)
				self.Entity:EmitSound(self.OnTouchSound)
				-- self.Entity:Remove()
			end
		end
	end
end
