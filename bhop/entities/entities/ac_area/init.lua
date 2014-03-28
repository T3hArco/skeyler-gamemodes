---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

AddCSLuaFile("cl_init.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()	
end

function ENT:Setup(Min, Max, Text)
	print(self:GetPos())
	self.Text = Text
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
	print('touche')
	if ply and ply:IsValid() and ply:IsPlayer() and !ply.Winner and ply:IsTimerRunning() then 
		ply:ResetTimer()
		ply:ChatPrint(self.Text)
	end 
end 

function ENT:EndTouch(ply) 
end