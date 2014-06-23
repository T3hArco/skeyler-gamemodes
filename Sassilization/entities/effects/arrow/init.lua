

function EFFECT:Init( data )

	local ArrowScale = 1.5
	
	self.vStart = data:GetOrigin()
	local timeEnd = data:GetScale() + CurTime()
	local target = data:GetEntity()
	local targetOffset = data:GetStart()
	
	if( not IsValid( target ) ) then return end
	
	self:SetRenderBoundsWS( self.vStart, target:GetPos() )
	
	self:SetPos( self.vStart )
	self.Model = ClientsideModel( "models/mrgiggles/sassilization/arrow_small.mdl" )
	self.Model:SetPos( self.vStart )
	self.Model:SetAngles( (target:GetPos() - self.vStart ):Angle() )
	self.Model:SetModelScale( ArrowScale, 0 )
	self.startTime = CurTime()
	self.lifeTime = timeEnd - CurTime()
	self.timeEnd = timeEnd
	self.Target = target
	
	self.TargetOffset = targetOffset
	self:CallOnRemove( "RemoveTrail", self.OnRemove )
	
	self.Trail = {}
	self.NextTrail = UnPredictedCurTime() + 0.05
	
end

function EFFECT:OnRemove()
	if( IsValid( self.Model ) ) then
		self.Model:Remove()
	end
end

function EFFECT:Think()

	if( not self.lifeTime ) then return false end
	
	if( self.Model ) then
		self:SetRenderBoundsWS( self.vStart, self.Model:GetPos() )
	end
	
	self:UpdateTrail()
	
	if( CurTime() < self.timeEnd ) then
		return true
	else
		if( self.Model ) then
			self.lastModelPos = self.Model:GetPos()
			self.Model:Remove()
			self.Model = nil
		end
		return #self.Trail > 0
	end
	
end

--Credit to Foszor and Jinto for Trail code
function EFFECT:UpdateTrail()
	
	if ( self.NextTrail > UnPredictedCurTime() ) then return end
	
	if( self.Model ) then
		self.Trail[ #self.Trail + 1 ] = {
			pos = self.Model:GetPos(),
			die = UnPredictedCurTime() + 0.5,
		}
	end
	
	for i = #self.Trail, 1, -1 do
		
		if ( self.Trail[ i ].die <= UnPredictedCurTime() ) then
			
			table.remove( self.Trail, i )
			
		end
		
	end
	
	self.NextTrail = UnPredictedCurTime() + 0.05
	
end

local color = Color( 200, 200, 200, 50 )
local trail = Material( "trails/laser" )
function EFFECT:RenderTrail( anchor, alpha )
	
	local count = #self.Trail
	
	render.SetMaterial( trail )
	render.StartBeam( count + 1 )
	
	for i = 1, count do
		
		local seg = self.Trail[ i ]
		
		local coord = ( 1 / count ) * ( i - 1 )
		
		local percent = math.Clamp( ( seg.die - UnPredictedCurTime() ) / 0.5, 0, 1 )
		
		color.a = alpha*percent
		render.AddBeam( seg.pos, .6, coord, color )
		
	end
	
	color.a = 255
	render.AddBeam( anchor, .6, 1, color )
	
	render.EndBeam()
	
end

function EFFECT:Render()
	
	if ( not self.Trail ) then return end
	if ( #self.Trail > 1 ) then
		
		if( self.Model ) then
			self:RenderTrail( self.Model:GetPos(), 80 )
		elseif( self.lastModelPos ) then
			self:RenderTrail( self.lastModelPos, 80 )
		end
		
	end
	
	if( not self.Model ) then return end
	if( not IsValid( self.Target ) ) then
		self.Model:SetNoDraw( true )
		return
	end
	
	local perc = 1 - math.Clamp( ( self.timeEnd - CurTime() ) / self.lifeTime, 0, 1 )
	local pos = self.vStart + (self.Target:LocalToWorld( self.TargetOffset ) - self.vStart) * perc
	
	self:SetPos( pos )
	self:SetRenderBounds( self.Model:GetRenderBounds() )
	local ang = (pos - self.Model:GetPos() ):Angle()
		ang.p = ang.p + 90
	self.Model:SetPos( pos )
	self.Model:SetAngles( ang )
	
end