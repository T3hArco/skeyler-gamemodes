----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

UNIT.Name = "Base"
UNIT.Model = "models/Roller.mdl"
UNIT.Iron = 1
UNIT.Food = 1
UNIT.Gold = 0
UNIT.Supply = 1
UNIT.AttackDelay = 1.5
UNIT.Range = 6
UNIT.SightRange = 32
UNIT.Speed = 30
UNIT.Spawnable = false
UNIT.HP = 14
UNIT.AttackDamage = 7

AccessorFunc( UNIT, "nextThink", "NextThink", 0, FORCE_NUMBER )
AccessorFunc( UNIT, "b_Alive", "Alive", false, FORCE_BOOL )
AccessorFunc( UNIT, "e_Empire", "Empire" )
AccessorFunc( UNIT, "v_Pos", "Pos" )
AccessorFunc( UNIT, "v_Vel", "Velocity" )
AccessorFunc( UNIT, "a_Angles", "Angles" )
AccessorFunc( UNIT, "v_Up", "Up" )
AccessorFunc( UNIT, "v_Forward", "Forward" )
AccessorFunc( UNIT, "v_Right", "Right" )
AccessorFunc( UNIT, "c_Color", "Color" )
AccessorFunc( UNIT, "n_Health", "Health" )
AccessorFunc( UNIT, "n_MaxHealth", "MaxHealth" )
AccessorFunc( UNIT, "b_Selected", "Selected" )
AccessorFunc( UNIT, "Model", "Model" )

UNIT.v_Pos = Vector(0, 0, 0)
UNIT.v_Vel = Vector(0, 0, 0)
UNIT.a_Angles = Angle(0, 0, 0)
UNIT.v_Up = Vector(0,0,1)
UNIT.v_Forward = Vector(0, 0, 0)
UNIT.v_Right = Vector(0, 0, 0)
UNIT.n_Health = 1
UNIT.n_MaxHealth = 1

UNIT.Refundable = true

UNIT.__tostring = function( self ) return "Unit ["..self:UnitIndex().."]["..self:GetClass().."]"; end

function UNIT:UnitIndex()
	
	return self.unit_index
	
end

function UNIT:GetClass()
	
	return self.Class
	
end

function UNIT:IsUnit()
	
	return true
	
end

function UNIT:IsWall()
	return false
end

function UNIT:IsBuilding()
	
	return false
	
end

function UNIT:SetColor( c )
	
	if( not self.c_Color ) then
		self.c_Color = Color( c.r, c.g, c.b, c.a )
	else
		self.c_Color.r = c.r
		self.c_Color.g = c.g
		self.c_Color.b = c.b
		self.c_Color.a = c.a
	end
	
	if( CLIENT ) then
		if( IsValid( self.Entity ) ) then
			self.Entity:SetColor( c )
		end
	end
	
end

function UNIT:GetColor()
	
	if( not self.c_Color ) then return color_white end
	return self.c_Color
	
end

if (SERVER) then
	util.AddNetworkString("unit.Health")
	
	function UNIT:SetHealth(health)
		self.n_Health = health
		
		net.Start("unit.Health")
			net.WriteUInt(health, 16)
			net.WriteUInt(self:UnitIndex(), 16)
		net.Broadcast()
	end
elseif (CLIENT) then
	net.Receive("unit.Health", function(bits)
		local health = net.ReadUInt(16)
		local unit = net.ReadUInt(16)
		
		unit = Unit:Unit(unit)
		
		if (unit) then
			unit:SetHealth(health)
		end
	end)
end

function UNIT:GetRandomPosInOBB()
	local mins, maxs = self.OBBMins, self.OBBMaxs
	return Vector( math.Rand( mins.x, maxs.x ), math.Rand( mins.y, maxs.y ), math.Rand( mins.z, maxs.z ) )
end

function UNIT:AddOrder( pos )
	
	self.queue = self.queue or {}
	self.queue[ CurTime() ] = pos
	
end

if (SERVER) then
	util.AddNetworkString( "unit.ClearQueue" )
	util.AddNetworkString( "unit.Remove" )
end

function UNIT:ClearQueue()
	
	self.queue = {}
	if(SERVER) then
		net.Start("unit.ClearQueue")
			-- UByte
			net.WriteUInt(self:UnitIndex(), 8)
		net.Broadcast()
	end
	
end

function UNIT:SetEmpire( emp )
	
	local oldEmpire = self:GetEmpire()
	if( oldEmpire and oldEmpire.units ) then
		oldEmpire.units[ self:UnitIndex() ] = nil
	end
	
	if( emp and emp.units ) then
		emp.units[ self:UnitIndex() ] = self
	end
	
	self.e_Empire = emp
	
end

function UNIT:IsValid()
	return self:IsAlive()
end

function UNIT:IsAlive()
	return self:GetAlive()
end

function UNIT:Remove( info )
	self:Select(false)
	self:OnRemove( info )
	
	if ( CLIENT and IsValid(self.Entity) ) then
		self.Entity.NoDraw = true
		SafeRemoveEntity(self.Entity)
	end
	
	if ( SERVER ) then
		if( IsValid( self.Hull ) ) then
			SafeRemoveEntity( self.Hull )
		end
		
		-- if( IsValid( self.View ) ) then
			-- SafeRemoveEntity( self.View )
		-- end
		
		if( IsValid( self.NWEnt ) ) then
			SafeRemoveEntity( self.NWEnt )
		end
		
		BroadcastCommand( nil, "~_cl.unit.Remove", self:UnitIndex(), string.char( info ) )
		
		-- net.Start("unit.Remove")
			-- Short
			-- net.WriteLong( self:UnitIndex() )
			-- Char
			-- net.WriteByte( info )
		-- umsg.End()
	end
	
	hook.Call( "OnUnitRemoved", unit, self )
end

function UNIT:OnRemove( info ) end