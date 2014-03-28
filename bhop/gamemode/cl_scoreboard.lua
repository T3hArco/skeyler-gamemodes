---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

SS.Scoreboard.RegisterRow("TIME", 110, TEXT_ALIGN_CENTER, SS.Scoreboard.ROW_RIGHT, function(panel, player, row)
	local label = panel:Add("DLabel")
	label:SetSize(row.width, 50)
	label:SetText(string.FormattedTime(RealTime(), "%02i:%02i:%02i") )
	label:SetFont("skeyler.scoreboard.row")
	label:SetColor(Color(242, 242, 242))
	label:SetExpensiveShadow(1, Color(0, 0, 0, 210))
	label:SetContentAlignment(5)
	label:Dock(RIGHT)
	
	local nextThink = 0
	
	function label:Think()
		if (nextThink <= CurTime()) then
			if (IsValid(player)) then
				local time = FormatTime(player:GetNetworkedInt("STimer_TotalTime", 0))
				
				self:SetText(time)
			end
			
			nextThink = CurTime() +0.5
		end
	end
end)

SS.Scoreboard.RegisterRow("STYLE", 132, TEXT_ALIGN_CENTER, SS.Scoreboard.ROW_RIGHT, function(panel, player, row)
	local label = panel:Add("DLabel")
	label:SetSize(row.width, 50)
	label:SetText("NORMAL")
	label:SetFont("skeyler.scoreboard.row")
	label:SetColor(Color(242, 242, 242))
	label:SetExpensiveShadow(1, Color(0, 0, 0, 210))
	label:SetContentAlignment(5)
	label:Dock(RIGHT)
	
	function label:Think()
		if (IsValid(player)) then
			local text = self:GetText()
			local level = GAMEMODE.Styles[player:GetNetworkedInt("Style", 1)]
			
			if (level and text != level.name) then
				self:SetText(string.upper(level.name))
			end
		end
	end
end)

SS.Scoreboard.RegisterRow("SCORE", 110, TEXT_ALIGN_CENTER, SS.Scoreboard.ROW_RIGHT, function(panel, player, row)
	local label = panel:Add("DLabel")
	label:SetSize(row.width, 50)
	label:SetText(math.random(100, 99999))
	label:SetFont("skeyler.scoreboard.row")
	label:SetColor(Color(242, 242, 242))
	label:SetExpensiveShadow(1, Color(0, 0, 0, 210))
	label:SetContentAlignment(5)
	label:Dock(RIGHT)
end)