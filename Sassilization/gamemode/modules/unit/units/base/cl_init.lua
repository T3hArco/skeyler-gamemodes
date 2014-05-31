----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

AccessorFunc( UNIT, "v_GroundPos", "GroundPos" )
AccessorFunc( UNIT, "v_GroundNorm", "GroundNormal" )

UNIT.v_GroundPos = Vector(0, 0, 0)
UNIT.v_GroundNorm = Vector(0,0,1)

local renderConvar = CreateClientConVar( "sass_buildingdistance", 640, true, true )

function UNIT:Init()
	self:SetNextThink(CurTime() +0.25)
	
	self.Entity = ClientsideModel( self.Model )
	self.Entity:SetColor( self:GetColor() )
	self.Entity:SetNoDraw( true )
	
	self.Entity.NoDraw = true
	
	self.Entity:SetPos( self:GetPos() )
	self.Entity:SetAngles( self:GetAngles() )
	self.Entity:SetNoDraw( true )
	
	self.Entity.NextAnim = 0
	self.Anim = "idle"
	
	self:SetGroundPos( self:GetPos() )
	self:Initialize()

	self.a_DirAng = Angle(0, 0, 0)
	self.f_Yaw = 0
	self.b_ShouldDraw = false
	self.Selected = false
	
	self:SetHealth(self.HP)
	self:SetMaxHealth(self.HP)
end

function UNIT:ShouldDraw()
	return self.b_ShouldDraw
end

function UNIT:SetNetworked()
	self.Networked = true
end

function UNIT:IsNetworked()
	return self.Networked
end

function UNIT:SetHullPos( pos )
	self.v_HullPos = pos
end

function UNIT:GetHullPos()
	return self.v_HullPos
end

function UNIT:SetYaw( yaw )
	self.a_DirAng.y = yaw
end

function UNIT:GetYaw()
	return self.a_DirAng.y
end

function UNIT:GetDirAng()
	return self.a_DirAng
end

function UNIT:GetEntity()
	return self.Entity
end

function UNIT:GetSequence()
	return self.Entity:LookupSequence(self.Anim)
end

function UNIT:Initialize() end

function UNIT:SetControl( Empire )
	
	self:SetColor( Empire:GetColor() )
	self:SetEmpire( Empire )
	
end

function UNIT:SetAngles( ang )
	
	self.a_DirAng = ang
	
	if( self.Entity ) then
		self.Entity:SetAngles( ang )
	end
	
	self:SetUp( ang:Up() )
	self:SetRight( ang:Right() )
	self:SetForward( ang:Forward() )
end

function UNIT:SetPos( pos )
	
	self.v_Pos = pos
	
	if( IsValid(self.Entity) ) then
		self.Entity:SetPos( pos )
	end
	
end

function UNIT:Think()
	if(not IsValid(self.Entity)) then return end
	
	local tr = util.TraceLine{
		start = self:GetPos(),
		endpos = self:GetPos() + VECTOR_UP * -100,
		mask = bit.bor(MASK_SOLID_BRUSHONLY, MASK_WATER)
	}
	
	if( tr.HitWorld ) then
		self:SetGroundPos( tr.HitPos )
		self:SetGroundNormal( tr.HitNormal )
		
		self.Jumping = false
	else
		if (self.CanJump) then
			self.Jumping = true
		end
		
		self:SetGroundPos( tr.StartPos )
		self:SetGroundNormal( VECTOR_UP )
	end
end

function UNIT:OnHull()
	
	self:SetPos( self:GetHullPos() - self.RenderOrigin )
	
	if( IsValid( self.Entity ) ) then
		self.Entity.NoDraw = false
	end
	
end

function UNIT:GetMoveAnim()
	
	return "run"
	
end

