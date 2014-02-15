ITEM.ID = "cowboyhat"										-- Should be a unique string that identifies the item
ITEM.Name = "Cowboy Hat"									-- The name the item should display
 
ITEM.Price = 2000
 
ITEM.Model = "models/mrgiggles/skeyler/hats/cowboyhat.mdl"	-- Model used by the item

ITEM.Type = "headcoverhalf"									-- Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = false										-- Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false										-- Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.Rotate = 45

ITEM.CamPos = Vector(50, 30, -1)								-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(0, 0, -1) 								-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Slot = SS.STORE.SLOT.HEAD								-- What inventory slot this item shoud be placed in.

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
ITEM.Models[SS.STORE.MODEL.DANTE] = {{0, 0, 0, pos=Vector(6.1, -0.15, 0), ang=Angle(10, -90, -90), scale=0.8}}
ITEM.Models[SS.STORE.MODEL.ELIN] = {{0, 0, 0, pos=Vector(7.75, -2.25, 0), ang=Angle(10, -90, -90), scale=0.98}}
ITEM.Models[SS.STORE.MODEL.MIKU] = {{0, 0, 0, pos=Vector(8.1, -1.5, 0), ang=Angle(5, -90, -90), scale=0.98}}
ITEM.Models[SS.STORE.MODEL.TRON] = {{0, 0, 0, pos=Vector(8, -0.35, 0), ang=Angle(4, -90, -90), scale=0.925}}
ITEM.Models[SS.STORE.MODEL.USIF] = {{0, 0, 0, pos=Vector(5.15, 0.25, 0.2), ang=Angle(0, -90, -90), scale=0.875}}
ITEM.Models[SS.STORE.MODEL.ZERO] = {
	{0, 0, 0, pos=Vector(6.65, -0.7, 0), ang=Angle(5, -90, -90), scale=0.875},
	{0, 0, 1, pos=Vector(12.65, -0.7, 0), ang=Angle(5, -90, -90), scale=0.875}
}
/* ************* */