----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

-- GM.Name 	= "Sassilization"
GM.Author 	= "Sassafrass and Friends"
GM.Email 	= ""
GM.Website 	= ""

GM.Sassilization = true

SA = {}
SA.TEAM_JOINING = 0
SA.TEAM_PLAYERS = 2

team.SetUp(SA.TEAM_JOINING, "Initializing", Color(80, 80, 80, 255))
team.SetUp(SA.TEAM_PLAYERS, "Players", Color(220, 20, 20, 255))

GM.PlayerMeta = FindMetaTable("Player")
GM.EntityMeta = FindMetaTable("Entity")

/*

if( not getLoader ) then Error( "Couldn't get loader.\n" ) end
local loader = getLoader()

loader.Name = GM.FolderName
loader.Prefix = tostring(loader.Name).."/gamemode"
loader.ModulePrefix = "gamemode"
loader.ContentPrefix = "addons/sassilizationcontent"

*/

MsgN("\n######################################################################")
MsgN("# Sassilization by Sassafrass #")

if (SERVER and !game.SinglePlayer()) then
	MsgN("# Start: Sending Resources to Client")
	

--[[	function AddDirectoryDownload(directory)
		local files, directories = file.Find(directory, "GAME")
		for k,v in pairs(files) do
			local addDirect = string.gsub(directory, "*", v)
			resource.AddFile(addDirect)
		end
	end
]]
	function AddCSLuaDirectory(directory)
		local files, directories = file.Find(directory, "LUA")
		for k,v in pairs(files) do
			if v != "server.lua" and v != "init.lua" then
				local addDirect = string.gsub(directory, "*", v)
				local addDirect = string.gsub(addDirect, "Sassilization/gamemode/", "")
				print("	Sending " .. addDirect .. " to client.")
				AddCSLuaFile(addDirect)
			end
		end
	end

	--[[AddDirectoryDownload("sound/*")
	AddDirectoryDownload("sound/sassilization/*")
	AddDirectoryDownload("sound/sassilization/units/*")
	AddDirectoryDownload("sound/sassilization/spells/*")
	AddDirectoryDownload("resource/fonts/*")
	AddDirectoryDownload("models/sassilization/*")
	AddDirectoryDownload("models/sassilization/viewtools/*")
	AddDirectoryDownload("models/sassilization/mrgiggles/pvk/*")
	AddDirectoryDownload("models/mrgiggles/sassilization/*")
	AddDirectoryDownload("models/jaanus/*")
	AddDirectoryDownload("materials/sassilization/*")
	AddDirectoryDownload("materials/sassilization/icons/*")
	AddDirectoryDownload("materials/sassilization/shrinehud/*")
	AddDirectoryDownload("materials/sassilization/mrgiggles/pvk/*")
	AddDirectoryDownload("materials/sassilization/mrgiggles/farm/*")
	AddDirectoryDownload("materials/models/sassilization/*")
	AddDirectoryDownload("materials/models/mrgiggles/sassilization/*")
	AddDirectoryDownload("materials/jaanus/*")
	AddDirectoryDownload("materials/jaanus/build_sprites/*")
	AddDirectoryDownload("scripts/surfaceproperties/*")
	AddDirectoryDownload("scripts/sounds/*")
	AddDirectoryDownload("scripts/decals/*")
	AddDirectoryDownload("settings/render_targets/*")
]]
	AddCSLuaDirectory("Sassilization/gamemode/client/*")
	AddCSLuaDirectory("Sassilization/gamemode/client/gui/*")
	AddCSLuaDirectory("Sassilization/gamemode/shared/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/alliance/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/building/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/empire/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/miracle/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/shared/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/client/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/units/archer/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/units/ballista/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/units/base/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/units/catapult/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/units/peasant/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/units/scallywag/*")
	AddCSLuaDirectory("Sassilization/gamemode/modules/unit/units/swordsman/*")

	//loader:AddCSLuaDirectory("client/gui")
	
	MsgN("# End: Sending Resources to Client")
end

--if (not game.SinglePlayer()) then
	-- loader:PrecacheDirectory("sound/lounge")
	-- loader:PrecacheDirectory("models/jaanus/lounge")
--end


if( CLIENT ) then

	function IncludeDirectoryCS(directory)
		local files, directories = file.Find(directory, "LUA")
		for k,v in pairs(files) do
			if v != "server.lua" and v != "init.lua" then
				local addDirect = string.gsub(directory, "*", v)
				local addDirect = string.gsub(addDirect, "Sassilization/gamemode/", "")
				include(addDirect)
			end
		end
	end

	IncludeDirectoryCS("Sassilization/gamemode/shared/*")
	IncludeDirectoryCS("Sassilization/gamemode/client/gui/*")
	IncludeDirectoryCS("Sassilization/gamemode/client/*")
	IncludeDirectoryCS("Sassilization/gamemode/modules/miracle/*")
	IncludeDirectoryCS("Sassilization/gamemode/modules/alliance/*")
	include("modules/building/shared.lua")
	include("modules/building/client.lua")
	include("modules/empire/shared.lua")
	include("modules/empire/client.lua")
	IncludeDirectoryCS("Sassilization/gamemode/modules/unit/*")
	IncludeDirectoryCS("Sassilization/gamemode/modules/unit/shared/*")
	IncludeDirectoryCS("Sassilization/gamemode/modules/unit/client/*")

end

/*
loader:LoadFiles()

if( CLIENT ) then
	loader:LoadDirectory("client/gui")
end
*/

MsgN("######################################################################\n")

function GM:GetGameDescription()
	return "Sassilization"
end