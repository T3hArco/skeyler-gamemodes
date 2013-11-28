---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------


include("shared.lua")
include("sv_config.lua")
include("sh_levels.lua") 
include("sh_maps.lua") 
include("sh_viewoffsets.lua") 
include("player_class/player_bhop.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_difficulty_menu.lua") 
AddCSLuaFile("sh_levels.lua") 
AddCSLuaFile("sh_viewoffsets.lua") 

GM.PSaveData = {} -- Save last known positions and angles for respawn here.
GM.ACAreas = {}

/* Setup the bhop spawn and finish */
function GM:AreaSetup() 
	local MapData = SS.MapList[game.GetMap()] 
	if MapData then -- We will assume the rest is valid
		self.MapSpawn = ents.Create("bhop_area")
		self.MapSpawn:SetPos(MapData.spawnarea.max-(MapData.spawnarea.max-MapData.spawnarea.min)/2) 
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

function GM:AddACArea(min,max,message)
	local m = ""
	if(!message) then
		m = "You have attempted to exploit the map and as such your time has been stopped."
	else
		m = message
	end
	table.insert(GAMEMODE.ACAreas,{min,max,m})
end

function GM:LevelSetup(ply, Level)
	if !Level or !isnumber(Level) or !self.Levels[Level] then return end 

	ply:SetNetworkedInt("ssbhop_level", Level) 
	ply.LevelData = self.Levels[Level] 

	if !ply.LevelData then return end 

	ply:SetGravity(ply.LevelData.gravity) 
	ply.StayTime = ply.LevelData.staytime 
	print(game.GetMap())
	ply.Payout = SS.MapList[game.GetMap()] and SS.MapList[game.GetMap()].payout or 100

	ply:ChatPrint("Your difficulty is ".. ply.LevelData.name ..".") 

	if ply:Team() == TEAM_BHOP then 
		ply:ResetTimer() 
		ply.Winner = false 
	end  
	ply:SetTeam(TEAM_BHOP) 
	ply:Spawn() 
end 
concommand.Add("level_select", function(ply, cmd, args) GAMEMODE:LevelSetup(ply, tonumber(args[1])) end)

function GM:ShowTeam(ply) 
	if ply:Team() != TEAM_BHOP and ply:HasTimer() then -- Just resume if they already played.
		self:LevelSetup(ply, self.PSaveData[ply:SteamID()].Level)
	else 
		ply:ConCommand("open_difficulties") 
	end 
end 

function GM:PlayerSpawn(ply)
	if ply:IsBot() then ply:SetTeam(TEAM_BHOP) end -- always spawn bots

	if ply:Team() == TEAM_BHOP then  
		ply:UnSpectate()
		
		player_manager.SetPlayerClass( ply, "player_bhop" )
	
		self.BaseClass:PlayerSpawn( ply )

		player_manager.OnPlayerSpawn( ply )
		player_manager.RunClass( ply, "Spawn" )
		
		hook.Call( "PlayerSetModel", GAMEMODE, ply )
		
		ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 62))
		ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45))
		

		if ply:IsSuperAdmin() then 
			ply:Give("ss_mapeditor") 
		end 

		if !ply.LevelData then
			self:LevelSetup(ply,2) --default level
		end
			
		if ply:HasTimer() and self.PSaveData[ply:SteamID()] then 
			ply.AreaIgnore = true 
			local PosInfo = self.PSaveData[ply:SteamID()] 
			ply:SetPos(PosInfo.LastPosition) 
			ply:SetEyeAngles(PosInfo.LastAngle) 
			ply:StartTimer() 
			ply.AreaIgnore = false
		elseif !ply.InSpawn then 
			ply:StartTimer() 
		end 

		local oldhands = ply:GetHands()
		if ( IsValid( oldhands ) ) then oldhands:Remove() end

		local hands = ents.Create( "gmod_hands" )
		if ( IsValid( hands ) ) then
			ply:SetHands( hands )
			hands:SetOwner( ply )

			-- Which hands should we use?
			local cl_playermodel = ply:GetInfo( "cl_playermodel" )
			local info = player_manager.TranslatePlayerHands( cl_playermodel )
			if ( info ) then
				hands:SetModel( info.model )
				hands:SetSkin( info.skin )
				hands:SetBodyGroups( info.body )
			end

			-- Attach them to the viewmodel
			local vm = ply:GetViewModel( 0 )
			hands:AttachToViewmodel( vm )

			vm:DeleteOnRemove( hands )
			ply:DeleteOnRemove( hands )

			hands:Spawn()
		end
	else 
		ply:SetTeam(TEAM_SPECTATOR)
		ply:Spectate(OBS_MODE_ROAMING)
	end 
