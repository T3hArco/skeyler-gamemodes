---------------------------
--        Deathrun       -- 
-- Created by xAaron113x --
---------------------------


include("shared.lua")
include("sv_gatekeeper.lua") 

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")


function GM:PlayerSpawn(ply) 
	self.BaseClass:PlayerSpawn(ply) 

	ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 62))
	ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45))
end 