----------------------------------------
--    Sassilization
--    http://sassilization.com
--    By Sassafrass
--    Models By Jaanus
----------------------------------------

local table = table
local type = type
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local MsgN = MsgN
local util = util
local tobool = tobool
local string = string
local Error = Error
local math = math
local setmetatable = setmetatable
local umsg = umsg
local hook = hook
local ErrorNoHalt = ErrorNoHalt
local PrintTable = PrintTable
local ents = ents
local Vector = Vector
local CurTime = CurTime
local SERVER = SERVER
local UNITS = SA.UNITS
local building
local Unit = Unit

hook.Add("modules.OnModuleLoaded", "sh_unit.OnModuleLoaded", function( name )
    if( name == "building" ) then
        building = _G.building
    end
end)

module( "sh_unit" )

local unitIncrement = 1

UnitOrder = {"swordsman", "archer", "scallywag", "catapult", "ballista"}

local units = {}
    
function Create(class, uid)
    class = string.lower(class)
	
    if (not UNITS.metatables[class]) then
		error("Attemping to create an invalid unit class: " .. tostring(class) .. "\n", 2)
    end
    
    local unit = table.Copy( Unit:GetData(class) )
    
    setmetatable( unit, UNITS.metatables[class] )
    
	if( not uid and SERVER ) then
		uid = unitIncrement
		unitIncrement = unitIncrement + 1
	end
	
    unit.unit_index = uid
    
    unit:Init()
	
    table.insert( units, unit )
    
    return unit
end

function Spawn(unit)
    if(SERVER) then
		Msg("Spawning: ", unit, "\n")
	else
		ErrorNoHalt( "Spawning: ", unit, "\n" )
    end 
	
    if( not unit ) then return end
    
    unit:Spawn()
end

function FindInSphere( pos, rad )
    local units = {}
    local count = 1
	if( SERVER ) then
		local Ents = ents.FindInSphere( pos, rad )
		for _, ent in pairs( Ents ) do
			if( ent:IsUnit() and ent:GetUnit() ) then
				units[ count ] = ent:GetUnit()
				count = count + 1
			end
		end
	else
		local radSqr = rad^2
		for _, Unit in ipairs( GetAll() ) do
			local upos = Unit:GetPos()
			if( math.abs(upos.x-pos.x) < rad and
				math.abs(upos.y-pos.y) < rad and
				math.abs(upos.z-pos.z) < rad and
				(upos-pos):LengthSqr() <= radSqr ) then
				units[ count ] = Unit
				count = count + 1
			end
		end
	end
    return units, count
end

function NumUnitsInSphere( pos, rad )
	local count = 0
	if( SERVER ) then
		local Ents = ents.FindInSphere( pos, rad )
		for _, ent in pairs( Ents ) do
			if( ent:IsUnit() and ent:GetUnit() ) then
				count = count + 1
			end
		end
	else
		local radSqr = rad^2
		for _, unit in ipairs( GetAll() ) do
			local upos = unit:GetPos()
			if( math.abs(upos.x-pos.x) < rad and
				math.abs(upos.y-pos.y) < rad and
				math.abs(upos.z-pos.z) < rad and
				(upos-pos):LengthSqr() <= radSqr ) then
				count = count + 1
			end
		end
	end
	return count
end

function GetCount()
    
    --TODO: Keep track of unit count
    return #units
    
end

function GetAll()
    
    return units
    
end

function OnUnitSpawned( self, Unit )
    
    UNITS.units[ Unit:UnitIndex() ] = Unit
    
end

local units_to_remove = {}

function OnUnitRemoved( self, Unit )
    
    UNITS.units[ Unit:UnitIndex() ] = nil
    units_to_remove[ Unit ] = Unit
    
end

local function post_think()
    for _, Unit in pairs( units_to_remove ) do
        for i = 1, GetCount() do
            local U = units[ i ]
			
            if( Unit == U ) then
                units_to_remove[ Unit ] = nil
				
                table.remove( units, i )
				
                break
            end
        end
    end
end

local function unit_think()
    local time = CurTime()
    local Units, unit = GetAll()
	
    for i = 1, GetCount() do
        unit = Units[ i ]
        
        if (Unit:ValidUnit( unit ) and time >= unit:GetNextThink()) then
            unit:Think()
        end
    end
    
    post_think()
end

hook.Add( "Think", "unit.Think", function()
    local ok, err = pcall( unit_think )
   
	if( not ok ) then
        ErrorNoHalt( err, "\n" )
    end
end )