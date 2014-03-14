----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

MAPS = {}
MAPS.List = {
	"sa_orbit"
}

/*
	Maps currently removed until we get their minimaps working properly.
	"sa_bridges",
	"sa_olympia",
	"sa_surf_remnants",
	"sa_spoonage",
	"sa_losttemple",
	"sa_castlebase",
	"sa_arabia_2",
	"sa_valley",
	"sa_field",
	"sa_highland",
	"sa_arcticsummit",
	"sa_exodus"
*/

--for _, map in pairs( MAPS.List ) do
	
	--resource.AddFile("maps/"..map..".bsp")
	
--end

function MAPS.GetNextMap()
	local CURRENTMAP = game.GetMap()
	local NEXTMAP = MAPS.List[math.random(1, table.Count(MAPS.List))]
	/*
	while NEXTMAP == CURRENTMAP do
		NEXTMAP = MAPS.List[math.random(1, table.Count(MAPS.List))]
	end
	*/
	return NEXTMAP
end