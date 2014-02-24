----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

AccessorFunc( GM.PlayerMeta, "empire", "Empire" )

local AccessorFunc = AccessorFunc
local building = building
local FORCE_NUMBER = FORCE_NUMBER
local CLIENT = CLIENT
local usermessage = usermessage
local net = net
local tostring = tostring
local assert = assert
local Msg = Msg
local MsgN = MsgN
local print = print
local PrintTable = PrintTable
local ErrorNoHalt = ErrorNoHalt
local tonumber = tonumber
local IsValid = IsValid
local SERVER = SERVER
local umsg = umsg
local net = net
local util = util
local table = table
local pairs = pairs
local IsValid = IsValid
local Color = Color
local building
local SA = SA
local setmetatable = setmetatable
local building = _G.building
local debug = debug
local math = math

function ValidEmpire( Empire )
	if( Empire and Empire:IsValid() ) then
		return true
	end
end

module( "sh_empire" )

mt = {}
methods = {}
mt.__index = methods
mt.__tostring = function(self) return "Empire [" .. self:GetID() .. "][" .. self:GetName() .. "]" end

EMPIRES = {}
EMPIRE_IDS = {}

AccessorFunc( methods, "i_ID", "ID", FORCE_NUMBER )
AccessorFunc( methods, "player", "Player" )

VARTYPE_STRING = "String"
VARTYPE_SHORT = "Short"
VARTYPE_LONG = "Long"
VARTYPE_BOOL = "Bool"
VARTYPE_CHAR = "Byte"

methods.NWVars = {}

local function ProfileAccessorFuncNW( tab, varname, name, varDefault, vartype, bPrivate )
	
	if(not tab.NWVars) then return end
	
	tab[ "Get"..name ] = function ( self, default )
		return self[ varname ] or default or varDefault
	end
	
	--Add to NWVars table for loading newcomers
	tab.NWVars[ name ] = vartype
	
	if(CLIENT) then
		net.Receive( "empire.NW"..vartype.."_"..name, function( len )
			-- UByte
			local id = net.ReadUInt( 8 )
			local emp = EMPIRES[id]
			if(not emp) then return end
			emp[ "Set"..name ]( emp, net[ "Read"..vartype ]() )
		end )
	end
	
	if (SERVER) then util.AddNetworkString( "empire.NW"..vartype.."_"..name ) end
	
	if ( vartype == VARTYPE_STRING ) then
		tab[ "Set"..name ] = function ( self, v )
			self[varname] = tostring(v)
			
			if (SERVER) then
				net.Start( "empire.NW" .. vartype .. "_" .. name )
					-- UByte
					
					net.WriteUInt( self:GetID(), 8 )
					net[ "Write"..vartype ]( v )
					rf = ((bPrivate and IsValid(self:GetPlayer())) and self:GetPlayer() or nil)
				if rf then net.Send( rf ) else net.Broadcast() end
			end
		end
	return end
	
	if ( vartype == VARTYPE_SHORT ) then
		tab[ "Set"..name ] = function ( self, v )
			self[varname] = tonumber(v)
			if(SERVER) then
				net.Start( "empire.NW"..vartype.."_"..name )
					-- UByte
					net.WriteUInt( self:GetID(), 8 )
					net[ "Write"..vartype ]( v )
					rf = ((bPrivate and IsValid(self:GetPlayer())) and self:GetPlayer() or nil)
				if rf then net.Send( rf ) else net.Broadcast() end
			end
		end
	return end
	
	if ( vartype == VARTYPE_LONG ) then
		tab[ "Set"..name ] = function ( self, v )
			self[varname] = tonumber(v)
			if(SERVER) then
				net.Start( "empire.NW"..vartype.."_"..name )
					net.WriteUInt( self:GetID(), 8 )
					net[ "Write"..vartype ]( v )
					rf = ((bPrivate and IsValid(self:GetPlayer())) and self:GetPlayer() or nil)
				if rf then net.Send( rf ) else net.Broadcast()  end
			end
		end
	return end
	
end

local PRIVATE = true
local PUBLIC = false

