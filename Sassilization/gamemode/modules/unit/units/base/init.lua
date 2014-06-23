----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

AccessorFunc( UNIT, "cmd_command", "Command" )
AccessorFunc( UNIT, "next_attack", "NextAttack", FORCE_NUMBER )
AccessorFunc( UNIT, "next_move", "NextMove", FORCE_NUMBER )
AccessorFunc( UNIT, "v_Dir", "Dir" )

UNIT.v_Dir = Vector(1,0,0)
UNIT.next_attack = 0
UNIT.next_move = 0

function UNIT:Init()
	self:SetNextThink(CurTime() +0.25)
	
	self.Hull = ents.Create( "unit_hull" )
	self.Hull.Size = self.Size
	self.Hull.Speed = self.Speed
	self.Hull.TurnSpeed = self.TurnSpeed
	self.Hull:SetUnit( self )
	
	self.NWEnt = ents.Create( "unit_nw_entity" )
	self.NWEnt:SetUnit( self )
	
	self.View = {}
	self.NextViewUpdate = 0

	self.CommandQueue = SA.NewCommandQueue()
	
	self:SetHealth(self.HP)
	self:SetMaxHealth(self.HP)
end

function UNIT:Initialize()
	self.Entity:SetModel( self.Model )
end

function UNIT:GetCommandQueue()
	
	return self.CommandQueue
	
end

function UNIT:PopCommand()

	self:GetCommandQueue():Pop()
	
end

function UNIT:AddCommand( Cmd )
	
	if( !Cmd ) then return end
	
	return self:GetCommandQueue():Add( Cmd )
	
end

function UNIT:PushCommand( Cmd )
	if( !Cmd ) then return end
	
	if( self:GetCommandQueue():Push( Cmd ) ) then
		self:SetCommand( Cmd )
		Cmd:Start( self )
		return true
	end
	
end

function UNIT:ClearCommands()
	
	self:GetCommandQueue():Clear()
	self:SetCommand( nil )
	
end

function UNIT:SetControl( Empire )
	if (Empire == nil) then return end
	
	if( self:GetEmpire() ) then
		self:OnLostControl()
	end
	
	self:SetColor( Empire:GetColor() )
	self:SetEmpire( Empire )
	
	Empire:AddSupplied(self.Supply or 1)
	
end

function UNIT:OnLostControl()
	
	self:GetEmpire():AddSupplied(-self.Supply or -1)
	
end

function UNIT:StartNextCommand()
	
	if( self:GetCommand() ) then return end
	
	local next_cmd = self:GetCommandQueue():GetHead()
	if( next_cmd ) then
		Msg( "Starting next command: ", next_cmd, "\n" )
		self:SetCommand( next_cmd )
		next_cmd:Start( self )
	end
	
end

local MoveInertia = Vector( 1, 1, 1 )
local AttackInertia = Vector( 1000, 1000, 1000 )
local Groundtrace = {}
	Groundtrace.mask = MASK_SOLID_BRUSHONLY
local Groundtrace2 = {}
	Groundtrace2.mask = MASK_SOLID_BRUSHONLY
local GroundtraceRes
local HullDirVector = Vector(0)
local rotationAng = Angle( 0, 90, 0 )

