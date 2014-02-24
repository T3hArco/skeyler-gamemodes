----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

select_limit = 10		--how many armies can be selected at once. NOTICE: too many causes crashes.
unit_limit = select_limit * 3.5
ally_limit = 2			-- for Infinite Allies, use -1. 1 would allow two people to be grouped. 0 would mean no allies.

iron_tick = 1			--how much iron is gained each tick from each node
food_tick = 1.2			--how much food is gained each tick from each node
iron_income = 8
food_income = 8
supply_income = 1

resource_tick = 10		--delay in seconds between resource collection
minimap_tick = 20
scoreboard_tick = 12

gate_maxvary = 8		-- How jagged a wall can be to allow a gate on it.

allow_setup = false		--If true, always allows players to create their resources when they start the game.

MISCSOUNDS = {
	"sassilization/buildascend.wav",
	"sassilization/units/unitLost.wav",
	"sassilization/units/sacrificed.wav",
	"sassilization/templeComplete.wav",
	"sassilization/workshopComplete.wav",
	"sassilization/buildsound01.wav",
	"sassilization/buildsound02.wav",
	"sassilization/select.wav",
	"sassilization/warnmessage.wav",
	"sassilization/buildsound03.wav"
}

Titles = {
	{"Mighty", "Mighties"},
	{"Dominator", "Dominators"},
	{"Bloody", "Blood Bringers"},
	{"Butcher", "Butchers"},
	{"Conqueror", "Conquerors"},
	{"Destroyer", "Destroyers"},
	{"Undefeatable", "Undefeatables"},
	{"Overlord", "Overlords"},
	{"Ghoulmaker", "Ghoulmakers"},
	{"Nightbringer", "Nightbringers"},
	{"Deathbringer", "Deathbringers"},
	{"Ultimate", "Unstoppables"},
	{"Fearless", "Fearless Emperors"}
}

Description = {
	{"false gods who tried to take his rightful place as ruler of the world.", "false gods who tried to take their rightful place as rulers of the world."},
	{"factions of the previous broken kingdom who failed to unite the land under one god.", "factions of the previous broken kingdom who tried to unite the land under one god."},
	{"heretic kingdoms that challenged his divine right to rule the world.", "heretic kingdoms that challenged their divine right as rulers of the world."},
	{"false gods.", "false gods."},
	{"pagan gods who attempted to unite the land under the one true god.", "pagan gods who attempted to unite the land under the one true god."},
	{"godless kingdoms that dared to deny his divinity.", "godless kingdoms that dared to deny their divinity."},
	{"savage gods that attempted to destroy the last refuge of civilization.", "savage gods that attempted to destroy the last refuge of civilization."}
}


GIB_STONE = 1001
GIB_ALL = 1002
GIB_WOOD = 1003

MB_LEFT = 107
MB_RIGHT = 108
MB_MIDDLE = 109