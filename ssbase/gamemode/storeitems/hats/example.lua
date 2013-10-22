ITEM.ID = "prettyhat"							--Should be a unique string that identifies the item
ITEM.Name = "Pretty Hat"						--The name the item should display
 
ITEM.Model = "folder/folder/hat.mdl"			--Model used by the item

ITEM.Type = "hat"								--Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Bone = "ValveBiped.Bip01_Head1"			--Bone the item is attached to. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.
ITEM.BoneMerge = False							--May be used for certain accessories to bonemerge the item instead. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.

ITEM.Colorable = False							--Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = True							--Used if the model is colorable, but a translation is needed to $selfillumtint

ITEM.Functions {} 								--anything that can be called but not a gmod hook but more of a "store hook" goes here

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