function UNIT:Attack( dir )
	
	if( not self:IsAlive() or self.Jumping ) then return end
	
	self.Entity:SetAngles( Angle( 0, dir, 0 ) )
	self.Anim = self:GetAttackAnim()
	if self:GetClass() == "catapult" or self:GetClass() == "ballista" then
		self.Anim2 = self:GetReloadAnim()
	end
	
	local Sequence = self.Entity:LookupSequence(self.Anim)
	
	if(Sequence >= 0) then
		self.Entity.Anim = self.Anim
		self.Entity:SetCycle(0)
		self.Entity:SetSequence(Sequence)
	end
	if self.Anim2 then
		self.AnimSpeed = self.AttackMoveDelay/2
	else
		self.AnimSpeed = self.AttackMoveDelay
	end

	
	self.Entity:SetPlaybackRate( self.Entity:SequenceDuration() / self.AnimSpeed )
	self.Entity.NextAnim = RealTime() + self.AnimSpeed

	if self.Anim2 then

		local Sequence2 = self.Entity:LookupSequence(self.Anim2)

		if(Sequence2 >= 0) then
			self.Entity.Anim = self.Anim2
			self.Entity:SetCycle(0)
			self.Entity:SetSequence(Sequence2)
		end
		
		self.Entity:SetPlaybackRate( self.Entity:SequenceDuration() / self.AnimSpeed )
		self.Entity.NextAnim = RealTime() + self.AnimSpeed
	end
	
end

-- net.Receive( "unit.Select", function( len )
	
	-- local uid = net.ReadUInt(8)
	-- local bSelected = net.ReadByte()
	-- local unit = Unit( uid )
	
	-- if( Unit:ValidUnit( unit ) ) then
		-- unit:Select( bSelected )
	-- end
	
-- end )

function UNIT:Select( bSelected )
	self:SetSelected( bSelected )
	
	local Empire = self:GetEmpire()
	
	if( ValidEmpire( Empire ) ) then
		Empire:SelectUnit( self, bSelected )
	end
end

local PreviewCircle = Material("sassilization/dashed_circle")
local UnitCircle = Material("sassilization/circle")
local UnitSelected = Material("sassilization/indicator")
local color_yellow = Color( 255, 255, 60, 255 )

--Draws a dashed, yellow, spinning, pulsating circle around the unit
function UNIT:DrawPreviewCircle( pos, time, offset )
	
	local size = self.PreviewSelectedSize * 1.2 - math.abs( offset * self.PreviewSelectedSize * 0.02 )
	render.SetMaterial(PreviewCircle)
	render.DrawQuadEasy( pos + VECTOR_UP * 0.1, self:GetGroundNormal(), size, size, color_yellow, time * 10  )
	
end

-- Draw a circle around the unit
function UNIT:DrawSelectedCircle( pos )
	render.SetMaterial(UnitSelected)
	--render.SetMaterial(UnitCircle)
	render.DrawQuadEasy(pos + VECTOR_UP * 0.1, self:GetGroundNormal(), self.SelectedSize, self.SelectedSize, color_white, 0)
end

-- Draws a team-colored circle under the unit
function UNIT:DrawCircle()
	local percent = (self:GetHealth() /self:GetMaxHealth())
	local color = self:GetColor()
	
	color = Color(color.r -(color.r *percent *0.5), color.g -(color.g *percent *0.5), color.b -(color.b *percent *0.5 ), 255)
	
	render.SetMaterial(UnitCircle)
	render.DrawQuadEasy(self:GetGroundPos() + VECTOR_UP * 0.1, self:GetGroundNormal(), self.Size, self.Size, color)
end

function UNIT:Draw()
	if( self.Entity.NoDraw ) then return end
	
	--TODO: Make this an option
	if( (EyePos()-self:GetPos()):LengthSqr() > renderConvar:GetFloat()*1000 ) then
		return
	end
	
	local c = self:GetColor()
	render.SetColorModulation( c.r / 255, c.g / 255, c.b / 255, 255 )
		self.Entity:DrawModel()
	render.SetColorModulation( 1, 1, 1 )
	
end

function UNIT:PostDraw()
end

local nextunitlostspeech = CurTime()

function UNIT:OnRemove( info )
	if( info == UNIT_KILL ) then
		if( self:GetEmpire() == LocalEmpire() and CurTime() > nextunitlostspeech ) then
			nextunitlostspeech = CurTime() + 0.3
			surface.PlaySound( "sassilization/units/unitLost.wav" )
		end
		
		local ed = EffectData()
			ed:SetOrigin(self:GetPos())
			ed:SetNormal(self:GetUp())
		util.Effect("gib_explosion", ed)
	elseif( info == UNIT_SELL ) then
		local ed = EffectData()
			EFFECT_ENT = self.Entity
		util.Effect("burrow", ed, true)
	end
end