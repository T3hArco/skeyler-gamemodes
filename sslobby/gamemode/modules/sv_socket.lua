local os = os
local Msg = Msg
local hook = hook
local math = math
local type = type
local file = file
local timer = timer
local table = table
local print = print
local unpack = unpack
local string = string
local require = require
local CurTime = CurTime
local tonumber = tonumber
local tostring = tostring
local PrintTable = PrintTable
local ErrorNoHalt = ErrorNoHalt
local GetConVarNumber = GetConVarNumber
local GetConVarString = GetConVarString

local luasocket = require(system.IsLinux() and "luasocket" or system.IsWindows() and "socket.core")

if(!luasocket) then
        luasocket = luasocket_stuff.luaopen_socket_core()
end

module("socket")

local socketData = {
	host = {}, -- This server.
	commands = {}, -- Available commands that servers can run.
	servers = {} -- Holds all the servers that are connected to this one.
}

---------------------------------------------------------
--
---------------------------------------------------------

function Log(text)
	text = "[SOCKET] [" .. os.date() .. "] " .. tostring(text)
	
	Msg(text .. "\n")
	
	file.Append("socket_log.txt", text .. "\n")
end

---------------------------------------------------------
--
---------------------------------------------------------

local function HandleSocketData(sock, data, ip, port)
	Log("HandleSocketData Parsing data from: '" .. tostring(ip) .. ":" .. port .. "' Size: " .. data:len())

	local data = string.Explode("¨", data)
	local command = data[1]

	-- Remove the command.
	table.remove(data, 1)
	
	if (command and socketData.commands[command]) then
		if (socketData.servers[ip] != nil) then
			socketData.commands[command](sock, ip, port, data)
			
			Log("CLIENT '" .. ip .. ":" .. port .. "' RAN COMMAND '" .. command .. "'")
		else
			Log("UNKNOWN CLIENT TRIED TO RUN COMMAND: " .. command .. " IP: '" .. tostring(ip) .. " :" .. port .. "'")
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("Tick", "socket.Tick", function()
	if (socketData.host.read) then
		local data, ip, port = socketData.host.sock:receivefrom()
	
		if (data) then
			HandleSocketData(socketData.host.sock, data, ip, port)
		end
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

function SetListenPackets()
	socketData.host.read = true
end

---------------------------------------------------------
--
---------------------------------------------------------

function GetHostIP()
	return socketData.host.ip
end

---------------------------------------------------------
--
---------------------------------------------------------

function GetServers()
	return socketData.servers
end

---------------------------------------------------------
--
---------------------------------------------------------

function SetupHost(ip, port)
	local sock = socket.udp()
	local success, errorMessage = sock:setsockname(ip, port)
	
	if (success == 1) then
		sock:settimeout(0)
		
		socketData.host.ip = ip
		socketData.host.port = port
		socketData.host.sock = sock
		socketData.host.read = true
		
		Log("BOUND SOCKET")
	else
		Log("FAILED TO BIND SOCKET: " .. errorMessage)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function AddCommand(command, callback)
	socketData.commands[command] = callback
end

---------------------------------------------------------
--
---------------------------------------------------------

function Send(ip, port, command, callback)
	command = command .. "¨"
	
	if (callback) then command = callback(command) end

	socketData.host.sock:sendto(command, ip, port)
end

---------------------------------------------------------
-- Automatic IP Locator
---------------------------------------------------------

local serverport = GetConVarNumber("hostport");
local serverip;
do -- Thanks raBBish! http://www.facepunch.com/showpost.php?p=23402305&postcount=1382
    local function band( x, y )
        local z, i, j = 0, 1
        for j = 0,31 do
            if ( x%2 == 1 and y%2 == 1 ) then
                z = z + i
            end
            x = math.floor( x/2 )
            y = math.floor( y/2 )
            i = i * 2
        end
        return z
    end
    local hostip = tonumber(string.format("%u", GetConVarString("hostip")))
    local parts = {
        band( hostip / 2^24, 0xFF );
        band( hostip / 2^16, 0xFF );
        band( hostip / 2^8, 0xFF );
        band( hostip, 0xFF );
    }
    
    serverip = string.format( "%u.%u.%u.%u", unpack( parts ) )
end

function GetServerIP()
	return serverip
end

---------------------------------------------------------
--
---------------------------------------------------------

function GetServerPort()
	return GetConVarString("hostport")
end

---------------------------------------------------------
--
---------------------------------------------------------

function AddServer(ip, port)
	socketData.servers[ip] = {port = port, connected = CurTime() -65}

	Send(ip, port, "ping")

	timer.Create("socket.PingPong." .. ip, 60, 0, function()
		Send(ip, port, "ping")

		timer.Simple(5, function()
			local connected = math.Round(socketData.servers[ip].connected) >= math.Round(CurTime() -61)
			
			if (!connected) then
				Log("Lost connection with '" .. ip .. ":" .. port .. "'! Trying again in 60 seconds.")
			end
		end)
	end)
end

---------------------------------------------------------
--
---------------------------------------------------------

AddCommand("ping", function(sock, ip, port, data, errorCode)
	local server = socketData.servers[ip]

	if (server) then
		Send(ip, server.port, "pong")
	else
		Log("GOT UNKNOWN PING FROM '" .. ip .. ":" .. port .. "'")
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

AddCommand("pong", function(sock, ip, port, data, errorCode)
	local server = socketData.servers[ip]

	if (server) then
		local connected = math.Round(server.connected) >= math.Round(CurTime() -62)
	
		if (!connected) then
			Log("Established connection with server '" .. ip .. ":" .. port .. "'")
			
			hook.Run("SocketConnected", ip, port, data)
		end
		
		server.connected = CurTime()
	else
		Log("GOT UNKNOWN PONG FROM '" .. ip .. ":" .. port .. "'")
	end
end)