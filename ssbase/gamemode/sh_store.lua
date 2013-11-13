SS.STORE = {}

SS.STORE.Equipped = {}

SS.STORE.Categories = {"PlayerModels","Hats","Accessories"}

SS.STORE.Items = {}

function SS.STORE:LoadItems()
	for id,c in pairs(self.Categories) do  
		for _,v in pairs(file.Find("ssbase/gamemode/storeitems/"..string.lower(c).."/*","LUA")) do 
			ITEM = {}
			ITEM.Category = id 

			include("storeitems/"..string.lower(c).."/"..v)
			
			local item = ITEM

			if item.Hooks and istable(item.Hooks) then 
				for k,h in pairs(item.Hooks) do
					hook.Add(k, 'Item_' .. item.Name .. '_' .. k, function(...)
						for _, ply in pairs(player.GetAll()) do
							if ply.HasEquipped && ply:HasEquipped(item.ID) then
								item.Hooks[k](item, ply, ...)
							end
						end
					end)
				end 
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
	if(SS.STORE.Equipped[self] && table.HasValue(SS.STORE.Equipped[self],id)) then
		return true
	else
		return false
	end
end