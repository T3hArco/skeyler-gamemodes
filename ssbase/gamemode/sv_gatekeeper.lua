---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

GM.AllowedList = {} 
GM.AllowedList["STEAM_0:0:25464234"]=true -- Aaron
GM.AllowedList["STEAM_0:1:19940367"]=true -- Ntag
GM.AllowedList["STEAM_0:1:9346397"]=true -- Snoipa 
GM.AllowedList["STEAM_0:0:43691646"]=true -- knoxed

GM.AllowedList[""]=true


function GM:CheckPassword(steam, IP, sv_pass, cl_pass, name) 
	steam = util.SteamIDFrom64(steam) 

	if self.AllowedList[steam] then 
		return true 
	else 
		MsgN(name.."<"..steam..">("..IP..") tried to join the server.") 
		return false, "This ia a private server." 
	end 
end 

function GM:SetMaxVisiblePlayers(num) 
	RunConsoleCommand("sv_visiblemaxplayers", num) 
end 