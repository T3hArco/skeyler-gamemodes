/*
function GM:CustomLoadGrab()
	
	local grab = {
		"GamesJoined"
	}
	return grab
	
end
*/

if( not libsass ) then
	//Error( "Sassilization Module required but not found\n" )
	return
end
util.AddNetworkString( "profile.NetworkContent" )
function libsass:NewGamemodeProfile( profile )
	
	if( not profile ) then return end
	
	profile.GamesJoined = 1
	profile.Items = {}
	/*
	net.Start( "profile.NetworkContent" )
		for id, item in pairs( shopitems ) do
			if( item.max > 1 ) then
				-- Char
				net.WriteByte( profile.Items[ id ] or 0 )
			else
				-- Bool
				net.WriteByte( profile.Items[ id ] )
			end
		end
	net.Send( profile:Pl() )
	*/
end

function libsass:LoadedProfileContent( profile, data )
	
	if( data.Items ) then
		
		if( data.Items == "" ) then
			
			data.Items = "[]"
			
		end
		
		local items = Json.Decode( data.Items )
		if( not items ) then
			
			RunConsoleCommand( "kickid", profile:Pl():UserID(), "Your sass data is corrupt, contact an owner." )
			player.CloseProfile( profile.SteamID )
			return
			
		else
			
			profile.Items = items
			
		end
		
	end
	
	profile:AddSave( "GamesJoined", (data.GamesJoined or 0) + 1, true )
	
	/*
	net.Start( "profile.NetworkContent" )
		for id, item in pairs( shopitems ) do
			if( item.max > 1 ) then
				-- Char
				net.WriteByte( profile.Items[ id ] or 0 )
			else
				-- Bool
				net.WriteByte( profile.Items[ id ] )
			end
		end
	net.Send( profile:Pl() )
	*/
end