
assert( SA )

SA.Sounds = {}
SA.Sounds.SelectSound = "sassilization/select.wav"

UnitOrderSounds = {
	{"sassilization/units/Move1.wav", 1},
	{"sassilization/units/Move2.wav", 1.5},
	{"sassilization/units/Move3.wav", 2},
	{"sassilization/units/Move4.wav", .5},
	{"sassilization/units/Move5.wav", .5}
}

function SA.Sounds.GetUnitOrderSound()
	return table.Random( UnitOrderSounds )
end

UnitDeathSounds = {}
UnitDeathSounds.Flesh = {
	{"ambient/voices/citizen_beaten5.wav", 1},
	{"ambient/voices/citizen_beaten4.wav", 1},
	{"ambient/voices/citizen_beaten3.wav", 1},
	{"ambient/voices/citizen_beaten2.wav", 1},
	{"ambient/voices/citizen_beaten1.wav", 1}
}

function SA.Sounds.GetFleshUnitDeathSound()
	return table.Random( UnitDeathSounds.Flesh )
end

UnitSpawnSounds = {
	{"sassilization/units/Drop.wav", 1}
}

function SA.Sounds.GetUnitSpawnSound()
	return UnitSpawnSounds[ 1 ]
end

function SA.Sounds.GetUnitSacrificeSound()
	return "sassilization/units/sacrificed.wav"
end

UnitAttackingSounds = {}
UnitAttackingSounds.BuildingHit = {
	{"sassilization/units/building_hit01.wav", 1},
	{"sassilization/units/building_hit02.wav", 1},
	{"sassilization/units/building_hit03.wav", 1}
}

function SA.Sounds.GetBuildingHitSound()
	return table.Random( UnitAttackingSounds.BuildingHit )[1]
end

UnitAttackingSounds.UnitHit = {
	{"sassilization/units/flesh_hit01.wav", 1},
	{"sassilization/units/flesh_hit02.wav", 1},
	{"sassilization/units/flesh_hit03.wav", 1}
}

function SA.Sounds.GetUnitHitSound()
	return table.Random( UnitAttackingSounds.UnitHit )[1]
end

UnitAttackingSounds.ArrowFire = {
	{"sassilization/units/arrowfire01.wav", 1},
	{"sassilization/units/arrowfire02.wav", 1}
}

function SA.Sounds.GetArrowFireSound()
	return table.Random( UnitAttackingSounds.ArrowFire )[1]
end

function SA.Sounds.GetFallDamageSound()
	return "npc/zombie/zombie_hit.wav"
end

UnitAttackingSounds.BulletHitFlesh = {
	{"physics/body/body_medium_impact_soft7.wav", 1},
	{"physics/body/body_medium_impact_soft6.wav", 1},
	{"physics/body/body_medium_impact_soft5.wav", 1},
	{"physics/body/body_medium_impact_soft4.wav", 1},
	{"physics/body/body_medium_impact_soft3.wav", 1},
	{"physics/body/body_medium_impact_soft2.wav", 1},
	{"physics/body/body_medium_impact_soft1.wav", 1}
}

UnitAttackingSounds.BulletHitBuilding = {
	{"physics/concrete/concrete_impact_bullet4.wav", 1},
	{"physics/concrete/concrete_impact_bullet3.wav", 1},
	{"physics/concrete/concrete_impact_bullet2.wav", 1},
	{"physics/concrete/concrete_impact_bullet1.wav", 1}
}

function SA.Sounds.GetArrowHitFleshSound()

	return table.Random( UnitAttackingSounds.BulletHitFlesh )[1]
end

function SA.Sounds.GetArrowHitBuildingSound()
	return table.Random( UnitAttackingSounds.BulletHitBuilding )[1]
end

UnitAttackingSounds.BallisaFire = {
	{"sassilization/units/ballista_fire01.wav", 1},
	{"sassilization/units/ballista_fire02.wav", 1}
}

function SA.Sounds.GetBallisaFireSound()
	return table.Random( UnitAttackingSounds.BallisaFire )[1]
end

UnitAttackingSounds.CrossbowFire = {
	{"sassilization/units/fireCrossbow.wav", 1}
}

function SA.Sounds.GetCrossbowFireSound()
	return table.Random( UnitAttackingSounds.CrossbowFire )[1]
end

UnitAttackingSounds.BuildingBreak = {
	{"sassilization/units/buildingbreak01.wav", 1},
	{"sassilization/units/buildingbreak02.wav", 1}
}

function SA.Sounds.GetBuildingBreakSound()
	return table.Random( UnitAttackingSounds.BuildingBreak )[1]
end

UnitAttackingSounds.WallBreak = {
	{"sassilization/units/wallbreak01.wav", 1},
	{"sassilization/units/wallbreak02.wav", 1}
}

function SA.Sounds.GetWallBreakSound()
	return table.Random( UnitAttackingSounds.WallBreak )[1]
end

sound.Add({
    name = "SASS_Gate.Open",
    channel = CHAN_STATIC,
    volume = 0.5000,
    soundlevel = 80,
    sound = "sassilization/gateopen.wav"
})
sound.Add({
    name = "SASS_Gate.Close",
    channel = CHAN_STATIC,
    volume = 0.5000,
    soundlevel = 80,
    sound = "sassilization/gateclose.wav"
})
sound.Add({
    name = "SASS_Ballista.Load",
    channel = CHAN_STATIC,
    volume = 0.5000,
    soundlevel = 80,
    sound = {
                "sassilization/ballista_load01.wav",
                "sassilization/ballista_load02.wav",
                "sassilization/ballista_load03.wav",
                "sassilization/ballista_load04.wav"
        }
})
sound.Add({
    name = "SASS_Ballista.Fire",
    channel = CHAN_STATIC,
    volume = 0.5000,
    soundlevel = 80,
    sound = {
                "sassilization/ballista_fire01.wav",
                "sassilization/ballista_fire02.wav",
                "sassilization/ballista_fire03.wav",
                "sassilization/ballista_fire04.wav",
                "sassilization/ballista_fire05.wav"
        }
})
sound.Add({
    name = "SASS_Catapult.Crank01",
    channel = CHAN_STATIC,
    volume = 0.5000,
    soundlevel = 80,
    sound = {
                "sassilization/catapult_crank01.wav",
                "sassilization/catapult_crank01a.wav",
                "sassilization/catapult_crank01b.wav"
        }
})
sound.Add({
    name = "SASS_Catapult.Crank02",
    channel = CHAN_STATIC,
    volume = 0.5000,
    soundlevel = 80,
    sound = {
                "sassilization/catapult_crank02.wav",
                "sassilization/catapult_crank02a.wav",
                "sassilization/catapult_crank02b.wav"
        }
})
sound.Add({
    name = "SASS_Catapult.Crank03",
    channel = CHAN_STATIC,
    volume = 0.5000,
    soundlevel = 80,
    sound = {
                "sassilization/catapult_crank03.wav",
                "sassilization/catapult_crank03a.wav",
                "sassilization/catapult_crank03b.wav"
        }
})
sound.Add({
    name = "SASS_Catapult.Fire",
    channel = CHAN_STATIC,
    volume = 0.5000,
    soundlevel = 80,
    sound = {
                "sassilization/catapult_fire01.wav",
                "sassilization/catapult_fire02.wav",
                "sassilization/catapult_fire03.wav",
                "sassilization/catapult_fire04.wav"
        }
})