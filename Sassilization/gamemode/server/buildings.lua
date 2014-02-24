--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

local HULL_BUILDER

hook.Add( "InitPostEntity", "Load_queryphys", function()
	HULL_BUILDER = ents.Create("prop_physics")
	HULL_BUILDER:SetSolid( SOLID_NONE )
	HULL_BUILDER:SetCollisionGroup( COLLISION_GROUP_NONE )
	HULL_BUILDER:SetMoveType( MOVETYPE_NONE )
	HULL_BUILDER:EnableCustomCollisions(false)
	
	local phys = HULL_BUILDER:GetPhysicsObject()
	
	if( phys:IsValid() ) then
		phys:EnableCollisions( false )
		phys:EnableMotion( false )
	end
end )

function SA.CreateConvexMeshBox( mins, maxs )
	HULL_BUILDER:PhysicsInitBox( mins, maxs )
	
	local phys = HULL_BUILDER:GetPhysicsObject()
	HULL_BUILDER:SetSolid( SOLID_NONE )
	HULL_BUILDER:SetCollisionGroup( COLLISION_GROUP_NONE )
	HULL_BUILDER:SetMoveType( MOVETYPE_NONE )
	
	if( phys:IsValid() ) then
		phys:EnableCollisions( false )
		phys:EnableMotion( false )
		
		return phys:GetMesh()
	end
end

function GM:SpawnBuilding(Name, Pos, Ang, Empire, NoTable)
	
	local Building = ents.Create("building_" .. Name)
	Building.dt.bBuilt = false
	
	Building:SetControl(Empire)
	Building:SetPos(Pos)
	Building:SetAngles(Ang)
	Building:Spawn()
	Building:Activate()
	
	Building.CachedType = Name
	
	return Building
end

function GM:SpawnWall( Empire, WallTower1, WallTower2, Positions )

	local Building = ents.Create("building_wall")
	Building:SetControl( Empire )
	Building:Spawn()
	Building:Activate()
	Building:SetTowers( WallTower1, WallTower2, Positions ) --Sets Position and Angle
	
	return Building
	
end

concommand.Add("sa_buildwall", function(ply, cmd, args)


	if(ply.NextBuildBuilding and ply.NextBuildBuilding > CurTime()) then
		return
	end
	ply.NextBuildBuilding = CurTime() + 0.1;
	
	local Empire = ply:GetEmpire()
	if( not Empire ) then return end
	
	if( GAMEMODE:MaxEntLimitReached() ) then
		ply:ChatPrint( "Map has reached Max Entity Limit" )
		return
	end

	if #args < 4 then 
		return
	end
	
	local Building = building.GetBuilding("walltower")
	if(not Building) then
		return
	end
	
	if(not building.CanBuild(Empire, "walltower")) then
		return
	end
	
	local aimVec = Vector( tonumber(args[1]), tonumber(args[2]), tonumber(args[3]) )
	local tower1 = Entity( args[4] )
	local tower2 = NULL
	if args[5] then
		tower2 = Entity( args[5] )
	end
	--MsgN("T1: ", tower1)
	--MsgN("T2: ", tower2)
	if( tower1 ~= NULL ) then
		if( not (IsValid( tower1 ) and tower1:IsWallTower() and tower1:GetEmpire() == Empire) ) then
			print( "Invalid tower1\n" )
			return
		end
	else
		return
	end
	
	if( tower2 ~= NULL ) then
		if( not (IsValid( tower2 ) and tower2:IsWallTower() and tower2:GetEmpire() == Empire) ) then
			print( "Invalid tower2\n" )
			return
		end
	else
		tower2 = nil
	end
	
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + aimVec * 2048;
	trace.filter = ply;
	trace.mask = MASK_SHOT_HULL
	local tr = util.TraceLine( trace );
	local Positions, Cost;
		
	if( tower1 and tower2 ) then
		
		local pos1 = tower1:GetPos()
		local pos2 = tower2:GetPos()
		local midpos = pos1:MidPoint(pos2)
		
		--Is it feasible that the player can create the wall at this position?
		if( tr.HitPos:Distance( (pos1 + pos2)*0.5 ) >= 10 ) then return end
		--Can this wall be built here?
		if( not ( GAMEMODE:NoInbetweenWall( tower1, tower2 ) and GAMEMODE:ValidWallAngle( tower1, midpos ) and GAMEMODE:ValidWallAngle( tower2, midpos ) ) ) then
			ply:ChatPrint( "Couldn't make wall here" )
			return
		end
		
		Positions, Cost = GAMEMODE:CalculateWallPositions( pos1, pos2, {tower1, tower2} )
		
		if( Positions ) then
			if( Empire:GetFood() >= Building.Food*Cost and
				Empire:GetIron() >= Building.Iron*Cost and
				Empire:GetGold() >= Building.Gold*Cost ) then
				
				Empire:AddFood(-Building.Food*Cost or 0)
				Empire:AddIron(-Building.Iron*Cost or 0)
				Empire:AddGold(-Building.Gold*Cost or 0)
				GAMEMODE:SpawnWall( Empire, tower1, tower2, Positions )
				ply:ChatPrint( "Successfully linked two Wall Towers." )
			end
		end
		
	elseif( tower1 ) then
		
		local CanFit, Pos, Ang = GAMEMODE:CanFit(tr, Building.OBBMins, Building.OBBMaxs, Angle(0, 0, 0), false, false)
		
		if( not GAMEMODE:IsPosInTerritory( Pos, ply:GetEmpire():GetID() ) ) then
			return
		end

		if( Pos:Distance( tower1:GetPos() ) < 10 ) then
			ply:ChatPrint( "Wall too close to another" )
			return
		end
		
		if( not ( GAMEMODE:ValidWallAngle( tower1, Pos ) ) ) then
			ply:ChatPrint( "Couldn't make wall here" )
			return
		end
		
		Positions, Cost = GAMEMODE:CalculateWallPositions( Pos, tower1:GetPos(), tower1 )
		
		if( Positions ) then
			if( Empire:GetFood() >= Building.Food*Cost and
				Empire:GetIron() >= Building.Iron*Cost and
				Empire:GetGold() >= Building.Gold*Cost ) then
				
				Empire:AddFood(-Building.Food*Cost or 0)
				Empire:AddIron(-Building.Iron*Cost or 0)
				Empire:AddGold(-Building.Gold*Cost or 0)
				local tower = GAMEMODE:SpawnBuilding("walltower", Pos, Ang, Empire)
				GAMEMODE:SpawnWall( Empire, tower1, tower, Positions )
				ply:ChatPrint( "You created a new Connected Wall" )
			end
			
		else
			ply:ChatPrint( "Failed to create Connected Wall" )
		end
		
	end
	
end )

