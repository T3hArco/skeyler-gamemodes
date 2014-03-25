---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

SS.MapList = {} 

local filename = "maplist.txt" 
function SS:LoadMaps() 
	if !file.Exists(SS.ServerDir..filename, "DATA") then Error("No map file!\n") return end 
	local data = file.Read(SS.ServerDir..filename, "DATA") 
	if !data or string.Trim(data) == "" then SS.MapList = {} return end 
	data = util.JSONToTable(data) 
	SS.MapList = data 
end  

function SS:SaveMaps() 
	file.Write(SS.ServerDir..filename, util.TableToJSON(SS.MapList)) 
end 

function SS:RemoveMap(name) 
	SS.MapList[name] = false 
	SS:SaveMaps() 
end 
