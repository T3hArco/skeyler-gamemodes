----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local arrowspeed = 60
function UNIT:DoAttack( enemy, dmginfo )
	
	dmginfo.dmgtype = DMG_BULLET
	
	local arrowTime = enemy:LocalToWorld(dmginfo.dmgpos):Distance( self:GetPos() ) / arrowspeed
	
	local ed = EffectData()
		ed:SetOrigin( self:GetPos() + VECTOR_UP * 1.8 )
		ed:SetScale( CurTime() + arrowTime )
		ed:SetEntity( enemy.NWEnt and enemy.NWEnt or enemy )
		ed:SetStart( dmginfo.dmgpos )
	util.Effect( "arrow", ed, true, true )
	
	timer.Simple( arrowTime, function()
		if( IsValid( enemy ) ) then
			enemy:Damage( dmginfo )
		end
	end )
	
end

local MoveInertia = Vector( 1, 1, 1 )
local AttackInertia = Vector( 1000, 1000, 1000 )
local Groundtrace = {}
	Groundtrace.mask = MASK_SOLID_BRUSHONLY
local GroundtraceRes
local Groundtrace2 = {}
	Groundtrace2.mask = MASK_WATER
local GroundtraceRes2
local HullDirVector = Vector(0)
local trace = {}
local tr

function UNIT:HullPhysicsSimulate( hull, phys )
	
	self.deltatime = self.lastphysicsupdate and CurTime() - self.lastphysicsupdate or 0
	self.lastphysicsupdate = CurTime()
	
	local curr_vel = phys:GetVelocity()
	local speed = hull.Speed
	
	local cmd = self:GetCommand()
	local vel = self:AvoidOtherScallies()

	if( cmd ) then
		trace.start = self:GetPos()
		trace.endpos = trace.start + VECTOR_UP * -100 + self:GetDir() * 20
		trace.mask = bit.bor(MASK_SOLID_BRUSHONLY, MASK_WATER)
		tr = util.TraceLine(trace)
		
		if( tr.HitWorld ) then
			--Float 50 above ground
			curr_vel.z = math.min( vel.z + (70 -tr.Fraction *100), 50 )
		else
			--This check keeps Scallywags from floating down after killing their target.
			if !cmd.Attack then
				--Float down
				curr_vel.z = math.max( curr_vel.z - 50 * self.deltatime, -30 )
			end
		end
		
		if( cmd.pos ) then
			
			local disp = cmd.pos - hull:GetPos()
			HullDirVector.x = disp.x
			HullDirVector.y = disp.y
			HullDirVector.z = 0
			
			local dis = HullDirVector:Length2D()
			if( dis < 5 ) then
				speed = speed * dis / 10
			end
			
			if( cmd.move and HullDirVector:Length2D() < (20 * cmd:CountUnitsAtDestination() + 0.5)  ) then
				
				cmd:Finish( self )
				
			end
			
			-- phys:EnableMotion( true )
			HullDirVector:Normalize()
			self.v_Dir.x = HullDirVector.x
			self.v_Dir.y = HullDirVector.y
			self.v_Dir.z = HullDirVector.z
			
		end
		
	end
	
	if( self:CanMove() ) then
		
		--Apply direction
		vel = vel + self:GetDir() * speed
		
	end
	
	local velLen = vel:Length()
	if( cmd ) then

		if cmd.target && self:GetPos():Distance(cmd.target:GetPos()) <= self.SightRange then

			if self.lastPush && self.lastPush < CurTime() - 2 then
				self.lastPush = CurTime()
				vel2 = ((cmd.target:GetPos() + Vector(0,0,50)) - self:GetPos()):GetNormal() * 62.5
			else
				if !self.lastPush then
					self.lastPush = CurTime()
					vel2 = ((cmd.target:GetPos() + Vector(0,0,50)) - self:GetPos()):GetNormal() * 62.5
				end
			end

			vel.z = 0
			vel:Normalize()
			vel = vel * math.min( velLen, speed )
			vel.z = curr_vel.z
			
			-- phys:SetInertia( MoveInertia )
			phys:SetVelocityInstantaneous( vel + Vector(vel2.x, vel2.y, 0) )

		else
			
			vel.z = 0
			vel:Normalize()
			vel = vel * math.min( velLen, speed )
			vel.z = curr_vel.z
			
			-- phys:SetInertia( MoveInertia )
			phys:SetVelocityInstantaneous( vel )

		end
		
	else
		
		--Recheck for if there's an enemy in the area, this way the unit doen't fall down for a few ticks before floating back up because there's still enemies in the area.
		self.Enemy = self:UpdateEnemy()

		local cmd = self:GetCommand()

		if !cmd then

			Groundtrace.start = phys:GetPos()
			Groundtrace.endpos = Groundtrace.start - VECTOR_UP * self.Size * 1.01
			GroundtraceRes = util.TraceLine( Groundtrace )

			Groundtrace2.start = phys:GetPos()
			Groundtrace2.endpos = Groundtrace2.start + VECTOR_UP * -100 + self:GetDir() * 20
			GroundtraceRes2 = util.TraceLine( Groundtrace2 )
			
			if( not GroundtraceRes.HitWorld and not GroundtraceRes2.Hit ) then
				phys:SetVelocityInstantaneous( VECTOR_UP * -10 )
			elseif GroundtraceRes2.Hit then
				--Float 50 above the water
				local vel = self:AvoidOtherScallies()
				curr_vel.z = math.min( vel.z + (70 -GroundtraceRes2.Fraction *100), 50 )
				vel = vel
				vel.z = curr_vel.z
				phys:SetVelocityInstantaneous(vel)
			else
				phys:SetInertia( AttackInertia )
				phys:SetVelocityInstantaneous( GroundtraceRes.HitNormal * -10 )
				phys:Sleep()
			end

		end
		
	end
	
end

function UNIT:AvoidOtherScallies()
	
	local scallyCount = 0
	local vel = Vector(0)
	local pos, epos = self:GetPos()
	for _, ent in pairs( ents.FindInSphere( pos, 22 ) ) do
		if( Unit:ValidUnit( ent.Unit ) and ent ~= self.Hull and ent.Unit.AvoidOtherScallies ) then
			local push_vel = (pos-ent:GetPos())
			vel = vel + math.max(20-push_vel:Length(),0) * push_vel:GetNormal()
			scallyCount = scallyCount + 1
		end
	end
	if( scallyCount > 0 ) then
		vel = vel / (scallyCount * 0.2)
	end
	
	return vel
	
end

function UNIT:Think()

	self.BaseClass.Think( self )
	
end

function UNIT:OnKill( info, Empire, Attacker )
	
	if( info == UNIT_KILL ) then
		
		local archer = GAMEMODE:SpawnUnit("archer", self:GetPos(), self:GetAngles(), Empire)
		if( self:GetSelected() ) then
			archer:Select( true )
			BroadcastCommand( {Empire:GetPlayer()}, "~_cl.unit.Select", archer:UnitIndex(), 1 )
		end
		
		local ed = EffectData()
			ed:SetOrigin( self:GetPos() + VECTOR_UP * 10 )
			local r, g, b = self:GetColor()
			ed:SetStart( Vector( r, g, b ) )
		util.Effect( "balloon_pop", ed, true, true )
		
	end
	
end