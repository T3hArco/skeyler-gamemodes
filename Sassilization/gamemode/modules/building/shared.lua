----------------------------------------
--    Sassilization
--  Shared Building Module
--    http://sassilization.com
--    By Sassafrass / Spacetech
----------------------------------------

local table = table
local util = util
local umsg = umsg
local ents = ents
local SERVER = SERVER
local Vertex = Vertex
local ipairs = ipairs
local pairs = pairs
local string = string
local type = type
local Vector = Vector
local CHECK_MASK = CHECK_MASK
local Mesh = Mesh
local IsValid = IsValid
local LocalEmpire
local VECTOR_UP = VECTOR_UP
local VECTOR_RIGHT = VECTOR_RIGHT
local SA = SA
local Angle = Angle
local empire = empire

local Msg = Msg
local MsgN = MsgN

hook.Add( "modules.OnModuleLoaded", "building.OnModuleLoaded", function( name )
    
    if( name == "empire" ) then
        
        LocalEmpire = _G.LocalEmpire
        
    end
    
end )

module( "sh_building" )

--ENUMERATIONS
BUILDING_SELL = 1
BUILDING_DESTROY = 2
BUILDING_UPGRADE = 3
BUILDING_DISCONNECTED = 4


BuildingData = {}
BuildingOrder = {}
HouseData = {}

function AddBuilding(Name, Table)
    BuildingData[Name] = Table
    if(!Table.NoSpawn) then
        table.insert(BuildingOrder, Name)
    end
    if(Table.Model) then
        if(type(Table.Model) == "table") then
            for k,v in ipairs(Table.Model) do
                util.PrecacheModel(v)
            end
        else
            util.PrecacheModel(Table.Model)
        end
    end
end

function GetBuilding(Name)
    return BuildingData[Name]
end

function IsBuilding(Name)
    return BuildingData[Name] ~= nil
end

function GetBuildingKey(Name, Key)
    if(not BuildingData[Name]) then
        return false
    end
    return BuildingData[Name][Key]
end

function CalcBuildingType(Ent)
    for k,v in pairs(BuildingData) do
        if(Ent:GetClass() == "building_"..string.lower(k)) then
            CachedType = k
            break
        end
    end
    return CachedType
end

function NearCity(Empire, Pos, Distance)
    if(SERVER and Empire) then
        for k,v in pairs(Empire:GetBuildings()) do
            if(v:GetType() == "city" and v:IsBuilt() and v:GetPos():Distance(Pos) <= Distance) then
                return true
            end
        end
    else
        for k,v in pairs(ents.FindByClass("building_city")) do
			if(v:GetPos():Distance(Pos) <= Distance)then
				if(not Empire) then
					return true
				elseif(v:GetEmpire() == Empire and v:IsBuilt()) then
					return true
				end
			end
        end
    end
    return false
end

function HasBuilding(Empire, Name, Level, Amount)
    local count = 0
    for _, bldg in pairs(Empire:GetBuildings()) do
        if( bldg:GetType() == Name and bldg:IsBuilt() ) then
            if(Level) then
                if(bldg:GetLevel() >= Level) then
                    return true
                end
            elseif(not Amount) then
                return true
            else
                count = count + 1
            end
        end
    end
    if( Amount ) then
        return count >= Amount
    else
        return false
    end
end

function CanUpgrade(Empire, Name, Level)
    
    if( not Empire ) then return false end
    
    local Building = GetBuilding(Name)
    if(not Building) then
        return false
    end
    
    if( not Building.Levels ) then
        return false
    end
    
    if( not Building.Levels[ Level ] ) then
        return false
    end
    
    for Requirement, Details in pairs(Building.Levels[ Level ]) do
        if( not HasBuilding( Empire, Requirement, Details.Level, Details.Amount ) ) then
            return false
        end
    end
    
    return true
end