end 

function GM:PlayerCanPickupWeapon(ply, wep)
	if ply:HasWeapon(wep:GetClass()) then return false end
	ply:SetAmmo(999,wep:GetPrimaryAmmoType())
	return true
end

function GM:PlayerDisconnected(ply) 
	ply:PauseTimer() 
	ply:ProfileSave() 
end 

function GM:PlayerShouldTakeDamage(ply, attacker) 
	return false 
end 

function GM:IsSpawnpointSuitable() -- Overwrite so we don't run into death problems
	return true 
end 

/* Setup the teleports, platforms, spawns, and finish lines */
function GM:InitPostEntity() 
	if !SS.MapList[game.GetMap()] or !SS.MapList[game.GetMap()].ignoredoors then
		for k,v in pairs(ents.FindByClass("func_door")) do
			if(!v.IsP) then continue end
			local mins = v:OBBMins()
			local maxs = v:OBBMaxs()
			local h = maxs.z - mins.z
			if(h > 80 && !table.HasValue(SS.Alldoors,game.GetMap())) then continue end
			local tab = ents.FindInBox( v:LocalToWorld(mins)-Vector(0,0,10), v:LocalToWorld(maxs)+Vector(0,0,5) )
			if(tab) then
				for _,v2 in pairs(tab) do if(v2 && v2:IsValid() && v2:GetClass() == "trigger_teleport") then tele = v2 end end
				if(tele) then
					v:Fire("Lock")
					v:SetKeyValue("spawnflags","1024")
					v:SetKeyValue("speed","0")
					v:SetRenderMode(RENDERMODE_TRANSALPHA)
					if(v.BHS) then
						v:SetKeyValue("locked_sound",v.BHS)
					else
						v:SetKeyValue("locked_sound","DoorSound.DefaultMove")
					end
					v:SetNWInt("Platform",1)
				end
			end
		end
	
		for k,v in pairs(ents.FindByClass("func_button")) do
			if(!v.IsP) then continue end
			if(v.SpawnFlags == "256") then 
				local mins = v:OBBMins()
				local maxs = v:OBBMaxs()
				local tab = ents.FindInBox( v:LocalToWorld(mins)-Vector(0,0,10), v:LocalToWorld(maxs)+Vector(0,0,5) )
				if(tab) then
					for _,v2 in pairs(tab) do if(v2 && v2:IsValid() && v2:GetClass() == "trigger_teleport") then tele = v2 end end
					if(tele) then
						v:Fire("Lock")
						v:SetKeyValue("spawnflags","257")
						v:SetKeyValue("speed","0")
						v:SetRenderMode(RENDERMODE_TRANSALPHA)
						if(v.BHS) then
							v:SetKeyValue("locked_sound",v.BHS)
						else
							v:SetKeyValue("locked_sound","None (Silent)")
						end
						v:SetNWInt("Platform",1)
					end
				end
			end
		end
	end
	
	self:AreaSetup()
end 

function GM:PlayerFootstep(ply)
	if ply:Alive() then -- If alive, assume we save positions
		if !self.PSaveData[ply:SteamID()] then self.PSaveData[ply:SteamID()] = {} end 
		self.PSaveData[ply:SteamID()].LastPosition = ply:GetPos() 
		self.PSaveData[ply:SteamID()].LastAngle = ply:GetAngles() 
		self.PSaveData[ply:SteamID()].Level = ply:GetNetworkedInt("ssbhop_level", 0) 
	end 
