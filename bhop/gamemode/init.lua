---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

include("shared.lua")
include("sv_config.lua")
include("sv_jumpstats.lua")
include("sh_styles.lua") 
include("sh_maps.lua") 
include("sh_viewoffsets.lua") 
include("player_class/player_bhop.lua")
include("sv_gatekeeper.lua") 
include("gas2_sv.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_styles.lua") 
AddCSLuaFile("sh_viewoffsets.lua") 
AddCSLuaFile("cl_records.lua") 
AddCSLuaFile("cl_scoreboard.lua") 
AddCSLuaFile("a12c.lua")

util.AddNetworkString("WriteRT")
util.AddNetworkString("ModifyRT")

SS.MapTime = 60
SS.SetupGamemode("bhop", true) 


local StoreFrames = {} --local is better
local Frames = {}
local LastWep = {}

GM.PSaveData = {} -- Save last known positions and angles for respawn here.
GM.ACAreas = {}
GM.RecordTable = {}
for k,_ in pairs(GM.Styles) do
		GM.RecordTable[k] = {}
end

function GM:Initialize()
	DB_Query("SELECT id FROM bh_mapids WHERE mapname='"..game.GetMap().."'", 
	function(data)
		if(data && data[1]) then
			self.CurrentID = data[1]["id"]
			self:LoadRecs()
		elseif(data && !data[1]) then
			DB_Query("INSERT INTO bh_mapids (mapname) VALUES ('"..game.GetMap().."')",
			function()
				DB_Query("SELECT id FROM bh_mapids WHERE mapname='"..game.GetMap().."'", 
				function(data)
					if(data && data[1]) then
						self.CurrentID = data[1]["id"]
						self:LoadRecs()
					end
				end)
			end)
		end
	end, 
	function() 
		--lets retry that one more time
		timer.Simple(4, function()
			DB_Query("SELECT id FROM bh_mapids WHERE mapname='"..game.GetMap().."'", 
			function(data)
				if(data && data[1]) then
					self.CurrentID = data[1]["id"]
					self:LoadRecs()
				elseif(data && !data[1]) then
					DB_Query("INSERT INTO bh_mapids (mapname) VALUES ('"..game.GetMap().."')",
						function()
						DB_Query("SELECT id FROM bh_mapids WHERE mapname='"..game.GetMap().."'", 
						function(data)
							if(data && data[1]) then
								self.CurrentID = data[1]["id"]
								self:LoadRecs()
							end
						end)
					end)
				end
			end)
		end)
	end)
	self.BaseClass:Initialize()
end

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
	local ac = ents.Create("ac_area")
	ac:SetPos(max-(max-min)/2) 
	ac:Setup(min, max, m) 
	ac:Spawn()
end

function GM:ShowTeam(ply) 
	ply:ConCommand("records")
end 

concommand.Add("ss_wr",function(ply)
	ply:ConCommand("records")
end)

SS.AddCommand("wr","ss_wr")

concommand.Add("ss_restart",function(ply)
	if ply:Team() == TEAM_BHOP then 
		ply:ResetTimer() 
		ply.Winner = false 
	end  
	ply:SetTeam(TEAM_BHOP) 
	ply:Spawn() 
end)

SS.AddCommand("r","ss_restart")
SS.AddCommand("rr","ss_restart")
SS.AddCommand("restart","ss_restart")

concommand.Add("ss_spec",function(p,cmd,args)
	if(p:Team() == TEAM_SPEC) then --toggle spectator with !spec
		if p:Team() == TEAM_BHOP then 
			p:ResetTimer() 
			p.Winner = false 
		end  
		p:SetTeam(TEAM_BHOP) 
		p:Spawn() 
		return
	end
	p:SetTeam(TEAM_SPEC)
	p:Spawn()
end)

SS.AddCommand("spec","ss_spec")

