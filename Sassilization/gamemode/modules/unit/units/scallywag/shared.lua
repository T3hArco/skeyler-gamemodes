----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

UNIT.Name = "Scallywag"
UNIT.Model = "models/mrgiggles/sassilization/scallywag.mdl"
UNIT.Iron = 17
UNIT.Food = 22
UNIT.Gold = 1
UNIT.Supply = 1.5
UNIT.AttackDelay = 2
UNIT.AttackMoveDelay = 0
UNIT.Range = 70
UNIT.SightRange = 110
UNIT.Speed = 25
UNIT.Require = {city = 0,workshop = 1}
UNIT.Spawnable = true
UNIT.HP = 15
UNIT.AttackDamage = 1.8
UNIT.OBBMins = Vector(-2, -2, -1)
UNIT.OBBMaxs = Vector(2, 2, 4)
UNIT.Size = 6
UNIT.Creed = 1

UNIT.camPos = Vector(-54.885307, -0.846844, 11.283769)
UNIT.angle = Angle(-4.875, 0.375, 0)
UNIT.fov = 45

function UNIT:GetAttackSound()

	return nil
	
end