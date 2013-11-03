ITEM.ID = "glasses03"							--Should be a unique string that identifies the item
ITEM.Name = "Glasses"						--The name the item should display
 
ITEM.Price = 2000
 
ITEM.Model = "models/mrgiggles/skeyler/accessories/glasses03.mdl"			--Model used by the item

ITEM.Type = "glasses"								--Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Bone = "ValveBiped.Bip01_Head1"			--Bone the item is attached to. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.
ITEM.BoneMerge = false							--May be used for certain accessories to bonemerge the item instead. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.

ITEM.Colorable = false							--Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false							--Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.Rotate = 45

ITEM.CamPos = Vector(50, 30, 0)						-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(0, 0, 0) 							-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Functions = {} 								--anything that can be called but not a gmod hook but more of a "store hook" goes here

ITEM.Functions["Equip"] = function ()
												--e.g miku hair attach with the models Equip
end

ITEM.Functions["Unequip"] = function ()
												--e.g miku hair attach with the models Equip
end

ITEM.Hooks = {}

ITEM.Hooks["Think"] = function ()
												--could run some shit in think hook maybe clientside only (e.g. repositioning or HEALTH CALCULATIONS OR SOMETHING LIKE THAT)
end

ITEM.Models = {} 
ITEM.Models["elin"] = {pos=Vector(1.8, 2.6, 0), ang=Angle(0, -90, -68), scale=1.05} 
ITEM.Models["miku"] = {pos=Vector(1.9, 1.15, 0), ang=Angle(0, -90, -83), scale=1} 
ITEM.Models["tron"] = {pos=Vector(3.25, 3.25, 0), ang=Angle(0, -90, -80), scale=1.05} 
ITEM.Models["usif"] = {pos=Vector(1.1, 2.8, 0.1), ang=Angle(0, -90, -90), scale=1} 
ITEM.Models["zer0"] = {pos=Vector(3.1, 2.5, 0), ang=Angle(0, -90, -75), scale=0.9} 