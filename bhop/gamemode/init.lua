---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------


AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_difficulty_menu.lua") 
AddCSLuaFile("sh_levels.lua") 
include("shared.lua")
include("sh_levels.lua") 
include("sh_maps.lua") 

RunConsoleCommand("sv_stopspeed", "75")
RunConsoleCommand("sv_friction", "6")
RunConsoleCommand("sv_accelerate", "8")
RunConsoleCommand("sv_airaccelerate", "150")
RunConsoleCommand("sv_gravity", "800")
-- GM:SetMaxVisiblePlayers(20) 

/* Setup the bhop spawn and finish */
function GM:AreaSetup() 
	local MapData = self.MapList[game.GetMap()] 
	if MapData then -- We will assume the rest is valid
		self.MapSpawn = ents.Create("bhop_area")
		self.MapSpawn:SetPos(MapData.spawnarea.max-(MapData.spawnarea.max-MapData.spawnarea.min)/2)          --MapData.SpawnArea.Min+(MapData.SpawnArea.Max-MapData.SpawnArea.Min)/2) 
		self.MapSpawn:Setup(MapData.spawnarea.min, MapData.spawnarea.max, true) 
		self.MapSpawn:Spawn()

		self.MapFinish = ents.Create("bhop_area") 
		self.MapFinish:SetPos(MapData.finisharea.max-(MapData.finisharea.max-MapData.finisharea.min)/2) 
		self.MapFinish:Setup(MapData.finisharea.min, MapData.finisharea.max) 
		self.MapFinish:Spawn() 

		for k,v in pairs(self.SpawnPoints) do 
			v:SetPos(MapData.spawnpos) 
			v:SetAngles(MapData.spawnang) 
		end 
	end 
end 

function GM:ShowTeam(ply) 
	if ply:Team() != TEAM_BHOP and ply:HasTimer() then -- Just resume if they already played.
		self:LevelSetup(ply, self.Positions[ply:SteamID()].Level)
	else 
		ply:ConCommand("open_difficulties") 
	end 
end 

function GM:PlayerSpawn(ply)
	if ply:IsBot() then ply:SetTeam(TEAM_BHOP) end -- always spawn bots

	if ply:Team() == TEAM_BHOP then  
		ply:UnSpectate() 
		-- ply:SetJumpPower(205) 
		ply:SetJumpPower( math.sqrt(2 * 800 * 64) )
		ply:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 62 ) )
		ply:SetHullDuck( Vector( -16, -16, 0 ), Vector( 16, 16, 45 ) )
		ply:SetWalkSpeed(250) 
		ply:SetRunSpeed(250) 
		ply:SetMaxSpeed(250) 
		hook.Call( "PlayerSetModel", GAMEMODE, ply )
		ply:SetNoCollideWithTeammates(true) 
		ply:Give("weapon_crowbar") 
		ply:Give("weapon_pistol")
		ply:Give("weapon_smg1") 
		ply:Give("weapon_fists") 
		ply:GiveAmmo(200, "Pistol", true) 
		ply:GiveAmmo(400, "Smg1", true) 

		if ply:IsSuperAdmin() then 
			ply:Give("ss_mapeditor") 
		end 

		if ply:IsVIP() then 
			ply:SetHealth(200) 
		end 
			
		if ply:HasTimer() and self.Positions[ply:SteamID()] then 
			ply.AreaIgnore = true 
			local PosInfo = self.Positions[ply:SteamID()] 
			ply:SetPos(PosInfo.LastPos) 
			ply:SetEyeAngles(PosInfo.LastAng) 
			ply:StartTimer() 
			ply.AreaIgnore = false
		elseif !ply.InSpawn then 
			ply:StartTimer() 
		end 
	else 
		ply:SetTeam(TEAM_SPECTATOR)
		ply:Spectate(OBS_MODE_ROAMING)
	end 
end 

function GM:LevelSetup(ply, Level) 
	if !Level then return end 

	ply.Level = Level 
	ply.LevelData = self.Levels[Level] 

	if !ply.LevelData then return end 

	ply:SetGravity(ply.LevelData.gravity) 
	ply.StayTime = ply.LevelData.staytime 
	ply.award = ply.LevelData.award 
	ply.GroundEnt = false 
	ply.LastBlock = false 

	ply:ChatPrint("Your difficulty is ".. ply.LevelData.name ..".") 

	if ply:Team() == TEAM_BHOP then 
		ply:ResetTimer() 
		ply.Winner = false 
	end  

	if !ply:HasTimer() then self.Positions[ply:SteamID()] = false end 

	ply:SetTeam(TEAM_BHOP) 
	ply:Spawn() 
