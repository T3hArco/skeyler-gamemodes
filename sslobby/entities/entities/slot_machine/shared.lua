ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

-- 1 -- Clock.
-- 2 -- Sassilization.
-- 3 -- Lemon.
-- 4 -- Strawberry.
-- 5 -- Melon.
-- 6 -- Cherry.

ENT.winDefines = {
	{slots = {6, 0, 0}, win = 2},
	{slots = {6, 6, 0}, win = 5},
	{slots = {3, 3, 5}, win = 10},
	{slots = {3, 3, 3}, win = 12},
	{slots = {4, 4, 5}, win = 14},
	{slots = {4, 4, 4}, win = 16},
	{slots = {1, 1, 5}, win = 17},
	{slots = {1, 1, 1}, win = 25},
	{slots = {5, 5, 5}, win = 120},
	{slots = {2, 2, 2}, win = 200}
}

util.PrecacheModel("models/sam/spinner.mdl")
util.PrecacheModel("models/sam/slotmachine.mdl")

util.PrecacheSound("sound/testslot/jackpot.mp3")
util.PrecacheSound("sound/testslot/pull_lever.mp3")
util.PrecacheSound("sound/testslot/spinning_1.mp3")
util.PrecacheSound("sound/testslot/spinning_3.mp3")
util.PrecacheSound("sound/testslot/spinning_3.mp3")