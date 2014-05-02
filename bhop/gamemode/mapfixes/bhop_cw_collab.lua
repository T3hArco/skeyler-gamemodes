AddCSLuaFile()

sound.Add( {
	name = "s1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 85,
	pitch = 100,
	sound = "aids/col1.mp3"
} )

sound.Add( {
	name = "s2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 85,
	pitch = 100,
	sound = "aids/col2.mp3"
} )

sound.Add( {
	name = "s3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 85,
	pitch = 100,
	sound = "aids/col3.mp3"
} )

sound.Add( {
	name = "s4",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 85,
	pitch = 100,
	sound = "aids/col4.mp3"
} )

--hope
sound.AddSoundOverrides("scripts/soundscapes_bhop_cw_collab.txt")