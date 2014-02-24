--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

SA.START_RES_GOLD = 75
SA.START_RES_FOOD = 120
SA.START_RES_IRON = 120
SA.START_SUPPLY = 6

SA.DEV = false

if SA.DEV then
	SA.START_RES_GOLD = 300
	SA.START_RES_FOOD = 300
	SA.START_RES_IRON = 300
end
SA.MAX_ENTITIES = 1500   --Last resort effort to prevent Edict crashes