function CanBuild(Empire, Name, IgnoreCost)
    
    if( not Empire ) then return false end
    
    local Building = GetBuilding(Name)
    if(not Building) then
        return false
    end
    
    if(Building.NoSpawn) then
        return false
    end
    
    if(not IgnoreCost) then
        if(Building.Gold and Building.Gold > Empire:GetGold()) then
            return false
        end
        if(Building.Food and Building.Food > Empire:GetFood()) then
            return false
        end
        if(Building.Iron and Building.Iron > Empire:GetIron()) then
            return false
        end    
    end
    
    if(Building.Require) then
        for k,v in pairs(Building.Require) do
            if(not HasBuilding(Empire, k, v)) then
                return false
            end
        end
    end
    
    return true
end

local function getVert( pos, norm, tang )
    local scale = 20
    
    local up = tang
    local right = norm:Cross( tang )
    
    local u = pos:Dot( right )
    local v = pos:Dot( up )
    
    return Vertex( pos, u / scale, v / scale, norm )
end

local function addTri( triangles, pos1, pos2, pos3, norm, tang )
    table.insert( triangles, getVert( pos1, norm, tang ) )
    table.insert( triangles, getVert( pos2, norm, tang ) )
    table.insert( triangles, getVert( pos3, norm, tang ) )
end

function CreateFoundation( bldg )

	local mins = bldg:OBBMins()
    local maxs = bldg:OBBMaxs()
    local center = bldg:LocalToWorld(bldg:OBBCenter())
    
    local corners = {
        Vector( mins.x, maxs.y, mins.z ),
        Vector( maxs.x, maxs.y, mins.z ),
        Vector( maxs.x, mins.y, mins.z ),
        Vector( mins.x, mins.y, mins.z ),
    }
    local trace, tr = {}
    local buildFoundation
    local buildBottom
    for _, pos in pairs( corners ) do
        corners[_].z = pos.z + 1
        pos = bldg:LocalToWorld( pos )
        trace.start = pos + VECTOR_UP
        trace.endpos = pos - VECTOR_UP * SA.FOUNDATION_HEIGHT
        trace.mask = CHECK_MASK
        tr = util.TraceLine( trace )
        if( tr.Fraction * SA.FOUNDATION_HEIGHT > 2 ) then
            buildFoundation = true
        end
    end
    
    if( SERVER ) then
        return buildFoundation
    end
    
    local triangles = {} --For building the mesh
    
    --Construct top of foundation
    
    addTri( triangles, corners[1], corners[2], corners[3], VECTOR_UP, VECTOR_RIGHT )
    addTri( triangles, corners[3], corners[4], corners[1], VECTOR_UP, VECTOR_RIGHT )
    
    --Construct sides of foundation
    
    local segments = 4
    local prev = 4
    local lowerPositions = {}
    local lowerPos, lowerPrevPos
    local sum = Vector(0)
    for i, _ in pairs( corners ) do
        
        local diff = (corners[ i ] - corners[ prev ])
        local distance = diff:Length()
        local right = diff:GetNormal()
        local norm = -right:Cross( VECTOR_UP )
        
        for j=1, segments do
            
            local prevPos = corners[prev] + right * distance * ((j-1) / segments)
            local pos = corners[prev] + right * distance * (j / segments)
            
            if( not lowerPrevPos ) then
                trace.start = bldg:LocalToWorld(prevPos) + VECTOR_UP
                trace.endpos = bldg:LocalToWorld(prevPos) - VECTOR_UP * SA.FOUNDATION_HEIGHT
                tr = util.TraceLine( trace )
                lowerPrevPos = bldg:WorldToLocal( tr.HitPos )
                lowerPrevPos.z = lowerPrevPos.z - 0.5
            end
            
            trace.start = bldg:LocalToWorld(pos) + VECTOR_UP
            trace.endpos = bldg:LocalToWorld(pos) - VECTOR_UP * SA.FOUNDATION_HEIGHT
            tr = util.TraceLine( trace )
            lowerPos = bldg:WorldToLocal( tr.HitPos )
            lowerPos.z = lowerPos.z - 0.5
            
            lowerPositions[ (i-1) * segments + j ] = lowerPos
            sum = sum + lowerPos
            
            if( not tr.Hit ) then
                buildBottom = true
            end
            
            addTri( triangles, pos, prevPos, lowerPrevPos, norm, VECTOR_UP )
            addTri( triangles, lowerPrevPos, lowerPos, pos, norm, VECTOR_UP )
            
            lowerPrevPos = lowerPos
            
        end
        
        prev = i
        
    end
    
    lowerMidPos = sum / (segments * 4 )
    
    --Create the bottom of the foundation
    if( buildBottom ) then
        
        local total = segments * 4
        local prev = lowerPositions[total]
        for i=1, total do
            addTri( triangles, lowerMidPos, lowerPositions[i], prev, VECTOR_UP*-1, VECTOR_RIGHT )
            prev = lowerPositions[i]
        end
    
    end
    
    --Make sure we always draw the foundation when we're looking at it
    mins.z = mins.z - SA.FOUNDATION_HEIGHT
    bldg:SetRenderBounds( mins, maxs )
    
    --Create the mesh to draw the foundation
    local foundation = Mesh()
    foundation:BuildFromTriangles( triangles )
    return foundation
    
