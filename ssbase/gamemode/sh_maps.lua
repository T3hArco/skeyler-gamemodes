---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 

SS.MapFile = "ss/maplist.txt" 

if !file.IsDir("ss", "DATA") then file.CreateDir("ss") end  

SS.MapList = {} 

function SS:LoadMaps() 
	if !file.Exists(SS.MapFile, "DATA") then Error("No map file!\n") return end 
	local data = file.Read(SS.MapFile, "DATA") 
	if !data or string.Trim(data) == "" then SS.MapList = {} return end 
	data = util.JSONToTable(data) 
	SS.MapList = data 
end  

function SS:SaveMaps() 
	file.Write(SS.MapFile, util.TableToJSON(SS.MapList)) 
end 

function SS:RemoveMap(name) 
	SS.MapList[name] = false 
	SS:SaveMaps() 
end 

SS:LoadMaps() 
