local inQueue = false
local queueTime = 0
local gameProgress = false

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Lobby.Minigame.IsInQueue()
	return inQueue
end

---------------------------------------------------------
--
---------------------------------------------------------

net.Receive("ss.lbmgup", function(bits)
	local game = net.ReadString()
	local scores = SS.Lobby.Minigame:GetScores()
	
	for teamID, _ in pairs(scores) do
		local score = net.ReadUInt(8)
		
		scores[teamID] = score
	end
	
	if (game != "") then
		SS.Lobby.Minigame:SetCurrentGame(game)
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

net.Receive("ss.lbmgtpl", function(bits)
	local bool = util.tobool(net.ReadBit())

	inQueue = bool
end)

---------------------------------------------------------
--
---------------------------------------------------------

net.Receive("ss.lbmggtim", function(bits)
	local time = net.ReadFloat()
	local inProgress = tobool(net.ReadBit())
	
	queueTime = time
	gameProgress = inProgress
end)

---------------------------------------------------------
--
---------------------------------------------------------

surface.CreateFont("minigame.timer", {font = "Arvil Sans", size = 36, weight = 400})

local color_shadow = Color(0, 0, 0, 200)

hook.Add("HUDPaint", "SS.Lobby.Minigame", function()
	if (inQueue) then
		local seconds = math.Round(queueTime -CurTime())
		local minigame = SS.Lobby.Minigame.Get(SS.Lobby.Minigame:GetCurrentGame())
		local offsetX, offsetY = 0, 0
		
		if (minigame) then
			offsetX, offsetY = minigame.TimerX or 0, minigame.TimerY or 0
		end
		
		surface.SetFont("minigame.timer")
		if (gameProgress) then
			width, height = surface.GetTextSize("THE GAME WILL END IN " .. seconds .. " SECONDS")
		else
			width, height = surface.GetTextSize("THE NEXT GAME BEGINS IN " .. seconds .. " SECONDS")
		end
		//5 pixel buffer on each side
		width = width + 10
		height = height + 10
		draw.RoundedBox(8, ScrW() /2 - width /2,  89 + offsetY - height, width, height, color_shadow)
		
		if (gameProgress) then
			draw.SimpleText("THE GAME WILL END IN " .. seconds .. " SECONDS", "minigame.timer", ScrW() /2 +offsetX +1, 85 +offsetY, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText("THE GAME WILL END IN " .. seconds .. " SECONDS", "minigame.timer", ScrW() /2 +offsetX, 84 +offsetY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		else
			draw.SimpleText("THE NEXT GAME BEGINS IN " .. seconds .. " SECONDS", "minigame.timer", ScrW() /2 +offsetX +1, 85 +offsetY, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText("THE NEXT GAME BEGINS IN " .. seconds .. " SECONDS", "minigame.timer", ScrW() /2 +offsetX, 84 +offsetY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end
	
	local shouldPaint = SS.Lobby.Minigame.Call("ShouldHUDPaint")
	
	if (shouldPaint) then
		SS.Lobby.Minigame.Call("HUDPaint")
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("Think", "SS.Lobby.Minigame", function()
	if (LocalPlayer():IsPlayingMinigame()) then
		SS.Lobby.Minigame.Call("Think")
	end
end)