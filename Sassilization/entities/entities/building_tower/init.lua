--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------
AddCSLuaFile("shared.lua")
include("shared.lua")

util.PrecacheSound("sassilization/units/arrowfire01.wav")
util.PrecacheSound("sassilization/units/arrowfire02.wav")

AccessorFunc( ENT, "next_attack", "NextAttack" )

function ENT:Initialize()
	self:SetLevel(1)
	self:Setup("tower", false)
	
	self.View = {}
	
	self.next_attack = 0
	
	self.Gib = GIB_WOOD
	self.NextCheck = CurTime() + 1
	
	local VECTOR_TOWERTOP = Vector(0, 0, 26)
	self.UpPos = self:GetPos() + VECTOR_TOWERTOP
end


function ENT:OnDestroy(Info, Empire, Attacker)
	if(Empire) then
		if(Info ~= building.BUILDING_SELL) then
			if self.level == 1 then
				self:SpawnUnits("archer", 1)
			elseif self.level == 2 then
				self:SpawnUnits("archer", math.random(1, 2))
			else
				self:SpawnUnits("archer", 2)
			end
		end
	end
	self:UpdateControl()
end

function ENT:OnLevel(Level)
	if(Level > 1) then
		self.Gib = GIB_ALL
	end
	self.level = Level
	
	self.AttackSpeed = building.GetBuildingKey("tower", "AttackSpeed")[Level]
	self.AttackRange = building.GetBuildingKey("tower", "AttackRange")[Level]
	self.AttackDamage = building.GetBuildingKey("tower", "AttackDamage")[Level]	
end

function ENT:CanAttack()
	
	if( not self:IsBuilt() ) then return end
	
	return CurTime() > self:GetNextAttack()
	
end

local targetTrace = {}
targetTrace.mask = MASK_SOLID_BRUSHONLY
local targetTraceRes

function ENT:UpdateView()
	
	self.View = {}
	
	for _, ent in pairs( ents.FindInSphere( self:GetPos(), self.AttackRange ) ) do
		if( ent.Attackable ) then
			targetTrace.start = self.UpPos
			targetTrace.endpos = ent:GetPos()
			targetTraceRes = util.TraceLine(targetTrace)

			--Only allow targetting this unit if it's actually visible through a direct line of sight
			if targetTraceRes.Fraction == 1 then
				if( ent.Unit ) then
					if( ent.Unit:GetEmpire() ~= self:GetEmpire() and !Allied(self:GetEmpire(), ent.Unit:GetEmpire())) then
						table.insert( self.View, ent.Unit )
					end
				elseif( ent.Building and ent:GetEmpire() ~= self:GetEmpire() and !Allied(self:GetEmpire(), ent:GetEmpire())) then
					table.insert( self.View, ent )
				end
			end
		end
	end
end

function ENT:GetPriorityEnemy()
	local pos = self:GetPos()
	
	local min_dist, closest_target = self.AttackRange
	
	for _, target in pairs(self.View) do
		if(IsValid(target)) then
			local dist = target:NearestAttackPoint(pos):Distance(pos)
			if(dist < min_dist) then
				closest_target = target
				min_dist = dist
			end
		end
	end
	
	return closest_target
end

function ENT:OnThink()
	
	if( not self:CanAttack() ) then return end
	
	self:UpdateView()
	
	local target = self:GetPriorityEnemy()
	if(target) then
		self.Enemy = target
	else
		self.Enemy = nil
	end
	
	if(self.Enemy) then
		if(Unit:ValidUnit(self.Enemy) or ValidBuilding(self.Enemy)) then
			self:ShootArrow(self.Enemy)
		else
			self.Enemy = nil
		end
	end
	
	return self.AttackSpeed * 0.9
end

local arrowspeed = 120
function ENT:ShootArrow( target )
	
	self:SetNextAttack( CurTime() + self.AttackSpeed )
	
	local attackPoint = target:NearestAttackPoint( self.UpPos )
	local arrowTime = attackPoint:Distance( self.UpPos ) / arrowspeed
	local targetEnt = target.NWEnt and target.NWEnt or target
	
	local dmginfo = {}
		dmginfo.damage = self.AttackDamage
		dmginfo.dmgtype = DMG_BULLET
		dmginfo.dmgpos = targetEnt:WorldToLocal(attackPoint)
		dmginfo.attacker = self
	
	self:EmitSound( SA.Sounds.GetArrowFireSound() )

	local ed = EffectData()
		ed:SetOrigin( self.UpPos )
		ed:SetScale( CurTime() + arrowTime )
		ed:SetEntity( targetEnt )
		ed:SetStart( dmginfo.dmgpos )
	util.Effect( "arrow", ed, true, true )
	
	timer.Simple( arrowTime, function()
		if( IsValid( target ) ) then
			target:Damage( dmginfo )
		end
	end )
	
end