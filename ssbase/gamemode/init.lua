---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 

DB_DEVS = false 
-- DB_HOST = "162.213.209.3" 
-- DB_USER = "aaron" 
-- DB_PASS = "wpNHCUnmxAMM93vG" 

DB_HOST = "162.213.209.3"
DB_USER = "servers_gmod"
DB_PASS = "wdXWciNSRsh2CA1jJ3Kdt"

for _,v in pairs(file.Find("ss_vgui/*.lua","LUA")) do  -- Fix this later fagget  
	print(v) 
	-- AddCSLuaFile("ss_vgui/"..v) 
end

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hud.lua") 
AddCSLuaFile("cl_chatbox.lua") 
AddCSLuaFile("sh_profiles.lua") 
AddCSLuaFile("sh_store.lua") 
AddCSLuaFile("cl_store.lua") 
-- AddCSLuaFile("vgui/ss_hub_store_icon.lua") 
include("shared.lua")
include("sh_profiles.lua") 
include("sv_database.lua") 
include("sh_maps.lua")
include("sh_store.lua") 
include("sv_profiles.lua") 
include("sv_store.lua") 
include("sv_timer.lua")
include("sv_commands.lua")
include("sv_gatekeeper.lua") 

function PLAYER_META:ChatPrintAll(msg) 
	if !msg or string.Trim(msg) == "" then return end 
	for k,v in pairs(player.GetAll()) do 
		v:ChatPrint(msg) 
	end 
end 

function GM:PlayerInitialSpawn(ply) 
	ply:ProfileLoad() 

	ply:SetTeam(TEAM_SPEC) 

	ply.SpecMode = OBS_MODE_CHASE 
	ply.SpecID = 1
	ply.roam = false
	ply.chase = true

	ply:SendLua("ResolutionCheck()") 
end 

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)
	player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" ) 

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
end 

function GM:GetPlayers(b_alive, filter)  
	local players = player.GetAll() 
	local Return = {} 
	for k,v in pairs(players) do 
		if v:Alive() and b_alive then 
			if (filter and !table.HasValue(filter, v)) or !filter then 
				table.insert(Return, v) 
			end 
		elseif !b_alive then
			if (filter and !table.HasValue(filter, v)) or !filter then 
				table.insert(Return, v) 
			end 
		end 
	end 
	return Return 
end 

function GM:SpectateNext(ply) 
	local players = self:GetPlayers(true,{ply})
	if(#players == 1) then
		if(ply.SpecID != 1) then
			ply.SpecID = 1
			ply:SpectateEntity(players[ply.SpecID])
		end
		return
	end
	ply.SpecID = ply.SpecID + 1
	if(ply.SpecID>#players)then
		ply.SpecID = 1
	end
	ply:SpectateEntity(players[ply.SpecID])
end 

function GM:SpectatePrev(ply) 
	local players = self:GetPlayers(true,{ply})
	if(#players == 1) then
		if(ply.SpecID != 1) then
			ply.SpecID = 1
			ply:SpectateEntity(players[ply.SpecID])
		end
		return
	end
	ply.SpecID = ply.SpecID - 1
	if(ply.SpecID<1)then
		ply.SpecID = #players
	end
	ply:SpectateEntity(players[ply.SpecID])
end 

function GM:ChangeSpecMode(ply)
	if(ply.chase) then
		ply.SpecMode = OBS_MODE_IN_EYE
		ply.chase = false
	else
		ply.SpecMode = OBS_MODE_CHASE
		ply.chase = true
	end
	ply:SetObserverMode(ply.SpecMode)
end

function GM:ToggleRoam(ply)
	if(ply.roam) then
		if(ply.chase) then
			ply.SpecMode = OBS_MODE_CHASE
		else
			ply.SpecMode = OBS_MODE_IN_EYE
		end
		ply.roam = false
	else
		ply.SpecMode = OBS_MODE_ROAMING
		ply.roam = true
	end
	ply:Spectate(ply.SpecMode)
end

hook.Add("KeyPress", "SpectateModeChange", function(ply, key) 
	if ply:Team() == TEAM_SPEC then 
		if !ply.roam && key == IN_ATTACK then 
			GAMEMODE:SpectateNext(ply)
		elseif !ply.roam && key == IN_ATTACK2 then 
			GAMEMODE:SpectatePrev(ply)
		elseif !ply.roam && key == IN_JUMP then 
			GAMEMODE:ChangeSpecMode(ply)
		elseif key == IN_RELOAD then 
			GAMEMODE:ToggleRoam(ply)
		end
	end 
end )

function GM:PlayerSay( ply, text, public )
	local t = string.lower( text )
	
	if(t == "!spec" || t == "!spectate") then
		if(ply:Team() == TEAM_SPEC) then
			ply:ChatPrint("You are already a spectator")
			return ""
		end
		ply:SetTeam(TEAM_SPEC)
		ply:Spawn()
		return ""
	end
	
	return self.BaseClass:PlayerSay(ply,text,public)
end

function GM:PlayerDisconnected(ply) 
	self:ProfileSave() 
end 

function GM:AllowPlayerPickup( ply, object )
	if ply:IsSuperAdmin() then return true end 
	return false 
end 

function GM:ShowHelp(ply) 
	ply:ConCommand("ss_store") 
end 

function GM:ShowTeam(ply) 
end 

function GM:ShowSpare(ply) 
end 

function GM:ShowSpare2(ply) 
end 

function GM:PlayerNoClip(ply) 
	return ply:IsSuperAdmin() 
end 

/* Get a list of SpawnPoints */
hook.Add("InitPostEntity", "SpawnPoints", function() 
	local self = GAMEMODE
	if ( !IsTableOfEntitiesValid( self.SpawnPoints ) ) then
		self.LastSpawnPoint = 0
		self.SpawnPoints = ents.FindByClass( "info_player_start" )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
		
		-- CS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
		
		-- DOD Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		-- (Old) GMod Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "gmod_player_start" ) )
		
		-- TF Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_teamspawn" ) )
		
		-- INS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "ins_spawnpoint" ) )  

		-- AOC Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "aoc_spawnpoint" ) )

		-- Dystopia Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "dys_spawn_point" ) )

		-- PVKII Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_pirate" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_viking" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_knight" ) )

		-- DIPRIP Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "diprip_start_team_blue" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "diprip_start_team_red" ) )
 
		-- OB Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_red" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_blue" ) )        
 
		-- SYN Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_coop" ) )
 
		-- ZPS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_human" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_zombie" ) )      
 
		-- ZM Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_zombiemaster" ) ) 

	end
end )

function GM:EntityKeyValue( ent, key, value )
     
    if !GAMEMODE.BaseStoreOutput or !GAMEMODE.BaseTriggerOutput then
     
        local e = scripted_ents.Get( "base_entity" )
        GAMEMODE.BaseStoreOutput = e.StoreOutput
        GAMEMODE.BaseTriggerOutput = e.TriggerOutput
         
    end
 
    if key:lower():sub( 1, 2 ) == "on" then
         
        if !ent.StoreOutput or !ent.TriggerOutput then -- probably an engine entity
         
            ent.StoreOutput = GAMEMODE.BaseStoreOutput
            ent.TriggerOutput = GAMEMODE.BaseTriggerOutput
            
		end
		
        if ent.StoreOutput then
                 
            ent:StoreOutput( key, value )
                 
        end
         
    end
     
end
