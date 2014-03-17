ITEM.ID = "glasses02"										-- Should be a unique string that identifies the item
ITEM.Name = "Sunglasses"									-- The name the item should display
 
ITEM.Price = 2000
 
ITEM.Model = "models/captainbigbutt/skeyler/accessories/glasses02.mdl"	-- Model used by the item

ITEM.Type = "glasses"										-- Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = true										-- Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false										-- Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.Rotate = 45

ITEM.CamPos = Vector(23, 18, 0.75)							-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(0, 0, 0.75) 							-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Slot = SS.STORE.SLOT.ACCESSORY_1						-- What inventory slot this item shoud be placed in.

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
ITEM.Models[SS.STORE.MODEL.DANTE] = {{0, 0, 0, pos=Vector(2.3, 2.55, 0), ang=Angle(0, -90, -80), scale=0.85}}
ITEM.Models[SS.STORE.MODEL.ELIN] = {{0, 0, 0, pos=Vector(1.5, 2.4, 0), ang=Angle(0, -90, -76), scale=1}}
ITEM.Models[SS.STORE.MODEL.MIKU] = {{0, 0, 0, pos=Vector(1.5, 0.5, 0), ang=Angle(0, -90, -90), scale=1}}
ITEM.Models[SS.STORE.MODEL.TRON] = {{0, 0, 0, pos=Vector(2.75, 2.75, 0), ang=Angle(0, -90, -80), scale=1.05}}
ITEM.Models[SS.STORE.MODEL.USIF] = {{0, 0, 0, pos=Vector(0.75, 2.5, 0.2), ang=Angle(0, -90, -90), scale=1}}
ITEM.Models[SS.STORE.MODEL.ZERO] = {
{0, 0, 0, pos=Vector(3.1, 2.1, 0), ang=Angle(0, -90, -85), scale=0.9},
{0, 0, 1, pos=Vector(9.1, 2.1, 0), ang=Angle(0, -90, -85), scale=0.9}
}
/* ************* */