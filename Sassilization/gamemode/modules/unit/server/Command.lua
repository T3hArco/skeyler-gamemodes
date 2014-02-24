----------------------------------------
--	Sassilization
--  Shared Unit Module
--	http://sassilization.com
--	By Spacetech & Sassafrass
----------------------------------------

assert( SA )
 
COMMAND = {}
COMMAND.MOVE = 1
COMMAND.ATTACKMOVE = 3
COMMAND.ATTACK = 4
COMMAND.SACRIFICE = 5

local cmdIncrement = 1

local CMDS = {}

function SA.CreateCommand( cmdtype, ... )
	
	assert( CMDS[ cmdtype ] )
	
	local Cmd = {__index = CMDS[ cmdtype ], __tostring = CMDS[ cmdtype ].__tostring}
	setmetatable(Cmd, Cmd)
	
	Cmd:Init( unpack( {...} ) )
	
	return Cmd
	
end

function SA.RegisterCommand( enum, metatbl )
	
	CMDS[ enum ] = metatbl
	
end

local function includeFolder( foldername )
	Msg("Loading "..foldername.." Files...\n")
	
	trace_include = false
	
	for k,v in pairs(file.Find(GM.FolderName.."/gamemode/modules/unit/server/"..foldername.."/*.lua", "LUA")) do
		Msg("\tLoading "..v..":")
		
		include(foldername.."/"..v)
		
		Msg("Loaded Successfully\n")
	end
	
	Msg("Loaded Successfully\n")
	
	trace_include = true
end

includeFolder( "commands" )
includeFolder = nil