end

function CacheOBB()
    for k,v in pairs(BuildingData) do
        if(v.Model) then
			local TestModel = v.Model
			if(type(v.Model) == "table") then
				TestModel = v.Model[1]
			end

            local FakeEntity
            if (SERVER) then
                FakeEntity = ents.Create("prop_physics")
            else
                FakeEntity = ents.CreateClientProp(TestModel)
            end

            if(IsValid(FakeEntity)) then
                if (SERVER) then
                    FakeEntity:SetModel(TestModel)
                end
				
				BuildingData[k].OBBCenter = FakeEntity:OBBCenter()
				BuildingData[k].OBBMins = FakeEntity:OBBMins()
				BuildingData[k].OBBMaxs = FakeEntity:OBBMaxs()
				
                FakeEntity:Remove()
            end
        end
    end
	for i=1,3 do
        local FakeEntity
		if (SERVER) then
            FakeEntity = ents.Create("prop_physics")
        else
            FakeEntity = ents.CreateClientProp(TestModel)
        end

		if(IsValid(FakeEntity)) then
			if (SERVER) then
                FakeEntity:SetModel("models/mrgiggles/sassilization/House0"..i..".mdl")
			end

			HouseData[i] = {}
			HouseData[i].OBBCenter = FakeEntity:OBBCenter()
			HouseData[i].OBBMins = FakeEntity:OBBMins()
			HouseData[i].OBBMaxs = FakeEntity:OBBMaxs()
			
			FakeEntity:Remove()
		end
	end
end

AddBuilding("city", {
    Name = "City",
    Model = "models/mrgiggles/sassilization/TownCenter.mdl",
    Influence = 50,
	BuildTime = 15,
    Health = 100,
    Iron = 50,
    Food = 50,
    Gold = 32,
    DestroyGold = 10,
    DestroyBonus = 5,
    Foundation = true,
	camPos = Vector(-392.774292, -330.134674, 259.718689),
	angle = Angle(25.065, 39.902, 0.000),
	fov = 5.89
})

AddBuilding("house", {
    Name = "House",
    Model = {"models/mrgiggles/sassilization/House01.mdl", "models/mrgiggles/sassilization/House02.mdl", "models/mrgiggles/sassilization/House03.mdl"},
    Influence = 67.5,
    Health = 45,
    NoSpawn = true,
    DestroyGold = 4,
    DestroyBonus = 1,
    Foundation = true
	--camPos = Vector(),
	--angle = Angle(),
	--fov = 45
})

AddBuilding("wall", {
    Name = "Wall",
    Model = "models/mrgiggles/sassilization/Wall.mdl",
    Health = 50,
    NoSpawn = true,
    DestroyGold = 1,
    DestroyBonus = 1
	--camPos = Vector(),
	--angle = Angle(),
	--fov = 45
})

