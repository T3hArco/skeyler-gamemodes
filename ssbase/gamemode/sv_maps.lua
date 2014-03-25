---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

SS.MapList = {} 

local filename = "maplist.txt" 

-- Set this to run in the SS.SetupGamemode function in your init.lua
function SS:LoadMaps() 
	if !SS.ServerDir then Error("YOU HAVE NO SERVERDIR!\n") return end 
	local data = file.Read(SS.ServerDir..filename, "DATA") 
	if !data or string.Trim(data) == "" then SS.MapList = {} return end 
	data = util.JSONToTable(data) 
	SS.MapList = table.Merge(SS.MapList, data) -- Overwrite hardcoded with ones stored in data 
	self:SaveMaps() 
end  

function SS:SaveMaps() 
	if !SS.ServerDir then Error("YOU HAVE NO SERVERDIR!\n") return end 
	file.Write(SS.ServerDir..filename, util.TableToJSON(SS.MapList)) 
end 

function SS:RemoveMap(name) 
	SS.MapList[name] = false 
	SS:SaveMaps() 
end 
