----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local CivModels = {
	"models/player/%group%/male_02.mdl",
	"models/player/%group%/male_04.mdl",
	"models/player/%group%/male_06.mdl",
	"models/player/%group%/male_08.mdl"
}

util.AddNetworkString( "PlayerLoadingTime" )
util.AddNetworkString( "PlayerLoadingList" )
util.AddNetworkString( "PlayerLoadingFinish" )

function GM:CheckPassword( sid, ip, serverPass, clientPass, username )
	local steamID = util.SteamIDFrom64(sid)
	
	if table.HasValue(SA.AuthedPlayers, steamID) then
		if !self.Started then
			if !timer.Exists("Player Loading") then
				timer.Create("Player Loading", 90, 1, function()
					if #player.GetAll() > 0 then
						self:StartGame()
						for k,v in pairs(player.GetAll()) do
							net.Start("PlayerLoadingFinish")
								net.WriteString("Game starting.")
							net.Send(v)
						end
					else
						self:RestartGame()
					end
				end)
				SA.StartTime = CurTime() + 90

				for k,v in pairs(player.GetBots()) do
					v:Kick("")
				end
			end
			
			table.insert(SA.LoadingPlayers, {username, steamID})
			for k,v in pairs(player.GetAll()) do
				net.Start("PlayerLoadingList")
					net.WriteTable(SA.LoadingPlayers)
				net.Send(v)
			end
		end
		return true
	else
		return false, "Please connect to the Lobby (208.115.236.184:27017) in order to play Sassilization."
	end
end

function GM:CanPlayerSuicide( pl )
	if (!GameTime()) then
		return false
	end
	
	return true
end