util.AddNetworkString( "NetworkConnectedGates" )

concommand.Add("sa_buildbuilding", function(ply, cmd, args)
	if(ply.NextBuildBuilding and ply.NextBuildBuilding > CurTime()) then
		return
	end
	ply.NextBuildBuilding = CurTime() + 0.05
	
	local Empire = ply:GetEmpire()
	if( not Empire ) then return end
	
	if( GAMEMODE:MaxEntLimitReached() ) then
		ply:ChatPrint( "Map has reached Max Entity Limit" )
		return
	end
	
	if(table.Count(args) ~= 13) then
		ply:ChatPrint( "Incorrect argument count for " .. tostring( cmd ) )
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
	
	local Building = building.GetBuilding(Name)
	if(not Building) then
		return
	end
	
	if(not building.CanBuild(Empire, Name)) then
		return
	end
	
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + Vector(tonumber(x), tonumber(y), tonumber(z)) * 2048
	trace.filter = ply
	trace.mask = MASK_SHOT_HULL
	local tr = util.TraceLine( trace )

	if Name == "gate" then
		closest = nil
		vecPos = Vector(tonumber(x), tonumber(y), tonumber(z))
	    for _, e in pairs(ents.FindByClass("building_wall")) do
	    	if e:GetEmpire() == Empire then
		    	if closest == nil then
		    		closest = e
		    	end
		    	if closest:GetPos():Distance(vecPos) > e:GetPos():Distance(vecPos) then
		    		closest = e
		    	end
		    end
	    end
	end

	if Name == "walltower" or Name == "shieldmono" then
		--I do these seperately because for some reason CanFit returns false on either of these if they're on a displacement
		CanFit, Pos, Ang = GAMEMODE:CanFit(tr, obbsMins, obbsMaxs, Angle(Pitch, Yaw, Roll), "wall", Building.Foundation) 
	else
		CanFit, Pos, Ang = GAMEMODE:CanFit(tr, obbsMins, obbsMaxs, Angle(Pitch, Yaw, Roll), true, Building.Foundation)
	end

	if(not CanFit and Name ~= "gate") then
		return
	end
	
	if Building.Require and Building.Require["city"] then
		if( not GAMEMODE:IsPosInTerritory( Pos, ply:GetEmpire():GetID() ) and Name ~= "gate" ) then
			return
		end
	else
		if( not GAMEMODE:IsPosInTerritory( Pos, 0 ) and Name ~= "gate" ) then
			return
		end
	end
	
	if(Name == "gate") then
		if(closest and closest:IsWall()) then
			local Valid, Walls, Guards = GAMEMODE:CalculateGate(Empire, closest, vecPos)
			if (Valid) then
				Empire:AddFood( -Building.Food or 0)
				Empire:AddIron( -Building.Iron or 0) 
				Empire:AddGold( -Building.Gold or 0)			
				
				Pos = vecPos + GATE_OFFSET
				Ang = Walls[1]:GetAngles()
				
				local Ent = GAMEMODE:SpawnBuilding(Name, Pos, Ang, Empire)
				Ent:Materialize()
				Ent.HiddenWalls = {}
				
				local LeftTower = GAMEMODE:SpawnBuilding(Name, Pos + (Ang:Right() * 26), Ang, Empire)
				LeftTower:ChangeSettings("Wall", "models/mrgiggles/sassilization/walltower.mdl", true)
				LeftTower:Materialize()
				Ent:AddConnected(LeftTower)
				LeftTower:AddConnected(Ent)
				LeftTower.HiddenWalls = {}
				
				local RightTower = GAMEMODE:SpawnBuilding(Name, Pos + (Ang:Right() * -26), Ang, Empire)
				RightTower:ChangeSettings("Wall", "models/mrgiggles/sassilization/walltower.mdl", true)
				RightTower:Materialize()
				Ent:AddConnected(RightTower)
				RightTower:AddConnected(Ent)
				RightTower.HiddenWalls = {}
				
				LeftTower:AddConnected(RightTower)
				RightTower:AddConnected(LeftTower)

				for k,v in pairs(Walls) do
					v.gate = Ent
					closest:HideWallSegment(v)
					table.insert(LeftTower.HiddenWalls, v)
					table.insert(Ent.HiddenWalls, v)
					table.insert(RightTower.HiddenWalls, v)
				end	

				for k,v in pairs(Guards) do
					table.insert(v.ConnectedGates, Ent)
					for i,d in pairs(player.GetAll()) do
						timer.Simple(0.1, function()
							net.Start("NetworkConnectedGates")
								net.WriteEntity(v)
								net.WriteEntity(Ent)
							net.Send(d)
							net.Start("NetworkConnectedGates")
								net.WriteEntity(v)
								net.WriteEntity(LeftTower)
							net.Send(d)
							net.Start("NetworkConnectedGates")
								net.WriteEntity(v)
								net.WriteEntity(RightTower)
							net.Send(d)
						end)
					end
				end

				return
			end
		else
			ply:ChatPrint( "Gate too close to another" )
			return
		end
	elseif(Name == "walltower") then
		local towers = GAMEMODE:GetWallTowersInSphere( Pos, 128, Empire )
		for _, tower in pairs( towers ) do
			if( Pos:Distance( tower:GetPos() ) < SA.MIN_WALL_DISTANCE ) then
				ply:ChatPrint( "Wall too close to another" )
				return
			end
		end
	end
	
	Empire:AddFood(-Building.Food or 0)
	Empire:AddIron(-Building.Iron or 0)
	Empire:AddGold(-Building.Gold or 0)
	GAMEMODE:SpawnBuilding(Name, Pos, Ang, Empire)
	
end)

concommand.Add("sa_upgradebuilding", function(ply, cmd, args)
	local Name = args[1]
	local EntIndex = args[2]
	
	if(table.Count(args) ~= 2) then
		return
	end
	
	local Empire = ply:GetEmpire()
	if( not Empire ) then return end
	
	local Building = building.GetBuilding(Name)
	if(not Building) then
		return
	end
	
	if(not building.CanBuild(Empire, Name)) then
		return
	end
	
	local Ent = Entity(EntIndex)
	if(not IsValid(Ent)) then
		return
	end
	
	if(not building.CanUpgrade(Empire, Name, Ent:GetLevel() + 1)) then
		return
	end
	
	if(not Ent:IsUpgradeable()) then
		return
	end
	
	Empire:AddFood(-Building.Food or 0)
	Empire:AddIron(-Building.Iron or 0)
	Empire:AddGold(-Building.Gold or 0)
	Ent:Upgrade()
end)
