---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------


include("shared.lua")
include("sv_config.lua")
include("sh_levels.lua") 
include("sh_styles.lua") 
include("sh_maps.lua") 
include("sh_viewoffsets.lua") 
include("player_class/player_bhop.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_difficulty_menu.lua") 
AddCSLuaFile("sh_levels.lua") 
AddCSLuaFile("sh_styles.lua") 
AddCSLuaFile("sh_viewoffsets.lua") 

util.AddNetworkString("WriteRT")
util.AddNetworkString("ModifyRT")

GM.PSaveData = {} -- Save last known positions and angles for respawn here.
GM.ACAreas = {}
GM.RecordTable = {}
for k,_ in pairs(GM.Levels) do
	GM.RecordTable[k] = {}
	for k2,_ in pairs(GM.Styles) do
		GM.RecordTable[k][k2] = {}
	end
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

function GM:PlayerSay( ply, text, public )
	local t = string.lower( text )
	
	for k,v in pairs(self.Styles) do
		if(t == v.cmd) then
			ply.Style = k
			ply:SetNWInt("Style",k)
			ply:PrintChat("Changed to "..v.name..".")
			if(ply:IsTimerRunning() || ply.Winner) then
				ply.Winner = false
				ply:Spawn()
			end
			return ""
		end
	end
	
	if(t == "!r") then
		ply.Winner = false
		ply:Spawn()
	end
	
	return self.BaseClass:PlayerSay(ply,text,public)
end

function GM:LoadRecs()
	DB_Query("SELECT level,style,time,steamid FROM bh_records WHERE mapid='"..self.CurrentID.."'",
	function(data)
		if(data) then
			for _,v in pairs(data) do
				table.insert(self.RecordTable[tonumber(v["level"])][tonumber(v["style"])],{["steamid"] = v["steamid"],["time"] = v["time"]})
			end
		end
	end)
end

function PLAYER_META:LoadPBs()
	self.PBS = {}
	for k,_ in pairs(GAMEMODE.Levels) do
		self.PBS[k] = {}
		for k2,_ in pairs(GAMEMODE.Styles) do
			self.PBS[k][k2] = 0
		end
	end
	for k,v in pairs(GAMEMODE.RecordTable) do
		for k2,v2 in pairs(v) do
			for _,rec in pairs(v2) do
				if(rec["steamid"] == string.sub(self:SteamID(),7)) then
					self.PBS[k][k2] = rec["time"]
				end
			end
		end
	end
	net.Start("WriteRT")
	net.WriteTable(GAMEMODE.RecordTable)
	net.Send(self)
end

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

		if !ply.LevelData then
			self:LevelSetup(ply,2) --default level
		end
		
		ply:SetPB(tonumber(ply.PBS[ply.LevelData.id][ply.Style]))
			
		if ply:HasTimer() and self.PSaveData[ply:SteamID()] then 
			ply.AreaIgnore = true 
			local PosInfo = self.PSaveData[ply:SteamID()] 
			ply:SetPos(PosInfo.LastPosition) 
			ply:SetEyeAngles(PosInfo.LastAngle) 
			ply:StartTimer() 
			ply.AreaIgnore = false
		elseif !ply.InSpawn then 
			ply:StartTimer() 
			ply.Q1 = nil
			ply.Q2 = nil
			ply.Q3 = nil
			ply.Q4 = nil
			ply.Secs = 1
			ply.Frames = 0
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
	
	self:ReadWRRun()
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

