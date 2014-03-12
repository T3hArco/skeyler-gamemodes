---------------------------------------------------------
--
---------------------------------------------------------

function MINIGAME:ShouldHUDPaint()
	return SS.Lobby.Minigame.IsInQueue() or LocalPlayer():IsPlayingMinigame()
end

---------------------------------------------------------
--
---------------------------------------------------------

local width, height = 800, 16
local color_line = Color(255, 255, 255, 160)
local color_background = Color(195, 109, 95, 255)
local winPosition = Vector(-8192, -2049, 572)

local proxy = {TEAM_RED, TEAM_BLUE, TEAM_GREEN, TEAM_ORANGE}

function MINIGAME:HUDPaint()
	local x, y = ScrW() /2 -width /2, 32
	
	for i = 1, 4 do
		local players = team.GetPlayers(proxy[i])
		local shouldDraw = false
		
		for k, player in pairs(players) do
			if (player:IsPlayingMinigame()) then
				shouldDraw = true
				
				break
			end
		end
		
		if (shouldDraw) then
			draw.RoundedBox(8, x, y, width, height, color_line)
			draw.RoundedBox(6, x +2, y +2, width -4, height -4, color_background)
			
			local distance, count = 0, 0
		
			for k, player in pairs(players) do
				if (player:IsPlayingMinigame()) then
					distance, count = distance +player:GetPos():Distance(winPosition), count +1
				end
			end
			
			distance = distance /count
			
			local position = x +((width -32) -math.Clamp(distance /2107, 0, 1) *(width -32))
			local teamColor = team.GetColor(proxy[i])
			
			draw.RoundedBox(15, position +1, y -(height -6) /2, height *2 -4, height *2 -4, color_white)
			draw.RoundedBox(15, position +2, y -(height -8) /2, height *2 -6, height *2 -6, teamColor)
			
			y = y +height *2 +4
		end
	end
	
	self.TimerY = y +6
end