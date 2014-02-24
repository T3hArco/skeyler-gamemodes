--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

local DownVec = Vector(0, 0, 6)

local WallOffset = Vector(3, 3, 3)

function GM:CanFit(tr, OBBMins, OBBMaxs, Ang, CheckWalls, bFoundation)
	local Pos = tr.HitPos - (tr.HitNormal * OBBMins.z) + tr.HitNormal * 0.1
	
	if(tr.HitNormal:Dot(VECTOR_UP) < 0.7) then
		return false, Pos, Ang
	end
	
	if(not tr.Hit or tr.HitSky or tr.HitNoDraw) then
		return false, Pos, Ang
	end
	
	local contents = util.PointContents( Pos );
	if ( bit.band(contents, CONTENTS_TRANSLUCENT) == CONTENTS_TRANSLUCENT ) or ( bit.band(contents, CONTENTS_WATER) == CONTENTS_WATER ) then
		return false, Pos, Ang
	end
	
	local Trace = {}
	Trace.filter = player.GetAll()
	Trace.mask = MASK_SHOT_HULL
	local tr1
	
	local angForward = Ang:Forward()
	local angRight = Ang:Right()
	local angUp = Ang:Up()
	local pos1 = Pos + (angForward * OBBMins.x) + (angRight * OBBMins.y)
	local pos2 = Pos + (angForward * OBBMins.x) + (angRight * OBBMaxs.y)
	local pos3 = Pos + (angForward * OBBMaxs.x) + (angRight * OBBMins.y)
	local pos4 = Pos + (angForward * OBBMaxs.x) + (angRight * OBBMaxs.y)
	local heightVec = Vector( 0, 0, SA.FOUNDATION_HEIGHT )
	local maxz = -999999
	local minz = 1e100
	
	--Check foundations, is there ground in the four corners of the structure?
	for _, pos in pairs{	pos1,
							pos2,
							pos3,
							pos4 } do
							
		Trace.start = pos + VECTOR_UP * 30;
		Trace.endpos = pos - heightVec;
		tr1 = util.TraceLine( Trace );
		
		if(tr1.Fraction == 0) then
			return false, Pos, Ang
		end
		
		if(tr1.Hit) then
			maxz = math.max( maxz, tr1.HitPos.z )
			minz = math.min( minz, tr1.HitPos.z )
		end
		
	end
	
	local oldz = Pos.z
	if( bFoundation ) then
		Pos.z = maxz + 0.2
	else
		Pos.z = minz - 0.2
	end
	
	--Check for collision with other stuff (We do many traces because TraceHull is an AABB and we can't trace an OBB
	pos1 = Pos + (angForward * OBBMins.x) + (angRight * OBBMins.y)
	pos2 = Pos + (angForward * OBBMins.x) + (angRight * OBBMaxs.y)
	pos3 = Pos + (angForward * OBBMaxs.x) + (angRight * OBBMins.y)
	pos4 = Pos + (angForward * OBBMaxs.x) + (angRight * OBBMaxs.y)
	
	for _, pos in pairs{	{pos1, pos3}, --diag
							{pos2, pos4}, --diag
							{pos1, pos2}, --side
							{pos2, pos3}, --side
							{pos3, pos4}, --side
							{pos4, pos1}, --side
							{pos1, pos3 + (angUp * OBBMaxs.z)}, --diag up
							{pos2, pos4 + (angUp * OBBMaxs.z)}, --diag up
							{pos1 + (angUp * OBBMaxs.z), pos3 + (angUp * OBBMaxs.z)},
							{pos2 + (angUp * OBBMaxs.z), pos4 + (angUp * OBBMaxs.z)} } do
							
		Trace.start = pos[1];
		Trace.endpos = pos[2];
		Trace.filter = player.GetAll()
		Trace.mask = MASK_SHOT_HULL
		tr1 = util.TraceLine( Trace );
		
		if(tr1.Hit) then
			--Pos.z = oldz
			if( not tr1.HitWorld or bFoundation ) then
				return false, Pos, Ang
			end
		end
		
	end
	
	for _, pos in pairs( {	Pos + (Ang:Forward() * OBBMins.x) + (Ang:Right() * OBBMins.y),
							Pos + (Ang:Forward() * OBBMins.x) + (Ang:Right() * OBBMaxs.y),
							Pos + (Ang:Forward() * OBBMaxs.x) + (Ang:Right() * OBBMins.y),
							Pos + (Ang:Forward() * OBBMaxs.x) + (Ang:Right() * OBBMaxs.y) } ) do
		
		Trace.start = pos
		Trace.endpos = Trace.start - heightVec
		Trace.filter = player.GetAll()
		Trace.mask = MASK_SHOT_HULL
		tr1 = util.TraceLine(Trace)
		
		contents = util.PointContents( tr.HitPos );
		if( bit.band(contents, CONTENTS_TRANSLUCENT) == CONTENTS_TRANSLUCENT ) or ( bit.band(contents, CONTENTS_WATER) == CONTENTS_WATER ) then
			Pos.z = oldz
			return false, Pos, Ang
		end
		
		if(tr1.Fraction == 1) then
			Pos.z = oldz
			if CheckWalls != "wall" then
				return false, Pos, Ang
			end
		end
	
	end
	
	if(CheckWalls) then
		OBBMins = OBBMins - WallOffset
		OBBMaxs = OBBMaxs + WallOffset
		for _, ent in ipairs( ents.FindInSphere(Pos, SA.MIN_WALL_DISTANCE * OBBMins:Distance(OBBMaxs)) ) do
			if(ent:IsWall() and ent.Walls) then
				for _, segment in pairs(ent.Walls) do
					if(segment) then
						local segPos = segment:GetPos() - Pos
						if(segPos.x >= OBBMins.x and segPos.y >= OBBMins.y and segPos.x <= OBBMaxs.x and segPos.y <= OBBMaxs.y) then
							return false, Pos, Ang
						end
					end
				end
			end
		end
	end
	
	return true, Pos, Ang
end