function GM:ReadWRRun()
	self.WRFrames = 0
	if(!file.IsDir("botfiles","DATA")) then
		file.CreateDir("botfiles","DATA")
	end
	if(file.Exists("botfiles/"..game.GetMap().."_1.txt","DATA")) then
		local str = file.Read("botfiles/"..game.GetMap().."_1.txt","DATA")
		str = string.gsub(str,"THISISABOTFILE\n","")
		str = util.Decompress(str)
		str = util.JSONToTable(str)
		self.WR1 = str
		self.WRFrames = self.WRFrames + #self.WR1
	end
	if(file.Exists("botfiles/"..game.GetMap().."_2.txt","DATA")) then
		local str = file.Read("botfiles/"..game.GetMap().."_2.txt","DATA")
		str = string.gsub(str,"THISISABOTFILE\n","")
		str = util.Decompress(str)
		str = util.JSONToTable(str)
		self.WR2 = str
		self.WRFrames = self.WRFrames + #self.WR2
	end
	if(file.Exists("botfiles/"..game.GetMap().."_3.txt","DATA")) then
		local str = file.Read("botfiles/"..game.GetMap().."_3.txt","DATA")
		str = string.gsub(str,"THISISABOTFILE\n","")
		str = util.Decompress(str)
		str = util.JSONToTable(str)
		self.WR3 = str
		self.WRFrames = self.WRFrames + #self.WR3
	end
	if(file.Exists("botfiles/"..game.GetMap().."_4.txt","DATA")) then
		local str = file.Read("botfiles/"..game.GetMap().."_4.txt","DATA")
		str = string.Replace(str,"THISISABOTFILE\n","")
		str = util.Decompress(str)
		str = util.JSONToTable(str)
		self.WR4 = str
		self.WRFrames = self.WRFrames + #self.WR4
	end
	if(self.WR1) then
		self:SpawnBot()
	end
end

function GM:SpawnBot()
	for k,v in pairs(player.GetAll()) do
		if(v:IsBot()) then
			self.WRBot = v
			if(v:GetMoveType() != 0) then
				v:SetMoveType(0)
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
					v:SetMoveType(0)
					v:SetCollisionGroup(10)
				end
			end
		end
	end)
end

