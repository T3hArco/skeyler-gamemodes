---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

SS.HardCodedMaps = {} 

function SS:AddMap(name, payout, spawnpos, spawnang, spawnareamin, spawnareamax, finishareamin, finishareamax) 
	SS.MapList[name] = {name=name, payout=payout, spawnpos=spawnpos, spawnang=spawnang, spawnarea={min=spawnareamin, max=spawnareamax}, finisharea={pos=finishareapos, min=finishareamin, max=finishareamax}}
	SS:SaveMaps() 
end 

--[[SS:AddMap("bhop_cobblestone_gm", 20000, Vector(68, 433, 192.88), Angle(0, -180, 0),
 Vector(-192, 194, 129), Vector(285, 670, 130),
 Vector(133, 2724, 129), Vector(360, 2870, 130))]]