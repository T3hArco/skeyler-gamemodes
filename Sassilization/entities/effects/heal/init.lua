local matLight = Material( "models/shiny" )
local matRefract = Material( "models/spawn_effect" )

function EFFECT:Init( data )
	local ent = Unit:Unit(data:GetScale())

	if ( ent == NULL ) then return end
	
	self.Time = data:GetMagnitude()

	self.LifeTime = CurTime() + self.Time
	self.ParentEntity = ent

	ent.paralyzed = nil
	ent.effecttime = self.Time
	ent.healing = self.LifeTime
	
	self:SetModel(ent:GetModel())
	self:SetPos(ent:GetPos())
	self:SetAngles(ent:GetAngles())
	self:SetParent(ent:GetEntity())
	self:SetMaterial(matLight)
	
	local sequence = ent:GetSequence()
	
	if sequence then self:ResetSequence( sequence ) end
end

function EFFECT:Think()
	if not IsValid( self.ParentEntity ) then
		return false
	elseif (self.ParentEntity.paralyzed) then
		self.ParentEntity.healing = nil
		return false
	elseif CurTime() > self.LifeTime then
		self.ParentEntity.healing = nil
		return false
	end
	
	local sequence = self.ParentEntity:GetSequence()
	
	if self:GetSequence() ~= sequence then
		self:ResetSequence( sequence )
	end
	
	return true
end

function EFFECT:Render()
	if self.ParentEntity == NULL then return end
	if self == NULL then return end
	
	local Fraction = (self.LifeTime - CurTime()) / self.Time
	Fraction = math.Clamp( Fraction, 0, 1 )
	
	self:SetColor( Color( 95, 250, 240, 1 + math.sin( Fraction * math.pi ) * 100 ) )
	
	local EyeNormal = self:GetPos() -EyePos()
	local Distance = EyeNormal:Length()
	EyeNormal:Normalize()
	
	local Pos = EyePos() + EyeNormal * Distance * 0.01
	
	cam.Start3D(Pos, EyeAngles())
		render.MaterialOverride( matLight )
			self:DrawModel()
		render.MaterialOverride( 0 )
		
		-- If our card is DX8 or above draw the refraction effect
		if ( render.GetDXLevel() >= 80 ) then
			
			-- Update the refraction texture with whatever is drawn right now
			render.UpdateRefractTexture()
			
			matRefract:SetFloat( "$refractamount", Fraction ^ 2 * 0.05 )
			
			render.MaterialOverride( matRefract )
				self:DrawModel()
			render.MaterialOverride( 0 )
			
		end
	cam.End3D()
end