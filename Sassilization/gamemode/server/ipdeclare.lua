ServerList = {}

function InitServerList()
	MsgN( "SERVERIP = ", GetConVar("ip"):GetString() )
	SERVERIP = GetConVar("ip"):GetString()
	libsass.mysqlDatabase:Query("SELECT * FROM "..DB_SERVER_TABLE,
	function( res, status, err )
		
		for k, v in pairs(res) do
			local server = {
				id = tonumber(v[1]),
				ip = v[4],
				port = v[5],
				chatport = v[6],
				name = v[8]
			}
				
			if (server.ip == SERVERIP) then
				SERVERID = server.id
				SERVERPORT = server.port
				CHATPORT = server.chatport
			end
			
			ServerList[server.id] = server
		end
		
		LOBBYIP = ServerList[1].ip
		LOBBYPORT = ServerList[1].port
		DATAPORT = "26780"
		
		ResetServerStatus()
		
	end )
end