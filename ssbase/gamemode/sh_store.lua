SS.STORE = {}

SS.STORE.Categories = {"Hats","Models","Accessories"}

SS.STORE.Items = {}

function SS.STORE:LoadItems()
	for id,c in pairs(self.Categories) do  
		for _,v in pairs(file.Find("ssbase/gamemode/storeitems/"..string.lower(c).."/*","LUA")) do 
			ITEM = {}
			ITEM.Category = id 

			include("storeitems/"..string.lower(c).."/"..v)
			
			local item = ITEM
			for k,h in pairs(item.Hooks) do
				hook.Add(k, 'Item_' .. item.Name .. '_' .. h, function(...)
					for _, ply in pairs(player.GetAll()) do
						if ply:HasEquipped(item.ID) then
							item[k](item, ply, ...)
						end
					end
				end)
			end
			
			util.PrecacheModel(ITEM.Model) 

			SS.STORE.Items[ITEM.ID] = ITEM

			if SERVER then AddCSLuaFile("storeitems/"..string.lower(c).."/"..v) end 
		end
	end
end 
SS.STORE:LoadItems()

local p = FindMetaTable("Player")

function p:HasEquipped(id)
	if SERVER then
		if(SS.STORE.Equipped[self] && table.HasValue(SS.STORE.Equipped[self],id) then
			return true
		else
			return false
		end
	else
		if(SS.STORE.Equipped && table.HasValue(SS.STORE.Equipped,id) then
			return true
		else
			return false
		end
	end
end