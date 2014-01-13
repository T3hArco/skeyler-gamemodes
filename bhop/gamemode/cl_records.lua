---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

local rw, rh = 622, 626
RECORDMENU = false 

NAME_BANK = {"Aaron", "Snoipa", "Arco", "George", "Knoxed", "Giggles", "Ntag", "Bentech", "Sassafrass", "Ugly", "Tobuscus", "PewDiePie", "1337_h4xR", "Taux", "Flynt", "Spacetech", "Bob"} 



surface.CreateFont("ss_records_header", {font="Arvil Sans", size=56, weight=500}) 
surface.CreateFont("ss_records_buttons", {font="Arial", size=24, weight=500}) 
surface.CreateFont("ss_records_listheader", {font="Arial", size=24, weight=500}) 
surface.CreateFont("ss_records_close", {font="Arial", size=20, weight=650}) 
surface.CreateFont("ss_records_list", {font="Arial", size=22, weight=500}) 
surface.CreateFont("ss_records_pages", {font="Arial", size=22, weight=500}) 

NEXT_ARROW = Material("skeyler/next_arrow.png") 

local PANEL = {} 
function PANEL:Init() 
	self.page = 1
	self:SetSize(rw, rh)

	self.CloseBtn = vgui.Create("DPanel", self) 

	function self.CloseBtn:Paint(w, h) 
		if self.Hovered then 
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 255*0.2)) 
		end 

		surface.SetFont("ss_records_close") 
		local tw, th = surface.GetTextSize("Close") 
		surface.SetTextColor(0, 0, 0, 255*0.35) 
		surface.SetTextPos(w/2-tw/2+1, h/2-th/2+1) 
		surface.DrawText("Close") 
		surface.SetTextColor(255, 255, 255, 255) 
		surface.SetTextPos(w/2-tw/2, h/2-th/2) 
		surface.DrawText("Close") 
	end 

	function self.CloseBtn:OnMouseReleased(mcode) 
		if mcode == MOUSE_LEFT then 
			RunConsoleCommand("records") 
		end 
	end 

	self.Container = vgui.Create("DPanel", self) 
	self.Container.Paint = nil 

	self.LevelButtons = {} 
	for k,v in pairs(GAMEMODE.Levels) do 
		local Button = vgui.Create("DPanel", self.Container) 
		Button.T = v 

		function Button:Paint(w, h) 
			if self.Selected then 
				surface.SetDrawColor(0, 0, 0, 255*0.35) 
				surface.DrawRect(0, 0, w, h)
			elseif self.Hovered then 
				surface.SetDrawColor(0, 0, 0, 255*0.275) 
				surface.DrawRect(1, 1, w-2, h-2) 
				surface.SetDrawColor(255, 255, 255, 255*0.275) 
				surface.DrawOutlinedRect(0, 0, w, h) 
			else 
				surface.SetDrawColor(0, 0, 0, 255*0.2) 
				surface.DrawRect(1, 1, w-2, h-2) 
				surface.SetDrawColor(255, 255, 255, 255*0.2) 
				surface.DrawOutlinedRect(0, 0, w, h) 
			end 

			surface.SetFont("ss_records_buttons") 
			local tw, th = surface.GetTextSize(self.T.name) 
			surface.SetTextPos(w/2-tw/2+1, h/2-th/2+1) 
			surface.SetTextColor(0, 0, 0, 255*0.2) 
			surface.DrawText(self.T.name) 
			surface.SetTextPos(w/2-tw/2, h/2-th/2) 
			surface.SetTextColor(255, 255, 255, 255) 
			surface.DrawText(self.T.name) 
		end 

		function Button:OnMouseReleased(mcode) 
			if mcode == MOUSE_LEFT then 
				RECORDMENU:SelectDifficulty(self.T.id) 
			end 
		end 

		self.LevelButtons[k] = Button
	end  

	self.StyleButtons = {} 
	for k,v in pairs(GAMEMODE.Styles) do 
		local Button = vgui.Create("DPanel", self.Container) 
		Button.T = v 

		function Button:Paint(w, h) 
			if self.Selected then 
				surface.SetDrawColor(0, 0, 0, 255*0.35) 
				surface.DrawRect(0, 0, w, h)
			elseif self.Hovered then 
				surface.SetDrawColor(0, 0, 0, 255*0.275) 
				surface.DrawRect(1, 1, w-2, h-2) 
				surface.SetDrawColor(255, 255, 255, 255*0.275) 
				surface.DrawOutlinedRect(0, 0, w, h) 
			else 
				surface.SetDrawColor(0, 0, 0, 255*0.2) 
				surface.DrawRect(1, 1, w-2, h-2) 
				surface.SetDrawColor(255, 255, 255, 255*0.2) 
				surface.DrawOutlinedRect(0, 0, w, h) 
			end 

			surface.SetFont("ss_records_buttons") 
			local tw, th = surface.GetTextSize(self.T.name) 
			surface.SetTextPos(w/2-tw/2+1, h/2-th/2+1) 
			surface.SetTextColor(0, 0, 0, 255*0.2) 
			surface.DrawText(self.T.name) 
			surface.SetTextPos(w/2-tw/2, h/2-th/2) 
			surface.SetTextColor(255, 255, 255, 255) 
			surface.DrawText(self.T.name) 
		end 

		function Button:OnMouseReleased(mcode) 
			if mcode == MOUSE_LEFT then 
				RECORDMENU:SelectStyle(self.T.id) 
			end 
		end 

		self.StyleButtons[k] = Button
	end 

	self:SelectDifficulty(3) 
	self:SelectStyle(1) 

	self.Pages = vgui.Create("DPanel", self.Container) 
	self.Pages.Paint = nil 

	self.CurPage = vgui.Create("DPanel", self.Pages) 
	function self.CurPage:Paint(w, h) 
		surface.SetFont("ss_records_pages") 
		local tw, th = surface.GetTextSize(tostring(RECORDMENU.page).."/32") 
		surface.SetTextPos(w/2-tw/2, h/2-th/2)  
		surface.SetTextColor(255, 255, 255, 255) 
		surface.DrawText(tostring(RECORDMENU.page).."/32") 
	end 

	self.NextPage = vgui.Create("DPanel", self.Pages)  
	function self.NextPage:Paint(w, h) 
		surface.SetMaterial(NEXT_ARROW) 
		surface.SetDrawColor(255, 255, 255, 255) 
		surface.DrawTexturedRect(self:GetWide()/2-11/2, self:GetTall()/2-13/2, 11, 13) 
	end 

	function self.NextPage:OnMouseReleased(mcode) 
		if mcode == MOUSE_LEFT then 
			RECORDMENU.page = math.min(RECORDMENU.page+1, 32) 
			RECORDMENU:UpdateList()
		end 
	end 

	self.PrevPage = vgui.Create("DPanel", self.Pages)  
	function self.PrevPage:Paint(w, h) 
		surface.SetMaterial(NEXT_ARROW) 
		surface.SetDrawColor(255, 255, 255, 255) 
		surface.DrawTexturedRectRotated(self:GetWide()/2-11/2+5, self:GetTall()/2-13/2+7, 11, 13, 180) 
	end 

	function self.PrevPage:OnMouseReleased(mcode) 
		if mcode == MOUSE_LEFT then 
			RECORDMENU.page = math.max(1, RECORDMENU.page-1) 
			RECORDMENU:UpdateList() 
		end 
	end 


	self.ListPanel = vgui.Create("DPanel", self.Container) 
	self.ListPanel.Paint = nil 
	-- self.ListPanel.Paint = function()
	-- 	local w, h = self.ListPanel:GetSize()  
	-- 	local lastY = 0 
	-- 	surface.SetDrawColor(255, 255, 255, 255*0.3) 
	-- 	surface.DrawRect(0, lastY, w, 30) 
	-- 	lastY = lastY+30 

	-- 	local slot = 1 
	-- 	local bgcolor = Color(255, 255, 255, 255*0.06) 
	-- 	for i=1, 10 do 
	-- 		surface.SetDrawColor(bgcolor) 
	-- 		surface.DrawRect(0, 30*slot, w, 30) 
	-- 		slot = slot+1 
	-- 		if bgcolor.a == 255*0.06 then 
	-- 			bgcolor.a = 255*0.12 
	-- 		else 
	-- 			bgcolor.a = 255*0.06 
	-- 		end 
	-- 	end 
	-- end  
	self.List = {} 
	local less = true 
	for i=1, 11 do 
		local PANEL = vgui.Create("DPanel", self.ListPanel) 
		PANEL.name = "" 
		PANEL.time = ""
		if i == 1 then 
			function PANEL:Paint(w, h) 
				surface.SetDrawColor(255, 255, 255, 255*0.3) 
				surface.DrawRect(0, 0, w, h) 

				surface.SetFont("ss_records_listheader") 
				local tw, th = surface.GetTextSize("Name") 
				surface.SetTextPos(RECORDMENU.nw, h/2-th/2) 
				surface.SetTextColor(255, 255, 255, 255) 
				surface.DrawText("Name") 

				local tw, th = surface.GetTextSize("Time")
				surface.SetTextPos(self:GetWide()-100, h/2-th/2) 
				surface.DrawText("Time") 
				RECORDMENU.timecenter = self:GetWide()-100+tw/2
			end 
		else 
			function PANEL:Paint(w, h) 
				surface.SetDrawColor(255, 255, 255, 255*(self.less and 0.06 or 0.12))  
				surface.DrawRect(0, 0, w, h) 

				surface.SetFont("ss_records_list")

				local tw, th = surface.GetTextSize(tostring(RECORDMENU.page*10-10+i-1)..".")
				surface.SetTextPos(5, h/2-th/2) 
				surface.SetTextColor(255, 255, 255, 255) 
				surface.DrawText(tostring(RECORDMENU.page*10-10+i-1)..".") 

				local tw, th = surface.GetTextSize(self.info.name) 
				surface.SetTextPos(RECORDMENU.nw, h/2-th/2) 
				surface.SetTextColor(255, 255, 255, 255) 
				surface.DrawText(self.info.name) 

				local tw, th = surface.GetTextSize(FormatTime(self.info.time)) 
				surface.SetTextPos(RECORDMENU.timecenter-tw/2, h/2-th/2) 
				surface.SetTextColor(255, 255, 255, 255) 
				surface.DrawText(FormatTime(self.info.time))
			end 
			PANEL.less = less 
			less = !less 
			print(less) 
		end
		self.List[i] = PANEL  
	end 
	self:UpdateList()