AddBuilding("walltower", {
    Name = "WallTower",
    Model = "models/mrgiggles/sassilization/Walltower.mdl",
    Health = 80,
    Iron = 1,
    Food = 0.75,
    Gold = 0.2,
    CustomGhost = true,
    Require = {city = 0},
    DestroyGold = 0,
    DestroyBonus = 2,
	camPos = Vector(-45.385292, -31.899818, 36.990265),
	angle = Angle(18.875, 34.500, 0),
	fov = 45
})

AddBuilding("gate", {
    Name = "Gate",
    Model = "models/mrgiggles/sassilization/Gate.mdl",
    Health = 80,
    Iron = 8,
    Food = 1,
    Gold = 5,
    CustomGhost = true,
    Require = {city = 0, workshop = 1},
    DestroyGold = 0,
    DestroyBonus = 3,
	camPos = Vector(-424.698181, -356.201508, 259.357513),
	angle = Angle(25.000, 40.000, 0.000),
	fov = 5.76
})

AddBuilding("tower", {
    Name = "Tower",
    --Model = {"models/mrgiggles/sassilization/archertower_01.mdl", "models/mrgiggles/sassilization/archertower_02.mdl", "models/mrgiggles/sassilization/archertower_03.mdl"},
    Model = {"models/mrgiggles/sassilization/archertower01.mdl", "models/mrgiggles/sassilization/archertower02.mdl", "models/mrgiggles/sassilization/archertower03.mdl"},
	BuildTime = 5,
    Health = {32, 38, 46},
    Iron = 22,
    Food = 16,
    Gold = 3,
    Levels = {
        { --Level 1 Requirements
            city = {Amount=1}
        },
        { --Level 2 Requirements
            workshop={Amount=1,Level=1}
        },
        { --Level 3 Requirements
            workshop={Amount=2,Level=2}
        }
    },
    AttackSpeed = {2.5, 2, 1.5},
    AttackRange = {80, 100, 100},
    AttackDamage = {2.5, 3, 3.5},
    Require = {city = 0},
    DestroyGold = 2,
    DestroyBonus = 3,
    Foundation = true,
	camPos = Vector(-45.385292, -31.899818, 36.990265),
	angle = Angle(18.875, 34.500, 0),
	fov = 45
})

AddBuilding("workshop", {
    Name = "Workshop",
    Model = {"models/mrgiggles/sassilization/Workshop.mdl", "models/mrgiggles/sassilization/Workshop02.mdl"},
    Influence = 40,
	BuildTime = 40,
    Health = {90, 120},
    Iron = 80,
    Food = 90,
    Gold = 25,
    Levels = {
        { --Level 1 Requirements
            city = {Amount=1}
        },
        { --Level 2 Requirements
            city = {Amount=1}
        }
    },
    Require = {city = 0},
    DestroyGold = 0,
    DestroyBonus = 20,
    Foundation = true,
	camPos = Vector(-37.039215, -28.321854, 20.390173),
	angle = Angle(15.973, 45.519, 0),
	fov = 60.7
})

AddBuilding("shieldmono", {
    Name = "ShieldMono",
    Model = "models/jaanus/shieldmonolith.mdl",
    Health = 30,
    Iron = 25,
    Food = 15,
    Gold = 10,
    Require = {city = 0, workshop = 1},
    DestroyGold = 2,
    DestroyBonus = 4,
	camPos = Vector(-251.917358, -211.387085, 163.293045),
	angle = Angle(25.196, 39.972, 0.000),
	fov = 5
})

AddBuilding("shrine", {
    Name = "Shrine",
    Model = "models/mrgiggles/sassilization/Altar.mdl",
    Influence = 40,
	BuildTime = 70,
    Health = 50,
    Iron = 100,
    Food = 100,
    Gold = 25,
    Require = {city = 0, workshop = 2},
    DestroyGold = 3,
    DestroyBonus = 12,
    Foundation = true,
	camPos = Vector(20.847956, 25.790237, 16.139711),
	angle = Angle(24.000, 231.125, 0),
	fov = 45
})