function GM:PlayerWon(ply) 
	ply:EndTimer()
	ply.Winner = true 
	ply:ChatPrintAll(ply:Name().." has won in ".. FormatTime(ply:GetTotalTime(true)))
	local t = ply:GetTotalTime(false)
	if(self.CurrentID && t < tonumber(ply.PBS[ply.LevelData.id][ply.Style])) then
		ply:ChatPrint("You have set a new Personal Best of "..FormatTime(t).."!")
		local steamid = ply:SteamID()
		if(tonumber(ply.PBS[ply.LevelData.id][ply.Style]) == 0) then
			DB_Query("INSERT INTO bh_records (mapid,level,style,date,time,steamid) VALUES('"..self.CurrentID.."','"..ply.LevelData.id.."','"..ply.Style.."','"..os.time().."','"..t.."','"..string.sub(steamid, 7).."')")
		else
			DB_Query("UPDATE bh_records SET time='"..t.."', date='"..os.time().."' WHERE style='"..ply.Style.."' AND level='"..ply.LevelData.id.."' AND steamid='"..string.sub(steamid, 7).."'")
		end
		ply.PBS[ply.LevelData.id][ply.Style] = t
		ply:SetPB(t)
	
		local rem = 0
		local newpos = nil
		for k,v in pairs(self.RecordTable[ply.LevelData.id][ply.Style]) do
			if(v["steamid"] == string.sub(steamid, 7)) then
				rem = k
			end
			if(!newpos && t < tonumber(v["time"])) then
				newpos = k
			end
		end
		if(!newpos) then
			newpos = #self.RecordTable[ply.LevelData.id][ply.Style] + 1
		end
		if(newpos == 1) then
			local q = {}
			if(ply.Q1) then
				q[1] = ply.Q1
			end
			if(ply.Q2) then
				q[2] = ply.Q2
			end
			if(ply.Q3) then
				q[3] = ply.Q3
			end
			if(ply.Q4) then
				q[4] = ply.Q4
			end
			if(!self.WRBot) then
				sb = true
			end
			self.WRFrames = ply.Frames
			self.WR1 = nil
			self.WR1 = {}
			self.WR2 = nil
			self.WR2 = {}
			self.WR3 = nil
			self.WR3 = {}
			self.WR4 = nil
			self.WR4 = {}
			for k,v in pairs(q[1]) do
				local tab = string.Explode(";",v)
				for _,l in pairs(tab) do
					if(l != "") then
						table.insert(self.WR1,l)
					end
				end
			end
			if(q[2] && type(q[2]) == "table") then
				for k,v in pairs(q[2]) do
					local tab = string.Explode(";",v)
					for _,l in pairs(tab) do
						if(l != "") then
							table.insert(self.WR2,l)
						end
					end
				end
			end
			if(q[3] && type(q[3]) == "table") then
				for k,v in pairs(q[3]) do
					local tab = string.Explode(";",v)
					for _,l in pairs(tab) do
						if(l != "") then
							table.insert(self.WR3,l)
						end
					end
				end
			end
			if(q[4] && type(q[4]) == "table") then
				for k,v in pairs(q[4]) do
					local tab = string.Explode(";",v)
					for _,l in pairs(tab) do
						if(l != "") then
							table.insert(self.WR4,l)
						end
					end
				end
			end
			self.NewWR = true
			file.Write("botfiles/"..game.GetMap().."_1.txt", "THISISABOTFILE\n")
			local write = util.TableToJSON(self.WR1)
			write = util.Compress(write)
			file.Append("botfiles/"..game.GetMap().."_1.txt",write)
			if(#self.WR2 > 0) then
				file.Write("botfiles/"..game.GetMap().."_2.txt", "THISISABOTFILE\n")
				local write2 = util.TableToJSON(self.WR2)
				write2 = util.Compress(write2)
				file.Append("botfiles/"..game.GetMap().."_2.txt",write2)
			end
			if(#self.WR3 > 0) then
				file.Write("botfiles/"..game.GetMap().."_3.txt", "THISISABOTFILE\n")
				local write2 = util.TableToJSON(self.WR3)
				write2 = util.Compress(write2)
				file.Append("botfiles/"..game.GetMap().."_3.txt",write2)
			end
			if(#self.WR4 > 0) then
				file.Write("botfiles/"..game.GetMap().."_4.txt", "THISISABOTFILE\n")
				local write2 = util.TableToJSON(self.WR4)
				write2 = util.Compress(write2)
				file.Append("botfiles/"..game.GetMap().."_4.txt",write2)
			end
				
			self:SpawnBot()
		end
		table.remove(self.RecordTable[ply.LevelData.id][ply.Style],k)
		table.insert(self.RecordTable[ply.LevelData.id][ply.Style],newpos,{["steamid"] = string.sub(steamid, 7), ["time"] = t})
		net.Start("ModifyRT")
		net.WriteString(steamid)
		net.WriteInt(4,ply.LevelData.id)
		net.WriteInt(4,ply.Style)
		net.WriteInt(128,rem)
		net.WriteInt(128,newpos)
		net.WriteInt(128,t)
		net.Broadcast()
	end
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
	for _,p in pairs(player.GetAll()) do
		if(p:IsBot()) then 
			if(p:GetMoveType() == 2) then
				p:SetMoveType(0)
			end
		end
		for _,v in pairs(GAMEMODE.ACAreas) do	
			if(p:Team() == TEAM_BHOP && p:HasTimer() && p:IsTimerRunning() && !p.Winner && GAMEMODE:IsInArea(p,v[1],v[2])) then
				p:EndTimer()
				p:ChatPrint(v[3])
			end
		end
	end
end) --seperate think hooks = more organised and no extra cost in proccessing afaik

hook.Add("SetupMove","LJStats",function(p,data)
	if(!p:IsOnGround()) then
		local dontrun = false
		if(!p.strafe) then
			p.strafe = {}
		end
		p.curangle = p:EyeAngles()
		if(p.curangle.y < 0) then
			p.curangle.y = p.curangle.y + 360
		end
		if(!p.lastangle) then
			p.lastangle = p.curangle.y
		end
		if(p.curangle.y == p.lastangle) then
			dontrun = true
		end
		p.lastangle = p:EyeAngles()

		if(p:KeyDown(IN_MOVELEFT) && (p.strafingright || (!p.strafingright && !p.strafingleft))) then
			p.strafingright = false
			p.strafingleft = true
			p.strafenum = p.strafenum + 1
			p.strafe[p.strafenum] = {}
			p.strafe[p.strafenum][1] = 0
			p.strafe[p.strafenum][2] = 0
		elseif(p:KeyDown(IN_MOVERIGHT) && (p.strafingleft || (!p.strafingright && !p.strafingleft))) then
			p.strafingright = true
			p.strafingleft = false
			p.strafenum = p.strafenum + 1
			p.strafe[p.strafenum] = {}
			p.strafe[p.strafenum][1] = 0
			p.strafe[p.strafenum][2] = 0
		elseif(p.strafenum == 0) then
			dontrun = true
		end
		if(!p.strafenum) then
			dontrun = true
		end
		if(!dontrun) then
			p.speed = data:GetVelocity():Length2D()
			if(p.lastspeed) then
				local g = p.speed - p.lastspeed
				if(g > 0.5) then
					p.strafe[p.strafenum][1] = p.strafe[p.strafenum][1] + 1
				else
					p.strafe[p.strafenum][2] = p.strafe[p.strafenum][2] + 1
				end
			end
			p.lastspeed = p.speed
		elseif(p.strafenum && p.strafenum != 0) then
			p.strafe[p.strafenum][2] = p.strafe[p.strafenum][2] + 1
		end
	end
end)

timer.Create("WRBot",1/100,0,function()
	for k,v in pairs(player.GetAll()) do
		if(v:Team() == TEAM_BHOP) then
			if(v:IsTimerRunning() && !v.Winner && v.Secs && v.Frames) then
				if(v.Frames == 0) then
					v.Frames = 1
					v.Q1 = {}
					v.Q2 = {}
					v.Q3 = {}
					v.Q4 = {}
				end
				if(v.Secs/60<30) then
					local start = 0
					local f = v.Secs - start
					if(!v.Q1[f]) then
						v.Q1[f] = ""
					end
					local p = v:GetPos()
					local ang = v:GetAngles()
					local aim = v:EyeAngles()
					local r = v:GetRenderAngles()
					local addon = p.x..","..p.y..","..p.z..":"..ang.p..","..ang.y..","..ang.r..":"..aim.p..","..aim.y..","..aim.r..":"..r.p..","..r.y..","..r.r..";"
					v.Q1[f] = v.Q1[f]..addon
				elseif(v.Secs/60<60) then
					local start = 29*60
					local f = v.Secs - start
					if(!v.Q2[f]) then
						v.Q2[f] = ""
					end
					local p = v:GetPos()
					local ang = v:GetAngles()
					local aim = v:EyeAngles()
					local r = v:GetRenderAngles()
					local addon = p.x..","..p.y..","..p.z..":"..ang.p..","..ang.y..","..ang.r..":"..aim.p..","..aim.y..","..aim.r..":"..r.p..","..r.y..","..r.r..";"
					v.Q2[f] = v.Q2[f]..addon
				elseif(v.Secs/60<90) then
					local start = 59*60
					local f = v.Secs - start
					if(!v.Q3[f]) then
						v.Q3[f] = ""
					end
					local p = v:GetPos()
					local ang = v:GetAngles()
					local aim = v:EyeAngles()
					local r = v:GetRenderAngles()
					local addon = p.x..","..p.y..","..p.z..":"..ang.p..","..ang.y..","..ang.r..":"..aim.p..","..aim.y..","..aim.r..":"..r.p..","..r.y..","..r.r..";"
					v.Q3[f] = v.Q3[f]..addon
				elseif(v.Secs/60<=120) then
					local start = 89*60
					local f = v.Secs - start
					if(!v.Q4[f]) then
						v.Q4[f] = ""
					end
					local p = v:GetPos()
					local ang = v:GetAngles()
					local aim = v:EyeAngles()
					local r = v:GetRenderAngles()
					local addon = p.x..","..p.y..","..p.z..":"..ang.p..","..ang.y..","..ang.r..":"..aim.p..","..aim.y..","..aim.r..":"..r.p..","..r.y..","..r.r..";"
					v.Q4[f] = v.Q4[f]..addon
				end
				v.Frames = v.Frames + 1
				v.Secs = math.floor((v.Frames/100)+1)
			end
		end
	end
	if(GAMEMODE.WRBot && GAMEMODE.WRBot:IsValid() && GAMEMODE.WR1) then
		local bot = GAMEMODE.WRBot
		if(GAMEMODE.NewWR) then
			GAMEMODE.NewWR = false
			wrframes = 1
			wrsecs = 1
		end
		if wrframes >= GAMEMODE.WRFrames then
			wrframes = 1
			wrsecs = 1
		end
		if(wrsecs/60<30 && GAMEMODE.WR1) then
			local start = 0
			local f = wrframes - start
			if(!GAMEMODE.WR1[f] || GAMEMODE.WR1[f] == "") then
				wrframes = wrframes + 1
				f = wrframes - start
			end
			local split = string.Explode(":",GAMEMODE.WR1[f])
			local sp1 = string.Explode(",",split[1])
			local sp2 = string.Explode(",",split[2])
			local sp3 = string.Explode(",",split[3])
			local sp4 = string.Explode(",",string.gsub(split[4],".",","))
			bot:SetPos(Vector(sp1[1],sp1[2],sp1[3]))
			bot:SetAngles(Angle(tonumber(sp2[1]),tonumber(sp2[2]),tonumber(sp2[3])))
			bot:SetEyeAngles(Angle(tonumber(sp3[1]),tonumber(sp3[2]),tonumber(sp3[3])))
			bot:SetRenderAngles(Angle(tonumber(sp4[1]),tonumber(sp4[2]),tonumber(sp4[3])))
		elseif(wrsecs/60<60 && GAMEMODE.WR2) then
			local start = 29*100*60
			local f = wrframes - start
			if(!GAMEMODE.WR2[f] || GAMEMODE.WR2[f] == "") then
				wrframes = wrframes + 1
				f = wrframes - start
			end
			local split = string.Explode(":",GAMEMODE.WR2[f])
			local sp1 = string.Explode(",",split[1])
			local sp2 = string.Explode(",",split[2])
			local sp3 = string.Explode(",",split[3])
			local sp4 = string.Explode(",",string.gsub(split[4],".",","))
			bot:SetPos(Vector(sp1[1],sp1[2],sp1[3]))
			bot:SetAngles(Angle(tonumber(sp2[1]),tonumber(sp2[2]),tonumber(sp2[3])))
			bot:SetEyeAngles(Angle(tonumber(sp3[1]),tonumber(sp3[2]),tonumber(sp3[3])))
			bot:SetRenderAngles(Angle(tonumber(sp4[1]),tonumber(sp4[2]),tonumber(sp4[3])))
		elseif(wrsecs/60<90 && GAMEMODE.WR3) then
			local start = 59*100*60
			local f = wrframes - start
			if(!GAMEMODE.WR3[f] || GAMEMODE.WR3[f] == "") then
				wrframes = wrframes + 1
				f = wrframes - start
			end
			local split = string.Explode(":",GAMEMODE.WR3[f])
			local sp1 = string.Explode(",",split[1])
			local sp2 = string.Explode(",",split[2])
			local sp3 = string.Explode(",",split[3])
			local sp4 = string.Explode(",",string.gsub(split[4],".",","))
			bot:SetPos(Vector(sp1[1],sp1[2],sp1[3]))
			bot:SetAngles(Angle(tonumber(sp2[1]),tonumber(sp2[2]),tonumber(sp2[3])))
			bot:SetEyeAngles(Angle(tonumber(sp3[1]),tonumber(sp3[2]),tonumber(sp3[3])))
			bot:SetRenderAngles(Angle(tonumber(sp4[1]),tonumber(sp4[2]),tonumber(sp4[3])))
		elseif(wrsecs/60<120 && GAMEMODE.WR4) then
			local start = 89*100*60
			local f = wrframes - start
			if(!GAMEMODE.WR4[f] || GAMEMODE.WR4[f] == "") then
				wrframes = wrframes + 1
				f = wrframes - start
			end
			local split = string.Explode(":",GAMEMODE.WR4[f])
			local sp1 = string.Explode(",",split[1])
			local sp2 = string.Explode(",",split[2])
			local sp3 = string.Explode(",",split[3])
			local sp4 = string.Explode(",",string.gsub(split[4],".",","))
			bot:SetPos(Vector(sp1[1],sp1[2],sp1[3]))
			bot:SetAngles(Angle(tonumber(sp2[1]),tonumber(sp2[2]),tonumber(sp2[3])))
			bot:SetEyeAngles(Angle(tonumber(sp3[1]),tonumber(sp3[2]),tonumber(sp3[3])))
			bot:SetRenderAngles(Angle(tonumber(sp4[1]),tonumber(sp4[2]),tonumber(sp4[3])))
		end
		wrframes = wrframes + 1
		wrsecs = math.floor((wrframes/120)+1)
	end
	if(GAMEMODE.WRBot && !GAMEMODE.WRBot:IsValid() && GAMEMODE.WR1 && #player.GetAll() != 0) then
		GAMEMODE:SpawnBot()
	end
end)