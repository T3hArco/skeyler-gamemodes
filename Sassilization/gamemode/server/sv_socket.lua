local os = os
local Msg = Msg
local math = math
local file = file
local print = print
local unpack = unpack
local string = string
local require = require
local tonumber = tonumber
local tostring = tostring
local PrintTable = PrintTable
local ErrorNoHalt = ErrorNoHalt
local GetConVarNumber = GetConVarNumber
local GetConVarString = GetConVarString

require("glsock2")

if (!GLSock) then Msg("FAILED TO LOAD GLSOCK!\n") return end

Msg("LOADED GLSOCK!\n")

local GLSock = GLSock
local GLSockBuffer = GLSockBuffer

local GLSOCK_ERROR_SUCCESS = GLSOCK_ERROR_SUCCESS
local GLSOCK_ERROR_ACCESSDENIED = GLSOCK_ERROR_ACCESSDENIED
local GLSOCK_ERROR_ADDRESSFAMILYNOTSUPPORTED = GLSOCK_ERROR_ADDRESSFAMILYNOTSUPPORTED
local GLSOCK_ERROR_ADDRESSINUSE = GLSOCK_ERROR_ADDRESSINUSE
local GLSOCK_ERROR_ALREADYCONNECTED = GLSOCK_ERROR_ALREADYCONNECTED
local GLSOCK_ERROR_ALREADYSTARTED = GLSOCK_ERROR_ALREADYSTARTED
local GLSOCK_ERROR_BROKENPIPE = GLSOCK_ERROR_BROKENPIPE
local GLSOCK_ERROR_CONNECTIONABORTED = GLSOCK_ERROR_CONNECTIONABORTED
local GLSOCK_ERROR_CONNECTIONREFUSED = GLSOCK_ERROR_CONNECTIONREFUSED
local GLSOCK_ERROR_CONNECTIONRESET = GLSOCK_ERROR_CONNECTIONRESET
local GLSOCK_ERROR_BADDESCRIPTOR = GLSOCK_ERROR_BADDESCRIPTOR
local GLSOCK_ERROR_BADADDRESS = GLSOCK_ERROR_BADADDRESS
local GLSOCK_ERROR_HOSTUNREACHABLE = GLSOCK_ERROR_HOSTUNREACHABLE
local GLSOCK_ERROR_INPROGRESS = GLSOCK_ERROR_INPROGRESS
local GLSOCK_ERROR_INTERRUPTED = GLSOCK_ERROR_INTERRUPTED
local GLSOCK_ERROR_INVALIDARGUMENT = GLSOCK_ERROR_INVALIDARGUMENT
local GLSOCK_ERROR_MESSAGESIZE = GLSOCK_ERROR_MESSAGESIZE
local GLSOCK_ERROR_NAMETOOLONG = GLSOCK_ERROR_NAMETOOLONG
local GLSOCK_ERROR_NETWORKDOWN = GLSOCK_ERROR_NETWORKDOWN
local GLSOCK_ERROR_NETWORKRESET = GLSOCK_ERROR_NETWORKRESET
local GLSOCK_ERROR_NETWORKUNREACHABLE = GLSOCK_ERROR_NETWORKUNREACHABLE
local GLSOCK_ERROR_NODESCRIPTORS = GLSOCK_ERROR_NODESCRIPTORS
local GLSOCK_ERROR_NOBUFFERSPACE = GLSOCK_ERROR_NOBUFFERSPACE
local GLSOCK_ERROR_NOMEMORY = GLSOCK_ERROR_NOMEMORY
local GLSOCK_ERROR_NOPERMISSION = GLSOCK_ERROR_NOPERMISSION
local GLSOCK_ERROR_NOPROTOCOLOPTION = GLSOCK_ERROR_NOPROTOCOLOPTION
local GLSOCK_ERROR_NOTCONNECTED = GLSOCK_ERROR_NOTCONNECTED
local GLSOCK_ERROR_NOTSOCKET = GLSOCK_ERROR_NOTSOCKET
local GLSOCK_ERROR_OPERATIONABORTED = GLSOCK_ERROR_OPERATIONABORTED
local GLSOCK_ERROR_OPERATIONNOTSUPPORTED = GLSOCK_ERROR_OPERATIONNOTSUPPORTED
local GLSOCK_ERROR_SHUTDOWN = GLSOCK_ERROR_SHUTDOWN
local GLSOCK_ERROR_TIMEDOUT = GLSOCK_ERROR_TIMEDOUT
local GLSOCK_ERROR_TRYAGAIN = GLSOCK_ERROR_TRYAGAIN
local GLSOCK_ERROR_WOULDBLOCK = GLSOCK_ERROR_WOULDBLOCK

