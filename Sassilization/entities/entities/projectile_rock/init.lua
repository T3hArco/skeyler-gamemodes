AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	
	--the rock
	self:SetModel( "models/mrgiggles/sassilization/catapult_rock.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor( color_white )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion( true )
		phys:Wake()
		phys:ApplyForceCenter( self.LaunchDir * self.power * 1.32 )
	end
	local trail = util.SpriteTrail(self, 0, Color(255,255,255), true, 2, 0, 0.3, 1/(1+0)*0.5, "trails/tube.vmt")
	
	timer.Simple( 8, function() self:Raze() end )
	
	self.HitUnits = {}
	self.CanHit = true
	
end

function ENT:StartTouch( ent )
	if not self.CanHit then return end
	if not IsValid( ent ) then return end
	if !ent.Unit then
		if ent:GetEmpire() != self:GetEmpire() and ent:GetClass() != "farm" and ent:GetClass() != "iron_mine" then
			if not self.HitUnits[ent] then
				self.HitUnits[ent] = true
				ent:Damage( self.damage )
				ent:Damage( self.damage )
				self:EmitSound( "sassilization/units/building_hit0"..math.random( 1,3 )..".wav" )
				if ent:GetHealth() <= 50 and ent:GetHealth() > 30 then
					amt = 2
				elseif ent:GetHealth() <= 30 then
					amt = 3
				else
					amt = 1
				end
				for i = 1,amt do
					local effectdata = EffectData()
						effectdata:SetOrigin(self:GetPos() + VectorRand() * 4)
						effectdata:SetScale(math.random(1, 7))
						effectdata:SetMagnitude( GIB_STONE )
					util.Effect("gib_catarock", effectdata)
				end
				function self:StartTouch( ent ) return end
				function self:PhysicsCollide( data, phys ) return end
			end
		end
	else
		if ent.Unit:GetEmpire() != self:GetEmpire() then
			if not self.HitUnits[ent] then
				self.HitUnits[ent] = true
				ent.Unit:Kill(UNIT_KILL)
				function self:StartTouch( ent ) return end
				function self:PhysicsCollide( data, phys ) return end
			end
		end
	end
end

function ENT:PhysicsCollide( data, phys )
	if not self.CanHit then return end
	if self.Hit then return end
	local ent = data.HitEntity
	if data.Speed > 80 and IsValid( ent ) and !ent.Unit and ent:GetClass() != "farm" and ent:GetClass() != "iron_mine" then
		self.Hit = true
		if ent:GetEmpire() != self:GetEmpire() then
			ent:Damage( self.damage )
			self:EmitSound( "sassilization/units/building_hit0"..math.random( 1,3 )..".wav" )
			if ent:GetHealth() <= 50 and ent:GetHealth() > 30 then
				amt = 2
			elseif ent:GetHealth() <= 30 then
				amt = 3
			else
				amt = 1
			end
			for i = 1,amt do
				local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos() + VectorRand() * 4)
					effectdata:SetScale(math.random(1, 7))
					effectdata:SetMagnitude( GIB_STONE )
				util.Effect("gib_catarock", effectdata)
			end
			self.StartTouch = function()end
			self.PhysicsCollide = function()end
		end
	elseif data.Speed > 80 and IsValid( ent ) and ent:GetClass() != "farm" and ent:GetClass() != "iron_mine" then
		self.Hit = true
		if ent.Unit:GetEmpire() != self:GetEmpire() then
			ent.Unit:Kill(UNIT_KILL)
			self.StartTouch = function()end
			self.PhysicsCollide = function()end
		end
	end
end

function ENT:Raze()
	if self.Dead then return end
	self.Dead = true
	if self.Entity and self.Entity:IsValid() then
		local ent = self.Entity
		local function RemoveEntity( ent )
 				ent:Remove()
 		end
 		timer.Simple( 1, function() SafeRemoveEntity(self) end )
	 	ent:SetNotSolid( true )
	 	ent:SetNoDraw( true )
	end
end