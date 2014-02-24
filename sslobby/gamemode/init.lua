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

include("shared.lua")
include("player_class/player_lobby.lua")

include("modules/sh_link.lua")
include("modules/sv_link.lua")
include("modules/sh_chairs.lua")
include("modules/sv_chairs.lua")
include("modules/sv_worldpicker.lua")
include("modules/sh_minigame.lua")
include("modules/sv_minigame.lua")

--------------------------------------------------
--
--------------------------------------------------

function GM:InitPostEntity()
	self.spawnPoints = {lounge = {}}
	
	local spawns = ents.FindByClass("info_player_spawn")
	
	for k, entity in pairs(spawns) do
		if (entity.lounge) then
			table.insert(self.spawnPoints.lounge, entity)
		elseif (entity.minigames) then
		else
			table.insert(self.spawnPoints, entity)
		end
	end
	
--[[	self.EnterSpawns = {}
	self.SpawnPoints = {}
	
	for k,v in pairs(ents.FindByClass("info_player_spawn")) do
		if(v.lounge) then
			table.insert(self.EnterSpawns, v)
		elseif v.gamemode and MINIGAMES then
			for k2, v2 in pairs( v.gamemode ) do
				if( MINIGAMES[v2] && MINIGAMES[v2].spawns ) then
					table.insert( MINIGAMES[v2].spawns, v)
				end
			end
		else
			table.insert(self.SpawnPoints, v)
		end
	end
	
	for k,v in pairs(ents.FindByClass("info_lounge")) do
		self.LoungeOrigin = v
		break
	end
	
	
	if(self.InitVendors) then
		self:InitVendors()
		self:SetupVendors()
	end
	
	]]
	
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
	
	--[[
	if (!player:IsBot()) then
		timer.Simple(5, function()
			if(IsValid(player)) then
				CommLink:RefreshPlayer(player)
				Leaderboards:RefreshPlayer(player)
			end
		end)
	end]]
	
	self:SetupAds(player)
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

function GM:PlayerSelectSpawn(player)
	local spawnPoint = self.spawnPoints.lounge
	
	if (player:Team() > TEAM_READY) then
		spawnPoint = self.spawnPoints
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









GM.Ads = {}

local grab_ads = {
	"locationID",
	"image",
	"action",
	"actioncontent"
}

function GM:LoadAds()
	
	if !tmysql then return end
	libsass.mysqlDatabase:Query( "SELECT "..table.concat(grab_ads,", ").." FROM adverts", function( res, stat, err )
		
		if err != 0 then Error( "LoadAds Error: ", tostring(err), ";", tostring(stat) ) end
		if !(res[1]) then return end
		
		local data = {}
		for i, _ in pairs( res ) do
			data[ i ] = {}
			for k, v in ipairs( grab_ads ) do
				data[ i ][ v ] = res[ i ][ k ]
			end
		end
		
		local ads = {}
		
		for _, data in pairs( data ) do
			local ad = {}
			ad.mat = data.image
			ad.act = data.action
			ad.cnt = data.actioncontent
			ads[ data.locationID ] = ad
			resource.AddFile( "materials/"..data.image..".vtf" )
			resource.AddFile( "materials/"..data.image..".vmt" )
		end
		
		self.Ads = table.Copy( ads )
		GAMEMODE:SetupAds()
		
	end )
	
end

local function CountAds()
	for k, v in pairs( GAMEMODE.Ads ) do
		if !v.used then return true end
	end
	return false
end

function GM:SetupServerIDs()
	nwt = nwt or 2
	nwt = nwt == 1 and 2 or 1
	for _, info in pairs( ents.FindByClass( "info_serverstatus" ) ) do
		info:SetNWInt( "sid", info.sid + nwt * 0.1 )
	end
end

function GM:SetupAds( pl )
	for _, ad in pairs( ents.FindByClass( "info_advertisement" ) ) do
		if !ad.location then
			local prop = ents.Create("info_scoreboard")
			prop:SetPos( ad:GetPos() )
			prop:SetAngles( ad:GetAngles() )
			prop:Spawn()
			prop:Activate()
			ad:Remove()
		elseif CountAds() then
			
			for k, v in pairs( self.Ads ) do
				if (ad.location or 0) == k-100 then
					ad.cnt = v.cnt
					ad.act = v.act
					ad.mat = v.mat
					ad.setup = true
					v.used = true
					break
				end
			end
		end
		if ad.setup then
			umsg.Start( "recvAd", pl )
				umsg.Short( ad:EntIndex() )
				umsg.String( ad.mat )
				umsg.String( ad.cnt )
				umsg.Short( ad.act )
				umsg.Short( ad.width )
				umsg.Short( ad.height )
			umsg.End()
		else
			umsg.Start( "recvAd", pl )
				umsg.Short( ad:EntIndex() )

				if ad.width > 64 then 
					umsg.String( "sassilization/adverts2/advert000_wide" )
				else 
					umsg.String( "sassilization/adverts2/advert000" )
				end 

				if(ad.location)then
					umsg.String(ad.location)
				else
					umsg.String("")
				end
				
		
				umsg.Short( 0 )
				umsg.Short( ad.width )
				umsg.Short( ad.height )
			umsg.End()
		end
	end
	if CountAds() then
		for k, v in pairs( self.Ads ) do
			v.used = true
		end
	end
	self:SetupServerIDs()
end