function UNIT:HullPhysicsSimulate( hull, phys )
	
	self.deltatime = self.lastphysicsupdate and CurTime() - self.lastphysicsupdate or 0
	self.lastphysicsupdate = CurTime()
	
	local curr_vel = phys:GetVelocity()
	local speed = hull.Speed
	
	local cmd = self:GetCommand()
	
	if( cmd ) then
		
		if( cmd.pos and self:CanMove() ) then
			
			self.targetPosition = cmd.pos
			
			local disp = cmd.pos - hull:GetPos()
			HullDirVector.x = disp.x
			HullDirVector.y = disp.y
			HullDirVector.z = 0
			
			local dis = HullDirVector:Length()
			
			if( dis < 5 ) then
				speed = speed * dis / 5
			end
			
			if( cmd.move and HullDirVector:Length() < (2 * cmd:CountUnitsAtDestination() + 0.5)  ) then
				
				cmd:Finish( self )
				
			end
			
			-- phys:EnableMotion( true )
			HullDirVector:Normalize()
			self.v_Dir.x = HullDirVector.x
			self.v_Dir.y = HullDirVector.y
			self.v_Dir.z = HullDirVector.z
		end
	end
	
	local vel
	
	if( hull:IsMoving() and self:CanMove() ) then --If CanAttack is false, then we are attacking and we shouldn't move
		
		--Apply direction
		vel = self:GetDir() * speed
		
	end
	
	if( vel and vel:Length() > 0.1 ) then
		vel.z = 0
		vel:Normalize()
		vel = vel * speed * 2
		
		local canGoUp = true
		--local hullZ = hull:GetPos().z
		local hullMins = math.abs(hull:OBBMins().z) -0.1
		
		--if (cmd) and (cmd.pos) then
		--	canGoUp = cmd.pos.z +hullMins > hullZ
		--end
		
		if (hull.Blasted or hull.Gravitated or hull.Paralyzed) then
			canGoUp = false
		end
		
		if (canGoUp) then
			-- Try to find a ramp. // Chewgum
			Groundtrace.start = phys:GetPos() -Vector(0, 0, hullMins +0.1)
			Groundtrace.endpos = Groundtrace.start +self:GetDir() *23
			GroundtraceRes = util.TraceLine(Groundtrace)

			-- Try to find a step/stairs. // Hateful
			Groundtrace2.start = phys:GetPos() -Vector(0, 0, hullMins +0.1) + self:GetDir() *8 + Vector(0,0,10)
			Groundtrace2.endpos = Groundtrace2.start - Vector(0,0,9)
			GroundtraceRes2 = util.TraceLine(Groundtrace2)
		else
			GroundtraceRes = nil
			GroundtraceRes2 = nil
		end

		-- Going up a ramp. // Chewgum
		if (GroundtraceRes and (GroundtraceRes.HitNormal.z > 0.8 and GroundtraceRes.HitNormal.z < 0.99)) then --and cmd and cmd.pos) then
			vel.z = 26

			--if (cmd.pos.z +hullMins < hullZ) then
			--	GroundtraceRes = nil
			--end
		elseif (GroundtraceRes2 and GroundtraceRes2.Fraction < 1 and GroundtraceRes2.Fraction > 0 and (GroundtraceRes2.HitNormal.z > 0.8 and GroundtraceRes2.HitNormal.z <= 1)) then
			--Going up a step // Hateful
			if self:GetClass() == "ballista" or self:GetClass() == "catapult" then
				--This seems a little weird in game to see the units jump up, could possibly just set their pos to the hitpos.
				vel.z = 100
			else
				vel.z = 85
			end
		else
			--Apply gravity 386.1
			vel.z = curr_vel.z - 200 * self.deltatime
		end



		-- phys:SetInertia( MoveInertia )
		phys:SetVelocityInstantaneous( vel )
		
	else
		if (curr_vel:Length() > 1) then
			Groundtrace.start = phys:GetPos()
			Groundtrace.endpos = Groundtrace.start - VECTOR_UP * self.Size * 1.01
			GroundtraceRes = util.TraceLine( Groundtrace )
			
			if (!GroundtraceRes.HitWorld) then
				phys:Wake()
				
				curr_vel.z = curr_vel.z - 200 * self.deltatime
				phys:SetVelocityInstantaneous( curr_vel )
			else
				if !self.Blasted then
					phys:Sleep() -- This fixes sliding but does not stop it from moving when others push it (which is perfect) // Chewgum
				end
				
				--	phys:SetInertia( AttackInertia )
				--curr_vel.z = curr_vel.z - 200 * self.deltatime
				--phys:SetVelocityInstantaneous( GroundtraceRes.HitNormal * math.min( curr_vel.z, -10 ) )
			end
		end
	end
	
	-- vel.z = 0
	-- self:SetForward( vel:Normalize() )
	-- debugoverlay.Line( self:GetPos(), self:GetPos() + self:GetForward() * 10 )
	-- self:SetRight( vel:Rotate( rotationAng ) )
	
end

function UNIT:Think()
	
	if( not self:IsAlive() ) then return end
	
	self:SetNextThink(CurTime()+0.1)
	
	self:StartNextCommand()

	if !self.Blasted then
	
		local cmd = self:GetCommand()
		
		--print(cmd)
		
		-- Doing this in the command instead. // Chewgum
		--if( self:CanAttack() ) then
		--	self.Enemy = self:UpdateEnemy()
		--end
		
		if( cmd and cmd.pos ) then
			if( not self.lastMoveCheck or CurTime() > self.lastMoveCheck ) then
				self.lastMoveCheck = CurTime() + 5
				
				if( self.lastMoveCheckPos and (self.lastMoveCheckPos -self:GetPos()):LengthSqr() < 10 ) then
					cmd:Finish( self )
					return
				end
				
				self.lastMoveCheckPos = self:GetPos()
			end
		end
		
		if( cmd and cmd.Think ) then
			cmd:Think( self )
		end
		
		if !cmd then
			if( self:CanAttack() ) then
				self.Enemy = self:UpdateEnemy()
			end
		end

	end

