ITEM.ID = "monocle"											-- Should be a unique string that identifies the item
ITEM.Name = "Monocle"										-- The name the item should display
 
ITEM.Price = 2000
 
ITEM.Model = "models/mrgiggles/skeyler/accessories/monocle.mdl"	-- Model used by the item

ITEM.Type = "glasses"										-- Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = false										-- Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false										-- Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.Rotate = 45

ITEM.CamPos = Vector(15, 11, 2)								-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(0, 0, 2) 								-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Functions = {} 										-- Anything that can be called but not a gmod hook but more of a "store hook" goes here

ITEM.Functions["Equip"] = function ()						-- e.g miku hair attach with the models Equip
end

ITEM.Functions["Unequip"] = function ()						-- e.g miku hair attach with the models Equip
end

ITEM.Hooks = {}												-- Could run some shit in think hook maybe clientside only (e.g. repositioning or HEALTH CALCULATIONS OR SOMETHING LIKE THAT)

ITEM.Hooks["Think"] = function ()
end

/* ACCESSORY VARIABLES */
ITEM.Bone = "ValveBiped.Bip01_Head1"						-- Bone the item is attached to. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.
ITEM.BoneMerge = false										-- May be used for certain accessories to bonemerge the item instead. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.

ITEM.Models = {} 
ITEM.Models["dante"] = {	["0_0_0_0"]= {pos=Vector(2, 2.45, 1.4), ang=Angle(0, -90, -95), scale=0.925}}
ITEM.Models["elin"] = {	["0_0_0_0"]= {pos=Vector(1.65, 2.15, 2.25), ang=Angle(0, -90, -100), scale=1}}
ITEM.Models["miku"] = {	["0_0_0_0"]= {pos=Vector(1.5, 0.6, 2.1), ang=Angle(0, -90, -110), scale=1}}
ITEM.Models["tron"] = {	["0_0_0_0"]= {pos=Vector(2.5, 3.35, 1.8), ang=Angle(0, -90, -100), scale=1}}
ITEM.Models["usif"] = {	["0_0_0_0"]= {pos=Vector(0.55, 2.3, 2.25), ang=Angle(0, -90, -105), scale=1}}
ITEM.Models["zer0"] = {
	["0_0_0_0"]= {pos=Vector(2.5, 1.75, 1.6), ang=Angle(0, -90, -100), scale=1},
	["0_1_0_0"]= {pos=Vector(0, 0, 0), ang=Angle(0, -90, -90), scale=1}
}
/* ************* */