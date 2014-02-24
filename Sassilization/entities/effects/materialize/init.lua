local matLight = Material( "models/shiny" )
local matRefract = Material( "models/spawn_effect" )

function EFFECT:Init(data)

	self.Time = 1.5 
	self.LifeTime = CurTime() + self.Time 
	 
	local ent = data:GetEntity()
	if ( not IsValid( ent ) ) then
		self.clear = true
		return
	end
	
	self.ParentEntity = ent
	self:SetModel( ent:GetModel() )
	self:SetPos( ent:GetPos() )
	self:SetAngles( ent:GetAngles() )
	self:SetParent( ent )
	local sequence = self:LookupSequence( "idle" )
	if sequence then self:ResetSequence( sequence ) end
	 
end

function EFFECT:Think()
	
	if (self.clear) then return false end
	
	if (not IsValid(self.ParentEntity)) then return false end 
	
	return (self.LifeTime > CurTime())
	
end

function EFFECT:Render()
	
	if (not IsValid(self.ParentEntity)) then return end
	if (not IsValid(self.Entity)) then return end
	
	local Fraction = (self.LifeTime - CurTime()) / self.Time
	Fraction = math.Clamp( Fraction, 0, 1 )
	
	self.Entity:SetColor( Color( 55, 255, 255, 1 + math.sin( Fraction * math.pi ) * 100 ) )
	
	local EyeNormal = self.Entity:GetPos() - EyePos()
	local Distance = EyeNormal:Length()
	EyeNormal:Normalize()
	
	local Pos = EyePos() + EyeNormal * Distance * 0.01
	
	cam.Start3D( Pos, EyeAngles() )
		
		render.MaterialOverride( matLight )
			self:DrawModel()
		render.MaterialOverride( 0 )
		
		-- If our card is DX8 or above draw the refraction effect
		if ( render.GetDXLevel() >= 80 ) then
			
			-- Update the refraction texture with whatever is drawn right now
			render.UpdateRefractTexture()
			
			matRefract:SetFloat( "$refractamount", Fraction ^ 2 * 0.05 )
			
			render.MaterialOverride( matRefract )
				self.Entity:DrawModel()
			render.MaterialOverride( 0 )
			
		end
		
	cam.End3D()

end