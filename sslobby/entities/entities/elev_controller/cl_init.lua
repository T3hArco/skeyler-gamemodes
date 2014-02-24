include("shared.lua")

local texButton = surface.GetTextureID("elevator/button" )
local texButtonPushed = surface.GetTextureID("elevator/button_selected" )
local ctrlElevTranslate = {}

usermessage.Hook( "elev_controller.Setup", function( um )
	
	local elevid = um:ReadShort()
	local floors = um:ReadShort()
	local ctrl = {}
	for i=1, floors do
		local eid = um:ReadShort()
		local num = um:ReadShort()
		local pressed = um:ReadBool()
		ctrl[ num ] = {}
		ctrl[ num ].pressed = pressed
		ctrlElevTranslate[ eid ] = elevid
	end
	ELEV.controllers[ elevid ] = ctrl
	
end )

usermessage.Hook( "elev_controller.Press", function( um )
	
	local elevid = um:ReadShort()
	local level = um:ReadShort()
	local pressed = um:ReadBool()
	if !ELEV.controllers[ elevid ] then return end
	if !ELEV.controllers[ elevid ][ level ] then return end
	ELEV.controllers[ elevid ][ level ].pressed = pressed
	
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
	
	local elevid = ctrlElevTranslate[ self:EntIndex() ]
	local layout = ELEV.controllers[ elevid ]
	if !layout then return end
	
	local ang = self:GetAngles()
	cam.Start3D2D( self:GetPos()+self:GetForward()*0.2-self:GetRight()*self.mins.y+self:GetUp()*self.maxs.z, Angle( 0, ang.y + 90, ang.p + 90 ), 0.1 )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		local w, h = 160, 240
		local x, y = 0, 0
		
		self.buttons = {}
		
		h, y = 170, 10
		local count, incr = 1, 48
		for lvl, btn in pairs( layout ) do
			
			local button = {}
			button.num = lvl
			button.cmd = {"elev_ctrl", elevid, lvl}
			button.pressed = btn.pressed
			
			table.insert( self.buttons, button )
			
		end
		
		table.sort( self.buttons, function( a, b ) return a.num > b.num end )
		
		for _, button in ipairs( self.buttons ) do
			
			button.x = w*0.5
			button.y = y+incr*count
			
			surface.SetTexture( button.pressed and texButtonPushed or texButton )
			surface.DrawTexturedRect( button.x-16, button.y-16, 32, 32 )
			DrawText( button.num, button.x-3, button.y-8, Color( 0, 0, 0, 255 ) )
			count = count + 1
			
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
	
	local elevid = ctrlElevTranslate[ self:EntIndex() ]
	local layout = ELEV.controllers[ elevid ]
	if !layout or !self.buttons then return end
	
	for _, btn in ipairs( self.buttons ) do
		
		if (	y > btn.y - 24	&&
			y < btn.y + 24	&&
			x > btn.x - 96	&&
			x < btn.x + 96 ) then
			RunConsoleCommand( unpack( btn.cmd ) )
		end
		
	end
	
end

hook.Add( "KeyPress", "elev_controller.Press", function( pl, key )
	
	if key == IN_USE then
		
		nextUse = nextUse or CurTime()
		if nextUse > CurTime() then return end
		
		local controllers = ents.FindByClass( "elev_controller" )
		if table.Count( controllers ) > 0 then
			local tr = {}
			tr.start = pl:EyePos()
			tr.endpos = tr.start + pl:GetAimVector() * 50
			tr.mask = MASK_SOLID_BRUSHONLY
			tr = util.TraceLine( tr )
			for _, ent in pairs( controllers ) do
				local x, y = ent:GetCursorPos( pl, 10, tr.HitPos )
				if x and y then
					ent:Pressed( pl, x, y, 10 )
				end
			end
		end
		
	end
	
end )