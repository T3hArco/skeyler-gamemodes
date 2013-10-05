---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

AddCSLuaFile("cl_init.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
end

function ENT:IsSpawn() 
	return (self.isSpawn and self.isSpawn == true)
end 

function ENT:Setup(Min, Max, IsSpawn)
	Max.z = Max.z+200

	self.isSpawn = IsSpawn
	self:SetMoveType(MOVETYPE_NONE)
	
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:SetColor(Color(255, 255, 255, 0))
	
	local bbox = (Max - Min) / 2
	
	self:PhysicsInitBox(-bbox, bbox)
	self:SetCollisionBounds(-bbox, bbox)
	
	self:SetTrigger(true)
	self:DrawShadow(false)
	self:SetNotSolid(true)
	self:SetNoDraw(false)
	
	self.Phys = self:GetPhysicsObject()
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:Sleep()
		self.Phys:EnableCollisions(false)
	end 
end 

function ENT:StartTouch(ply) 
	if ply and ply:IsValid() and ply:IsPlayer() and !ply.Winner and !ply.AreaIgnore then 
		if self:IsSpawn() then 
			ply.InSpawn = true
			ply:ResetTimer()  
		else
			hook.Call("PlayerWon", GAMEMODE, ply)  
		end  
	end 
end 

function ENT:EndTouch(ply) 
	if ply and ply:IsValid() and ply:IsPlayer() and !ply.AreaIgnore then 
		if self:IsSpawn() and !ply.Winner then 
			ply.InSpawn = false 
			ply:StartTimer() 
		end 
	end 
end 