end

function UNIT:CanAttack()
	
	return CurTime() > self:GetNextAttack()
	
end

function UNIT:CanMove()
	
	return CurTime() > self:GetNextMove()
	
end

function UNIT:LocalToWorld(pos)
	return self.Hull:LocalToWorld(pos)
end

function UNIT:UpdateEnemy()
	if( not self.View ) then return end
	
	local cmd = self:GetCommandQueue()
	
	cmd = cmd:GetHead()
	
	if( cmd ) then
		if( cmd.move and not cmd.attack ) then
			return
		elseif( cmd.target and cmd.noswitchingtarget  ) then
			if( IsValid( cmd.target ) and cmd.target:GetHealth() > 0 ) then
				if( self:IsTargetInRange( cmd.target ) ) then
					return cmd.target
				else
					cmd:Pursue( self )
					return
				end
			else
				cmd:Finish( self )
				return
			end
		end
	end
	
	if( self.Enemy and self:CanTarget( self.Enemy ) and self:IsTargetInRange( self.Enemy ) ) then
		self:PushCommand( SA.CreateCommand( COMMAND.ATTACK, self.Enemy ) )
		return self.Enemy
	end
	
	self:UpdateView()
	
	local target = self:GetPriorityEnemy()
	if( target ) then
		local inrange = self:IsTargetInRange( target )
		if( cmd ) then
			if( cmd.target ) then

				cmd.target = target
				if( inrange ) then
					return target
					
				elseif( IsValid( cmd.target ) and cmd.target:GetHealth() > 0 ) then
					cmd:Pursue( self )
					return
				else
					cmd:Finish( self )
					return
				end
			elseif( cmd.attack ) then
				if self:CanTarget(target) then
					self:PushCommand( SA.CreateCommand( COMMAND.ATTACK, target ) )
				end
			end
		else
			if self:CanTarget(target) then
				self:PushCommand( SA.CreateCommand( COMMAND.ATTACK, target ) )
			end
		end
	elseif( cmd and cmd.target ) then
		cmd:Pursue( self )
	end
	
end

function UNIT:UpdateView()
	
	if( CurTime() < self.NextViewUpdate ) then return end
	self.NextViewUpdate = CurTime() + 0.4
	
	self.View = {}
	for _, ent in pairs( ents.FindInSphere( self:GetPos(), self.SightRange * 2 ) ) do
		if( ent.Attackable and (ent:GetPos()-self:GetPos()):LengthSqr() < self.SightRangeSqr ) then

			if( ent.Unit ) then
				if( ent.Unit ~= self and ent.Unit:GetEmpire() ~= self:GetEmpire() and !Allied(self:GetEmpire(), ent.Unit:GetEmpire())) then
					table.insert( self.View, ent.Unit )
				end
			elseif( ent.Building and ent:GetEmpire() ~= self:GetEmpire() and !Allied(self:GetEmpire(), ent:GetEmpire())) then
				table.insert( self.View, ent )
			end
		end
	end
	
end

function UNIT:GetPriorityEnemy()
	local pos = self:GetPos()
	local min_dist, closest_target = self.SightRange
	for _, target in pairs( self.View ) do
		if( IsValid( target ) ) then
			local dist = target:NearestAttackPoint(pos):Distance( pos )
			if target.Unit then
				if( self:CanTarget( target ) and (dist - 1000) < (min_dist) )  then
					closest_target = target
					min_dist = dist - 1000
				end
			else
				if( self:CanTarget( target ) and dist < min_dist )  then
					closest_target = target
					min_dist = dist
				end
			end
		end
	end

	return closest_target
end

function UNIT:NearestAttackPoint( pos )
	
	return self:GetPos() + ( pos - self:GetPos() ):GetNormal() * self.Size * 0.5
	
end

local targetTrace = {}
	targetTrace.mask = MASK_SOLID_BRUSHONLY