end

function GM:PlayerWon(ply) 
	ply:EndTimer()
	ply.Winner = true 
	ply:ChatPrintAll(ply:Name().." has won in ".. FormatTime(ply:GetTotalTime(true)))
	print(ply.Payout) 
	ply:GiveMoney(ply.Payout)
end 

hook.Add("OnPlayerHitGround","StrafeySyncy",function(p,bool)
	local good = 0
	local bad = 0
	local sync = 0
	local totalsync = {}
	
	for k,v in pairs(p.strafe or {}) do
		if(type(v) == "table") then
			totalsync[k] = (v[1]*100)/(v[1]+v[2]) --to be used later for stats
			good = good + v[1]
			bad = bad + v[2]
		end
	end
	
	local straf = p.strafenum
	timer.Simple(0.2,function()
		if(straf && straf != 0 && good && bad && totalsync && p && p:IsValid() && p:IsOnGround()) then --checkzooors
			sync = (good*100)/(good+bad)
		
			for k,v in pairs(totalsync) do
				p:PrintMessage(HUD_PRINTCONSOLE,"Strafe "..k..": "..(math.Round(v*100)/100).."% sync.")
			end

			p:PrintMessage(HUD_PRINTCONSOLE,"You got "..(math.Round(sync*100)/100).."% sync with "..straf.." strafes.")
		end
	end)

	p.strafe = {}
	p.strafenum = 0
	p.strafingleft = false
	p.strafingright = false
	p.turningleft = false
	p.lastangle = nil
	p.speed = nil
	p.lastspeed = nil
end)

hook.Add("Think","ACAreas",function()
	for _,v in pairs(GAMEMODE.ACAreas) do
		for _,p in pairs(player.GetAll()) do
			if(p:Team() == TEAM_BHOP && p:HasTimer() && !p.Winner && GAMEMODE:IsInArea(p,v[1],v[2])) then
				p:EndTimer()
				p:ChatPrint(v[3])
			end
		end
	end
end) --seperate think hooks = more organised and no extra cost in proccessing afaik

hook.Add("Think","StrafeyThink",function()
	for _,p in pairs(player.GetAll()) do
		if(!p:IsOnGround()) then
			p.curangle = p:GetAngles()
			if(!p.lastangle) then
				p.lastangle = p.curangle
			end
			if(p.curangle.y < p.lastangle.y) then
				p.turningleft = false
			elseif(p.curangle.y > p.lastangle.y) then
				p.turningleft = true
			else
				p.lastangle = p:GetAngles()
				continue
			end
			p.lastangle = p:GetAngles()

			if(p:KeyDown(IN_MOVELEFT) && p.turningleft && (p.strafingright || (!p.strafingright && !p.strafingleft))) then
				p.strafingright = false
				p.strafingleft = true
				p.strafenum = p.strafenum + 1
				p.strafe[p.strafenum] = {}
				p.strafe[p.strafenum][1] = 0
				p.strafe[p.strafenum][2] = 0
			elseif(p:KeyDown(IN_MOVERIGHT) && !p.turningleft && (p.strafingleft || (!p.strafingright && !p.strafingleft))) then
				p.strafingright = true
				p.strafingleft = false
				p.strafenum = p.strafenum + 1
				p.strafe[p.strafenum] = {}
				p.strafe[p.strafenum][1] = 0
				p.strafe[p.strafenum][2] = 0
			elseif(!p.strafingleft && !p.strafingright) then
				continue
			end
			local s = p:GetVelocity()
			s.z = 0
			p.speed = s:Length()
			if(p.lastspeed) then
				local g = p.speed - p.lastspeed
				if(g > 0.6) then
					p.strafe[p.strafenum][1] = p.strafe[p.strafenum][1] + 1
				else
					p.strafe[p.strafenum][2] = p.strafe[p.strafenum][2] + 1
				end
			end
			p.lastspeed = p.speed
		end
	end
end)