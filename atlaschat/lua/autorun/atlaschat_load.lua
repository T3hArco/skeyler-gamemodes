--          _   _                  _           _   
--     /\  | | | |                | |         | |  
--    /  \ | |_| | __ _ ___    ___| |__   __ _| |_ 
--   / /\ \| __| |/ _` / __|  / __| '_ \ / _` | __|
--  / ____ \ |_| | (_| \__ \ | (__| | | | (_| | |_ 
-- /_/    \_\__|_|\__,_|___/  \___|_| |_|\__,_|\__|
--                                                 
--                                                 
-- © 2014 metromod.net do not share or re-distribute
-- without permission of its author (Chewgum - chewgumtj@gmail.com).
--

AddCSLuaFile()

if (SERVER) then
	AddCSLuaFile("atlaschat/cl_init.lua")
	
	include("atlaschat/init.lua")
else
	include("atlaschat/cl_init.lua")
end

if (atlaschat) then
	if (CLIENT) then
		MsgC(color_green, "Atlas chat v" .. atlaschat.version:GetString() .. " has loaded!\n")
	else
		MsgC(color_green, "Atlas chat has loaded!\n")
	end
else
	MsgC(color_red, "Atlas chat failed to load!\n")
end