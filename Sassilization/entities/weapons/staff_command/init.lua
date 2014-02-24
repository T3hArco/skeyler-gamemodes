--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:PrimaryAttack()
	
	if( not self.Owner:KeyDown(IN_RELOAD) ) then return end
	
	self:SetNextPrimaryFire(CurTime() + 0.2)
	
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() +0.2)
	
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	
	if( self.Owner:KeyDown(IN_RELOAD) ) then return end
	
	local Emp = self.Owner:GetEmpire()
	
	if( not ValidEmpire( Emp ) ) then return end
	if( Emp:NumSelectedUnits() < 1 ) then return end
	
	local trace = {}
	trace.start 	= self.Owner:EyePos()
	trace.endpos 	= self.Owner:EyePos() +self.Owner:GetAimVector() *2048
	trace.mask 		= self.Owner:KeyDown(IN_WALK) and MASK_SOLID or MASK_SOLID_BRUSHONLY
	trace.filter 	= player.GetAll()
	
	trace = util.TraceLine(trace)
	
	if (not trace.Hit or trace.HitSky) then return end
	
	local CommandPos = trace.HitPos
	
	if (IsValid(trace.Entity)) then
		CommandPos = trace.Entity:GetPos()
	end
	
	Emp:CommandUnits(CommandPos, self.Owner:KeyDown( IN_WALK ), self.Owner:KeyDown( IN_SPEED ))
end

concommand.Add( "sa_sell", function( pl, cmd, args )

	
	local e = pl:GetEmpire()
	if( not ValidEmpire( e ) ) then return end
	
	local ent = Entity( args[1] )
	if( not IsValid( ent ) ) then return end
	if( not ValidBuilding( ent ) ) then return end
	if( not ent:IsBuilt() ) then return end
	if( ent:GetEmpire() ~= e ) then return end
	if(ent.DamageSell) then return end
	
	local Type = ent:GetType()
	
	local Table = building.GetBuilding(Type)
	
	if(Table) then
		if(Table.NoSpawn) then
			return
		end
		
		e:AddFood(((Table.Food / 2) * (ent:GetHealth() / ent:GetMaxCHealth())))
		e:AddIron(((Table.Iron / 2) * (ent:GetHealth() / ent:GetMaxCHealth())))
	end
	
	if(Type == "walltower") then
		for k,v in pairs(ent.ConnectedGates) do
			if v:IsValid() then
				SellGate(v, e, false)
			end
		end
		local Sold = ent:SellConnectedWalls()
		if(Sold > 0) then
			e:AddFood( Sold * (Table.Food / 2))
			e:AddIron( Sold * (Table.Iron / 2))
		end
	elseif Type == "gate" then
		SellGate(ent, e, true)
	end
	
	ent:Destroy( building.BUILDING_SELL )
	
end )

function SellGate(ent, emp, byItself)
	if !byItself then
		local Table = building.GetBuilding(ent:GetType())
	
		if(Table) then
			if(Table.NoSpawn) then
				return
			end
			
			emp:AddFood(((Table.Food / 2) * (ent:GetHealth() / ent:GetMaxCHealth())))
			emp:AddIron(((Table.Iron / 2) * (ent:GetHealth() / ent:GetMaxCHealth())))
		end
	end

	ent:SellConnected()
	local vecPos = ent:GetPos()
	local closest = nil
	for _, w in pairs(ents.FindByClass("building_wall")) do
    	if w:GetEmpire() == emp then
	    	if closest == nil then
	    		closest = w
	    	end
	    	if closest:GetPos():Distance(vecPos) > w:GetPos():Distance(vecPos) then
	    		closest = w
	    	end
	    end
    end
    if closest != nil then
    	for k,v in pairs(ent.HiddenWalls) do
    		v.gate = nil
    	end
    	closest:UnHideWalls(ent.HiddenWalls)
    end
    
end

concommand.Add( "sa_sellunits", function( pl, cmd, args )
	local e = pl:GetEmpire()
	if( not ValidEmpire( e ) ) then return end
	
	for _, a in pairs( args ) do
		local u = Unit:Unit( tonumber( a ) )
		
		if( Unit:ValidUnit( u ) and u:IsAlive() and u:GetEmpire() == e ) then
			e:AddFood((u.Food * 0.5) * (u:GetHealth() / u:GetMaxHealth()))
			e:AddIron((u.Iron * 0.5) * (u:GetHealth() / u:GetMaxHealth()))

			u:Kill( UNIT_SELL )
		end
	end
end )

function SWEP:Think()
end