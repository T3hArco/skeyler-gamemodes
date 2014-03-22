SS.Scoreboard.RegisterRow("TEAM", 125, TEXT_ALIGN_CENTER, nil, function(panel, player, row)
	local teamPanel = panel:Add("Panel")
	teamPanel:SetSize(row.width, 50)
	teamPanel:Dock(RIGHT)
	
	function teamPanel:Paint(w, h)
		if (IsValid(player)) then
			local index = player:Team()
			local name, color = string.upper(team.GetName(index)), team.GetColor(index)
			
			if (name) then
				draw.SimpleRect(1, 1, w -1, h -2, color)

				draw.SimpleText(name, "skeyler.scoreboard.row", w /2 +1, h /2 +1, SS.Scoreboard.Color_Shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(name, "skeyler.scoreboard.row", w /2, h /2, SS.Scoreboard.Color_Label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
end)