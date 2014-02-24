include("shared.lua")

local texButton = surface.GetTextureID("elevator/button" )
local texButtonPushed = surface.GetTextureID("elevator/button_selected" )
local texButtonArrow = surface.GetTextureID("elevator/button_arrow" )

usermessage.Hook( "elev_caller.Setup", function( um )
	
	local eid = um:ReadShort()
	local rank = um:ReadShort()
	local dir = um:ReadShort()
	local pressed = um:ReadBool()
	local press = um:ReadShort()
	ELEV.callers[ eid ] = {
		dir=dir,
		pressed=(pressed and press or nil),
		access_rank = rank
	}
	
end )

usermessage.Hook( "elev_caller.Press", function( um )
	
	local eid = um:ReadShort()
	local pressed = um:ReadBool()
	local press = um:ReadShort()
	if !ELEV.callers[ eid ] then return end
	if !pressed then
		ELEV.callers[ eid ].pressed = nil
	else
		ELEV.callers[ eid ].pressed = press
	end
	
end )

function ENT:Initialize()
	
	self:SetRenderBounds( self.mins, self.maxs ) 
	
end

local function DrawText( txt, x, y, col )
	if !txt then return end
	col = col or {r=255,g=255,b=255,a=255}
	surface.SetFont( "default" )
	surface.SetTextPos( x+.5, y+.5 )
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.DrawText( txt )
	surface.SetTextPos( x, y )
	surface.SetTextColor( col.r, col.g, col.b, col.a )
	surface.DrawText( txt )
end

function ENT:Draw()
	
	local layout = ELEV.callers[ self:EntIndex() ]
	if !layout then return end
	
	local ang = self:GetAngles()
	cam.Start3D2D( self:GetPos()+self:GetForward()*0.2-self:GetRight()*self.mins.y+self:GetUp()*self.maxs.z, Angle( 0, ang.y + 90, ang.p + 90 ), 0.1 )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		local w, h = 80, 240
		if layout.dir == 0 then
			
			surface.SetTexture( (layout.pressed == 1 || layout.pressed == 0) and texButtonPushed or texButton )
			surface.DrawTexturedRect( w*0.5-16,h*0.35-16,32,32 )
			surface.SetTexture( texButtonArrow )
			surface.DrawTexturedRectRotated( w*0.5,h*0.35,32,32,90 )
			
			surface.SetTexture( (layout.pressed == -1 || layout.pressed == 0) and texButtonPushed or texButton )
			surface.DrawTexturedRect( w*0.5-16,h*0.65-16,32,32 )
			surface.SetTexture( texButtonArrow )
			surface.DrawTexturedRectRotated( w*0.5,h*0.65,32,32,-90 )
			
		else
			
			surface.SetTexture( layout.pressed and texButtonPushed or texButton )
			surface.DrawTexturedRect( w*0.5-16,h*0.5-16,32,32 )
			surface.SetTexture( texButtonArrow )
			surface.DrawTexturedRectRotated( w*0.5,h*0.5,32,32,(layout.dir==1 and 90 or -90) )
			
		end
		
		/*
		local x, y = self:GetCursorPos( LocalPlayer(), 10 )
		if x and y then
			DrawText( math.Round(x).." "..math.Round(y), x, y )
		end
		*/
		
	cam.End3D2D()
	
end

function ENT:Pressed( pl, x, y, scale )
	
	local layout = ELEV.callers[ self:EntIndex() ]
	if !layout then return end
	
	if layout.dir == 0 then
		
		if y < self.maxs.z*scale then
			RunConsoleCommand( "elev_call", self:EntIndex(), 1 )
		else
			RunConsoleCommand( "elev_call", self:EntIndex(), -1 )
		end
		
	else
		
		RunConsoleCommand( "elev_call", self:EntIndex(), layout.dir )
		
	end
	
end

hook.Add( "KeyPress", "elev_caller.Press", function( pl, key )
	
	if key == IN_USE then
		
		nextUse = nextUse or CurTime()
		if nextUse > CurTime() then return end
		
		local callers = ents.FindByClass( "elev_caller" )
		if table.Count( callers ) > 0 then
			local tr = {}
			tr.start = pl:EyePos()
			tr.endpos = tr.start + pl:GetAimVector() * 50
			tr.mask = MASK_SOLID_BRUSHONLY
			tr = util.TraceLine( tr )
			for _, ent in pairs( callers ) do
				if ent.GetCursorPos then
					local x, y = ent:GetCursorPos( pl, 10, tr.HitPos )
					if x and y and ent.Pressed then
						ent:Pressed( pl, x, y, 10 )
					end
				end
			end
		end
		
	end
	
end )