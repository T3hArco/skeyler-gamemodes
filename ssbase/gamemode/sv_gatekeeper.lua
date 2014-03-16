---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

-- Overwrite if you need different
function GM:CheckPassword( steamid, networkid, server_password, password, name )

	-- Todo, check to see if user is banned.

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