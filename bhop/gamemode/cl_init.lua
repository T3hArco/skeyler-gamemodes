---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

include("shared.lua")
include("sh_levels.lua") 
include("cl_difficulty_menu.lua")

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
