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
AddCSLuaFile("modules/sh_sound.lua")

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
include("modules/sv_elevator.lua")
include("modules/sh_sound.lua")

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
	
	timer.Simple(5,function()
		socket.SetupHost("192.168.1.152", 40000)
	
		timer.Simple(2,function()
			socket.AddServer("192.168.1.152", 40001)
		end)
	end)
end

--------------------------------------------------
--
--------------------------------------------------

function GM:PlayerInitialSpawn(player)
	self.BaseClass:PlayerInitialSpawn(player)
	
	player:SetTeam(TEAM_READY)

	player:SetCollideWithTeammates(true) 
	player:SetModel("models/player/group01/male_01.mdl")
	
	timer.Simple(0.4,function()
		for i = LEADERBOARD_DAILY, LEADERBOARD_ALLTIME_10 do
			SS.Lobby.LeaderBoard.Network(i, player)
		end

		SS.Lobby.Minigame:UpdateScreen(player)
	end)
end

--------------------------------------------------
--
--------------------------------------------------

function GM:PlayerSpawn(player)
	self.BaseClass:PlayerSpawn(player)
	
	player:SetJumpPower(205)
end

--------------------------------------------------
--
--------------------------------------------------

function GM:PlayerLoadout(player)
	player:StripWeapons()
	player:RemoveAllAmmo()

	SS.Lobby.Minigame:CallWithPlayer("PlayerLoadout", player)
end

--------------------------------------------------
--
--------------------------------------------------

function GM:IsSpawnpointSuitable( pl, spawnpointent, bMakeSuitable )

	local Pos = spawnpointent:GetPos()
	
	-- Note that we're searching the default hull size here for a player in the way of our spawning.
	-- This seems pretty rough, seeing as our player's hull could be different.. but it should do the job
	-- (HL2DM kills everything within a 128 unit radius)
	local Ents = ents.FindInBox( Pos + Vector( -14, -14, 0 ), Pos + Vector( 14, 14, 64 ) )
	
	if ( pl:Team() == TEAM_SPECTATOR ) then return true end
	
	local Blockers = 0
	
	for k, v in pairs( Ents ) do
		if ( IsValid( v ) && v:GetClass() == "player" && v:Alive() ) then
		
			Blockers = Blockers + 1
			
			if ( bMakeSuitable ) then
				v:Kill()
			end
			
		end
	end

	if ( bMakeSuitable ) then return true end
	if ( Blockers > 0 ) then return false end
	return true

end

--------------------------------------------------
--
--------------------------------------------------

function GM:PlayerSelectSpawn(player, minigame)
	local spawnPoint = self.spawnPoints.lounge
	
	if (player:Team() > TEAM_READY) then
		if (minigame) then
			spawnPoint = minigame:GetSpawnPoints(player)
		else
			spawnPoint = self.spawnPoints
		end
	end

	for i = 1, #spawnPoint do
		local entity = spawnPoint[i]
		local suitAble = self:IsSpawnpointSuitable(player, entity, false)

		if (suitAble) then
			return entity
		end
	end
-- IS THIS SHIT SPAWNING THE PLAYER AT THE QUEUE AGAIN????
	spawnPoint = table.Random(spawnPoint)
	
	return spawnPoint
end

--------------------------------------------------
--
--------------------------------------------------

function GM:KeyPress(player, key)
	if (key == IN_USE) then
		local trace = player:EyeTrace(84)
		
		if (IsValid(trace.Entity) and trace.Entity:IsPlayer()) then
			local canSlap = player:CanSlap(trace.Entity)
			
			if (canSlap) then
				player:Slap(trace.Entity)
			end
		end
	end
	
	SS.Lobby.Minigame:CallWithPlayer("KeyPress", player, key)
end

--------------------------------------------------
--
--------------------------------------------------

function GM:DoPlayerDeath(victim, inflictor, dmginfo)
	SS.Lobby.Minigame:CallWithPlayer("DoPlayerDeath", victim, inflictor, dmginfo)
	
	return self.BaseClass:DoPlayerDeath(victim, inflictor, dmginfo)
end

--------------------------------------------------
--
--------------------------------------------------

function GM:CanPlayerSuicide(player)
	local bool = SS.Lobby.Minigame:CallWithPlayer("CanPlayerSuicide", player)

	if (bool != nil) then
		return bool
	end
	
	return true
end

--------------------------------------------------
--
--------------------------------------------------

function GM:EntityKeyValue(entity, key, value)
	if (IsValid(entity)) then
		local class = entity:GetClass()
		
		if (class == "func_door" and key == "hammerid") then
			entity.id = tonumber(value)
		end
	end
end

--------------------------------------------------
--
--------------------------------------------------

function GM:AllowPlayerPickup( ply, object )
	return false
end

--------------------------------------------------
--
--------------------------------------------------

function GM:PlayerCanPickupItem( player, entity )
	return false
end

-- dev
concommand.Add("poo",function()
RunConsoleCommand("bot")
timer.Simple(0,function()
for k, bot in pairs(player.GetBots()) do
bot:SetTeam(math.random(TEAM_RED,TEAM_ORANGE))
bot:SetPos(Vector(-607.938110, -447.018799, 16.031250))
bot:Freeze(true)
end
end)
end)