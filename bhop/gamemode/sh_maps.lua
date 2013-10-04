---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 

SS.MapFile = "ss/maplist.txt" 

if !file.IsDir("ss", "DATA") then file.CreateDir("ss") end  

GM.MapList = {} 
function GM:AddMap(name, payout, spawnpos, spawnang, spawnareamin, spawnareamax, finishareamin, finishareamax, ignoredoors) 
	self.MapList[name] = {name=name, payout=payout, spawnpos=spawnpos, spawnang=spawnang, spawnarea={min=spawnareamin, max=spawnareamax}, finisharea={pos=finishareapos, min=finishareamin, max=finishareamax}, ignoredoors}
	self:SaveMaps() 
end 

function GM:RemoveMap(name) 
	self.MapList[name] = false 
	self:SaveMaps() 
end 

function GM:LoadMaps() 
	if !file.Exists(SS.MapFile, "DATA") then Error("No map file!\n") return end 
	local data = file.Read(SS.MapFile, "DATA") 
	if !data or string.Trim(data) == "" then self.MapList = {} return end 
	data = util.JSONToTable(data) 
	self.MapList = data 
end  
GM:LoadMaps() 

function GM:SaveMaps() 
	file.Write(SS.MapFile, util.TableToJSON(self.MapList)) 
end 


-- GM:AddMap("bhop_cobblestone_gm", 200, Vector(68, 433, 192.88), Angle(0, -180, 0),
--  Vector(-192, 194, 129), Vector(285, 670, 130),
--  Vector(133, 2724, 129), Vector(360, 2870, 130))
