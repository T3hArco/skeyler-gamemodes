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
			SS.Lobby.LeaderBoard.Update()
			timer.Simple(1, function()
				for k,v in pairs(player.GetAll()) do
					for i = LEADERBOARD_DAILY, LEADERBOARD_ALLTIME_10 do
						SS.Lobby.LeaderBoard.Network(i, v)
					end
				end
			end)
		end)
	end

	if timeTable.day == 1 && timeTable.hour == 0 && timeTable.min == 0 && timeTable.sec == 0 then
		Msg("[LEADERBOARD] Resetting monthly leaderboards...\n")
		DB_Query("UPDATE rts_leaderboards SET gamesMonthly=0, winsMonthly=0 WHERE gamesMonthly>0", function(data)
			Msg("[LEADERBOARD] Monthly leaderboards reset.\n")
			SS.Lobby.LeaderBoard.Update()
			timer.Simple(1, function()
				for k,v in pairs(player.GetAll()) do
					for i = LEADERBOARD_DAILY, LEADERBOARD_ALLTIME_10 do
						SS.Lobby.LeaderBoard.Network(i, v)
					end
				end
			end)
		end)
	end

	if timeTable.hour == 0 && timeTable.min == 0 && timeTable.sec == 0 then
		Msg("[LEADERBOARD] Resetting daily leaderboards...\n")
		DB_Query("UPDATE rts_leaderboards SET gamesDaily=0, winsDaily=0 WHERE gamesDaily>0", function(data)
			Msg("[LEADERBOARD] Daily leaderboards reset.\n")
			SS.Lobby.LeaderBoard.Update()
			timer.Simple(1, function()
				for k,v in pairs(player.GetAll()) do
					for i = LEADERBOARD_DAILY, LEADERBOARD_ALLTIME_10 do
						SS.Lobby.LeaderBoard.Network(i, v)
					end
				end
			end)
		end)
	end

	thinkTime = os.time() + 1
end