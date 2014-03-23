---------------------------
--        Deathrun       -- 
-- Created by xAaron113x --
--------------------------- 

function GetFilteredPlayers(filters) 
	filters = filters or {}
	local players = {} 
	for k,v in pairs(player.GetAll()) do 
		if table.HasValue(filters, v:Team()) then 
			table.insert(players, v) 
		end 
	end 
	return players 
end 

-- Credit to STGamemodes for this one.
function rpairs(t)
	-- math.randomseed(os.time())
	local keys = {}
	for k,_ in pairs(t) do
		table.insert(keys, k)
	end
	return function()
		if(#keys == 0) then
			return nil
		end
		local i = math.random(1, #keys)
		local k = keys[i]
		local v = t[k]
		table.remove(keys, i)
		return k, v
	end
end
