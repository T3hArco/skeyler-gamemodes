----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local require = require
local pairs = pairs
local Color = Color
local Error = Error
local setmetatable = setmetatable
local umsg = umsg
local net = net
local IsValid = IsValid
local Vector = Vector
local math = math
local timer = timer
local rpairs = rpairs
local assert = assert
local tostring = tostring
local COMMAND = COMMAND
local SA = SA
local util = util
local MsgN = MsgN
local print = print
local EffectData = EffectData
local Unit = Unit
local ErrorNoHalt = ErrorNoHalt

hook.Add("modules.OnModuleLoaded", "empire.svOnModuleLoaded", function(name)
    if ( name == "unit" ) then
        COMMAND = _G.COMMAND
	end
end)

local _G = _G

module("empire")

if( not _G.sh_empire ) then return end

for k, v in pairs( _G.sh_empire ) do
	if not _M[k] then
		_M[k] = v
	end
end

_G.sh_empire = nil
_G = nil

UsedColors = {}

local LuaPineappleColorID = 10

UsedColors[LuaPineappleColorID] = true --Reserved for LuaPineapple

util.AddNetworkString( "empire.Create" )

function Create(pl, id, sid)
	if (EMPIRES[ id ]) then
		error( "WARNING: Tried to create an existing empire\n", 2)
	end
	
	local empire = {}
	
	setmetatable( empire, mt )
	
	empire.SteamID = sid
	empire:SetID( id )
	empire:SetShields(0)
	empire:SetupColor()
	empire:SetPlayer( pl )
	empire.name = pl:Nick() --Can't use :SetName() because the empire hasn't been created clientside yet

	empire.structures = {}
	empire.units = {}
	empire.spawns = {}
	empire.selected = {}
	empire.selected.units = {}
	empire.selected.unitcount = 0
	
	if( history ) then
		empire.history = history.New()
	end
	
	EMPIRES[id] = empire
	EMPIRE_IDS[sid] = id

	print("Creating empire ", id, "\n")

	timer.Simple( 5, function()
	
		net.Start( "empire.Create" )
			net.WriteEntity( pl )
			net.WriteUInt( id, 8 )
			net.WriteUInt( empire:GetColorID(), 8 )
			net.WriteString( empire:Nick() )
		net.Broadcast()
	
		empire:SetGold( SA.START_RES_GOLD )
		empire:SetFood( SA.START_RES_FOOD )
		empire:SetIron( SA.START_RES_IRON )
		empire:CalculateSupply()

	end )

	print( "Created "..tostring(empire).."\n" )
	
	return empire
end

function methods:GetUserID()
	local pl = self:GetPlayer()
	if (IsValid(pl) and pl:IsPlayer()) then
		return pl:UserID()
	else
		return 0
	end
end

function Allied(emp1, emp2)
	if emp1 and emp2 then
		if emp1:GetPlayer() and emp1:GetPlayer().Alliance then
			for k,v in pairs(emp1:GetPlayer().Alliance) do
				if v:GetEmpire() == emp2 then
					return true
				end
			end
		else
			return false
		end
	end
end

