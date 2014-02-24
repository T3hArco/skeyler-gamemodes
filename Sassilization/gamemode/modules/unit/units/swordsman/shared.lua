----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

UNIT.Name = "Swordsman"
UNIT.Model = "models/mrgiggles/sassilization/swordsman.mdl"
UNIT.Iron = 10
UNIT.Food = 12
UNIT.Gold = 0.5
UNIT.Supply = 1
UNIT.AttackDelay = 1.2
UNIT.AttackMoveDelay = 1
UNIT.Range = 6
UNIT.SightRange = 32
UNIT.Speed = 15 -- 25
UNIT.Require = {city = 0}
UNIT.Spawnable = true
UNIT.HP = 15
UNIT.AttackDamage = 1.5
UNIT.OBBMins = Vector(-1, -1, -1)
UNIT.OBBMaxs = Vector(1, 1, 4)
UNIT.Size = 5
UNIT.Creed = 1

UNIT.camPos = Vector(-10.764297, 0.018947, 6.085919)
UNIT.angle = Angle(13.054, -0.361, 0.000)
UNIT.fov = 40.138888888889

function UNIT:GetAttackSound()
	return nil
end