function GM:LoadRecs()
	DB_Query("SELECT name,style,time,steamid FROM bh_records WHERE mapid='"..self.CurrentID.."' AND pb='1' ORDER BY time",
	function(data)
		if(data) then
			for _,v in pairs(data) do
				table.insert(self.RecordTable[tonumber(v["style"])],{["name"] = v["name"],["steamid"] = v["steamid"],["time"] = v["time"]})
			end
		end
	end)
end

function PLAYER_META:LoadPBs()
	self.PBS = {}
	for k,_ in pairs(GAMEMODE.Styles) do
		self.PBS[k] = 0
	end
	for k,v in pairs(GAMEMODE.RecordTable) do
		for _,rec in pairs(v) do
			if(rec["steamid"] == string.sub(self:SteamID(),7)) then
				self.PBS[k] = rec["time"]
			end
		end
	end
	net.Start("WriteRT")
	net.WriteTable(GAMEMODE.RecordTable)
	net.Send(self)
end

local cache = false --more of my dumb cache shit
local cacheresult = false

function GM:PlayerInitialSpawn(ply) 
	if(self.CurrentID) then
		ply:LoadPBs()
	else
		timer.Simple(4, function()
			if(self.CurrentID) then
				ply:LoadPBs()
			end
		end)
	end
	self.BaseClass:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_BHOP)
	if(!cache) then
		cache = true
		if(table.HasValue(SS.AutoMaps,game.GetMap())) then
			cacheresult = true
		else
			cacheresult = false
		end
	end
	if(cacheresult) then
		timer.Simple(5,function()
			ply:ChatPrint("This map has auto enabled. Hold SPACE to bhop.")
		end)
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
		
		if !ply.Style then
			ply.Style = 1 --normal style
			ply:SetNWInt("Style",1)
		end

		if ply:IsSuperAdmin() then 
			ply:Give("ss_mapeditor") 
		end 

		if(!ply:IsBot()) then
			if ply.PBS and ply.PBS[ply.Style] then -- We have to make sure it exists.
				ply:SetPB(tonumber(ply.PBS[ply.Style])) 
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
				Frames[ply] = 0
				StoreFrames[ply] = nil
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
		end
	else 
		self:PlayerSpawnAsSpectator(ply) 
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
			if(h > 80 && !table.HasValue(SS.Alldoors,game.GetMap()) && !table.HasValue(SS.Heightdoors,game.GetMap())) then continue end
			local tab = ents.FindInBox( v:LocalToWorld(mins)-Vector(0,0,10), v:LocalToWorld(maxs)+Vector(0,0,5) )
			if(tab || table.HasValue(SS.Alldoors,game.GetMap())) then
				for _,v2 in pairs(tab) do if(v2 && v2:IsValid() && v2:GetClass() == "trigger_teleport") then tele = v2 end end
				if(tele || table.HasValue(SS.Alldoors,game.GetMap())) then
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
	
	self:ReadWRRun()
	self:AreaSetup()
end 

function GM:PlayerFootstep(ply)
	if ply:Alive() then -- If alive, assume we save positions
		if !self.PSaveData[ply:SteamID()] then self.PSaveData[ply:SteamID()] = {} end 
		self.PSaveData[ply:SteamID()].LastPosition = ply:GetPos() 
		self.PSaveData[ply:SteamID()].LastAngle = ply:GetAngles() 
	end 
end

function GM:ReadWRRun()
	self.WRFrames = 0
	if(!file.IsDir("botfiles","DATA")) then
		file.CreateDir("botfiles","DATA")
	end
	if(file.Exists("botfiles/"..game.GetMap()..".txt","DATA")) then
		local str = file.Read("botfiles/"..game.GetMap()..".txt","DATA")
		str = string.gsub(str,"THISISABOTFILE\n","")
		str = util.Decompress(str)
		str = util.JSONToTable(str)
		self.WRFr = str
		self.WRFrames = #self.WRFr[1]
	end
	self:SpawnBot()
end

