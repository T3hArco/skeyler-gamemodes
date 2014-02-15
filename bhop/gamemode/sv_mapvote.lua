util.AddNetworkString("ss_mapvote")
util.AddNetworkString("ss_rtv")

local findprefix = {
	"bhop_",
	"kz_"
}

timer.Create("MapChangeTimer",7200,1,function() --2 hour default
	if(!inrtv) then
		GAMEMODE:StartVote()
	end
end)

local nominations,maplist,eligible,votes,canextend,inrtv,extendtime,startjoinvote,rtvcount = {},{},{},{},true,false,3600,false,0

for k,v in pairs(file.Find("maps/*.bsp","GAME")) do
	for _,pr in pairs(findprefix) do
		if(string.sub(v,1,string.len(pr)) == pr) then
			local m = string.gsub(v,".bsp","")
			table.insert(eligible,string.lower(m))
		end
	end
end
table.sort(eligible)

local function FinishVote()
	inrtv = false
	local revote = false
	local highest = 0
	local winner = 0
	for k,v in pairs(votes) do
		if(v > highest) then
			winner = k
		end
	end
	for k,v in pairs(votes) do
		if(v == highest) then revote = true end
	end
	if(winner == 0) then
		ChatPrintAll("No one voted, starting a revote.")
		timer.Simple(5,function()
			if(#player.GetAll() == 0) then
				startjoinvote = true
				return
			end
			votes = {}
			net.Start("ss_rtv")
			net.WriteTable(maplist)
			net.Broadcast()
			for k,v in pairs(player.GetAll()) do
				v.curopt = nil
			end
			timer.Simple(30,function()
				FinishVote()
			end)
		end)
		return
	end
	if(revote) then
		ChatPrintAll("Two or more options had the highest number of votes, starting a revote.")
		timer.Simple(5,function()
			if(#player.GetAll() == 0) then
				startjoinvote = true
				return
			end
			votes = {}
			net.Start("ss_rtv")
			net.WriteTable(maplist)
			net.Broadcast()
			for k,v in pairs(player.GetAll()) do
				v.curopt = nil
			end
			timer.Simple(30,function()
				FinishVote()
			end)
		end)
		return
	end
	if(winner == 6 && canextend) then
		for k,v in pairs(player.GetAll()) do
			v.curopt = nil
		end
		maplist = {}
		votes = {}
		inrtv = false
		local mins = extendtime/60
		timer.Create("MapChangeTimer",extendtime,1,function()
			if(!inrtv) then
				GAMEMODE:StartVote()
			end
		end)
		if(extendtime == 900) then
			canextend = false
		end
		extendtime = extendtime/2
		ChatPrintAll("Extending the map for "..mins.." minutes!")
	else
		local win = maplist[winner]
		ChatPrintAll(win.." has won the vote! Changing map in 5 seconds.")
		timer.Simple(5,function()
			RunConsoleCommand("changelevel",win)
		end)
	end
end

function GM:StartVote()
	for k,v in pairs(player.GetAll()) do
		v.hasrtved = false
	end
	if(timer.Exists("MapChangeTimer")) then
		timer.Remove("MapChangeTimer")
	end
	if(#player.GetAll() == 0) then
		RunConsoleCommand("changelevel",table.Random(eligible))
	end
	local number = 0
	for k,v in RandomPairs(nominations) do
		if(number > 2) then break end
		table.insert(maplist,v)
		number = number + 1
	end
	for k,v in RandomPairs(eligible) do
		if(table.HasValue(maplist,v)) then continue end
		if(number > 4) then break end
		table.insert(maplist,v)
		number = number + 1
	end
	MsgN("Picked Vote Maps")
	for k,v in pairs(maplist) do
		MsgN(v)
	end
	net.Start("ss_rtv")
	net.WriteTable(maplist)
	net.WriteBit(canextend)
	net.Broadcast()
	inrtv = true
	timer.Simple(30,function()
		FinishVote()
	end)
end

net.Receive("ss_mapvote",function(l,ply)
	local max = 6
	if(!canextend) then
		max = 5
	end
	local n = net.ReadInt(4)
	if(n > max) then return end
	if(n < 1) then return end
	if(!inrtv) then return end
	if(!ply.cooldown || (ply.cooldown < CurTime())) then
		votes[n] = votes[n] or 0
		if(ply.curopt) then
			votes[ply.curopt] = votes[ply.curopt] - 1
		end
		votes[n] = votes[n] + 1
		ply.curopt = n
		ply.cooldown = CurTime() + 1
	end
end)

hook.Add("PlayerSay","MAPRTV_SS",function(ply,text,p)
	local t = string.lower(text)
	local t2 = string.sub(t,1,9)
	if(t == "!rtv"||t == "/rtv"||t == "rtv") then
		if(inrtv) then return "" end
		if(ply.hasrtved) then return "" end
		ply.hasrtved = true
		rtvcount = rtvcount + 1
		local need = math.ceil((#player.GetAll())*0.66)
		ChatPrintAll(ply:Nick().." has voted to Rock the Vote. ("..rtvcount.."/"..need.." votes)")
		if(rtvcount >= need) then
			GAMEMODE:StartVote()
		end
		return ""
	elseif(string.sub(t,1,8) == "nominate"||t2 == "!nominate"||t2 == "/nominate") then
		local t = string.Explode(" ",t)
		if(#t == 1) then
			ply:ChatPrint("Check your console for a list of maps you can nominate (ID or name)!")
			for k,v in pairs(eligible) do
				ply:PrintMessage(HUD_PRINTCONSOLE,k..": "..v)
			end
			return ""
		else
			table.remove(t,1)
			if(#t != 1) then
				ply:ChatPrint("Wrong number of arguments for !nominate.")
				return ""
			end
			if(type(tonumber(t[1])) != "number" && type(t[1]) != "string") then
				ply:ChatPrint("First argument should be an ID or a mapname.")
				return ""
			end
			if(eligible[tonumber(t[1])]) then
				if(table.HasValue(nominations,eligible[tonumber(t[1])])) then
					ply:ChatPrint(eligible[tonumber(t[1])].." has already been nominated.")
					return ""
				end
				nominations[ply:UniqueID()] = eligible[tonumber(t[1])]
				ChatPrintAll(ply:Nick().." has nominated "..eligible[tonumber(t[1])]..".")
			elseif(table.HasValue(eligible,t[1])) then
				if(table.HasValue(nominations,eligible[tonumber(t[1])])) then
					ply:ChatPrint(t[1].." has already been nominated.")
					return ""
				end
				nominations[ply:UniqueID()] = t[1]
				ChatPrintAll(ply:Nick().." has nominated "..t[1]..".")
			else
				ply:ChatPrint("Invalid mapname or ID: "..t[1]..".")
			end
			return ""
		end
	end
end)

hook.Add("PlayerDisconnected","CheckTheVotes",function(ply)
	local u = ply:UniqueID()
	if(ply.hasrtved) then
		rtvcount = rtvcount - 1
		timer.Simple(1,function() --wait till the bastards left
			local need = math.ceil((#player.GetAll())*0.66)
			if(rtvcount >= need) then
				GAMEMODE:StartVote()
			end
		end)
	end
	if(nominations[u]) then
		nominations[u] = nil
	end
end)

hook.Add("PlayerInitialSpawn","StartJoinVote",function(ply)
	if(startjoinvote) then
		startjoinvote = false
		inrtv = true
		timer.Simple(5,function()
			GAMEMODE:StartVote()
		end)
	end
end)