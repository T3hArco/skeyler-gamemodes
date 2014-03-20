--[[---------------------------------------------------------
Name: Sassilization
Desc: A garrysmod RTS Gamemode
-----------------------------------------------------------]]

/*
if( not libsass ) then
	Error( "Sassilization Module required but not found\n" )
end
*/

resource.AddWorkshop("238759748")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

/*
-- Development // Chewgum
if (!game.IsDedicated()) then
	libsass:DBConnect("127.0.0.1", "root", "")
else
	libsass:DBConnect("10.5.5.1", "gmod_sass", "619FFF5EF14C8B067603EC925D295CF56D15403FFF1497A3F800FED804762F2F")
end
*/

function IncludeDirectory(directory)
	local files, directories = file.Find(directory, "LUA")
	for k,v in pairs(files) do
		if v != "client.lua" and v != "cl_init.lua" then
			local addDirect = string.gsub(directory, "*", v)
			local addDirect = string.gsub(addDirect, "Sassilization/gamemode/", "")
			print(addDirect)
			include(addDirect)
		end
	end
end

IncludeDirectory("Sassilization/gamemode/shared/*")
IncludeDirectory("Sassilization/gamemode/server/*")
IncludeDirectory("Sassilization/gamemode/modules/unit/*")
IncludeDirectory("Sassilization/gamemode/modules/unit/shared/*")
IncludeDirectory("Sassilization/gamemode/modules/unit/server/*")
IncludeDirectory("Sassilization/gamemode/modules/miracle/*")
IncludeDirectory("Sassilization/gamemode/modules/alliance/*")
include("modules/building/shared.lua")
include("modules/building/server.lua")
include("modules/empire/shared.lua")
include("modules/empire/server.lua")

util.AddNetworkString("territory.GhostCheck")