ProfileAccessorFuncNW(methods, "name", 			"Name", 	"Sass Empire", 	VARTYPE_STRING)
ProfileAccessorFuncNW(methods, "res_food", 		"Food", 	0, 				VARTYPE_SHORT, PRIVATE)
ProfileAccessorFuncNW(methods, "res_iron", 		"Iron", 	0, 				VARTYPE_SHORT, PRIVATE)
ProfileAccessorFuncNW(methods, "res_gold", 		"Gold", 	0, 				VARTYPE_SHORT, PUBLIC)
ProfileAccessorFuncNW(methods, "res_creed",		"Creed", 	0, 				VARTYPE_SHORT, PRIVATE)
ProfileAccessorFuncNW(methods, "res_supply", 	"Supply", 	0, 				VARTYPE_SHORT, PRIVATE)
ProfileAccessorFuncNW(methods, "res_supplied", 	"Supplied", 0, 				VARTYPE_SHORT, PRIVATE)
ProfileAccessorFuncNW(methods, "cities", 		"Cities", 	0, 				VARTYPE_SHORT, PUBLIC)
ProfileAccessorFuncNW(methods, "shrines", 		"Shrines", 	0, 				VARTYPE_SHORT, PRIVATE)
ProfileAccessorFuncNW(methods, "houses", 		"Houses", 	0, 				VARTYPE_SHORT, PRIVATE)
ProfileAccessorFuncNW(methods, "mines", 		"Mines", 	0, 				VARTYPE_SHORT, PRIVATE)
ProfileAccessorFuncNW(methods, "farms", 		"Farms", 	0, 				VARTYPE_SHORT, PRIVATE)

if (SERVER) then
	AccessorFunc(methods, "shields", "Shields", FORCE_NUMBER)
end

local function AccessorIncrDecrFunc( tab, varName, funcName )
	
	tab[ "Incr"..varName ] = function( self )
		tab[ "Set"..funcName ]( self, self[ "Get"..funcName ](self) + 1 )
	end
	tab[ "Decr"..varName ] = function( self )
		tab[ "Set"..funcName ]( self, self[ "Get"..funcName ](self) - 1 )
	end
	
end

AccessorIncrDecrFunc( methods, "Mine", 		"Mines" )
AccessorIncrDecrFunc( methods, "Farm", 		"Farms" )
AccessorIncrDecrFunc( methods, "City", 		"Cities" )
AccessorIncrDecrFunc( methods, "House", 	"Houses" )
AccessorIncrDecrFunc( methods, "Shrine", 	"Shrines" )

if (SERVER) then
	AccessorIncrDecrFunc(methods, "Shields", "Shields")
end

function GetAll()
	return EMPIRES
end

function GetByID( nid )
	if( not nid ) then return end
	
	for id, empire in pairs( GetAll() ) do
		if (id == nid) then
			return empire
		end
	end
end

function GetBySteamID( sid )
	if( not sid ) then return end
	
	return GetByID( EMPIRE_IDS[ sid ] )
end

function GetColorByID( cid )
	assert( cid )
	
	--Msg( "Color ID ", cid, "\n" )
	
	local c = ColorTable[ cid ]
	
	assert( c )
	
	return c
end

function GetBuildings()
	local buildings = {}
	
	for id, empire in pairs( GetAll() ) do
		for _, bldg in pairs( empire:GetBuildings() ) do
			if( IsValid( bldg ) ) then
				table.insert( buildings, bldg )
			else
				empire:GetBuildings()[ _ ] = nil
			end
		end
	end
	
	return buildings
end

function GetUnits()
	local units = {}
	
	for id, emp in pairs( GetAll() ) do
		for uid, unit in pairs( emp:GetUnits() ) do
			table.insert( units, unit)
		end
	end
	
	return units
end

function methods:GetGoldIncome()
	if( self:GetCities() > 0 ) then
		return self:GetCities()
	elseif( self:GetGold() < building.GetBuildingKey( "city", "Gold" ) ) then
		return 1
	else
		return 0
	end
end

function methods:GetFoodIncome()
	return math.ceil(SA.DEFAULT_INCOME_FOOD + self:GetFarms() *1.2)
end

function methods:GetIronIncome()
	return math.ceil(SA.DEFAULT_INCOME_IRON +self:GetMines())
end

function methods:AddGold( value )
	if self:GetGold() + value < 0 then
		self:SetGold(0)
	else
		self:SetGold(self:GetGold() +value)
	end
end

function methods:AddFood( value )
	self:SetFood(self:GetFood() +value)
end

function methods:AddIron( value )
	self:SetIron(self:GetIron() +value)
end

function methods:AddSupplied( value )
	self:SetSupplied( self:GetSupplied() + value )
end

function methods:AddCreed( value )
	self:SetCreed( self:GetCreed() + value )
end

function methods:GetBuildings()
	return self.structures
end

function methods:GetUnits()
	local units = {}
	local count = 1
	
	for id, unit in pairs( self.units ) do
		units[ count ] = unit
		count = count + 1
	end
	
	return units
end

function methods:GetSelectedUnits()
	
	return self.selected.units
	
end

function methods:NumSelectedUnits()
	
	return self.selected.unitcount
	
end

