----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

UNIT.Name = "Catapult"
UNIT.Model = "models/mrgiggles/sassilization/catapult.mdl"
UNIT.Iron = 38
UNIT.Food = 50
UNIT.Gold = 5
UNIT.Supply = 2
UNIT.AttackDelay = 6
UNIT.AttackMoveDelay = 2
UNIT.Range = 120
UNIT.SightRange = 140
UNIT.Speed = 7 -- 20
UNIT.Require = {city = 0,workshop = 2}
UNIT.Spawnable = true
UNIT.HP = 35
UNIT.AttackDamage = 5
UNIT.OBBMins = Vector(-8, -8, -1)
UNIT.OBBMaxs = Vector(8, 8, 8)
UNIT.Size = 10
UNIT.Creed = 1

UNIT.camPos = Vector(-207.945709, -174.530258, 97.833298)
UNIT.angle = Angle(18.841, 40.027, 0.000)
UNIT.fov = 4.86

function UNIT:GetAttackSound()

	return "SASS_Catapult.Fire"
	
end