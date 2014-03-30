---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

SS.STORE = {}
SS.STORE.Categories = {"Player Models", "Hats", "Accessories"}
SS.STORE.Items = {}

if (CLIENT) then
	
	-- The clientside container for the items that they own.
	SS.STORE.INVENTORY = {}
end

---------------------------------------------------------
--
---------------------------------------------------------

SS.STORE.SLOT = {}

SS.STORE.SLOT.HEAD = 1
SS.STORE.SLOT.EFFECT = 2 -- UNUSED AT THE MOMENT
SS.STORE.SLOT.MODEL = 3
SS.STORE.SLOT.ACCESSORY_1 = 4
SS.STORE.SLOT.ACCESSORY_2 = 5
SS.STORE.SLOT.ACCESSORY_3 = 6
SS.STORE.SLOT.ACCESSORY_4 = 7

-- Used when generating the slots. Set to the highest index.
SS.STORE.SLOT.MAXIMUM = 7

---------------------------------------------------------
--
---------------------------------------------------------

SS.STORE.SLOT.NAME = {}

SS.STORE.SLOT.NAME[SS.STORE.SLOT.HEAD] = "Hat"
SS.STORE.SLOT.NAME[SS.STORE.SLOT.EFFECT] = "Effect"
SS.STORE.SLOT.NAME[SS.STORE.SLOT.MODEL] = "Model"
SS.STORE.SLOT.NAME[SS.STORE.SLOT.ACCESSORY_1] = "Accessory 1"
SS.STORE.SLOT.NAME[SS.STORE.SLOT.ACCESSORY_2] = "Accessory 2"
SS.STORE.SLOT.NAME[SS.STORE.SLOT.ACCESSORY_3] = "Accessory 3"
SS.STORE.SLOT.NAME[SS.STORE.SLOT.ACCESSORY_4] = "Accessory 4"

---------------------------------------------------------
--
---------------------------------------------------------

SS.STORE.MODEL = {}

SS.STORE.MODEL.DANTE = "models/captainbigbutt/skeyler/playermodels/dante.mdl"
SS.STORE.MODEL.ELIN = "models/captainbigbutt/skeyler/playermodels/elin.mdl"
SS.STORE.MODEL.MIKU = "models/captainbigbutt/skeyler/playermodels/miku.mdl"
SS.STORE.MODEL.TRON = "models/captainbigbutt/skeyler/playermodels/tron.mdl"
SS.STORE.MODEL.ZERO = "models/captainbigbutt/skeyler/playermodels/zer0.mdl"
SS.STORE.MODEL.USIF = "models/captainbigbutt/skeyler/playermodels/usifarmor.mdl"

-- First number -> Model bodygroup index.
-- Second number -> The item bodygroup index.
-- Third number -> What the bit.bor of the other numbers should equal to.

---------------------------------------------------------
-- Item customization.
---------------------------------------------------------

SS.STORE.CUSTOM = {}

SS.STORE.CUSTOM.SKIN = "skin"
SS.STORE.CUSTOM.COLOR = "color"
SS.STORE.CUSTOM.BODYGROUP = "bodygroup"

---------------------------------------------------------
--
---------------------------------------------------------
  
function SS.STORE:LoadItems()
	for id,c in pairs(self.Categories) do  
		c = string.gsub(c," ","")
		for _,v in pairs(file.Find("ssbase/gamemode/storeitems/"..string.lower(c).."/*","LUA")) do 
			ITEM = {}
			ITEM.Category = id 

			include("storeitems/"..string.lower(c).."/"..v)
			
			local item = ITEM
				
			-- Since we're calling Think and other hooks manually we don't need this?
		--[[	if item.Hooks and istable(item.Hooks) then 
				for k,h in pairs(item.Hooks) do
					hook.Add(k, 'Item_' .. item.Name .. '_' .. k, function(...)
						for _, ply in pairs(player.GetAll()) do
							if ply.HasEquipped && ply:HasEquipped(item.ID) then
								item.Hooks[k](item, ply, ...)
							end
						end
					end)
				end 
			end ]]
			
			util.PrecacheModel(ITEM.Model) 

			SS.STORE.Items[ITEM.ID] = ITEM

			if SERVER then AddCSLuaFile("storeitems/"..string.lower(c).."/"..v) end 
		end
	end
end 

SS.STORE:LoadItems()

---------------------------------------------------------
-- Item hooks.
---------------------------------------------------------

if (SERVER) then
	hook.Add("Think", "ss.gear.Think", function()
		local players = player.GetAll()
		
		for k, player in pairs(players) do
			local equipped = player.storeEquipped
			
			if (equipped) then
				for i = 1, SS.STORE.SLOT.MAXIMUM do
					local unique = equipped[i].unique
					
					if (unique) then
						local item = SS.STORE.Items[unique]
						
						if (item and item.Hooks and item.Hooks.Think) then
							item.Hooks.Think(equipped, player)
						end
					end
				end
			end
		end
	end)
end

if (CLIENT) then
	hook.Add("UpdateAnimation", "ss.gear.UpdateAnimation", function(player, velocity, maxSequenceGroundSpeed)
		local cache = SS.Gear.GetCacheByPlayer(player)
	
		if (cache) then
			for i = 1, SS.STORE.SLOT.MAXIMUM do
				local data = cache[i]
				
				if (data) then
					local item = SS.STORE.Items[data.item]
					
					if (item and item.Hooks.UpdateAnimation) then
						item.Hooks.UpdateAnimation(cache, player)
					end
				end
			end
		end
	end)
end

---------------------------------------------------------
--
---------------------------------------------------------

function PLAYER_META:HasEquipped(id)
	local item = SS.STORE.Items[id]
	
	if (item) then
		if (CLIENT) then
			local data = SS.Gear.Get(self, item.Slot)
			
			return data and data.item and data.item == item.ID
		else
			return self.storeEquipped and self.storeEquipped[item.Slot] and self.storeEquipped[item.Slot].unique == item.ID
		end
	end
end

---------------------------------------------------------
-- Checks if a player owns an item in the store.
---------------------------------------------------------

function PLAYER_META:HasStoreItem(id)
	local item = SS.STORE.Items[id]
	
	if (item) then
		return SERVER and self.storeItems[item.ID] != nil or CLIENT and SS.STORE.INVENTORY[item.ID] != nil
	end
end

---------------------------------------------------------
-- Checks if a player can afford the item.
---------------------------------------------------------

function PLAYER_META:CanAffordItem(id)
	local item = SS.STORE.Items[id]
	
	if (item) then
		return self:HasMoney(item.Price)
	end
end

---------------------------------------------------------
-- Returns customization data.
---------------------------------------------------------

function PLAYER_META:GetItemData(id, field)
	local hasItem = self:HasStoreItem(id)
	
	if (hasItem) then
		local item = SS.STORE.Items[id]
		
		return SERVER and self.storeItems[item.ID][field] or CLIENT and SS.STORE.INVENTORY[item.ID][field]
	end
end

---------------------------------------------------------
-- Returns customization data.
---------------------------------------------------------

function PLAYER_META:GetSlotData(id)
	return SERVER and self.storeEquipped[id] or CLIENT and SS.STORE.INVENTORY[id]
end