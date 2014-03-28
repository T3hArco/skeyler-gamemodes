---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 
include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
end

function ENT:Setup(Min, Max, IsSpawn)
	if(IsSpawn) then
		Max.z = Max.z+75
	else
		Max.z = Max.z+200
	end

	self:SetSpawn(IsSpawn)
	
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
	if ply and ply:IsValid() and ply:IsPlayer() and !ply.AreaIgnore then 
		if self:GetSpawn() then 
			ply.InSpawn = true
			ply.Winner = false
			ply:ResetTimer()
			ply:ClearFrames()
		elseif ply:IsTimerRunning() then
			hook.Call("PlayerWon", GAMEMODE, ply)  
		end  
	end 
end 

function ENT:EndTouch(ply) 
	if ply and ply:IsValid() and ply:IsPlayer() and !ply.AreaIgnore then 
		if self:GetSpawn() and !ply.Winner then 
			ply.InSpawn = false 
			ply:StartTimer() 
			ply:ClearFrames()
		end 
	end 
end 