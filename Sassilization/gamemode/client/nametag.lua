surface.CreateFont("sa_playerName", {
	font = "Arial",
	size = 24,
	wegith = 400,
	shadow = true
})

hook.Add("HUDPaint", "sa_NameTags", function()
	surface.SetFont("sa_playerName")

	local myself = LocalPlayer()
	
	for _, pl in pairs( player.GetAll() ) do
		
		local dis = pl:EyePos():Distance(myself:EyePos())
		
		if IsValid( pl ) and pl != myself and dis < 600 then
			
			local eyes = pl:LookupAttachment( 'eyes' )
			local attachment = pl:GetAttachment( eyes )
			
			if attachment then
				
				local tr = util.TraceLine( {start=myself:EyePos(),endpos=attachment.Pos,mask=MASK_SOLID_BRUSHONLY} )
				if tr.Fraction == 1 then
					
					local scrpos = (attachment.Pos+Vector(0,0,12)):ToScreen()
					local name = pl:Nick()
					local w, h = surface.GetTextSize( name )
					local perc = math.Min((600-dis+200)/600,1)
					
					surface.DrawLine(scrpos.x-w*0.5-4, scrpos.y-h*0.5-2, scrpos.x-w*0.5-4, scrpos.y-h*0.5-2)
					
					surface.SetTextColor( 0, 0, 0, 100*perc )
					surface.SetTextPos( scrpos.x-w*0.5+1, scrpos.y-h*0.5+1 )
					surface.DrawText(name)
					surface.SetTextColor( 255, 255, 255, 255*perc )
					surface.SetTextPos( scrpos.x-w*0.5, scrpos.y-h*0.5 )
					surface.DrawText(name)
				end
			end
		end
	end
end)