---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

include("shared.lua")
include("sh_viewoffsets.lua") 
include("player_class/player_bhop.lua")
include("sh_styles.lua") 
include("cl_records.lua") 
include("cl_scoreboard.lua")
include("a12c.lua") 

GM.RecordTable = {}

for k,v in pairs(GM.Styles) do
	GM.RecordTable[k] = {}
end

net.Receive("WriteRT",function()
	GAMEMODE.RecordTable = net.ReadTable()
end)

net.Receive("ModifyRT",function()
	local p = net.ReadString()
	local n = net.ReadString()
	local s = net.ReadInt(4)
	local t = net.ReadFloat()
	
	if(!GAMEMODE.RecordTable[s]) then
		GAMEMODE.RecordTable[s] = {}
	end
	
	local rem = nil
	for k,v in pairs(GAMEMODE.RecordTable[s]) do
		if(v["steamid"] == p) then
			rem = k
		end
	end
	if(rem) then
		table.remove(GAMEMODE.RecordTable[s],rem)
	end
	table.insert(GAMEMODE.RecordTable[s],{["name"] = n,["steamid"] = p,["time"] = t})
	table.SortByMember(GAMEMODE.RecordTable[s], "time", function(a, b) return a > b end)
	if(RECORDMENU) then
		RECORDMENU:UpdateList()
	end
end)

timer.Create("HullstuffSadface",5,0,function()
	if(LocalPlayer() && LocalPlayer():IsValid() && LocalPlayer().SetHull && LocalPlayer().SetHullDuck) then
		if(LocalPlayer().SetViewOffset && LocalPlayer().SetViewOffsetDucked && !viewset) then
			LocalPlayer():SetViewOffset(Vector(0, 0, 64))
			LocalPlayer():SetViewOffsetDucked(Vector(0, 0, 47))
			viewset = true
		end
		LocalPlayer():SetHull(Vector(-16, -16, 0), Vector(16, 16, 62))
		LocalPlayer():SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45))
	end
end)

hook.Add("CalcView","CheckShitOut",function(ply, pos, angles, fov, nearZ, farZ)
	if(ply:GetObserverTarget() && ply:GetObserverTarget():IsValid() && ply:GetObserverTarget():IsBot()) then
		local view = {}

		view.origin = pos
		view.angles = angles
		view.znear = nearZ
		view.zfar = farZ
		view.fov = 90
 
		return view
	end
end)

PLAYER_META.OldNick = PLAYER_META.OldNick or PLAYER_META.Nick

function PLAYER_META:Nick()
	if(self:IsBot()) then
		if(!GAMEMODE.RecordTable[1] || !GAMEMODE.RecordTable[1][1]) then
			return "[BOT] NO RECORD"
		else
			return "[BOT] "..string.sub(GAMEMODE.RecordTable[1][1]["name"],1,19).." - "..FormatTime(GAMEMODE.RecordTable[1][1]["time"])
		end
	end
	
	return self:OldNick()
end