function GM:PlayerSelectSpawn( pl )
	
	if self.SpawnPoints == nil then
		self.SpawnPoints = ents.FindByClass("info_player_start")
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass("gmod_player_start") )	
	end
	
	local Count = table.Count( self.SpawnPoints )
	if Count == 0 then
		Msg( "No Spawn Points.\n" )
		return ents.GetByID(0)
	end
	
	local ChosenSpawnPoint = self.SpawnPoints[1]
	
	if( not GameTime() ) then
		pl.LastSpawn = ChosenSpawnPoint
		self.LastSpawn = ChosenSpawnPoint
		return ChosenSpawnPoint
	end
	
	local AvailableSpawns = {}
	for i=1, Count do
		local spawn = self.SpawnPoints[ i ]
		if (	spawn			and
			spawn:IsValid()		and
			spawn:IsInWorld()	and
			spawn ~= pl.LastSpawn	and
			spawn ~= self.LastSpawn	) then

			local blocked = false
			for _, ent in pairs(ents.FindInBox(spawn:GetPos() + Vector(-16, -16, 0), spawn:GetPos() + Vector(16, 16, 60))) do
				if( IsValid(ent) and ent:IsPlayer() ) then
					blocked = true
				end
			end
			if not blocked then
				table.insert( AvailableSpawns, spawn )
			end
		end
	end
	
	if( table.Count( AvailableSpawns ) <= 0 ) then
		pl.blocked = true
		pl.LastSpawn = ChosenSpawnPoint
		self.LastSpawn = ChosenSpawnPoint
		return ChosenSpawnPoint
	end
	
	ChosenSpawnPoint = AvailableSpawns[ math.random( 1, #AvailableSpawns ) ]
	pl.LastSpawn = ChosenSpawnPoint
	self.LastSpawn = ChosenSpawnPoint
	
	return ChosenSpawnPoint
	
end

function GM:PlayerInitialSpawn(pl)
	if pl:SteamID() == "STEAM_0:0:12454744" or game.SinglePlayer() then sass = pl end

	if !self.Started then
		pl:Lock()
		for k,v in pairs(SA.LoadingPlayers) do
			if v[2] == pl:SteamID() then
				table.remove(SA.LoadingPlayers, k)
			end
		end
		PrintTable(SA.LoadingPlayers)
		if #SA.LoadingPlayers >= 1 then
			net.Start("PlayerLoadingTime")
				net.WriteInt(SA.StartTime - CurTime(), 16)
			net.Send(pl)
			net.Start("PlayerLoadingList")
				net.WriteTable(SA.LoadingPlayers)
			net.Send(pl)
		else
			if timer.Exists("Player Loading") then
				timer.Destroy("Player Loading")
				SA.StartTime = CurTime() + 5
				for k,v in pairs(player.GetAll()) do
					net.Start("PlayerLoadingTime")
						net.WriteInt(5, 16)
					net.Send(v)
					net.Start("PlayerLoadingFinish")
						net.WriteString("All players loaded. Game starting.")
					net.Send(v)
					
					v:ChatPrint("All players loaded. Game starting.")
				end
				timer.Simple(5, function()
					self:StartGame()
				end)
			end
		end
	else
		net.Start("PlayerLoadingFinish")
			net.WriteString("Game starting.")
		net.Send(pl)
	end
	
	pl:SetJumpPower(280)
	pl:SetTeam(SA.TEAM_PLAYERS)
	pl:SetCollisionGroup( COLLISION_GROUP_NONE )
	pl:SetSolid( 0 )

	-- Setup the tables for requesting and alliances for the player.
	pl.incRequests = {}
	pl.Alliance = {}
	pl.allyNum = 0

	if pl:IsBot() then return end
	
	AssociatePlayer(pl)

	pl:ChatPrint("Welcome to Sassilization.")

	-- Setup the delays for each miracle on the player. // Chewgum
	miracles.Setup(pl)

	timer.Simple(1, function()
		self:ShareGameInfo( pl )
	end)
	
	--if (SA.DEV and !pl:IsBot()) then
	--else
	--	pl:Lock()
	--end
end

function GM:PlayerDisconnected(pl)
	if not (IsValid( pl ) and pl:IsPlayer()) then return end

	for i,d in pairs(pl.Alliance) do
		breakAlly(pl, d)
	end
	table.Empty(pl.Alliance)

	Msg( pl:Nick().." has disconnected" )
	
	if #player.GetAll()-1 <= 1 and self.Started then
		if #player.GetAll()-1 == 1 then
			for k,v in pairs(player.GetAll()) do
				if v != pl then
					self:EndGame(v:GetEmpire())
				end
			end
		else
			self:RestartGame(MAPS.GetNextMap())
		end
	end
end

function GM:PlayerSpawn(pl)
	self:SetPlayerSpeed(pl, 280, 280)
	
	gamemode.Call( "PlayerLoadout", pl )
	
	pl:SetCollisionGroup( COLLISION_GROUP_WORLD )
	pl:SetNoCollideWithTeammates(true)
	
	if( not pl.PlayerModel ) then

		local model = CivModels[math.random( 1, #CivModels )]
		model = string.gsub( model, "%%group%%", "Group01" )
		pl.PlayerModel = model	
		
	end

	pl:SetModel( pl.PlayerModel )

end

function GM:SetupPlayerVisibility(pl) end

util.AddNetworkString( "empire.AssociatePlayer" )
function AssociatePlayer( pl )
	
	assert( pl )
	
	MsgN( "Associating player ", pl )
	
	local sid = pl:SteamID()
	if not (sid) then return end
	
	local id = #empire.GetAll()+1
	
	local emp = empire.GetBySteamID( sid )
	if( emp ) then
		
		pl:SetEmpire( emp )
		emp:SetPlayer( pl )
		timer.Simple(1, function() 
			net.Start( "empire.AssociatePlayer" )
				net.WriteEntity( pl )
				net.WriteUInt( emp:GetID(), 8 )
			net.Broadcast()
		end)

		pl:ChatPrint( "Welcome Back, empire of "..pl:Nick() )
		
		gamemode.Call("OnPlayerEmpire", pl, emp)
		
	else -- Create a new Empire
		
		pl:SetEmpire( empire.Create( pl, id, sid ) )
		
		pl:ChatPrint( "Welcome new empire of "..pl:Nick()..". Good Luck." )
		
		gamemode.Call("OnPlayerEmpire", pl, pl:GetEmpire())
		
	end
	
end

concommand.Add("dev_empire", function(ply, cmd, args)
	if (args[1]) then
		ply:ChatPrint("Setting your empire to "..args[1])
		ply:SetEmpire(empire.GetByID(tonumber(args[1])))
	else
		local sid = ply:SteamID()
		if not (sid) then return end
		local id = #empire.GetAll()+1

		ply:ChatPrint("Creating new empireid of "..id)
	end
end)

concommand.Add("dev_trans", function(ply, cmd, args)

	local tr = ply:GetEyeTraceNoCursor()
	if (IsValid(tr.Entity)) then
		local e = empire.GetByID(tonumber(args[1]))
		tr.Entity:SetEmpire(e)
		ply:ChatPrint("Setting entity to new empire.")
	end

end)

function GM:ShareGameInfo( pl )
	
	MsgN( "Sharing game info with player ", pl )
	
	pl.loading = {}
	pl.loading.empires = {}
	pl.loading.walls = {}
	pl.loading.units = {}
	
	net.Quick("load.empires", pl)

	for k,v in pairs(player.GetAll()) do
		for i,d in pairs(player.GetAll()) do
			net.Start("SetPublicAlliance")
				net.WriteEntity(v)
				net.WriteTable(v.Alliance)
			net.Send(d)
		end
	end
	
	for _, empire in pairs( empire.GetAll() ) do

		pl.loading.empires[ empire ] = true

	end
	
	for _, wall in pairs( ents.FindByClass( "building_wall" ) ) do
		
		pl.loading.walls[ wall ] = true
		
	end
	
	-- net.Quick("load.structs.houses", pl)
	
	-- local houses = GAMEMODE:GetHouses()
	-- local sCount = 1
	-- while sCount <= SA.HouseCount do
		-- local total = math.min(SA.HouseCount+1-sCount,8)
		-- net.Start( "house.Create" )
			-- Char
			-- net.WriteByte(total)
			-- for i=1, total do
				-- GAMEMODE:NETHouse( houses[sCount] )
				-- sCount = sCount + 1
			-- end
		-- net.Send( pl )
	-- end
	-- sCount = nil
	
	-- net.Quick("load.structs.ownership", pl)
	
	-- local buildings = empire.GetBuildings()
	-- local sCount = 1
	-- while sCount <= #buildings do
		-- local total = math.min(#buildings+1-sCount,8)
		-- net.Start( "empire.Control" )
			-- Char
			-- net.WriteByte(total)
			-- for i=1, total do
				-- print( sCount, "/", total, "\t", buildings[sCount], "\t", buildings[sCount]:GetEmpire(), "\t", buildings[sCount]:GetEmpire():GetID(), "\n" )
				-- UByte
				-- net.WriteUInt( buildings[sCount]:EntIndex(), 8 )
				-- UByte
				-- net.WriteUInt( buildings[sCount]:GetEmpire():GetID(), 8 )
				-- sCount = sCount + 1
			-- end
		-- net.Send( pl )
	-- end
	-- sCount = nil
	
	for _, u in pairs( unit.GetAll() ) do
		pl.loading.units[ u ] = true
	end

	-- local units = unit.GetAll()
	-- local sCount = 1
	-- while sCount < unit.GetCount() do
		-- local total = math.min(unit.GetCount()-sCount,8)
		-- net.Start( "unit.SpawnUnits" )
			-- Char
			-- net.WriteByte(total)
			-- for i=1, total do
				-- local unit = units[sCount]
				-- 2 UByte
				-- net.WriteUInt( unit:GetEmpire():GetID(), 8 )
				-- Net.WriteUInt( unit:UnitIndex(), 8 )
				-- net.WriteString( unit:GetClass() )
				-- sCount = sCount + 1
			-- end
		-- net.Send( pl )
	-- end
	-- sCount = nil
	
end

util.AddNetworkString( "empire.Control" )
util.AddNetworkString( "load.empires" )
util.AddNetworkString( "load.structs.houses" )
util.AddNetworkString( "load.structs.ownership" )
util.AddNetworkString( "load.structs.walls" )
util.AddNetworkString( "load.units" )
util.AddNetworkString( "load.territories" )
util.AddNetworkString( "loaded" )

hook.Add( "Think", "player.Loading", function()
	
	for _, pl in pairs( player.GetAll() ) do
		
		if( pl.loading ) then
			
			if( pl.loading.empires ) then
				
				local bload = false
				for e, _ in pairs( pl.loading.empires ) do
					
					if( ValidEmpire( e ) ) then
						
						MsgN( "Networking empire ", e, " to player ", pl )
						
						net.Start( "empire.Create" )
							net.WriteEntity( e:GetPlayer() )
							net.WriteUInt( e:GetID(), 8 )
							net.WriteUInt( e:GetColorID(), 8 )
							net.WriteString( e:Nick() )
						net.Send( pl )
						
						e:SendNWVars( pl )
						
					end
					
					pl.loading.empires[ e ] = nil
					bload = true
					break
					
				end
				
				if( not bload ) then
					
					pl.loading.empires = nil
					net.Quick("load.structs.walls", pl)
				end
				
			elseif( pl.loading.walls ) then
				
				local bload = false
				for w, _ in pairs( pl.loading.walls ) do
					
					if( IsValid( w ) and not w.Destroyed ) then
						net.Start( "wall.SpawnNewWall" )
							-- 3 UByte, 1 Char
							net.WriteEntity(w)
							net.WriteEntity(w.entTower1)
							net.WriteEntity(w.entTower2)
							net.WriteUInt(#w.OptimizedPositions,8)
							for i = 1, #w.OptimizedPositions do
								net.WriteVector( w.OptimizedPositions[ i ] )
							end
						net.Send( pl )
					end
					
					pl.loading.walls[ w ] = nil
					bload = true
					break
					
				end
				
				if( not bload ) then
					
					pl.loading.walls = nil
					net.Quick("load.units", pl)
					
				end
			
			elseif( pl.loading.units ) then
				
				local bload = false
				for u, _ in pairs( pl.loading.units ) do
					
					if( Unit:ValidUnit( u ) ) then
						
						BroadcastCommand( {pl}, "~_cl.unit.Spawn", u:GetEmpire():GetID(), u:UnitIndex(), u:GetClass() )
						
					end
					
					pl.loading.units[ u ] = nil
					bload = true
					break
					
				end
				
				if( not bload ) then
					
					pl.loading.units = nil
					net.Quick("load.territories", pl)
					
				end
				
			elseif( pl.loading.territories ) then
				
				local bload = false
				for t, _ in pairs( pl.loading.territories ) do
					
					gamemode.Call( "NetworkTerritory", t, pl )
					
					pl.loading.territories[ t ] = nil
					bload = true
					break
					
				end
				
				if( not bload ) then
					
					pl.loading.territories = nil
					
				end

			else
				
				net.Quick("loaded", pl)
				pl.loading = nil
				gamemode.Call( "NetworkTerritories", pl )
				
			end
			
		end
		
	end
	
end )

function BroadcastCommand( players, cmd, ... )
	local args = {...}
	
	players = players or player.GetAll()
	
	for _, a in pairs( args ) do
		cmd = cmd .. " " .. tostring( a )
	end
	
	for _, pl in pairs( players ) do
		if pl:IsValid() then
			pl:ConCommand( cmd )
		end
	end
	
end

function GM:PlayerLoadout( pl )
	pl:StripWeapons()
	
	pl:Give( "staff_command" )
	pl:SelectWeapon( "staff_command" )
end

util.AddNetworkString( "SendPing" )

function GM:PlayerSwitchFlashlight( pl, SwitchOn )
	if SwitchOn then
		local Trace = {}
		Trace.start = pl:GetShootPos()
		Trace.endpos = Trace.start + (pl:GetAimVector() * 4096)
		Trace.mask = MASK_SOLID_BRUSHONLY
		
		local tr = util.TraceLine(Trace)
		
		if(!tr.Hit or tr.HitSky or !tr.Entity) then
			return false
		end
		local angle = tr.HitNormal:Angle()
		net.Start("SendPing")
	        net.WriteEntity(pl)
	        net.WriteVector(tr.HitPos)
	        net.WriteAngle(angle)
	    net.Send(pl)
		if pl.Alliance then
			for k,v in pairs(pl.Alliance) do
				net.Start("SendPing")
			        net.WriteEntity(pl)
			        net.WriteVector(tr.HitPos)
			        net.WriteAngle(angle)
			    net.Send(v)
			end
		end
	end
	return false
end

function GM:DoPlayerDeath( pl, attacker, dmginfo )
	pl:StripWeapons()
	pl:CreateRagdoll()
	
	return true
end

function GM:PlayerDeathThink( pl )
	if ( pl.NextSpawnTime and pl.NextSpawnTime > CurTime() ) then return end
	
	pl:Spawn()
end

function GM:PlayerDeath( pl, inflictor, attacker )
	pl.NextSpawnTime = CurTime() + 2
end

function GM:PlayerSay( pl, txt, team )
	return txt
end

function GM:PlayerNoClip( pl )
	return pl == sass
end

function GM:PlayerCanSeePlayersChat( strText, bTeamOnly, receiver, sender )
	if bTeamOnly then
		if Allied(sender:GetEmpire(), receiver:GetEmpire()) then
			return true
		else
			return
		end
	end
	return true
end