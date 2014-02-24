----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

UNIT.Name = "Archer"
UNIT.Model = "models/sassilization/mrgiggles/pvk/archer.mdl"
UNIT.Iron = 11
UNIT.Food = 9
UNIT.Gold = 0
UNIT.Supply = 1
UNIT.AttackDelay = 2
UNIT.AttackMoveDelay = 1
UNIT.Range = 60
UNIT.SightRange = 72
UNIT.Speed = 15 -- 30
UNIT.Require = {city=0,workshop=1}
UNIT.Spawnable = true
UNIT.HP = 9
UNIT.AttackDamage = 1.4
UNIT.OBBMins = Vector(-1, -1, -1)
UNIT.OBBMaxs = Vector(1, 1, 4)
UNIT.Size = 4
UNIT.Creed = 1

UNIT.camPos = Vector(-76.834396, -64.008919, 50.046741)
UNIT.angle = Angle(25.060, 39.617, 0.000)
UNIT.fov = 4.3

function UNIT:GetAttackSound()

	return SA.Sounds.GetArrowFireSound()
	
end