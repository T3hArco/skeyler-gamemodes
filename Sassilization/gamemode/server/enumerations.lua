--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

SA.START_RES_GOLD = 75
SA.START_RES_FOOD = 120
SA.START_RES_IRON = 120
SA.START_SUPPLY = 6

if game.IsDedicated() then
	SA.DEV = false
else
	SA.DEV = true
end

if SA.DEV then
	SA.START_RES_GOLD = 300
	SA.START_RES_FOOD = 5000
	SA.START_RES_IRON = 5000
end

SA.MAX_ENTITIES = 1500   --Last resort effort to prevent Edict crashes

SA.AuthedPlayers = {}
SA.LoadingPlayers = {}
SA.StartTime = 0