function UNIT:CanTarget( target )
	
	if( not target ) then return false end
	
	if( target.Unit ) then
		target = target.Unit
	end

	if self:GetClass() == "archer" or self:GetClass() == "ballista" then

		--Only stop units from targetting this if there's a wall blocking it
		--This is kind of a shitty way to handle checking to see if there's a wall blocking vision
		--2 units is roughly the units head and where they can see to/from
		local box = ents.FindInBox( self:GetPos() + VECTOR_UP * 2 - (self.NWEnt:GetRight() * 0.1), target:GetPos() + VECTOR_UP * 1.9 + (self.NWEnt:GetRight() * 0.1) )
		if target:GetClass() != "building_wall" && target:GetClass() != "building_walltower" then
			for k,v in pairs(box) do
				if v:GetClass() == "building_wall" then
					if !v:GetNearestSegment(self:GetPos(), true).Destroyed && !v:GetNearestSegment(self:GetPos(), true).Hidden then
						return false
					end
				elseif v:GetClass() == "building_walltower" then
					return false
				end
			end
		end
		
	end

	
	if( Unit:ValidUnit( target ) and target:IsAlive() and !Allied(self:GetEmpire(), target:GetEmpire())) then
		if self:GetClass() != "archer" and self:GetClass() != "scallywag" and target:GetClass() == "scallywag" then
			return false
		else
			return true
		end
	elseif( ValidBuilding( target ) and !Allied(self:GetEmpire(), target:GetEmpire())) then
		return true
	end
	return false
	
end

function UNIT:IsTargetInRange( target )
	return (target:NearestAttackPoint(self:GetPos())-self:GetPos()):LengthSqr() < self.RangeSqr
end

function UNIT:Attack( enemy )
	
	if( not self:CanAttack() ) then return end
	if( not self:CanTarget( enemy ) ) then return end
	
	self:SetNextAttack( CurTime() + self.AttackDelay )
	self:SetNextMove( CurTime() + self.AttackMoveDelay )
	
	self.Hull:SetMoving( false )
	
	local dmginfo = {}
		dmginfo.damage = self.AttackDamage
		dmginfo.dmgtype = DMG_SLASH
		dmginfo.attacker = self
		
	if( enemy:IsWall() ) then
		dmginfo.dmgpos = enemy:GetNearestSegment( self:GetPos() ):GetRandomPosInOBB()
	elseif( enemy:IsBuilding() ) then
		dmginfo.dmgpos = enemy:GetRandomPosInOBB()
	elseif( enemy:IsUnit() ) then
		dmginfo.dmgpos = enemy:GetRandomPosInOBB()
	end
	
	local attackSound = self:GetAttackSound()
	if( attackSound ) then
		
		self.NWEnt:EmitSound( attackSound )
		
	end
	
	self:SetDir( (enemy:LocalToWorld( dmginfo.dmgpos ) - self:GetPos()):GetNormal() )
	
	local ed = EffectData()
		ed:SetOrigin( enemy:LocalToWorld(dmginfo.dmgpos) )
		ed:SetEntity( self.NWEnt )
	util.Effect( "unit_attack", ed, true, true )
	
	self:DoAttack( enemy, dmginfo )
	
	-- if( enemy:IsUnit() and not enemy:GetAlive() ) then
		-- self:GetCommand():Finish( self )
		-- self:UpdateEnemy()
	-- elseif( enemy:IsBuilding() and enemy.Destroyed ) then
		-- self:GetCommand():Finish( self )
		-- self:UpdateEnemy()
	-- end
	
end

function UNIT:DoAttack( enemy, dmginfo )
	enemy:Damage( dmginfo )
end

function UNIT:Damage( dmginfo )
	
	if( not self:GetAlive() ) then return end
	
	self:SetHealth( self:GetHealth() - dmginfo.damage )
	
	if( dmginfo.dmgtype == DMG_SLASH ) then
		self.NWEnt:EmitSound( SA.Sounds.GetUnitHitSound() )
	elseif( dmginfo.dmgtype == DMG_FALL ) then
		self.NWEnt:EmitSound( SA.Sounds.GetFallDamageSound() )
	elseif( dmginfo.dmgtype == DMG_BULLET ) then
		self.NWEnt:EmitSound( SA.Sounds.GetArrowHitFleshSound() )
	end
	
	if( self:GetHealth() <= 0 ) then
		
		self:Kill( UNIT_KILL )
		return
		
	end
	
	if( dmginfo.attacker ) then
		local cmd = self:GetCommand()
		if( not cmd ) then

			if self:CanTarget(dmginfo.attacker) then
			
				self:PushCommand( SA.CreateCommand( COMMAND.ATTACK, dmginfo.attacker ) )

			end
			
		elseif( cmd.attack ) then
			
			if( cmd.target ) then
				
				--is the attacker closer than our current target?
				if( cmd.target ~= dmginfo.attacker and self:IsTargetInRange( dmginfo.attacker ) ) then

					if self:CanTarget(dmginfo.attacker) then
					
						cmd.target = dmginfo.attacker

					end
					
				end
				
			else

				if self:CanTarget(dmginfo.attacker) then
				
					self:PushCommand( SA.CreateCommand( COMMAND.ATTACK, dmginfo.attacker ) )

				end
					
			end
			
		end
	end
	
