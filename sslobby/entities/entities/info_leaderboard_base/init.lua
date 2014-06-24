AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetNotSolid(true)
end

local thinkTime = os.time()
function ENT:Think()
	if thinkTime > os.time() then return end

	local timeTable = os.date("*t", os.time())

	if timeTable.wday == 2 && timeTable.hour == 0 && timeTable.min == 0 && timeTable.sec == 0 then
		Msg("[LEADERBOARD] Resetting weekly leaderboards...\n")
		DB_Query("UPDATE rts_leaderboards SET gamesWeekly=0, winsWeekly=0 WHERE gamesWeekly>0", function(data)
			Msg("[LEADERBOARD] Weekly leaderboards reset.\n")
			SS.Lobby.LeaderBoard.Network(2)
		end)
	end

	if timeTable.day == 1 && timeTable.hour == 0 && timeTable.min == 0 && timeTable.sec == 0 then
		Msg("[LEADERBOARD] Resetting monthly leaderboards...\n")
		DB_Query("UPDATE rts_leaderboards SET gamesMonthly=0, winsMonthly=0 WHERE gamesMonthly>0", function(data)
			Msg("[LEADERBOARD] Monthly leaderboards reset.\n")
			SS.Lobby.LeaderBoard.Network(3)
		end)
	end

	if timeTable.hour == 0 && timeTable.min == 0 && timeTable.sec == 0 then
		Msg("[LEADERBOARD] Resetting daily leaderboards...\n")
		DB_Query("UPDATE rts_leaderboards SET gamesDaily=0, winsDaily=0 WHERE gamesDaily>0", function(data)
			Msg("[LEADERBOARD] Daily leaderboards reset.\n")
			SS.Lobby.LeaderBoard.Network(1)
		end)
	end

	thinkTime = os.time() + 1
end