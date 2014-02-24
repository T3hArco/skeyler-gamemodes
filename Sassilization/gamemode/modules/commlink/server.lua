-----------------
-- Sassilization
-----------------

require("hio")

CommLink = {}
CommLink.UpdateTime = 2
CommLink.IP = GetConVar("ip"):GetString()
CommLink.GameReady = false
CommLink.LobbyFile = false
CommLink.Dir = "C:\\servers\\commlink"
CommLink.File = CommLink.Dir.."\\"..CommLink.IP..".txt"
CommLink.Chat = {}
CommLink.MaxChat = 7

function CommLink:OnDBConnect()
	MsgN("CommLink:OnDBConnect")
	if( libsass.GateKeeper ) then
		libsass.GateKeeper:Lock()
		libsass.GateKeeper:Reset()
	end
	self:RetrieveServers()
	timer.Create("CommLink:Update", self.UpdateTime, 0, function() self:Update() end )
	timer.Create("CommLink:Monitor", self.UpdateTime, 0, function() self:Monitor() end)
end

function CommLink:PlayerSay(ply, Message)
	local Empire = ply:GetEmpire()
	if(Empire) then
		if(table.Count(self.Chat) >= self.MaxChat) then
			table.remove(self.Chat, 1)
		end
		table.insert(self.Chat, {Empire = Empire:Nick(), Message = Message, Time = os.time()})
	end
end

function CommLink:Update()
	if(!hIO.DirExists(self.Dir)) then
		return
	end
	
	local Data = tostring(os.time()).."\n"
	
	Data = Data..(self.GameReady and "1" or "0").."\n"
	
	for i=1,self.MaxChat do
		local Chat = self.Chat[i]
		if(Chat) then
			Data = Data..tostring(Chat.Time).."EMPIRECHATSPLIT"..Chat.Empire.."EMPIRECHATSPLIT"..Chat.Message.."\n"
		else
			Data = Data.." \n"
		end
	end
	
	for k,v in pairs(empire.GetAll()) do
		local r, g, b, a = v:GetColor()
		Data = Data..v:Nick().."EMPIRECHATSPLIT"..r.." "..g.." "..b.." "..v:GetCities().." "..math.Round(v:GetGold()).." "..math.Round(v:GetFood()).." "..math.Round(v:GetIron()).."\n"
	end
	
	hIO.Write(self.File, Data)
end

function CommLink:Monitor()
	if(!self.LobbyFile) then
		return
	end
	
	if(!hIO.FileExists(self.LobbyFile)) then
		return
	end
	
	local Read = hIO.Read(self.LobbyFile)
	
	for k,v in pairs(string.Explode("\n", Read)) do
		if(k > 1 and v != "") then
			local Explode = string.Explode("|", v)
			if(table.Count(Explode) == 2) then
				local IP = Explode[1]
				if(IP == CommLink.IP) then
					local Data = Explode[2]
					local Split = string.Explode(" ", Data)
					if(table.Count(Split) > 0) then
						MsgN("GameReady")
						
						for k2,v2 in pairs(Split) do
							libsass.GateKeeper:Allow(v2, true)
						end
						
						self.GameReady = true
						
						timer.Remove("CommLink:Monitor")
						
						libsass:KickBot()
					end
				end
			end
		end
	end
end

function CommLink:RetrieveServers()
	libsass:RetrieveServers(function(Servers)
		if(!Servers) then
			print("CommLink didn't find any servers\n")
			self:RetrieveServers()
		else
			for k,v in pairs(Servers) do
				if(v.description == "Lobby") then
					MsgN("CommLink Found Lobby", v.sip, v.sport)
					-- if(v.status == "open") then
					self.LobbyFile = self.Dir.."\\"..v.sip..".txt"
					
					-- else
						-- MsgN("\tLobby is down")
					-- end
					break
				end
			end
		end
	end)
end

hook.Add("OnDBConnect", "CommLink:OnDBConnect", function()
	CommLink:OnDBConnect()
end)

hook.Add("PlayerSay", "CommLink:PlayerSay", function(ply, Message)
	CommLink:PlayerSay(ply, Message)
end)
