ITEM.ID = "example"											-- Should be a unique string that identifies the item
ITEM.Name = "Example"										-- The name the item should display
 
ITEM.Price = 2000
 
ITEM.Model = "models/somepath/model.mdl"					-- Model used by the item

ITEM.Type = "hat"											-- Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Limited = false										-- Used if the model is a limited time (such as a holiday) item. "True" displays a little effect in the store.
ITEM.Hidden = false											-- If true, the item will not be loaded into the store. Used for "special" hats such as limited hats which are no longer purchasable or staff hats.
ITEM.Level = 0												-- The level required before the player can purchase this item.
ITEM.VIP = false											-- If true, the item is VIP only

ITEM.Colorable = false										-- Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false										-- Used if the model is colorable, but a translation is needed to $selfillumtint

ITEM.Rotate = 0 											-- Rotates the model (temporary) [MUST BE MULTIPLE OF 5]

ITEM.CamPos = Vector(50, 30, 64)							-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(0, 0, 64) 								-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Functions = {} 										-- anything that can be called but not a gmod hook but more of a "store hook" goes here

ITEM.Functions["Equip"] = function ()						-- e.g miku hair attach with the models Equip
end

ITEM.Functions["Unequip"] = function ()						-- e.g miku hair attach with the models Equip
end

ITEM.Hooks = {}												-- could run some shit in think hook maybe clientside only (e.g. repositioning or HEALTH CALCULATIONS OR SOMETHING LIKE THAT)

ITEM.Hooks["HookName"] = function ()						
end


/* HAT VARIABLES */
ITEM.Bone = "ValveBiped.Bip01_Head1"						-- Bone the item is attached to. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.
ITEM.BoneMerge = false										-- May be used for certain accessories to bonemerge the item instead. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.

ITEM.Models = {} 
--ITEM.Models["id"] = {pos=Vector(0, 0, 0), ang=Angle(0, 0, 0), scale=1}
ITEM.Models["id"] = {modelgroup=(0, 0), itemgroup=(0, 0), pos=Vector(0, 0, 0), ang=Angle(0, 0, 0), scale=1}
/* ************* */

/*
NOTE:	"modelgroup" will be the value returned for GetBodygroup() in the script. modelgroup(0, 1) will return GetBodygroup (0, 1) for bodygroups the playermodel listed in the id uses. 
		"itemgroup" will be the value returned for the same thing, but that the item this file relates to uses. 

	Ex: 
*/
--BRACKET FORMAT = ["BODYGROUPID_BODYGROUPNUM_BODYGROUPID_BODYGROUPNUM"] (for model first then item nothing changed would be 0_0_0_0	
ITEM.Models["zer0"] = {
	["0_0_0_0"]= {pos=Vector(1, 2, 0), ang=Angle(0, 0, 0), scale=1}
}

--ALL GIGGLES BAD FORMAT :(
ITEM.Models["zer0"] = {modelgroup={0, 0}, itemgroup={0, 0}, pos=Vector(1, 2, 0), ang=Angle(0, 0, 0), scale=1}
ITEM.Models["zer0"] = {modelgroup=(0, 1), itemgroup=(0, 0), pos=Vector(1.5 2.5, 0), ang=Angle(0, 0, 0), scale=1}
ITEM.Models["zer0"] = {modelgroup=(0, 0), itemgroup=(0, 1), pos=Vector(1, 2, 0), ang=Angle(0, 0, 0), scale=1}
ITEM.Models["zer0"] = {modelgroup=(0, 1), itemgroup=(0, 1), pos=Vector(1.5 2.5, 0), ang=Angle(0, 0, 0), scale=1}

ITEM.Models["miku"] = {modelgroup=(0, 0), itemgroup=(0, 0), pos=Vector(0.5, 0.75, 0), ang=Angle(0, 0, 0), scale=1}

ITEM.Models["tron"] = {modelgroup=(0, 0), itemgroup=(0, 0), pos=Vector(0.5, 0.75, 0), ang=Angle(0, 0, 0), scale=1}

