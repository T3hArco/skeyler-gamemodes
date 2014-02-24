----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local require = require
local usermessage = usermessage
local net = net
local ErrorNoHalt = ErrorNoHalt
local PrintTable = PrintTable
local print = print
local pairs = pairs
local string = string
local concommand = concommand
local tonumber = tonumber
local tobool = tobool
local Vector = Vector
local ValidUnit = Unit.ValidUnit
local UNITS = SA.UNITS
local Unit = Unit

local empire = empire

hook.Add( "modules.OnModuleLoaded", "unit.OnModuleLoaded", function( name )
	
	if( name == "empire" ) then
		empire = _G.empire
	end
	
end )

local _G = _G

module( "unit" )

if( not _G.sh_unit ) then return end

for k, v in pairs( _G.sh_unit ) do
	if not _M[k] then
		_M[k] = v
	end
end

_G.sh_unit = nil
_G = nil

-- net.Receive( "unit.SpawnUnits", function( len )
	
	-- local count = net.ReadByte()
	-- for i=1, count do
		-- local eid = net.ReadUInt(8)
		-- local uid = net.ReadUInt(8)
		-- local class = net.ReadString()
		-- Spawn( ed, uid, class )
	-- end
	
-- end )

concommand.Add( "~_cl.unit.Spawn", function(pl, cmd, args)
	local eid = tonumber( args[1] )
	local uid = tonumber( args[2] )
	local class = args[3]
	
	Spawn( eid, uid, class )
end)

concommand.Add( "~_cl.unit.Select", function( pl, cmd, args )
	local uid = tonumber( args[1] )
	local bSelect = tobool( args[2] )
	local u = Unit:Unit( uid )
	
	if Unit:ValidUnit(u) then
		u:Select( bSelect )
	end
end )

-- usermessage.Hook( "unit.Spawn", function( um )
	
	-- local eid = um:ReadShort()
	-- local uid = um:ReadShort()
	-- local class = um:ReadString()
	
	-- Spawn( eid, uid, class )
	
-- end )

function Spawn( eid, uid, class )
	
	local emp = empire.GetByID( eid )
	
	if (!(emp and emp:IsEmpire())) then
		ErrorNoHalt( "tried to spawn a unit with non-existant empire!\n" )
		
		return
	end
	
	if (Unit:Unit(uid)) then
		ErrorNoHalt( "tried to spawn a unit with an existing unit index!\n" )
		
		return
	end
	
	local u = _M.Create( class, uid )
	
	if (!u) then
		ErrorNoHalt( "tried to create a unit with an invalid class!\n" )
		
		return
	end

	u:SetControl( emp )
	u.RenderOrigin = Vector( 0, 0, u.Size * 0.5 )
	
	u:Init()
	u:SetAlive( true )
	
	UNITS.units[ tonumber(uid) ] = u
	
	-- ErrorNoHalt( "Spawned ", uid, "\n" )
end

concommand.Add( "~_cl.unit.Remove", function( pl, cmd, args )
	local uid = tonumber( args[1] )
	local info = string.byte( args[2] )
	local u = Unit:Unit( uid )
	
	if( not Unit:ValidUnit( u ) ) then
		ErrorNoHalt( "tried to remove invalid unit! ", u, "\t", uid, "\n" )
		
		return
	end
	
	-- ErrorNoHalt( "Removing ", u, "\n" )
	
	u:Remove( info )
end )
	

-- net.Receive( "unit.Remove", function( len )
	
	-- local uid = net.ReadUInt(8)
	-- local info = net.ReadByte()
	-- local u = Unit( uid )
	-- if ( not Unit:ValidUnit( u ) ) then return end
	
	-- ErrorNoHalt( "Removing ", u, "\n" )
	
	-- u:Remove( info )
	
-- end )