end 

function PANEL:UpdateList() 
	local n = 1
	self.nw = 0 
	surface.SetFont("ss_records_list") 
	local w, h = 0, 0
	for i=self.page*10, self.page*10+10 do 
		w, h = surface.GetTextSize(i..".") 
		if w+15 > self.nw then 
			self.nw = w+15 
		end 
		self.List[n].info = {name=table.Random(NAME_BANK), time=n*self.page*(math.random(1, 10)/3)}  
		n = n+1
	end 
end 

function PANEL:SelectDifficulty(id) 
	self.SelectedDifficulty = id 
	for k,v in pairs(self.LevelButtons) do 
		if k == id then 
			v.Selected = true 
		else 
			v.Selected = false 
		end 
	end 
end 

function PANEL:SelectStyle(id) 
	self.SelectedStyle = id 
	for k,v in pairs(self.StyleButtons) do 
		if k == id then 
			v.Selected = true 
		else 
			v.Selected = false 
		end 
	end 
end 

function PANEL:PerformLayout(w, h) 
	self:SetSize(rw, rh)  
	self:SetPos(ScrW()/2-w/2, ScrH()/2-h/2) 

	surface.SetFont("ss_records_close") 
	local tw, th = surface.GetTextSize("Close") 
	self.CloseBtn:SetSize(tw+20, th+5)  
	self.CloseBtn:SetPos(w-self.CloseBtn:GetWide(), 42-self.CloseBtn:GetTall()+10) 

	self.Container:SetPos(5, 102) 
	self.Container:SetSize(w-10, h-102-26) 

	local LastX = 0 
	for k,v in pairs(self.LevelButtons) do 
		v:SetPos(LastX, 0) 
		v:SetSize(self.Container:GetWide()/3, 42) 
		LastX = LastX+v:GetWide() 
	end 

	LastX = 0 
	for k,v in pairs(self.StyleButtons) do 
		v:SetPos(LastX, 42) 
		v:SetSize(self.Container:GetWide()/3, 42) 
		LastX = LastX+v:GetWide() 
	end 

	self.ListPanel:SetPos(18, 18+42*2) 
	self.ListPanel:SetSize(w-10-18*2, 30*11) 

	local Slot = 0 
	for n, PANEL in pairs(self.List) do 
		PANEL:SetSize(self.ListPanel:GetWide(), 30) 
		PANEL:SetPos(0, Slot*30) 
		Slot = Slot+1 
	end 

	surface.SetFont("ss_records_pages") 
	local tw, th = surface.GetTextSize(tostring(self.Page).."/32") 
	self.NextPage:SetSize(15, th+8) 
	self.PrevPage:SetSize(15, th+8)
	self.CurPage:SetSize(tw, th) 
	self.Pages:SetSize(self.NextPage:GetWide()+self.PrevPage:GetWide()+tw+10, th+8) 
	self.NextPage:SetPos(self.Pages:GetWide()-self.NextPage:GetWide(), self.Pages:GetTall()/2-self.NextPage:GetTall()/2) 
	self.CurPage:SetPos(self.Pages:GetWide()-self.NextPage:GetWide()-tw, self.Pages:GetTall()/2-th/2) 
	self.PrevPage:SetPos(self.Pages:GetWide()-self.NextPage:GetWide()-tw-self.PrevPage:GetWide(), self.Pages:GetTall()/2-self.PrevPage:GetTall()/2) 
	self.Pages:SetPos(self.Container:GetWide()/2-self.Pages:GetWide()/2, self.Container:GetTall()-self.Pages:GetTall()-20) 
