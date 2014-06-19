----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------
local structID
function GM:SpawnUnit(Name, Pos, Ang, Empire, NoTable)
	local Unit = unit.Create(string.lower(Name))
	Unit:SetPos(Pos + Vector( 0, 0, Unit.Size * 0.5 ))
	Unit:SetAngles( Ang )
	Unit:SetDir( Ang:Forward() )
	Unit:SetControl( Empire )
	Unit:Spawn()
	-- unit.NW_Manager:RegisterUnit( Unit )
	if(not NoTable) then
		--TODO: Fix this mess
		table.insert(Empire:GetUnits(), Unit)
	end
	--This is for saving information to the database
	if string.lower(Name) == "swordsman" then
		structID = 1
	elseif string.lower(Name) == "archer" then
		structID = 2
	elseif string.lower(Name) == "scallywag" then
		structID = 3
	elseif string.lower(Name) == "catapult" then
		structID = 4
	elseif string.lower(Name) == "ballista" then
		structID = 5
	end

	if Empire.spawns[structID] != nil then
		Empire.spawns[structID] = Empire.spawns[structID] + 1
	else
		Empire.spawns[structID] = 1
	end

	return Unit
end

concommand.Add("sa_spawnunit", function(ply, cmd, args)
	if(ply.NextBuildUnit and ply.NextBuildUnit > CurTime()) then
		return
	end
	ply.NextBuildUnit = CurTime() + 0.05
	
	local Empire = ply:GetEmpire()
	if( not Empire ) then return end
	
	if( GAMEMODE:MaxEntLimitReached() ) then
		ply:ChatPrint( "Map has reached Max Entity Limit" )
		return
	end
	
	local Name = args[1]
	local x = tonumber(args[2])
	local y = tonumber(args[3])
	local z = tonumber(args[4])
	
	local Pitch = tonumber(args[5])
	local Yaw = tonumber(args[6])
	local Roll = tonumber(args[7])
	
	local obbsMins = Vector(args[8], args[9], args[10])
	local obbsMaxs = Vector(args[11], args[12], args[13])

	if(table.Count(args) ~= 13) then
		return
	end
	
	local unit = Unit:GetData(Name)
	if( not unit ) then
		return
	end
	
	if( not Unit:CanSpawn(Empire, Name) ) then
		return
	end
	
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + Vector(x, y, z) * 2048
	trace.filter = ply
	trace.mask = MASK_SHOT_HULL
	local tr = util.TraceLine( trace )
	
	if( not tr.HitWorld ) then
		return
	end
	
	local CanFit, Pos, Ang = GAMEMODE:CanFit(tr, obbsMins, obbsMaxs, Angle(Pitch, Yaw, Roll), true, true)
	
	if(not CanFit) then
		return
	end
	
	if( not GAMEMODE:IsPosInTerritory( Pos, ply:GetEmpire():GetID() ) ) then
		return
	end
	
	Empire:AddFood(-unit.Food or 0)
	Empire:AddIron(-unit.Iron or 0) 
	Empire:AddGold(-unit.Gold or 0)
	GAMEMODE:SpawnUnit(Name, Pos, Ang, Empire)
end)
