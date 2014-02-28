---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

include("shared.lua")
include("sh_levels.lua") 
include("sh_viewoffsets.lua") 
include("player_class/player_bhop.lua")
include("cl_difficulty_menu.lua")
include("sh_styles.lua") 
include("cl_records.lua") 
include("cl_scoreboard.lua") 
include("cl_mapvote.lua") 

GM.RecordTable = {}

GM.DifficultyMenu = false 
function GM:CreateDifficultyMenu() 
	self:SetGUIBlur(true) 

	if self.DifficultyMenu then 
		if self.DifficultyMenu:IsVisible() then 
			gui.EnableScreenClicker(false)
			self.DifficultyMenu:SetVisible(false) 
			self:SetGUIBlur(false) 
			return 
		end 
		self.DifficultyMenu:SetVisible(true) 
		gui.EnableScreenClicker(true)
		return 
	end 

	self.DifficultyMenu = vgui.Create("SS_DifficultyMenu") 
	gui.EnableScreenClicker(true)
end 
concommand.Add("open_difficulties", function() GAMEMODE:CreateDifficultyMenu() end)

net.Receive("WriteRT",function()
	GAMEMODE.RecordTable = net.ReadTable()
end)

net.Receive("ModifyRT",function()
	local p = net.ReadString()
	local n = net.ReadString()
	local l = net.ReadInt(4)
	local s = net.ReadInt(4)
	local r = net.ReadInt(32)
	local t = net.ReadInt(32)
	
	if(!GAMEMODE.RecordTable[l]) then
		GAMEMODE.RecordTable[l] = {}
	end
	if(!GAMEMODE.RecordTable[l][s]) then
		GAMEMODE.RecordTable[l][s] = {}
	end
	if(r && r != 0 && GAMEMODE.RecordTable[l][s][r]) then
		table.remove(GAMEMODE.RecordTable[l][s],r)
	end
	table.insert(GAMEMODE.RecordTable[l][s],{["name"] = n,["steamid"] = p,["time"] = t})
	table.SortByMember(GAMEMODE.RecordTable[l][s], "time", function(a, b) return a > b end)
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