local GLSOCKBUFFER_SEEK_SET = GLSOCKBUFFER_SEEK_SET
local GLSOCKBUFFER_SEEK_CUR = GLSOCKBUFFER_SEEK_CUR
local GLSOCKBUFFER_SEEK_END = GLSOCKBUFFER_SEEK_END

local GLSOCK_TYPE_ACCEPTOR = GLSOCK_TYPE_ACCEPTOR
local GLSOCK_TYPE_TCP = GLSOCK_TYPE_TCP
local GLSOCK_TYPE_UDP = GLSOCK_TYPE_UDP

module("socket")

local socketData = {
	host = {}, -- This server.
	clients = {}, -- Holds all the servers that are connected to this one.
	commands = {}, -- Available commands that clients can run.
	allowedClients = {} -- This holds the ips that are allowed to connect.
}

local socketErrors = {
	[GLSOCK_ERROR_SUCCESS] = "GLSOCK_ERROR_SUCCESS",
	[GLSOCK_ERROR_ACCESSDENIED] = "GLSOCK_ERROR_ACCESSDENIED",
	[GLSOCK_ERROR_ADDRESSFAMILYNOTSUPPORTED] = "GLSOCK_ERROR_ADDRESSFAMILYNOTSUPPORTED",
	[GLSOCK_ERROR_ADDRESSINUSE] = "GLSOCK_ERROR_ADDRESSINUSE",
	[GLSOCK_ERROR_ALREADYCONNECTED] = "GLSOCK_ERROR_ALREADYCONNECTED",
	[GLSOCK_ERROR_ALREADYSTARTED] = "GLSOCK_ERROR_ALREADYSTARTED",
	[GLSOCK_ERROR_BROKENPIPE] = "GLSOCK_ERROR_BROKENPIPE",
	[GLSOCK_ERROR_CONNECTIONABORTED] = "GLSOCK_ERROR_CONNECTIONABORTED",
	[GLSOCK_ERROR_CONNECTIONREFUSED] = "GLSOCK_ERROR_CONNECTIONREFUSED",
	[GLSOCK_ERROR_CONNECTIONRESET] = "GLSOCK_ERROR_CONNECTIONRESET",
	[GLSOCK_ERROR_BADDESCRIPTOR] = "GLSOCK_ERROR_BADDESCRIPTOR",
	[GLSOCK_ERROR_BADADDRESS] = "GLSOCK_ERROR_BADADDRESS",
	[GLSOCK_ERROR_HOSTUNREACHABLE] = "GLSOCK_ERROR_HOSTUNREACHABLE",
	[GLSOCK_ERROR_INPROGRESS] = "GLSOCK_ERROR_INPROGRESS",
	[GLSOCK_ERROR_INTERRUPTED] = "GLSOCK_ERROR_INTERRUPTED",
	[GLSOCK_ERROR_INVALIDARGUMENT] = "GLSOCK_ERROR_INVALIDARGUMENT",
	[GLSOCK_ERROR_MESSAGESIZE] = "GLSOCK_ERROR_MESSAGESIZE",
	[GLSOCK_ERROR_NAMETOOLONG] = "GLSOCK_ERROR_NAMETOOLONG",
	[GLSOCK_ERROR_NETWORKDOWN] = "GLSOCK_ERROR_NETWORKDOWN",
	[GLSOCK_ERROR_NETWORKRESET] = "GLSOCK_ERROR_NETWORKRESET",
	[GLSOCK_ERROR_NETWORKUNREACHABLE] = "GLSOCK_ERROR_NETWORKUNREACHABLE",
	[GLSOCK_ERROR_NODESCRIPTORS] = "GLSOCK_ERROR_NODESCRIPTORS",
	[GLSOCK_ERROR_NOBUFFERSPACE] = "GLSOCK_ERROR_NOBUFFERSPACE",
	[GLSOCK_ERROR_NOMEMORY] = "GLSOCK_ERROR_NOMEMORY",
	[GLSOCK_ERROR_NOPERMISSION] = "GLSOCK_ERROR_NOPERMISSION",
	[GLSOCK_ERROR_NOPROTOCOLOPTION] = "GLSOCK_ERROR_NOPROTOCOLOPTION",
	[GLSOCK_ERROR_NOTCONNECTED] = "GLSOCK_ERROR_NOTCONNECTED",
	[GLSOCK_ERROR_NOTSOCKET] = "GLSOCK_ERROR_NOTSOCKET",
	[GLSOCK_ERROR_OPERATIONABORTED] = "GLSOCK_ERROR_OPERATIONABORTED",
	[GLSOCK_ERROR_OPERATIONNOTSUPPORTED] = "GLSOCK_ERROR_OPERATIONNOTSUPPORTED",
	[GLSOCK_ERROR_SHUTDOWN] = "GLSOCK_ERROR_SHUTDOWN",
	[GLSOCK_ERROR_TIMEDOUT] = "GLSOCK_ERROR_TIMEDOUT",
	[GLSOCK_ERROR_TRYAGAIN] = "GLSOCK_ERROR_TRYAGAIN",
	[GLSOCK_ERROR_WOULDBLOCK] = "GLSOCK_ERROR_WOULDBLOCK"
}

