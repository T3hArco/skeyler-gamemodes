SS.STORE = {}

SS.STORE.Categories = {"Hats","Models","Accesories"}

SS.STORE.Item = {}

function SS.STORE.LoadItems()
	for id,c in pairs(self.Categories) do
		for _,v in pairs(file.Find("storeitems/"..string.lower(c).."/*","LUA")) do
			ITEM = {}
			ITEM.Category = id
			include("storeitems/"..string.lower(c).."/"..v)
			
			local item = ITEM
			for k,hook in pairs(item.Hooks) do
				hook.Add(k, 'Item_' .. item.Name .. '_' .. prop, function(...)
					for _, ply in pairs(player.GetAll()) do
						if ply:HasEquipped(item.ID) then
							item[k](item, ply, ...)
						end
					end
				end)
			end
			
			SS.STORE.Items[ITEM.ID] = ITEM
		end
	end
end