end 

function PANEL:Paint(w, h) 
	surface.SetFont("ss_records_header") 
	local tw, th = surface.GetTextSize("Records") 
	surface.SetTextPos(1, 1) 
	surface.SetTextColor(0, 0, 0, 35) 
	surface.DrawText("Records") 
	surface.SetTextPos(0, 0) 
	surface.SetTextColor(255, 255, 255, 255) 
	surface.DrawText("Records") 

	draw.RoundedBox(2, 0, 57, w, 45, Color(255, 255, 255, 255)) 
	draw.RoundedBox(2, 0, h-26, w, 26, Color(255, 255, 255, 255))  
	surface.SetDrawColor(255, 255, 255, 255*0.36) 
	surface.DrawRect(5, 102, w-10, h-102-26) 
end 
vgui.Register("ss_records", PANEL, "DPanel") 

concommand.Add("records", function() 
	if !RECORDMENU then 
		RECORDMENU = vgui.Create("ss_records") 
		GAMEMODE:SetGUIBlur(true) 
		gui.EnableScreenClicker(true)
		return 
	end 
	if RECORDMENU:IsVisible() then 
		GAMEMODE:SetGUIBlur(false) 
		gui.EnableScreenClicker(false)
		RECORDMENU:SetVisible(false) 
	else 
		RECORDMENU:SetVisible(true) 
		GAMEMODE:SetGUIBlur(true) 
		gui.EnableScreenClicker(true)
	end 
end )  