function methods:Select(Ent, Select)
	if(Ent) then
		return Ent:Select(Select)
	else
		if(not Select) then
			local unit = self:GetSelectedUnits()[ Ent ]
			if(IsValid(unit)) then
				unit:Select(false)
			end
		end
	end
end

function methods:SelectUnit( unit, bSelected )
	
	local wasSelected = self:GetSelectedUnits()[ unit ]
	self:GetSelectedUnits()[ unit ] = bSelected or nil
	if( bSelected and not wasSelected ) then
		self.selected.unitcount = self.selected.unitcount + 1
	elseif( not bSelected and wasSelected ) then
		self.selected.unitcount = self.selected.unitcount - 1
	end
	
end

function methods:DeselectAllUnits()
	
	assert( self.selected.units )
	
	for unit, selected in pairs( self.selected.units ) do
		unit:Select( false )
	end
	
	self.selected.units = {}
	self.selected.unitcount = 0
	
end

--[[
	No longer using these because some are too similar to eachother.
	ColorTable = {
		Color(90, 90, 90, 255),     -- Grey
		Color(200, 0, 0, 255),      -- Red
		Color(0, 200, 0, 255),       -- Green
		Color(0, 0, 200, 255),       -- Blue
		Color(200, 0, 200, 255),     -- Magenta
		Color(200, 200, 0, 255),     -- Yellow
		Color(0, 200, 200, 255),     -- Cyan
		Color(255, 140, 50, 255),    -- Orange
		Color(100, 0, 200, 255),     -- Purple
		Color(0, 128, 128, 255),     -- Teal
		Color(100, 64, 0, 255),      -- Brown
		Color(128, 200, 0, 255),     -- Olive
		Color(90, 150, 59, 255),   -- Green-Gray
		Color(155, 166, 200, 255),   -- Light Purple
		Color(0, 144, 200, 255),     -- Sky blue
		Color(200, 150, 160, 255),    -- Pink
		Color(255, 255, 0, 255),     -- Pineapple Yellow (LuaPineapple Only)
	}
--]]

ColorTable = {
	Color(200, 60, 60, 255),     -- Red
	Color(90, 90, 90, 255),     -- Grey
	Color(45, 150, 140, 255),     -- Torquise
	Color(150, 150, 45, 255),     -- Yellow
	Color(200, 60, 165, 255),     -- Pink
	Color(100, 37, 125, 255),     -- Purple
	Color(60, 77, 201, 255),     -- Blue
	Color(100, 75, 30, 255),     -- Brown
	Color(60, 160, 50, 255),     -- Green | The ones from this point on are overflow in case someone leaves the game and we need another color for a new player
	Color(180, 204, 137, 255),	-- Olive | The reason I copy pasted old ones was so that there are colors for people to go to without any problems, this is just temporarily for the dedicated server without the Lobby.
	Color(255, 159, 51, 255),	-- Orange
	Color(93, 255, 77, 255), 	-- Bright Green
	Color(255, 179, 252, 255),	-- Bubblegum
	Color(128, 42, 42, 255),	-- Maroon
	Color(237, 237, 66, 255),	-- Bright Yellow
	Color(200, 0, 200, 255),     -- Magenta
	Color(200, 200, 0, 255),     -- Yellow
	Color(0, 200, 200, 255),     -- Cyan
	Color(255, 140, 50, 255),    -- Orange
	Color(100, 0, 200, 255),     -- Purple
	Color(0, 128, 128, 255),     -- Teal
	Color(100, 64, 0, 255),      -- Brown
	Color(255, 255, 0, 255)     -- Pineapple Yellow (LuaPineapple Only)
}

function methods:HasColor()
	return (self.color ~= nil)
end

function methods:SetColorID( cid )
	
	self.colorID = cid
	self:SetColor( GetColorByID( cid ) )
	
end

function methods:GetColorID()
	
	return self.colorID
	
end

function methods:SetColor( c )
	if( not self:HasColor() ) then
		self.color = Color( c.r, c.g, c.b, c.a )
		return
	end
	self.color.r = c.r
	self.color.g = c.g
	self.color.b = c.b
	self.color.a = c.a
end

function methods:GetColor()
	return self.color
end

function methods:HasOwner( pl )
	
	local owner = self:GetPlayer()
	if not (IsValid( owner ) and owner:IsPlayer()) then return end
	if not (owner == pl) then return end
	
	return true
	
end

function methods:IsEmpire()
	
	return true
	
end

function methods:IsPlayer()
	
	return false
	
end

function methods:IsValid()
	
	return true
	
end

function methods:HasBuilding()
end

function methods:Nick()
	
	return self:GetName( "Empire" )
	
end