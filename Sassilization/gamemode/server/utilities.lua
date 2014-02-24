function gmod.BroadcastLua(lua)
	for _, pl in pairs(player.GetAll()) do
		pl:SendLua(lua)
	end
end

function net.Quick( msg, rf )
	
	net.Start( msg )
	if( not rf ) then
		net.Broadcast()
	else
		net.Send( rf )
	end
	
end

function GM:PosInWater(Pos)
	return bit.band(util.PointContents(Pos), CONTENTS_WATER) == CONTENTS_WATER
end

function GM:MaxEntLimitReached()
	return #ents.GetAll() >= SA.MAX_ENTITIES
end