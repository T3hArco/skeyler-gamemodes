ITEM.ID = "pumpkinhat"										-- Should be a unique string that identifies the item
ITEM.Name = "Pumpkin Hat"									-- The name the item should display
 
ITEM.Price = 2000
 
ITEM.Model = "models/mrgiggles/skeyler/hats/pumpkin.mdl"	-- Model used by the item

ITEM.Type = "mask"											-- Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = false										-- Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false										-- Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.Rotate = 45

ITEM.CamPos = Vector(50, 30, 2)								-- Used the modify the position of the camera on DModelPanels 
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

/* HAT VARIABLES */
ITEM.Bone = "ValveBiped.Bip01_Head1"						-- Bone the item is attached to. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.
ITEM.BoneMerge = false										-- May be used for certain accessories to bonemerge the item instead. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.

ITEM.Models = {} 
ITEM.Models["elin"] = {pos=Vector(0, -0.75, 0), ang=Angle(8, -90, -90), scale=1.15} 
ITEM.Models["miku"] = {pos=Vector(0, -1.75, 0), ang=Angle(8, -90, -90), scale=1.125} 
ITEM.Models["tron"] = {pos=Vector(1, -0.8, 0), ang=Angle(5, -90, -90), scale=1.175} 
ITEM.Models["usif"] = {pos=Vector(-0.875, 0.85, 0.2), ang=Angle(5, -90, -90), scale=1.025} 
ITEM.Models["zer0"] = {pos=Vector(0, -1, 0), ang=Angle(5, -90, -90), scale=1.1} 
/* ************* */