function GM:SpawnBot()
	for k,v in pairs(player.GetAll()) do
		if(v:IsBot()) then
			self.WRBot = v
			if(v:GetMoveType() != 0) then
				v:SetMoveType(1)
				v:SetCollisionGroup(10)
			end
		end
	end
	if(self.WRBot && self.WRBot:IsValid()) then return end
	RunConsoleCommand("bot")
	timer.Simple(0.5,function()
		for k,v in pairs(player.GetAll()) do
			if(v:IsBot()) then
				self.WRBot = v
				if(v:GetMoveType() != 0) then
					v:SetMoveType(1)
					v:SetCollisionGroup(10)
				end
			end
		end
	end)
end

function GM:PlayerWon(ply) 
	if(ply:IsBot()) then return end
	ply:EndTimer()
	ply.Winner = true 
	local steamid = ply:SteamID()
	local name = ply:Nick()
	ply:ChatPrintAll(ply:Name().." has finished on "..self.Styles[ply.Style].name.." in ".. FormatTime(ply:GetTotalTime(true)))
	local t = ply:GetTotalTime(false)
	if(self.CurrentID && (tonumber(ply.PBS[ply.Style]) == 0 ||t < tonumber(ply.PBS[ply.Style]))) then
		ply:ChatPrint("You have set a new Personal Best of "..FormatTime(t).."!")
		if(tonumber(ply.PBS[ply.Style]) == 0) then
			DB_Query("INSERT INTO bh_records (name,mapid,style,date,time,steamid,pb) VALUES('"..name.."','"..self.CurrentID.."','"..ply.Style.."','"..os.time().."','"..t.."','"..string.sub(steamid, 7).."','1')")
		else
			DB_Query("UPDATE bh_records SET pb='0' WHERE style='"..ply.Style.."' AND steamid='"..string.sub(steamid, 7).."' AND pb='1'")
			DB_Query("INSERT INTO bh_records (name,mapid,style,date,time,steamid,pb) VALUES('"..name.."','"..self.CurrentID.."','"..ply.Style.."','"..os.time().."','"..t.."','"..string.sub(steamid, 7).."','1')")
		end
		ply.PBS[ply.Style] = t
		ply:SetPB(t)
	
		local rem = nil
		for k,v in pairs(self.RecordTable[ply.Style]) do
			if(v["steamid"] == string.sub(steamid, 7)) then
				rem = k
			end
		end
		local i = {["name"] = name, ["steamid"] = string.sub(steamid, 7), ["time"] = t}
		if(rem) then
			table.remove(self.RecordTable[ply.Style],rem)
		end
		table.insert(self.RecordTable[ply.Style],i)
		table.SortByMember(self.RecordTable[ply.Style], "time", function(a, b) return a > b end)
		if(self.RecordTable[ply.Style][1]["steamid"] == i["steamid"] && ply.Style == 1 && StoreFrames[ply]) then
			self.WRFr = StoreFrames[ply]
			self.WRFrames = #self.WRFr[1]
			self.NewWR = true
			file.Write("botfiles/"..game.GetMap()..".txt", "THISISABOTFILE\n")
			local write = util.TableToJSON(self.WRFr)
			write = util.Compress(write)
			file.Append("botfiles/"..game.GetMap()..".txt",write)
			
			self:SpawnBot()
		end
		net.Start("ModifyRT")
		net.WriteString(string.sub(steamid,7))
		net.WriteString(name)
		net.WriteInt(ply.Style,4)
		net.WriteFloat(t)
		net.Broadcast()
	else
		DB_Query("INSERT INTO bh_records (name,mapid,style,date,time,steamid,pb) VALUES('"..name.."','"..self.CurrentID.."','"..ply.Style.."','"..os.time().."','"..t.."','"..string.sub(steamid, 7).."','0')")
	end
	StoreFrames[ply] = nil
	--print(ply.Payout) 
	--ply:GiveMoney(ply.Payout)
end 

hook.Add("Think","BotShit",function()
	for _,p in pairs(player.GetAll()) do
		if(p:IsBot() && GAMEMODE.WRBot && p == GAMEMODE.WRBot) then 
			if(p:GetMoveType() == 2) then
				p:SetMoveType(0)
			end
		end
	end
	if(GAMEMODE.WRBot && !GAMEMODE.WRBot:IsValid()) then
		GAMEMODE:SpawnBot()
	end
end)