end

util.AddNetworkString( "unit.Select" )
function UNIT:Select( bSelected )
	
	local wasSelected = self:GetSelected()
	self:SetSelected( bSelected )
	
	local emp = self:GetEmpire()
	emp:SelectUnit( self, bSelected )
	
	-- if( IsValid( emp:GetPlayer() ) ) then
		
		-- net.Start( "unit.Select", emp:GetPlayer() )
			-- Short
			-- net.WriteLong( self:UnitIndex() )
			-- Bool
			-- net.WriteByte( bSelected )
		-- net.Broadcast()
		
	-- end
	
	return not wasSelected
	
end

function UNIT:SetPos( v )
	
	self.v_Pos = v
	
	if( IsValid( self.Hull ) ) then
		
		self.Hull:SetPos( v )
		
	end
	
end

function UNIT:SetAngles( a )
	
	self.a_Angles = a
	
end

util.AddNetworkString( "unit.Spawn" )
function UNIT:Spawn()
	
	if( self:GetAlive() ) then return end
	
	self:SetAlive( true )
	
	self.Hull:SetPos( self:GetPos() )
	self.Hull:Spawn()
	self.Hull:Activate()
	
	self.NWEnt:SetPos( self.Hull:GetPos() )
	self.NWEnt.dt.Dir = math.deg( math.atan2( self:GetDir().y, self:GetDir().x ) )
	self.NWEnt:Spawn()
	self.NWEnt:Activate()
	
	self:SetHealth( self.HP )
	
	-- self.View:Spawn()
	-- self.View:Activate()
	
	hook.Call( "OnUnitSpawned", unit, self )
	
	-- net.Start( "unit.Spawn" )
		-- 2 Shorts
		-- net.WriteLong( self:GetEmpire():GetID() )
		-- net.WriteLong( self:UnitIndex() )
		-- net.WriteString( self:GetClass() )
		
	-- net.Broadcast()
	
	BroadcastCommand( nil, "~_cl.unit.Spawn", self:GetEmpire():GetID(), self:UnitIndex(), self:GetClass() )
end

function UNIT:Burn( time )
	timer.Create(tostring(self.NWEnt:EntIndex()), 1, time, function()
		local dmginfo = {}
			dmginfo.damage = 2
			dmginfo.dmgtype = DMG_BURN
		self:Damage( dmginfo )
		
		local effectdata = EffectData()
			effectdata:SetEntity( self.NWEnt )
			effectdata:SetScale( 0.5 )
			effectdata:SetMagnitude( 1 )
		util.Effect( "unit_burn", effectdata, 1, 1 )
	end)
end

function UNIT:Extinguish()
	if (timer.Exists(tostring(self.NWEnt:EntIndex()))) then
		timer.Remove(tostring(self.NWEnt:EntIndex()))
	end
end

function UNIT:GetCreedValue()
	return self.Creed
end

function UNIT:Kill( info )
	
	if( not self:IsAlive() ) then
		return
	end
	self:SetAlive( false )
	
	local Empire = self:GetEmpire()
	
	hook.Call( "OnKill", self, info, Empire, Attacker )
	
	if( ValidEmpire( Empire ) ) then
		Empire:AddSupplied(-self.Supply)
	end
	
	if(info == UNIT_KILL) then
		
		-- if(IsValid(Attacker)) then
			-- Attacker:AddGold( self.DestroyGold or 2 )
			-- --TODO: Player Bonus
			-- --ply.Bonus = ply.Bonus + (self.CData.DestroyBonus or 1)
		-- end
		if( deathSound ) then
			self.NWEnt:EmitSound( SA.Sounds.GetFleshUnitDeathSound() )
		end
		
	elseif(info == UNIT_SHRINED) then
		
		self.NWEnt:EmitSound( SA.Sounds.GetUnitSacrificeSound() )
		
	end
	
	self:Extinguish()
	self:Remove( info )
	--self:SetNoDraw(true)
	
	hook.Call( "OnKilled", self, info, Empire, Attacker )
	
end