function Log(text)
	text = "[SOCKET] [" .. os.date() .. "] " .. tostring(text)
	
	Msg(text .. "\n")
	
	local oldLog = file.Read("socket_log.txt") or ""
	
	file.Write("socket_log.txt", oldLog .. text .. "\n")
end

local function HandleSocketSending(sock, bytes, errorCode)
	if (errorCode != GLSOCK_ERROR_SUCCESS) then
		Log("!! ERROR SENDING DATA: " .. socketErrors[errorCode] .. " !!")
	else
		Log("Sending Data " .. bytes .. " bytes.")
	end
end

local function HandleSocketData(sock, ip, port, buffer, errorCode)
	if (errorCode == GLSOCK_ERROR_SUCCESS) then
		Log("HandleSocketData Parsing " .. tonumber(buffer:Size()) .. " bytes. IP: " .. tostring(ip) .. " PORT: " .. port)
		
		local _, command = buffer:ReadString()
		
		if (command) then
			if (command == "connect") then
				if (socketData.allowedClients[ip]) then
					Log("GOT CLIENT: " .. tostring(ip) .. " PORT: " .. port)
					
					socketData.clients[ip] = {}
				else
					sock:Cancel()
					
					Log("UNKNOWN CLIENT TRIED TO CONNECT: " .. tostring(ip) .. " PORT: " .. port)
				end
			else
				if (socketData.commands[command]) then
					if (socketData.clients[ip] != nil) then
						socketData.commands[command](sock, ip, port, buffer, errorCode)
						
						Log("CLIENT '" .. ip .. "' RAN COMMAND '" .. command)
					else
						sock:Cancel()
						
						Log("UNKNOWN CLIENT TRIED TO RUN COMMAND: " .. command .. " IP: " .. tostring(ip) .. " PORT: " .. port)
					end
				end
			end
		end
		
		-- Make it keep reading packets.
		sock:ReadFrom(1500, HandleSocketData)
	else
		Log("HandleSocketData ERROR: " .. socketErrors[errorCode] .. " !!")
	end
end

local function HandleSocketBind(sock, errorCode)
	if (errorCode != GLSOCK_ERROR_SUCCESS) then
		Log("!! CANNOT BIND SOCKET: " .. socketErrors[errorCode] .. " !!")
	else
		Log("BOUND SOCKET")
		
		-- Begin waiting for packets.
		socketData.host.sock:ReadFrom(1500, HandleSocketData)
	end
end

-- FORCE THE FUCKER
function SetListenPackets()
	socketData.host.sock:ReadFrom(1500, HandleSocketData)
end

function GetHostIP()
	return socketData.host.ip
end

function GetClients()
	return socketData.clients
end

function Connect(ip, port, password)
	socketData.host.sock:ReadFrom(1500, HandleSocketData)
	
	local buffer = GLSockBuffer()
		buffer:WriteString("connect")
	socketData.host.sock:SendTo(buffer, ip, port, HandleSocketSending)
end

function SetupHost(ip, port)
	local sock = GLSock(GLSOCK_TYPE_UDP)
	sock:Bind(ip, port, HandleSocketBind)
	
	socketData.host.ip = ip
	socketData.host.port = port
	socketData.host.sock = sock
end

function AddAllowedClient(ip)
	socketData.allowedClients[ip] = true
end

function GetAllowedClients()
	return socketData.allowedClients
end

function AddCommand(command, callback)
	socketData.commands[command] = callback
end

function Send(ip, port, command, callback)
	--if (socketData.commands[command]) then
		local buffer = GLSockBuffer()
		buffer:WriteString(command)
		
		if (callback) then
			callback(buffer)
		end
		
		socketData.host.sock:SendTo(buffer, ip, port, HandleSocketSending)
	--end
end

--[[ Automatic IP Locator ]]--
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