end 
concommand.Add("level_select", function(ply, cmd, args) GAMEMODE:LevelSetup(ply, tonumber(args[1])) end)

function GM:PlayerDisconnected(ply) 
	ply:PauseTimer() 
end 

function GM:PlayerShouldTakeDamage(ply, attacker) 
	return false 
end 

function GM:InBetweenNumber(Value, Min, Max)
	if(Value < Min or Value > Max) then
		return false
	end
	return true
end

function GM:FindTeleporter(Pos)
	for k,v in pairs(self.Teleporters) do
		if(self:InBetweenNumber(Pos.x, v.Mins.x, v.Maxs.x) and self:InBetweenNumber(Pos.y, v.Mins.y, v.Maxs.y) and self:InBetweenNumber(Pos.z, v.Mins.z, v.Maxs.z)) then
			return k
		end
	end
	return false
end

/* Setup the teleports, platforms, spawns, and finish lines */
function GM:InitPostEntity() 
	self.Teleporters = {}
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do 
		self.Teleporters[v] = {Mins=v:LocalToWorld(v:OBBMins()), Maxs=v:LocalToWorld(v:OBBMaxs())} 
		if !self.MapList[game.GetMap()] then 
			local KeyValues = v:GetKeyValues() 
			local Target = false 
			if KeyValues.target then 
				Target = ents.FindByName(KeyValues.target) 
				if Target[1] and Target[1]:IsValid() then 
					Target = {Target[1]:GetPos(), Target[1]:GetAngles()} 
				else 
					Target = false 
				end 
			end 
			if istable(Target) then 
				v.TelePos = Target[1] 
				v.TeleAng = Target[2] 
			else 
				v.TelePos = false 
				v.TeleAng = false 
			end 
		end 
	end 

	for k,v in pairs(ents.FindByClass("func_door")) do
		v.Block = true 

		local Tries = 0  
		local Origin = v:GetPos() 
		while(!v.Teleporter and Tries < 300) do 
			Origin = Origin+Vector(0, 0, -1) 
			v.Teleporter = self:FindTeleporter(Origin)  
			v.TeleOrigin = Origin-Vector(0, 0, 2)
			Tries = Tries+1
		end 
		v.TeleOrigin = v.TeleOrigin-Vector(0,0,5) 
	end 
	self:AreaSetup()
end 

GM.Positions = {} 
local GroundEnt, NextGroundEnt, LastBlock = false, false, false 
function GM:Move(ply, data) 
	if ply:Alive() then 
		GroundEnt = ply.GroundEnt or false 
		NextGroundEnt = ply:GetGroundEntity() 
		LastBlock = ply.LastBlock or false 
		ply.GroundTime = ply.GroundTime or CurTime() 

		if NextGroundEnt and NextGroundEnt:IsValid() then 
			if NextGroundEnt.Block then 
				local Teleport = false 
				if ply.LastBlock and ply.LastBlock == NextGroundEnt then 
					Teleport = true 
				elseif GroundEnt == NextGroundEnt then 
					if CurTime()-(ply.GroundTime or CurTime()) >= ply.StayTime then 
						Teleport = true 
					end 
				else 
					ply.GroundTime = CurTime() 
				end 

				if Teleport and GroundEnt and GroundEnt:IsValid() then 
					if ply.LevelData.kill then 
						ply:Kill() 
						return 
					end 

					data:SetOrigin(GroundEnt.TeleOrigin) 
					ply:SetVelocity(Vector(0, 0, 0)) 
					ply.GroundEnt = false 
					ply.LastBlock = false 
					ply.GroundTime = CurTime()
					NextGroundEnt = false 

					if !GAMEMODE.MapList[game.GetMap()] and ply:IsAdmin() then 
						local Pos = GroundEnt.Teleporter.TelePos
						local Ang = GroundEnt.Teleporter.TeleAng
						ply:ChatPrint("TelePos:  Vector("..Pos.x..", "..Pos.y..", "..Pos.z.."), Angle("..Ang.p..", "..Ang.y..", "..Ang.r..")")
					end 
				end 
			end 
		elseif GroundEnt and GroundEnt:IsValid() and GroundEnt.Block then 
			ply.LastBlock = GroundEnt 
		end 

		if NextGroundEnt == game.GetWorld() and !ply.InSpawn then 
			self.Positions[ply:SteamID()] = {LastPos=ply:GetPos(), LastAng=ply:GetAngles(), Level=ply.Level} 
			ply.LastBlock = false 
			GroundEnt = false 
			ply.GroundTime = false 
		end 

		ply.GroundEnt = NextGroundEnt 
	end 
end 

function GM:PlayerWon(ply) 

end 