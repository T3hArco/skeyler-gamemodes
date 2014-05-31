----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

UNIT.Name = "Peasant"
UNIT.Model = "models/mrgiggles/sassilization/peasant.mdl"
UNIT.Iron = 0
UNIT.Food = 0
UNIT.Gold = 0
UNIT.Supply = 0
UNIT.AttackDelay = 1.2
UNIT.AttackMoveDelay = 1
UNIT.Range = 6
UNIT.SightRange = 50
UNIT.Speed = 15 -- 45
UNIT.Require = {}
UNIT.Spawnable = false
UNIT.HP = 10
UNIT.AttackDamage = 1
UNIT.OBBMins = Vector(-1, -1, -1)
UNIT.OBBMaxs = Vector(1, 1, 4)
UNIT.Size = 3
UNIT.Creed = 2

UNIT.camPos = Vector(-9.859277, 0.239006, 5.009994)
UNIT.angle = Angle(7.375, -1.875, 0.000)
UNIT.fov = 45

function UNIT:GetAttackSound()

	return nil
	
end