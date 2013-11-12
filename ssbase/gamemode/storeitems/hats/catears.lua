ITEM.ID = "catears"											-- Should be a unique string that identifies the item
ITEM.Name = "Cat Ears"										-- The name the item should display
 
ITEM.Price = 2000
 
ITEM.Model = "models/mrgiggles/skeyler/hats/cat_ears.mdl"	-- Model used by the item

ITEM.Type = "hat"											-- Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = false										-- Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false										-- Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.Rotate = 45

ITEM.CamPos = Vector(45, 27, 8)								-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(0, 0, 8) 								-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Functions = {} 										-- Anything that can be called but not a gmod hook but more of a "store hook" goes here

ITEM.Functions["Equip"] = function ()						-- e.g miku hair attach with the models Equip
end

ITEM.Functions["Unequip"] = function ()						-- e.g miku hair attach with the models Equip
end

ITEM.Hooks = {}												-- Could run some shit in think hook maybe clientside only (e.g. repositioning or HEALTH CALCULATIONS OR SOMETHING LIKE THAT)

ITEM.Hooks["Think"] = function ()
end

/* HAT VARIABLES */
ITEM.Bone = "ValveBiped.Bip01_Head1"						-- Bone the item is attached to. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.
ITEM.BoneMerge = false										-- May be used for certain accessories to bonemerge the item instead. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.

ITEM.Models = {} 
ITEM.Models["elin"] = {	["0_0_0_0"]= {pos=Vector(-1, 1, -0.3), ang=Angle(0, -90, -90), scale=1}}
ITEM.Models["miku"] = {	["0_0_0_0"]= {pos=Vector(0, 1, -0.3), ang=Angle(0, -90, -90), scale=0.95}}
ITEM.Models["tron"] = {	["0_0_0_0"]= {pos=Vector(0.25, 1.5, -0.3), ang=Angle(0, -90, -90), scale=0.925}}
ITEM.Models["usif"] = {	["0_0_0_0"]= {pos=Vector(-1.5, 1.5, -0.1), ang=Angle(0, -90, -90), scale=0.9}}
ITEM.Models["zer0"] = {
	["0_0_0_0"]= {pos=Vector(1, 1, -0.3), ang=Angle(0, -90, -90), scale=0.8},
	["0_1_0_0"]= {pos=Vector(6, 1, -0.3), ang=Angle(0, -90, -90), scale=0.8}
}
/* ************* */