function methods:CommandUnits(Pos, bInFocus, bInAdd)
	if( self:NumSelectedUnits() == 0 ) then return end
	
	local Cmd
	
	local pl = self:GetPlayer()
	local trace = {}
	trace.start = pl:EyePos()
	trace.endpos = trace.start + pl:GetAimVector() * 4096
	trace.filter = pl
	trace.mask = MASK_PLAYERSOLID_BRUSHONLY
	local tr = util.TraceLine( trace )
	
	if( tr.Entity:IsShrine() and (tr.Entity:GetEmpire() == self or Allied(tr.Entity:GetEmpire(), self)) ) then
		Cmd = SA.CreateCommand( COMMAND.SACRIFICE, tr.Entity )
	elseif( bInFocus ) then
		-- Player is attacking an entity. // Chewgum
		if (IsValid(tr.Entity)) then
			if (tr.Entity:GetEmpire() == self) then return end
			if Allied(tr.Entity:GetEmpire(), self) then return end
			
			if (tr.Entity:IsUnit()) then
				Cmd = SA.CreateCommand(COMMAND.ATTACK, tr.Entity:GetUnit())
				
				local effect = EffectData()
					effect:SetEntity(NULL)
					effect:SetMagnitude(tr.Entity:GetUnit():UnitIndex())
					effect:SetScale(self:GetPlayer():UserID())
				util.Effect("order_attack", effect, true, true)
			elseif tr.Entity:IsPlayer() or tr.Entity:GetClass() == "iron_mine" or tr.Entity:GetClass() == "farm" then
				Cmd = SA.CreateCommand( COMMAND.MOVE, tr.Entity:GetPos() )
			else
				Cmd = SA.CreateCommand(COMMAND.ATTACK, tr.Entity)
				
				local effect = EffectData()
					effect:SetEntity(tr.Entity)
					effect:SetScale(self:GetPlayer():UserID())
				util.Effect("order_attack", effect, true, true)
			end
		else
			Cmd = SA.CreateCommand( COMMAND.MOVE, Pos )
		end
	else
		Cmd = SA.CreateCommand( COMMAND.ATTACKMOVE, Pos )
	end
	
	for k,v in pairs(self:GetSelectedUnits()) do
		if(IsValid(k)) then
			if( bInAdd ) then
				if( not k:AddCommand( Cmd ) ) then
					self:ChatPrint( "Command Queue is Full!" )
				end
			else
				if !k.Paralyzed and !k.Blasted and !k.Gravitated then -- Check to see if unit should be allowed to be controlled
					k:ClearCommands()
					k:PushCommand( Cmd )
				end
			end
		end
	end
end

function methods:ChatPrint( str )
	local pl = self:GetPlayer()
	
	if( IsValid(pl) ) then
		pl:ChatPrint( str )
	end
end

function methods:SetPlayer(pl)
	self.player = pl
	
	local col = self:GetColor()
	pl:SetPlayerColor( Vector( col.r / 255, col.g / 255, col.b / 255 ) )
end

function methods:GetPlayer()
	return self.player
end

function methods:SendNWVar( NWtype, name, value, rf )
	net.Start( "empire.NW"..NWtype.."_"..name, rf )
		-- UByte
		net.WriteUInt( self:GetID(), 8 )
		net[ "Write"..NWtype ]( value )
	net.Send( rf )
	
end

function methods:SendNWVars( rf ) --recipientFilter
	for NWname, NWtype in pairs( self.NWVars ) do
		self:SendNWVar( NWtype, NWname, self[ "Get"..NWname ]( self ), rf )
	end
end

function methods:SetupColor()
	if ( self:HasColor() ) then return end
	
	if( self.SteamID == "STEAM_0:0:12190592" ) then
		UsedColors[ LuaPineappleColorID ] = self
		self:SetColorID( LuaPineappleColorID )
		return
	end
	
	for i, col in rpairs( ColorTable ) do
		if i <= 9 then
			if( not UsedColors[i] ) then
				UsedColors[i] = self
				self:SetColorID( i )
				return
			end
		else
			if UsedColors[1] && UsedColors[2] && UsedColors[3] && UsedColors[4] && UsedColors[5] && UsedColors[6] && UsedColors[7] && UsedColors[8] && UsedColors[9] then
				if( not UsedColors[i] ) then
					UsedColors[i] = self
					self:SetColorID( i )
					return
				end
			end
		end
	end
end

function methods:CalculateSupply()
	if MONUMENTS and MONUMENTS["jaanus"] == self then
		--self:SetNWInt( "_supply", unit_limit )
		return
	end
	
	local count = SA.START_SUPPLY + self:GetCities() + self:GetHouses() * 0.5
	
	self:SetSupply(math.floor(count))
end

function methods:Remove()
	--TODO: Clear this entire empire's units and structures
	
	UsedColors[ self:GetColorID() ] = nil
end