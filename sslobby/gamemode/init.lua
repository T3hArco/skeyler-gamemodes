AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_scoreboard.lua") 

AddCSLuaFile("modules/sh_link.lua")
AddCSLuaFile("modules/cl_link.lua")
AddCSLuaFile("modules/sh_chairs.lua")
AddCSLuaFile("modules/cl_chairs.lua")
AddCSLuaFile("modules/cl_worldpicker.lua")
AddCSLuaFile("modules/sh_minigame.lua")
AddCSLuaFile("modules/cl_minigame.lua")
AddCSLuaFile("modules/cl_worldpanel.lua")
AddCSLuaFile("modules/sh_leaderboard.lua")
AddCSLuaFile("modules/cl_leaderboard.lua")

include("shared.lua")
include("player_class/player_lobby.lua")
include("player_extended.lua")

include("modules/sv_socket.lua")
include("modules/sh_link.lua")
include("modules/sv_link.lua")
include("modules/sh_chairs.lua")
include("modules/sv_chairs.lua")
include("modules/sv_worldpicker.lua")
include("modules/sh_minigame.lua")
include("modules/sv_minigame.lua")
include("modules/sh_leaderboard.lua")
include("modules/sv_leaderboard.lua")

--------------------------------------------------
--
--------------------------------------------------

function GM:InitPostEntity()
	self.spawnPoints = {lounge = {}}
	
	local spawns = ents.FindByClass("info_player_spawn")
	
	for k, entity in pairs(spawns) do
		if (entity.lounge) then
			table.insert(self.spawnPoints.lounge, entity)
		else
			if (!entity.minigames) then
				table.insert(self.spawnPoints, entity)
			end
		end
	end
	
	--local pokerTable = ents.Create("poker_table")
--	pokerTable:SetPos(Vector(-1193.461914, -9.690007, 176.031250))
	--pokerTable:SetAngles(Angle(0, 89.546 *2, 0.000))
	--pokerTable:Spawn()
	
	local slotMachines = ents.FindByClass("prop_physics_multiplayer")
	
	for k, entity in pairs(slotMachines) do
		if (IsValid(entity)) then
			local model = string.lower(entity:GetModel())
			
			if (model == "models/sam/slotmachine.mdl") then
				local position, angles = entity:GetPos(), entity:GetAngles()
				
				local slotMachine = ents.Create("slot_machine")
				slotMachine:SetPos(position)
				slotMachine:SetAngles(angles)
				slotMachine:Spawn()
				
				entity:Remove()
			end
		end
	end
end

--------------------------------------------------
--
--------------------------------------------------

function GM:PlayerInitialSpawn(player)
	self.BaseClass:PlayerInitialSpawn(player)
	
	player:SetTeam(TEAM_READY)
	
	timer.Simple(0.1,function()
		for i = LEADERBOARD_DAILY, LEADERBOARD_ALLTIME_10 do
			SS.Lobby.LeaderBoard.Network(i, player)
		end
	end)
end

--------------------------------------------------
--
--------------------------------------------------

function GM:PlayerSpawn(player)
	self.BaseClass:PlayerSpawn(player)
	
	--self:InitSpeed(ply)
	-- ply:SetRunSpeed(300)
	-- ply:SetWalkSpeed(300)
	
	player:SetJumpPower(205)
end

--------------------------------------------------
--
--------------------------------------------------

function GM:PlayerSelectSpawn(player, minigame)
	local spawnPoint = self.spawnPoints.lounge
	
	if (player:Team() > TEAM_READY) then
		if (minigame) then
			spawnPoint = minigame:GetSpawnPoints()
		else
			spawnPoint = self.spawnPoints
		end
	end
	
	for i = 1, #spawnPoint do
		local entity = spawnPoint[i]
		local suitAble = self:IsSpawnpointSuitable(player, entity, i == #spawnPoint)
		
		if (suitAble) then
			return entity
		end
	end
	
	spawnPoint = table.Random(spawnPoint)
	
	return spawnPoint
end

--------------------------------------------------
--
--------------------------------------------------

function GM:KeyPress(player, key)
	local trace = player:EyeTrace(200)
	
	if (IsValid(trace.Entity) and trace.Entity:IsPlayer()) then
		local canSlap = player:CanSlap()
		
		if (canSlap) then
			player:Slap(trace.Entity)
		end
	end
end

--------------------------------------------------
--
--------------------------------------------------

function GM:PlayerDeath(victim, inflictor, attacker)
	local minigame = SS.Lobby.Minigame:GetCurrentGame()
	
	minigame = SS.Lobby.Minigame:Get(minigame)
	
	if (minigame) then
		local hasPlayer = minigame:HasPlayer(victim)
		
		if (hasPlayer) then
			SS.Lobby.Minigame.Call("PlayerDeath", victim, inflictor, attacker)
		end
	end
end