---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

ITEM.ID = "miku"							--Should be a unique string that identifies the item
ITEM.Name = "Hatsune Miku"						--The name the item should display
 
ITEM.Price = 200000
 
ITEM.Model = "models/captainbigbutt/skeyler/playermodels/miku.mdl"			--Model used by the item

ITEM.Type = "model"								--Also works for stuff like "mask" and such. Used for item compatibility

ITEM.Colorable = false							--Used if the model is colorable via setcolor (or in a models case, setplayercolor)
ITEM.Tintable = false							--Used if the model is colorable, but a translation is needed to $selfillumtint 

ITEM.CamPos = Vector(50, 30, 64)						-- Used the modify the position of the camera on DModelPanels 
ITEM.LookAt = Vector(0, 0, 64) 							-- Used to change the angle at which the camera views the model 
ITEM.Fov = 20 

ITEM.Slot = SS.STORE.SLOT.MODEL								-- What inventory slot this item shoud be placed in.

ITEM.Functions = {} 								--anything that can be called but not a gmod hook but more of a "store hook" goes here

ITEM.Functions["Equip"] = function ()
												--e.g miku hair attach with the models Equip
end

ITEM.Functions["Unequip"] = function ()
												--e.g miku hair attach with the models Equip
end

ITEM.Hooks = {}

function ITEM.Hooks.Think(data, ply)
	if (SERVER) then

		if ply.IsPlayer && ply:IsPlayer() && ply:GetSkin() > 0 then
			if ply:Health() > 66 then 
				ply:SetSkin(1)
			elseif ply:Health() <= 66 and ply:Health() > 33 then 
				ply:SetSkin(2)
			elseif ply:Health() <= 33 and ply:Health() > 0 then 
				ply:SetSkin(3)
			else
				ply:SetSkin(1)
			end
		end
	
		if (data) then
			local info = data[SS.STORE.SLOT.HEAD]
			
			if (info and info.unique) then
				local item = SS.STORE.Items[info.unique]
				
				if (item) then
					if (item.Type == "mask" or item.Type == "headcoverfull") then
						ply:SetBodygroup(2, 3)
					elseif (item.Type == "headcoverhalf") then
						ply:SetBodygroup(2, 2)
					elseif (item.Type == "headcoverpart") then
						ply:SetBodygroup(2, 1)
					else
						ply:SetBodygroup(2, 0)
					end
				end
			else
				ply:SetBodygroup(2, 0)
			end
		end
	end
end