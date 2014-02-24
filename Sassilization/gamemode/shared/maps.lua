----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

MAPS = {}
MAPS.List = {
	"sa_orbit",
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
}

--for _, map in pairs( MAPS.List ) do
	
	--resource.AddFile("maps/"..map..".bsp")
	
--end

function MAPS.GetNextMap()
	local PLAYERS = #player.GetAll()
	local CURRENTMAP = game.GetMap()
	local NEXTMAP = MAPS.List[1]
	local num = 0
	for i=1, #MAPS.List do
		if CURRENTMAP == MAPS.List[i] then
			NEXTMAP = MAPS.List[i+1]
			num = i+1
			if num > #MAPS.List then
				NEXTMAP = MAPS.List[1]
				num = 1
			end
			break
		end
	end
	return NEXTMAP
end