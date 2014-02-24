local function GeneratePassword()
	
	local str = ""
	
	while string.len(str) < 6 do
		
		local int = math.random(97,122)
		local stradd = string.char(int)
		str = str .. stradd
		
	end
	
	str = "~_~"..str
	
	GAMEMODE.password = str
	
	return str
	
end

function ResetPassword()
	
	local pass = GeneratePassword()
	
	MsgN("Changing the server's Password to: "..pass)
	
	RunConsoleCommand("sv_password",pass)
	
	libsass.mysqlDatabase:Query("UPDATE "..DB_SERVER_TABLE.." SET password=\'"..pass.."\' WHERE ip=\'"..HOSTIP.."\' AND port=\'"..HOSTPORT.."\'" )
	
end

function ResetServerStatus()
	
	for _, pl in pairs( player.GetAll() ) do
		
		pl:ConCommand("connect "..LOBBYIP.. ":"..LOBBYPORT)
		
	end
	
	ResetPassword()
	libsass.mysqlDatabase:Query("UPDATE "..DB_SERVER_TABLE.." SET status=\'ready\' WHERE ip=\'"..HOSTIP.."\' AND port=\'"..HOSTPORT.."\'" )
	tcpSend( LOBBYIP, DATAPORT, tostring("UPDATESTATUS:"..Json.Encode({SERVERID,"ready",game.GetMap()}).."\n") )
	
end

--[[ THIS IS VERY OLD CODE
function GM:UpdateScoreboard()
	
	if game.SinglePlayer() then return end
	if not START or ENDROUND then return end
	if not SERVERID then return end
	
	local players = player.GetAll()
	table.sort(players, function( a, b ) return math.Round(a:GetNWInt("_gold")) > math.Round(b:GetNWInt("_gold")) end)
	
	--Send the scoreboard information to the lobby
	local info = 'LEADERBOARD:'..SERVERID..'|SCORES = {'
	for _, pl in pairs(players) do
		if IsValid(pl) and pl:IsPlayer() and pl.MyColor then
			info = info..'{'
			info = info..'n="'..tmysql.escape(string.gsub( pl:GetName(), "|", "" ))..'",'
			info = info..'c={r='..pl.MyColor[1].r..',g='..pl.MyColor[1].g..',b='..pl.MyColor[1].b..'},'
			info = info..'g='..math.Round(pl:GetNWInt("_gold"))..','
			info = info..'f='..math.Round(pl:GetNWInt("_food"))..','
			info = info..'i='..math.Round(pl:GetNWInt("_iron"))..','
			info = info..'ci='..math.Round(pl:GetNWInt("_cities"))..','
			info = info..'cr='..math.Round(pl:GetNWInt("_spirits"))..','
			info = info..'s='..math.Round(pl:GetNWInt("_shrines"))..','
			info = info..'fa='..math.Round(pl:GetNWInt("_farms"))..','
			info = info..'mi='..math.Round(pl:GetNWInt("_mines"))..','
			info = info..'u='..pl:GetNWInt("_soldiers")
			if _ == #players then info = info..'}' else info = info..'},' end
		end
	end
	info = info..'}'
	tcpSend(LOBBYIP,DATAPORT,info.."\n","Scoreboard Updated")
	
end

function GM:UpdateMinimapBuildings()
	
	if game.SinglePlayer() then return end
	if not START or ENDROUND then return end
	if not SERVERID then return end
	
	if not MINIMAPS then return end
	if MINIMAPS[game.GetMap()] then
		local map = MINIMAPS[game.GetMap()]
		local info = 'MINIMAP:'..SERVERID..'|bldg|DATA = {'
		local bldgs = ents.FindByClass("bldg_*")
		for _, ent in pairs(bldgs) do
			local r,g,b,a = ent:GetColor()
			ent.lastAttacked = ent.lastAttacked == 1 and 1 or 0
			info = info..'{'
			info = info..'i='..ent:EntIndex()..','
			info = info..'s="'..math.ceil(ent:OBBMaxs().x*map.Scale)..'",'
			info = info..'c={r='..r..',g='..g..',b='..b..',a='..a..'},'
			info = info..'a='..ent.lastAttacked..','
			info = info..'x='..math.Round((ent:GetPos().x-map.Origin.x)*map.Scale)..','
			info = info..'y='..math.Round((map.Origin.y-ent:GetPos().y)*map.Scale)
			if _ == #bldgs then info = info..'}' else info = info..'},' end
			ent.lastAttacked = 0
		end
		info = info..'}'
		tcpSend(LOBBYIP,DATAPORT,info.."\n","Minimap Buildings Updated")
	end
end

function GM:UpdateMinimapUnits()
	
	if game.SinglePlayer() then return end
	if not START or ENDROUND then return end
	if not SERVERID then return end
	
	if not MINIMAPS then return end
	if MINIMAPS[game.GetMap()] then
		local map = MINIMAPS[game.GetMap()]
		local info = 'MINIMAP:'..SERVERID..'|unit|DATA = {'
		local units = ents.FindByClass("unit_*")
		for _, ent in pairs(units) do
			if ent:GetEmpire() and ent:GetEmpire():GetPlayer():IsPlayer() then
				local r,g,b,a = ent:GetEmpire():GetColor()
				local pos = ent:GetPos()
				ent.lastAttacked = ent.lastAttacked == 1 and 1 or 0
				ent.lastPos = ent.lastPos or {x=pos.x,y=pos.y}
				info = info..'{'
				info = info..'i='..ent:EntIndex()..','
				info = info..'s="'..math.ceil(ent:OBBMaxs().x*map.Scale)..'",'
				info = info..'c={r='..r..',g='..g..',b='..b..',a='..a..'},'
				info = info..'a='..ent.lastAttacked..','
				info = info..'px='..math.Round((ent.lastPos.x-map.Origin.x)*map.Scale)..','
				info = info..'py='..math.Round((map.Origin.y-ent.lastPos.y)*map.Scale)..','
				info = info..'x='..math.Round((pos.x-map.Origin.x)*map.Scale)..','
				info = info..'y='..math.Round((map.Origin.y-pos.y)*map.Scale)
				if _ == #units then info = info..'}' else info = info..'},' end
				ent.lastAttacked = 0
				ent.lastPos = {x=pos.x,y=pos.y}
			end
		end
		info = info..'}'
		tcpSend(LOBBYIP,DATAPORT,info.."\n","Minimap Units Updated")
	end
end
]]