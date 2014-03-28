---------------------------- 
--        Deathrun        -- 
-- Created by Skeyler.com -- 
---------------------------- 

GM.AllowedList = {} 
GM.AllowedList["STEAM_0:0:25464234"]=true -- Aaron
GM.AllowedList["STEAM_0:1:19940367"]=true -- Ntag
GM.AllowedList["STEAM_0:1:9346397"]=true -- Snoipa 
GM.AllowedList["STEAM_0:0:43691646"]=true -- knoxed
GM.AllowedList["STEAM_0:1:20059628"]=true -- George
GM.AllowedList["STEAM_0:0:17219175"]=true -- Knoxed main
GM.AllowedList["STEAM_0:0:8398971"]=true -- Giggles
GM.AllowedList["STEAM_0:0:14340930"]=true -- Arcky
GM.AllowedList["STEAM_0:0:13707575"]=true -- Stebbzor
GM.AllowedList["STEAM_0:1:22006069"]=true -- Arco
GM.AllowedList["STEAM_0:1:14671056"]=true -- Hateful
GM.AllowedList["STEAM_0:0:8232794"]=true -- Chewgum


function GM:CheckPassword(steam, IP, sv_pass, cl_pass, name) 
	steam = util.SteamIDFrom64(steam) 

	--[[if self.AllowedList[steam] then 
		return true 
	else 
		MsgN(name.."<"..steam..">("..IP..") tried to join the server.") 
		return false, "Skeyler Deathrun is currently in Development, please try another day." 
	end ]]
	return true
end 