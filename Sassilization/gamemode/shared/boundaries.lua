----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

BOUNDARIES = {}

function GetMap()
	if CLIENT then
		return string.sub( Entity(0):GetModel(), 6, -5 )
	elseif SERVER then
		return game.GetMap()
	end
end

function ConfirmBoundary( pos )
	local boundary = BOUNDARIES[GetMap()]
	if not boundary then return true end
	if boundary.Mins then
		if pos.x < boundary.Mins.x then return end
		if pos.y < boundary.Mins.y then return end
		if pos.z < boundary.Mins.z then return end
	end
	if boundary.Maxs then
		if pos.x > boundary.Maxs.x then return end
		if pos.y > boundary.Maxs.y then return end
		if pos.z > boundary.Maxs.z then return end
	end
	return true
end

BOUNDARIES["sa_snowfrost"] = {
	Mins = Vector( -864, -864, -180 ),
	Maxs = Vector( 864, 864, 60 )
}
BOUNDARIES["sa_crossroads"] = {
	Maxs = Vector( 860, 496, 400 )
}
BOUNDARIES["sa_angelsarena"] = {
	Mins = Vector( -1372, -512, 62 ),
	Maxs = Vector( 0, 992, 98 )
}
BOUNDARIES["sa_olympia"] = {
	Mins = Vector( -1500, -1000, -1 ),
	Maxs = Vector( 300, 1500, 31 )
}