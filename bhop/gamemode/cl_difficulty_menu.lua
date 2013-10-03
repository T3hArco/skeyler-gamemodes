---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

surface.CreateFont("DiffMenu", {font="Arvil Sans", size=32, weight=300, blursize=0.4})
surface.CreateFont("CloseFont", {font="Arial", size=16, 500}) 

local PANEL = {} 
function PANEL:Init() 
	self:SetKeyboardInputEnabled(false) 
	self:SetMouseInputEnabled(true)

	self:NoClipping(true) 

	self.LevelPanels = {} 
	self.Width, self.Height = 4, 4 
	for k,v in pairs(GAMEMODE.Levels) do 
		local Button = vgui.Create("DPanel", self) 
		Button:SetPos(4, self.Height) 
		Button:SetSize(425, 65) 
		Button:NoClipping(true) 
		Button.Text = string.upper(v.name) 
		function Button.OnMouseReleased() 
			RunConsoleCommand("level_select", k) 
			GAMEMODE:SetGUIBlur(false) 
			gui.EnableScreenClicker(false)
			self:SetVisible(false) 
		end 

		function Button.Paint() 
			local w, h = Button:GetSize()
			if !Button.Hovered then  
				surface.SetDrawColor(255, 255, 255, 255*0.15) 
				surface.DrawRect(0, 0, w, h) 
			end 
			if k < #GAMEMODE.Levels then 
				surface.SetDrawColor(255, 255, 255, 255*0.25) 
				surface.DrawRect(0, h, w, 2) 
			end 

			surface.SetFont("DiffMenu") 
			local tw, th = surface.GetTextSize(Button.Text) 
			surface.SetTextPos(w/2-tw/2+1, h/2-th/2+1)
			surface.SetTextColor(0, 0, 0, 255*0.35) 
			surface.DrawText(Button.Text) 
			surface.SetTextPos(w/2-tw/2, h/2-th/2) 
			surface.SetTextColor(255, 255, 255, 255) 
			surface.DrawText(Button.Text) 
		end 

		self.Height = self.Height+Button:GetTall()+2
		self.Width = Button:GetWide()+8
		table.insert(self.LevelPanels, Button) 
	end  
	self.Height = self.Height+2
end 

function PANEL:PerformLayout() 
	self:SetSize(self.Width, self.Height) 
	self:SetPos(ScrW()/2-self.Width/2, ScrH()/2-self.Height/2) 
end 

function PANEL:Paint(w, h) 
	draw.RoundedBoxEx(2, 0, 0, w, 4, Color(255, 255, 255, 255*0.4), true, true, false, false) 
	draw.RoundedBoxEx(2, 0, h-4, w, 4, Color(255, 255, 255, 255*0.4), false, false, true, true) 
	surface.SetDrawColor(255, 255, 255, 255*0.4) 
	surface.DrawRect(0, 4, 4, h-8) 
	surface.DrawRect(w-4, 4, 4, h-8) 

	surface.SetDrawColor(255, 255, 255, 255*0.1) 
	surface.DrawRect(2, 2, w-4, h-4) 

	surface.SetTextColor(255, 255, 255, 255) 
	surface.SetFont("CloseFont") 
	local tw, th = surface.GetTextSize("Press F2 to close") 
	surface.SetTextPos(w/2-tw/2, h+5) 
	surface.DrawText("Press F2 to close") 
end 
vgui.Register("SS_DifficultyMenu", PANEL, "DPanel") 
