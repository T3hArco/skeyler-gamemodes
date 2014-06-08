---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

-- Overwrite if you need different
function GM:CheckPassword( steamid, networkid, server_password, password, name )

	if PLAYER_META:IsBanned(util.SteamIDFrom64(steamid)) then
		return false, "You have been banned from this server. Check www.skeyler.com for more info" 	-- Placeholder
	end

	if ( server_password != "" ) then
		if ( server_password != password ) then
			return false, "#GameUI_ServerRejectBadPassword"
		end

	end
	return true
end

function GM:SetMaxVisiblePlayers(num) 
	RunConsoleCommand("sv_visiblemaxplayers", num) 
end 