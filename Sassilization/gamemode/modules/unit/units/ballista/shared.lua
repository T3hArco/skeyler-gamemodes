----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

UNIT.Name = "Ballista"
UNIT.Model = "models/mrgiggles/sassilization/ballista.mdl"
UNIT.Iron = 30
UNIT.Food = 25
UNIT.Gold = 5
UNIT.Supply = 2
UNIT.AttackDelay = 3
UNIT.AttackMoveDelay = 1
UNIT.Range = 60
UNIT.SightRange = 80
UNIT.Speed = 7 -- 21
UNIT.Require = {city = 0,workshop = 2}
UNIT.Spawnable = true
UNIT.HP = 30
UNIT.AttackDamage = 10
UNIT.OBBMins = Vector(-12, -12, -1)
UNIT.OBBMaxs = Vector(12, 12, 8)
UNIT.Size = 13
UNIT.Creed = 1

UNIT.camPos = Vector(-189.863266, -153.886780, 93.880409)
UNIT.angle = Angle(20.470, 39.718, 0.000)
UNIT.fov = 4.8

function UNIT:GetAttackSound()

	return "SASS_Ballista.Fire"
	
end