function PLAYER_META:ClearFrames()
	Frames[self] = 0
	StoreFrames[self] = nil
end

function GM:GetFallDamage( ply, speed )
	return 0
end

local wrframes = 1

hook.Add("SetupMove","wrbot",function(ply,data)
	if(ply:GetObserverTarget() && ply:GetObserverTarget():IsValid() && ply:GetObserverMode() != OBS_MODE_ROAMING) then
		local o = ply:GetObserverTarget()
		data:SetOrigin(o:GetPos())
		if(ply:GetObserverMode() == OBS_MODE_IN_EYE) then
			ply:SetEyeAngles(o:EyeAngles())
		end
	end
	if(ply == GAMEMODE.WRBot && GAMEMODE.WRFr) then
		if(GAMEMODE.NewWR) then
			GAMEMODE.NewWR = false
			wrframes = 1
		end
		if wrframes >= GAMEMODE.WRFrames then
			wrframes = 1
		end
		
		local o = Vector(GAMEMODE.WRFr[1][wrframes],GAMEMODE.WRFr[2][wrframes],GAMEMODE.WRFr[3][wrframes])
		local a = Angle(GAMEMODE.WRFr[4][wrframes],GAMEMODE.WRFr[5][wrframes],0)

		data:SetOrigin(o)
		ply:SetEyeAngles(a)
		if(GAMEMODE.WRFr[7][wrframes]) then
			if(!ply:HasWeapon(GAMEMODE.WRFr[7][wrframes])) then
				ply:Give(GAMEMODE.WRFr[7][wrframes])
			end
			ply:SelectWeapon(GAMEMODE.WRFr[7][wrframes])
		end
		wrframes = wrframes + 1
	elseif(ply:Team() == TEAM_BHOP && !ply.InStart && ply:IsTimerRunning() && !ply.Winner && Frames[ply]) then
		if(!StoreFrames[ply]) then
			Frames[ply] = 0
			StoreFrames[ply] = {}
			StoreFrames[ply][1] = {}
			StoreFrames[ply][2] = {}
			StoreFrames[ply][3] = {}
			StoreFrames[ply][4] = {}
			StoreFrames[ply][5] = {}
			StoreFrames[ply][6] = {}
			StoreFrames[ply][7] = {}
			LastWep[ply] = "weapon_crowbar"
		end
		local o = data:GetOrigin()
		local a = data:GetAngles()
		StoreFrames[ply][1][Frames[ply]] = o.x
		StoreFrames[ply][2][Frames[ply]] = o.y
		StoreFrames[ply][3][Frames[ply]] = o.z
		StoreFrames[ply][4][Frames[ply]] = a.p
		StoreFrames[ply][5][Frames[ply]] = a.y
		
		local c = ply:GetActiveWeapon():GetClass()
		if(LastWep[ply] != c) then
			StoreFrames[ply][7][Frames[ply]] = c
			LastWep[ply] = c
		end
		
		Frames[ply] = Frames[ply] + 1
	elseif(ply:Team() == TEAM_BHOP && ply.InStart && StoreFrames[ply]) then
		StoreFrames[ply] = nil
	end
end)

hook.Add("StartCommand","wrbot2",function(ply,data)
	if(ply == GAMEMODE.WRBot && wrframes) then
		if(GAMEMODE.WRFr) then
			if(ply:GetMoveType() == 0) then
				data:SetButtons(tonumber(GAMEMODE.WRFr[6][wrframes])) --only place this actually works
			end
		else
			data:ClearButtons()
			data:ClearMovement()
		end
	elseif(ply:Team() == TEAM_BHOP && !ply.InStart && ply:IsTimerRunning() && !ply.Winner && StoreFrames[ply] && Frames[ply]) then
		StoreFrames[ply][6][Frames[ply]] = data:GetButtons() --may aswell record it in here too
	end
end)