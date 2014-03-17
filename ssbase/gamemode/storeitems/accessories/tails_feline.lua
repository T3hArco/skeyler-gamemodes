ITEM.ID = "tails_feline"									-- Should be a unique string that identifies the item
ITEM.Name = "Tail (Cat)"									-- The name the item should display
 
ITEM.Price = 2000
 
ITEM.Model = "models/captainbigbutt/skeyler/accessories/tails_feline.mdl"	-- Model used by the item

ITEM.Type = "tail"											-- Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = true										-- Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false										-- Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.Rotate = 45

ITEM.CamPos = Vector(30, 22, -1)							-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(-20, 0, -1) 							-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Slot = SS.STORE.SLOT.ACCESSORY_4						-- What inventory slot this item shoud be placed in.

ITEM.Functions = {} 										-- Anything that can be called but not a gmod hook but more of a "store hook" goes here

ITEM.Functions["Equip"] = function ()						-- e.g miku hair attach with the models Equip
end

ITEM.Functions["Unequip"] = function ()						-- e.g miku hair attach with the models Equip
end

ITEM.Hooks = {}												-- Could run some shit in think hook maybe clientside only (e.g. repositioning or HEALTH CALCULATIONS OR SOMETHING LIKE THAT)

ITEM.Hooks["UpdateAnimation"] = function (item,ply)
	if CLIENT then
		if(SS.STORE.CSModels[ply] && SS.STORE.CSModels[ply][item.ID]) then
			local i = SS.STORE.CSModels[ply][item.ID]
			if(ply:GetVelocity():Length2D() <= 150 and ply:GetVelocity():Length2D() >= 1 ) then
				ply.idle = false
				ply.walking = true
				ply.running = false
			elseif(ply:GetVelocity():Length2D() > 150) then
				ply.idle = false
				ply.walking = false
				ply.running = true
			elseif(ply:GetVelocity():Length2D() == 0) then
				ply.idle = true
				ply.walking = false
				ply.running = false
			else
				ply.idle = true
				ply.walking = false
				ply.running = false
			end
			
			if ply.idle then
				if i:GetSequence() > 6 then
					i:SetSequence(math.random(1,6))
				end
			elseif ply.walking then 
				if i:GetSequence() != 7 then
					i:SetSequence(7) 
				end
			elseif ply.running then
				if i:GetSequence() < 8 then
					i:SetSequence(math.random(8,11)) 
				end
			end
			if(i.lastthink) then
				i:FrameAdvance(CurTime()-i.lastthink) --this function better fucking work I HAD TO FIND THIS IN DMODELPANEL ITS NOT EVEN DOCUMENTED!
			end
			i.lastthink = CurTime()
		end
	end
end

/* ACCESSORY VARIABLES */
ITEM.Bone = "ValveBiped.Bip01_Spine"						-- Bone the item is attached to. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.
ITEM.BoneMerge = false										-- May be used for certain accessories to bonemerge the item instead. ONLY NEED TO DEFINE FOR HATS/ACCESSORIES.

ITEM.Models = {} 
ITEM.Models[SS.STORE.MODEL.DANTE] = {{0, 0, 0, pos=Vector(0, -1, -0.6), ang=Angle(0, 180, -90), scale=2.0774}}
ITEM.Models[SS.STORE.MODEL.ELIN] = {{0, 0, 0, pos=Vector(0, -2.6, -0.6), ang=Angle(0, 180, -90), scale=2.0774}}
ITEM.Models[SS.STORE.MODEL.MIKU] = {{0, 0, 0, pos=Vector(-0.5, -3.7, -0.6), ang=Angle(0, 180, -90), scale=2.0774}}
ITEM.Models[SS.STORE.MODEL.TRON] = {{0, 0, 0, pos=Vector(0.2, -3.5, -0.6), ang=Angle(0, 180, -90), scale=2.0774}}
ITEM.Models[SS.STORE.MODEL.USIF] = {{0, 0, 0, pos=Vector(1.5, -0.75, -0.6), ang=Angle(0, 180, -90), scale=2.0774}}
ITEM.Models[SS.STORE.MODEL.ZERO] = {{0, 0, 0, pos=Vector(0.35, -5.25, -0.6), ang=Angle(0, 180, -90), scale=2.0774}}
/* ************* */