--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

SWEP.PrintName 		= "Command"
SWEP.Author			= "Sassafrass"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Secondary Fire: Order Units\nSprint + Primary Fire: Selection Box\nSprint + Secondary Fire: Command Units\nSprint + Reload: Deselect Units\nReload: Sell Units/Buildings"

SWEP.ViewModel	= "models/jaanus/v_sasshand2.mdl"
SWEP.WorldModel	= "models/props_lab/reciever01b.mdl"

SWEP.ViewModelFOV = 60
SWEP.HoldType = "melee2"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Reload()
end

function SWEP:Deploy()
	self.Owner:DrawWorldModel(false)
	return true
end