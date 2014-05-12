----------------------------------------
--	Sassilzation
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------
surface.CreateFont("WinFont", {
	font = "middlesaxonytext",
	size = ScreenScale(14),
	weight = 500
})

function SetWinners(len)
	local winner = net.ReadString()
	local winnerTable = net.ReadTable()
	local winnerTitle = net.ReadString()
	local winnerDesc = net.ReadString()

	WinFrame = vgui.Create( "DFrame" )
	WinFrame:SetSize( ScrW(), ScrH() )
	WinFrame:SetPos( 0, 0 )
	WinFrame:SetVisible( true )
	WinFrame:SetDraggable( false )
	WinFrame:ShowCloseButton( false )
	WinFrame:SetTitle(" ")
	if #winnerTable == 0 then
		winText = winner .. " has won the round!"
		winText2 = "He will go into the history books forever as " .. winner .. " the " .. winnerTitle
		if #player.GetHumans() <= #winnerTable + 1 then
			winText3 = " "
		else
			winText3 = "for his victory over the " .. #player.GetHumans() - (#winnerTable + 1) .. " " .. winnerDesc 
		end
	else
		winText = winner .. " have won the round!"
		winText2 = "They will go into the history books forever as "
		for k,v in pairs(winnerTable) do
			if k == #winnerTable then
				winText = string.gsub(winText, " have won the round!", " and " .. v:Nick() .. " have won the round!")
				winText2 = winText2 .. v:Nick() .. " and "
			else
				winText = v:Nick() .. ", " .. winText
				winText2 = winText2 .. v:Nick() .. ", "
			end
		end
		winText2 = winText2 .. winner .. " the " .. winnerTitle
		winText3 = "for their victory over the " .. #player.GetHumans() - (#winnerTable + 1) .. " " .. winnerDesc 
	end

	if LocalPlayer():Nick() == winner then
		winning = true
	end
	for k,v in pairs(winnerTable) do
		if LocalPlayer() == v then
			winning = true
		end
	end

	function WinFrame:Paint()
		draw.RoundedBox( 0, 0, 0, WinFrame:GetWide(), WinFrame:GetTall(), Color( 0, 0, 0, 255 ))

		surface.SetFont("WinFont")
		local distw, disth = surface.GetTextSize(winText)
		surface.SetTextPos( WinFrame:GetWide()*0.5 - distw/2, WinFrame:GetTall()*0.5 )
		surface.SetTextColor( 255,255,255,255 )
		surface.DrawText( winText )
		local curheight = disth

		local distw, disth = surface.GetTextSize(winText2)
		surface.SetTextPos( WinFrame:GetWide()*0.5 - distw/2, WinFrame:GetTall()*0.5 + curheight )
		surface.SetTextColor( 255,255,255,255 )
		surface.DrawText( winText2 )
		local curheight = curheight + disth

		local distw, disth = surface.GetTextSize(winText3)
		surface.SetTextPos( WinFrame:GetWide()*0.5 - distw/2, WinFrame:GetTall()*0.5 + curheight )
		surface.SetTextColor( 255,255,255,255 )
		surface.DrawText( winText3 )
		local curheight = curheight + disth

		if winning then
			local distw, disth = surface.GetTextSize("You have won!")
			surface.SetTextPos( WinFrame:GetWide()*0.5 - distw/2, WinFrame:GetTall()*0.7 )
			surface.SetTextColor( 255,255,255,255 )
			surface.DrawText( "You have won!" )
		end

		if !winSound then
			surface.PlaySound( "jetheme-01.mp3" )
		end

		winSound = true
	end
end
net.Receive("SetWinners", SetWinners)

net.Receive("sa.connectlobby", function(bits)
	LocalPlayer():ConCommand("connect 63.143.48.134:27017")
end)