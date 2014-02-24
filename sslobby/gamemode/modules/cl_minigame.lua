local inQueue = false
local queueTime = 0

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
	
	SS.Lobby.Minigame:SetCurrentGame(game)
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
	
	queueTime = time
end)

---------------------------------------------------------
--
---------------------------------------------------------

surface.CreateFont("minigame.timer", {font = "Arial", size = 32, weight = 1000})

local color_shadow = Color(0, 0, 0, 200)

hook.Add("HUDPaint", "SS.Lobby.Minigame", function()
	if (inQueue) then
		draw.RoundedBox(8, ScrW() /2 -216, 36, 432, 60, color_shadow)
		
		draw.SimpleText("NEXT GAME IN " .. math.Round(queueTime -CurTime()) .. " seconds", "minigame.timer", ScrW() /2 +1, 85, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("NEXT GAME IN " .. math.Round(queueTime -CurTime()) .. " seconds", "minigame.timer", ScrW() /2, 84, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	
	if (LocalPlayer():IsPlayingMinigame()) then
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