---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 

-- MAKE THE RIGHT-CLICK DRAG FROM CURRENT VIEW POSITION

-- NICE RAMP!!! LET'S SKATE
local bit = bit
local net = net
local util = util
local hook = hook
local pairs = pairs
local table = table
local CLIENT = CLIENT
local IsValid = IsValid
local EF_NODRAW = EF_NODRAW
local ValidPanel = ValidPanel
local LocalPlayer = LocalPlayer
local GetViewEntity = GetViewEntity
local ClientsideModel = ClientsideModel
local MAXIMUM_SLOTS = SS.STORE.SLOT.MAXIMUM

local HubWidth = math.max(ScrW()*0.6, 800) 
local HubHeight = math.max(ScrH()*0.725, 600)

SS.Hub = false 
SS.HubTabs = {} 
local StoreCats = {} 

surface.CreateFont("ss_hub", {font = "Arvil Sans", size = 62, weight = 400}) 
surface.CreateFont("ss_hub_blur", {font = "Arvil Sans", size = 62, weight = 400, antialias = false, blursize = 4})
surface.CreateFont("ss_hub_header", {font="Arvil Sans", size=42, weight=400}) 
surface.CreateFont("ss_hub_nav", {font="Arial", size=20, weight=800}) 
surface.CreateFont("ss_hub_store_cat", {font="Arvil Sans", size=32, weight=400}) 
surface.CreateFont("ss_hub_store_buttons", {font="Arial", size=14, weight=700}) 
surface.CreateFont("ss_hub_store_price", {font="Arial", size=18, weight=1000}) 
surface.CreateFont("ss_hub_close_tip", {font="Calibri", size=16, weight=400}) 
surface.CreateFont("ss_hub_close_tip.blur", {font="Calibri", size=16, weight=400, antialias = false, blursize = 4}) 

surface.CreateFont("ss_hub_store_purchase", {font = "Arvil Sans", size = 36, weight = 400}) 
surface.CreateFont("ss_hub_store_purchase_blur", {font = "Arvil Sans", size = 36, weight = 400, antialias = false, blursize = 6}) 

surface.CreateFont("ss.settings.label", {font = "Arvil Sans", size = 32, weight = 400}) 

function SS:AddHubTab(name, iconPath, panelName) 
	table.insert(self.HubTabs, 1, {name=name, iconPath=iconPath, panelName=panelName}) 
end 

SS:AddHubTab("Store", "skeyler/vgui/icons/store.png", "ss_hub_store") 
SS:AddHubTab("Inventory", "skeyler/vgui/icons/profile.png", "ss_hub_inventory") 
SS:AddHubTab("Settings", "skeyler/vgui/icons/settings.png", "ss_hub_settings") 
SS:AddHubTab("Help", "skeyler/vgui/icons/help.png", "ss_hub_help")

---------------------------------------------------------
-- The HUB's main panel.
---------------------------------------------------------

local PANEL = {} 
function PANEL:Init() 
	self:DockPadding(0, 75, 0, 30)
	--self:SetFocusTopLevel(true)
	self:SetDrawOnTop(true)
	
	self.nav = vgui.Create("ss_hub_nav", self) 
	
	-- The middle part.
	self.container = self:Add("ss_hub_container")
	self.container:Dock(FILL)
	
	self:InvalidateLayout(true)
	self.container:InvalidateLayout(true)
	
	GAMEMODE:SetGUIBlur(true) 
	
	self:MakePopup()
end 

function PANEL:AddCategories()
	for k, v in pairs(SS.HubTabs) do
		
		-- Create the category panel.
		self.container:AddCategory(k, v.name, v.panelName)
		
		v.button = vgui.Create("ss_hub_nav_buttons", self.nav) 
		v.button:SetIcon(v.iconPath) 
		v.button:SetLabel(v.name) 
		v.button.t = v  
		v.button.id = k 
	end
	
	self:SetTab(#SS.HubTabs, SS.HubTabs[#SS.HubTabs].button) 
end

function PANEL:GetCategory(id)
	return self.container:GetCategory(id)
end

function PANEL:PerformLayout() 
	self:SetSize(HubWidth, HubHeight) 
	self:SetPos(ScrW()/2-HubWidth/2, ScrH()/2-HubHeight/2) 

	local lastX = HubWidth+15
	for k,v in pairs(SS.HubTabs) do 
		if (ValidPanel(v.button)) then
			lastX = lastX-v.button:GetWide()-15
			v.button:SetPos(lastX, self.nav:GetTall()/2-v.button:GetTall()/2) 
		end
	end 
end 

function PANEL:SetTab(id, button)
	self.container:SetActive(id)
	
	if (ValidPanel(self.lastButton)) then
		self.lastButton.Active = false
	end
	
	self.lastButton = button
	
	if (ValidPanel(self.lastButton)) then
		self.lastButton.Active = true
	end
end 

-- TextEntry only works when you have the panel do MakePopup (???).
-- So we need this to make F1 available.
function PANEL:OnKeyCodePressed(code)
	if (code == KEY_F1) then
		RunConsoleCommand("ss_store")
	end
end

function PANEL:Think()
	local alpha = self:GetAlpha()
	if (GAMEMODE.GUIBlur) then
		if (alpha < 255) then
			self:SetAlpha(255 /10 *GAMEMODE.GUIBlurAmt)
		end
	else
	
		if (alpha > 0) then
			self:SetAlpha(255 /10 *GAMEMODE.GUIBlurAmt)
			
			if (self:GetAlpha() -4 <= 0) then
				self:SetVisible(false)
			end
		end
	end
end 
vgui.Register("ss_hub", PANEL, "EditablePanel") 

---------------------------------------------------------
-- The Hub Navigation.
---------------------------------------------------------

local PANEL = {} 
function PANEL:PerformLayout() 
	self:SetSize(HubWidth, 60) 
	self:SetPos(0, 0) 
end 

function PANEL:Paint(w, h)
	draw.SimpleText("THE HUB", "ss_hub_blur", 0, 0, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("THE HUB", "ss_hub", 1, 1, Color(0, 0, 0, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("THE HUB", "ss_hub", 0, 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

vgui.Register("ss_hub_nav", PANEL, "DPanel") 

---------------------------------------------------------
-- The Hub Navigation Buttons.
---------------------------------------------------------

local PANEL = {} 
function PANEL:Init() 
	self:NoClipping(true) 
	
	self:SetCursor( "hand" )
end 

function PANEL:PerformLayout() 
	surface.SetFont("ss_hub_nav") 
	local tw, th = surface.GetTextSize(self.Label)
	self:SetSize(7+32+7+tw+10, 36) 
end 

function PANEL:Paint(w, h) 
	if self.Hovered or self.Active then 
		draw.RoundedBox(4, 0, 0, w, h, Color(39, 207, 255, 255))
	end 

	surface.SetDrawColor(255, 255, 255, 255) 
	surface.SetMaterial(self.Icon) 
	surface.DrawTexturedRect(7, 2, 32, 32)  

	surface.SetFont("ss_hub_nav") 
	local tw, th = surface.GetTextSize(self.Label) 
	surface.SetTextPos(7+32+7+1, 2+32/2-th/2+1) 
	surface.SetTextColor(0, 0, 0, 255*0.35) 
	surface.DrawText(self.Label)
	surface.SetTextPos(7+32+7, 2+32/2-th/2) 
	surface.SetTextColor(255, 255, 255, 255) 
	surface.DrawText(self.Label) 

	if self.id != 1 then 
		surface.SetDrawColor(232, 232, 232, 255*0.1) 
		surface.DrawLine(w+7.5, 7, w+7.5, h-7) 
	end
end 

function PANEL:OnMouseReleased() 
	if self.Active then return end 
	SS.Hub:SetTab(self.id, self)  
end 

function PANEL:SetLabel(txt) 
	self.Label = txt 
end 

function PANEL:SetIcon(matPath)  
	self.Icon = Material(matPath) 
end 
vgui.Register("ss_hub_nav_buttons", PANEL, "DPanel") 

---------------------------------------------------------
-- The HUB's container.
---------------------------------------------------------

local PANEL = {}

function PANEL:Init() 
	self.categories = {}
	
	self:DockPadding(2, 60, 2, 30)
end 

function PANEL:GetCategory(id)
	return self.categories[id]
end

-- Adds a new category panel.
function PANEL:AddCategory(id, name, panelName)
	local category = self:Add(panelName)
	
	if (!ValidPanel(category)) then
		category = self:Add("Panel")
	end
	
	category:Dock(FILL)
	
	category.id = id
	category.name = name

	table.insert(self.categories, id, category)
	
	category:SetVisible(false)
	
	return category
end

-- Changes the active category.
function PANEL:SetActive(id)
	if (!self.movingPanels) then
		local current = self.categories[id]

		if (ValidPanel(self.lastCategory) and self.lastCategory != current and ValidPanel(current)) then
			if (self.lastCategory.id > current.id) then
				current:Dock(NODOCK)
				current:SetPos(self:GetWide(), current.y)
				current:MoveTo(0, current.y, 0.2, 0, 0.4, function(tbl, panel) panel:Dock(FILL) end)
				
				local last = self.lastCategory
				
				last:Dock(NODOCK)
				last:MoveTo(-self:GetWide(), last.y, 0.2, 0, 0.4, function() self.movingPanels = nil last:SetVisible(false) end)
			elseif (self.lastCategory.id < current.id) then
				current:Dock(NODOCK)
				current:SetPos(-self:GetWide(), current.y)
				
				current:MoveTo(0, current.y, 0.2, 0, 0.4, function(tbl, panel) panel:Dock(FILL) end)
				
				local last = self.lastCategory
				
				last:Dock(NODOCK)
				last:MoveTo(self:GetWide(), last.y, 0.2, 0, 0.4, function() self.movingPanels = nil last:SetVisible(false) end)
			end
			
			self.movingPanels = true
		end
		
		-- Maybe we want to update the category when you click it?
		--self.callback(self.categoryPanel, self.created)
		
		if (ValidPanel(current) and self.lastCategory != self) then
			current:SetVisible(true)
			self.created = true
			
			self.lastCategory = current
		end
		
		self.active = id
	end
end

local color_outline = Color(194, 193, 198, 160)
local color_background = Color(251, 251, 251)
local color_background_dark = Color(245, 245, 245)

function PANEL:Paint(w, h) 
	draw.RoundedBox(4, 0, 0, w, 60, color_outline)
	draw.SimpleRect(1, 1, w -2, 60 -2, color_background)
	draw.SimpleRect(2, 25, w -4, 60 -27, color_background_dark)
	
	draw.RoundedBox(4, 0, h -30, w, 30, color_outline)
	draw.SimpleRect(1, h -(30 -1), w -2, 28, color_background)
	draw.SimpleRect(2,  h -15, w -4, 13, color_background_dark)

	if (self.active) then
		local text = self.categories[self.active].name
		
		draw.SimpleText(text, "ss_hub_header", w /2, 51, Color(80, 80, 77, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	
	draw.SimpleRect(2, 60, w -4, h -90, Color(0, 0, 0, 120))
end

function PANEL:PaintOver(w, h)
	surface.DisableClipping(true)
		util.PaintShadow(w, 60, -w, -60, 4, 0.35)
		util.PaintShadow(w, h, -w, -30, 4, 0.35)
		
		draw.SimpleText("F1 TO CLOSE", "ss_hub_close_tip.blur", w, h +8, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		draw.SimpleText("F1 TO CLOSE", "ss_hub_close_tip", w +1, h +9, Color(0, 0, 0, 180), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		draw.SimpleText("F1 TO CLOSE", "ss_hub_close_tip", w, h +8, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	surface.DisableClipping(false)
end

vgui.Register("ss_hub_container", PANEL, "DPanel")

---------------------------------------------------------
-- The HUB's store.
---------------------------------------------------------

STORE = false 
local PANEL = {} 
function PANEL:Init() 
	STORE = self
	
	self.categoryList = self:Add("DScrollPanel")
	self.categoryList:Dock(LEFT)
	self.categoryList:SetWide(170)
	self.categoryList:GetCanvas():DockPadding(0, 21, 0, 0)
	
	local list = self.categoryList
	
	local listBase = self:Add("Panel")
	listBase:Dock(LEFT)
	listBase:DockPadding(0, 0, 0, 90)
	listBase:SetWide(HubWidth -615)

	function listBase:Paint(w, h)
		draw.SimpleRect(0, 0, w, h, Color(19, 19, 19, 255 *0.6))
		
		surface.SetDrawColor(19, 19, 19, 255 *0.25)
		surface.DrawLine(1, 1, w, 1)
		surface.DrawLine(w -2, 2, w -2, h -2)
		surface.DrawLine(1, h -2, w -1, h -2)
		
		if (ValidPanel(list.selected)) then
			local x, y = list.selected:GetPos()
			local height = list.selected:GetTall()
			
			surface.DrawLine(1, 2, 1, y)
			surface.DrawLine(1, y +height, 1, h -2)
		end
	end
	
	listBase.search = listBase:Add("DTextEntry")
	listBase.search:SetTall(36)
	listBase.search:SetText("search for an item in the shop...")
	listBase.search:SetFont("ss_hub_store_buttons")
	
	function listBase.search.OnEnter(_self)
		local value = _self:GetValue()
		
		self.categoryList.selected.t.List:Clear()
	
		for k2, v2 in pairs(SS.STORE.Items) do
			if v2.Category == self.categoryList.selected.t.id then
				local found = string.find(v2.Name, value, 0, true)
				
				if (found) then
					local Panel =  self.categoryList.selected.t.List:Add("ss_hub_store_icon") 
					Panel:SetSize(150, 150) 
					Panel:SetModel(v2.Model) 
					Panel:SetCamPos(v2.CamPos) 
					Panel:SetLookAt(v2.LookAt) 
					Panel:SetFOV(v2.Fov)
					Panel:SetData(v2)
					Panel.Rotate = v2.Rotate or 45 
					Panel.PPanel = self.categoryList.selected.t.Panel 

					if v2.Type == "model" then Panel.Model = true end
				end
			end 
		end 
	end
	
	function listBase.search:Paint(w, h)
		draw.RoundedBox(8, 0, 0, w, h, color_white)
		
		self:DrawTextEntryText(Color(70, 70, 70, 200), Color(60, 160, 60, 60), Color(60, 60, 60, 240))
	end
	
	function listBase:PerformLayout()
		local w, h = self:GetSize()
		
		self.search:SetWide(w /2)
		self.search:SetPos(w /2 -self.search:GetWide() /2, h -62)
	end
	
	self.Preview = self:Add("ss_hub_store_preview")
	self.Preview:Dock(FILL)
	
	for k, v in pairs(SS.STORE.Categories) do 
		StoreCats[v] = {} 
		
		local t = StoreCats[v] 
		
		t.button = vgui.Create("ss_hub_store_button") 
		t.button:SetCursor("hand")
		t.button:SetTall(44) 
		t.button:SetTitle(v) 
		t.button.t = t 
		t.id = k
		
		if (k == #SS.STORE.Categories) then
			t.button:SetLastLine(true)
		end
		
		self.categoryList:AddItem(t.button)
		
		t.Panel = listBase:Add("DScrollPanel")
		t.Panel:Dock(FILL)
		
		util.ReplaceScrollbar(t.Panel)

		t.List = vgui.Create("DIconLayout")
		t.List:SetSpaceX(12)
		t.List:SetSpaceY(12)
		t.List:SetBorder(21)
		t.List:Dock(FILL)
		t.Panel:AddItem(t.List)  

		for k2, v2 in pairs(SS.STORE.Items) do 
			if v2.Category == k then 
				local Panel = t.List:Add("ss_hub_store_icon") 
				Panel:SetSize(150, 150) 
				Panel:SetModel(v2.Model) 
				Panel:SetCamPos(v2.CamPos) 
				Panel:SetLookAt(v2.LookAt) 
				Panel:SetFOV(v2.Fov)
				Panel:SetData(v2)
				
				Panel.preview = self.Preview
				
				Panel.Rotate = v2.Rotate or 45 
				Panel.PPanel = t.Panel 

				if v2.Type == "model" then Panel.Model = true end
			end 
		end 
	end 
	self:SetCat(1) -- Lets immediately open a tab
end 

function PANEL:Paint(w, h) 
	return true
end 

function PANEL:SetCat(i) 
	for k,v in pairs(StoreCats) do 
		if v.id == i then 
			v.button.Active = true 
			v.Panel:SetVisible(true)
			
			self.categoryList.selected = v.button
		else
			v.button.Active = false 
			v.Panel:SetVisible(false) 
		end 
	end 
end 
vgui.Register("ss_hub_store", PANEL, "DPanel") 

---------------------------------------------------------
-- The store buttons.
---------------------------------------------------------

local PANEL = {} 

AccessorFunc(PANEL, "m_bLastLine", "LastLine")

function PANEL:Init() 
	self:Dock(TOP)
end 

function PANEL:SetTitle(txt) 
	self.Title = txt 
end 

function PANEL:Paint(w, h) 
	if self.Active or self.Hovered then 
		surface.SetDrawColor(19, 19, 19, 255 *0.6) 
		surface.DrawRect(0, 0, w, h) 
	end
	
	surface.SetDrawColor(19, 19, 19, 255 *0.5)
	surface.DrawRect(0, 0, w, 1) 
	
	if (self.m_bLastLine) then
		surface.DrawRect(0, h -1, w, 1) 
	end
	
	if self.Title then 
		surface.SetFont("ss_hub_store_cat") 
		local tw, th = surface.GetTextSize(self.Title) 
		surface.SetTextColor(0, 0, 0, 255*0.35) 
		surface.SetTextPos(w/2-tw/2+1, h/2-th/2+1) 
		surface.DrawText(self.Title) 
		surface.SetTextColor(255, 255, 255, 255) 
		surface.SetTextPos(w/2-tw/2, h/2-th/2) 
		surface.DrawText(self.Title) 
	end 
end 

function PANEL:OnMouseReleased() 
	STORE:SetCat(self.t.id)
end 
vgui.Register("ss_hub_store_button", PANEL, "DPanel") 

---------------------------------------------------------
-- The store icons.
---------------------------------------------------------

local PANEL = {}

AccessorFunc(PANEL, "m_bEqupIcon", "EquipIcon")
AccessorFunc(PANEL, "m_bInventoryIcon", "InventoryIcon")

local bgmat = Material("skeyler/vgui/store/icon_base.png", "noclamp smooth") 
local highlight = Material("skeyler/vgui/store/icon_highlight.png", "noclamp smooth")

function PANEL:Init()
	local this = self
	
	self:DockPadding(4, 4, 4, 4)
	
	self.Rotate = 0
	self.Ang = 45
	self:SetCamPos( Vector( 60, 30, 64 ) )
	self:SetLookAt( Vector( 0, 0, 64 ) )
	self:SetFOV( 20 )

	self.InfoPnl = vgui.Create("DPanel", self) 
	self.InfoPnl:Dock(FILL)
	
	function self.InfoPnl:OnMousePressed(code)
		if (code == MOUSE_RIGHT) then
			self.tooltip_ss:EnableButton()
		end
	end
	
	self.toolTip = self.InfoPnl:CreateToolTip()
	self.toolTip:SetSize(300, 0)
	self.toolTip:DockPadding(8, 8, 8, 8)
	
	self.InfoPnl.Offset = 0 
	
	function self.InfoPnl:Paint(w, h)
		local hasItem = LocalPlayer():HasStoreItem(this.Info.ID)
		
		if (hasItem and !this.m_bInventoryIcon) then
			self.Offset = math.Approach(self.Offset, 0, 5)
			
			draw.SimpleRect(0, 0, w, h, Color(0, 0, 0, 220))
			
			draw.SimpleText("PURCHASED", "ss_hub_store_purchase_blur", w /2, h /2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("PURCHASED", "ss_hub_store_purchase", w /2 +1, h /2 +1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("PURCHASED", "ss_hub_store_purchase", w /2, h /2, Color(166, 217, 93, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			if self.Hovered or self:IsChildHovered(1) then 
				self.Offset = math.Approach(self.Offset, 32, 5)
			else 
				self.Offset = math.Approach(self.Offset, 0, 5)
			end 
			
			surface.SetDrawColor(0, 0, 0, 255 *0.85) 
			surface.DrawRect(0, 0, w, self.Offset) 
	
			local x, y = self:LocalToScreen(0, 0) 
			local text = FormatNum(this.Info.Price or "100")
			local width = util.GetTextSize("ss_hub_store_price", text)
			
			draw.SimpleText(text, "ss_hub_store_price", w /2 -(width +23) /2 +23, -15 +(32 *(self.Offset /32)), color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(text, "ss_hub_store_price", w /2 -(width +22) /2 +22, -16 +(32 *(self.Offset /32)), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			draw.Material(w /2 -(width +14) /2, -16 +(32 *(self.Offset /32)) -8, 12, 17, color_white, HUD_COIN)
		end
	end 

	self.BPreview = vgui.Create("DPanel", self.InfoPnl) 
	self.BPreview:SetCursor( "hand" )
	
	function self.BPreview:Paint(w, h) 
		self.Col = self.Hovered and Color(195, 195, 195, 250) or Color(156, 156, 156, 250)
		draw.SimpleRect(0, 0, w, h, self.Col) 

		draw.SimpleText("PREVIEW", "ss_hub_store_buttons", w /2 +1, h /2 +1, Color(0, 0, 0, 255 *0.42), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("PREVIEW", "ss_hub_store_buttons", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end 

	function self.BPreview:Think() 
		self:SetPos(0, self:GetParent():GetTall()-self:GetParent().Offset +6)
	end 

	function self.BPreview:OnMouseReleased() 
		local parent = self:GetParent():GetParent()
		
		if (parent.Info.Bone) then
			STORE.Preview:SetHat(parent.Entity:GetModel(), parent.Info) 
		else
			STORE.Preview:SetModel(parent.Entity:GetModel(), parent.Info) 
		end 
		
		surface.PlaySound("garrysmod/ui_click.wav")
	end 

	self.BPurchase = vgui.Create("DPanel", self.InfoPnl) 
	self.BPurchase:SetCursor( "hand" )
	
	function self.BPurchase:OnMouseReleased()
		local id = this.Info.ID
		local hasItem = LocalPlayer():HasStoreItem(id)
		
		if (hasItem and this.m_bInventoryIcon) then
			net.Start("SS_ItemEquip")
				net.WriteString(id)
			net.SendToServer()
		else
			net.Start("ss.store.buy")
				net.WriteString(id)
			net.SendToServer()
		end
		
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	
	function self.BPurchase:Paint(w, h) 
		self.Col = self.Hovered and Color(33 +10, 175 +20, 234 +20, 240) or Color(33, 175, 234, 240)
		draw.SimpleRect(0, 0, w, h, self.Col) 
		
		if (this.m_bInventoryIcon) then
			draw.SimpleText("EQUIP", "ss_hub_store_buttons", w /2 +1, h /2 +1, Color(0, 0, 0, 255 *0.42), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("EQUIP", "ss_hub_store_buttons", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("PURCHASE", "ss_hub_store_buttons", w /2 +1, h /2 +1, Color(0, 0, 0, 255 *0.42), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("PURCHASE", "ss_hub_store_buttons", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end 

	function self.BPurchase:Think() 
		self:SetPos(self:GetParent():GetWide() /2, self:GetParent():GetTall()-self:GetParent().Offset +6)
	end 
end 

function PANEL:SetData(data)
	self.Info = data
	
	local label = self.toolTip:Add("DLabel")
	label:Dock(TOP)
	label:DockMargin(0, 0, 0, 8)
	label:SetText(SS.STORE.SLOT.NAME[data.Slot] .. " - " .. data.Name)
	label:SetFont("ss.tooltip.name")
	label:SetColor(color_white)
	label:SizeToContents()
	
	local this = self
	
	if (!this:GetInventoryIcon()) then
		if (data.Colorable) then
			local colorMixer = self.toolTip:Add("DColorMixer")
			colorMixer:Dock(TOP)
			colorMixer:DockMargin(0, 0, 0, 8)
			colorMixer:SetTall(128)
			colorMixer:SetAlphaBar(false)
			
			function colorMixer:ValueChanged(color)
				self.nextUpdate = CurTime() +0.35
			end
			
			function colorMixer:Think()
				self:ConVarThink()
				
				if (self.nextUpdate and self.nextUpdate <= CurTime()) then
					local color = self:GetColor()
					
					if (data.Slot == SS.STORE.SLOT.MODEL) then
						this.preview.Entity:SetColor(color)
					else
						this.preview.Entity.previews[data.Slot].entity:SetColor(color)
					end
					
					self.nextUpdate = nil
				end
			end
		end
		
		local skinAmount = this.Entity:SkinCount()
		
		if (skinAmount > 1) then
			local slider, base = util.SliderAndLabel(self.toolTip, "Model Skin")
			base:Dock(TOP)
			base:SetTall(34)
			
			base.label:SetFont("ss.tooltip.options")
			base.label:SizeToContents()
			
			slider:SetWide(125)
			
			slider:SetMin(1)
			slider:SetMax(skinAmount)
			slider:SetValue(this.Entity:GetSkin())
			
			function slider:OnValueChanged(value)
				self.nextUpdate = CurTime() +0.1
			end
			
			function slider:Think()
				if (self.nextUpdate and self.nextUpdate <= CurTime()) then
					local value = self:GetValue()
					
					if (data.Slot == SS.STORE.SLOT.MODEL) then
						this.preview.Entity:SetSkin(value)
					else
						this.preview.Entity.previews[data.Slot].entity:SetSkin(value)
					end
					
					self.nextUpdate = nil
				end
			end
		end
		
		if (data.Model) then
			local bodyGroups = this.Entity:GetBodyGroups()
			
			for i = 1, #bodyGroups do
				local info = bodyGroups[i]
				
				local slider, base = util.SliderAndLabel(self.toolTip, "Bodygroup - " .. info.name)
				base:Dock(TOP)
				base:SetTall(34)
		
				base.label:SetFont("ss.tooltip.options")
				base.label:SizeToContents()
				
				slider:SetWide(125)
				slider:SetMin(0)
				slider:SetMax(#info.submodels)
				slider:SetValue(0)
				
				function slider:OnValueChanged(value)
					self.nextUpdate = CurTime() +0.15
				end
				
				function slider:Think()
					if (self.nextUpdate and self.nextUpdate <= CurTime()) then
						local value = self:GetValue()
						
						if (IsValid(this.preview.Entity)) then
							if (data.Slot == SS.STORE.SLOT.MODEL) then
								this.preview.Entity:SetBodygroup(info.id, value)
							else
								if (this.preview.Entity.previews[data.Slot]) then
									this.preview.Entity.previews[data.Slot].entity:SetBodygroup(info.id, value)
								end
							end
						end
						
						self.nextUpdate = nil
					end
				end
			end
		end
	end
	
	self.toolTip:InvalidateLayout(true)
	self.toolTip:SizeToChildren(false, true)
end

function PANEL:SetEquipIcon(bool)
	
	-- Remove useless stuff.
	if (bool) then
		self:DockPadding(0, 0, 0, 0)
		
		self.InfoPnl.tooltip_ss:Remove()
	
		self.InfoPnl:Remove()
		self.BPreview:Remove()
		self.BPurchase:Remove()
	end
	
	self.m_bEqupIcon = bool
end

function PANEL:PerformLayout() 
	if (ValidPanel(self.InfoPnl)) then
		local w, h = self.InfoPnl:GetSize()
		
		self.BPreview:SetSize(w /2, 26) 
		self.BPurchase:SetSize(w /2, 26)
	end
end 

function PANEL:LayoutEntity( Entity )
	if self.Ang >= 360 then self.Ang = 0 end 

	if self.Hovered or self:IsChildHovered(5) then 
		self.Ang = self.Ang + 1 
	elseif self.Ang != self.Rotate then 
		self.Ang = self.Rotate
	end 
	Entity:SetAngles( Angle( 0, self.Ang,  0) )
end

function PANEL:Paint(w, h)

	-- We draw this in the equip icon.
	if (!self.m_bEqupIcon) then
		surface.SetMaterial(bgmat) 
		surface.SetDrawColor(249, 249, 249, 250) 
		surface.DrawTexturedRect(0, 0, 150, 150)  
	end
	
	if ( !IsValid( self.Entity ) ) then return end
	
	local x, y = self:LocalToScreen( 0, 0 )
	local ox, oy = self.PPanel:GetParent():GetParent():GetParent():LocalToScreen(0, 0) 
	local ow, oh = self.PPanel:GetParent():GetParent():GetParent():GetSize() 
	local px, py = self.PPanel:LocalToScreen(0, 0) 
	local pw, ph = self.PPanel:GetSize()  
	
	self:LayoutEntity( self.Entity )
	
	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end
	
	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, 4096 ) 
		cam.IgnoreZ( false )
			render.SuppressEngineLighting( true )
				render.SetLightingOrigin( self.Entity:GetPos() )
				render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
				render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
				render.SetBlend( self.colColor.a/255 )
		
				local hasItem = LocalPlayer():HasStoreItem(self.Info.ID)
		
				if ((!hasItem or self.m_bInventoryIcon) or self.m_bEqupIcon) then
					for i = 0, 6 do
						local col = self.DirectionalLight[ i ]
						
						if ( col ) then
							render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
						end
					end
				end
	 
				render.SetScissorRect(math.max(x+4, px, ox), math.max(y+4, py, oy), math.min(x+w-4, px+pw, ox+ow), math.min(y+h-4, py+ph, oy+oh), true) 
					self.Entity:DrawModel()
					
					if (self.Info and self.Info.Hooks) then
						if (self.Info.Hooks.Think) then
							self.Info.Hooks.Think(nil, self.Entity)
						end
						
						if (self.Info.Hooks.PostDrawOpaqueRenderables) then
							self.Info.Hooks.PostDrawOpaqueRenderables(nil, self.Entity)
						end
					end
				render.SetScissorRect(math.max(x+4, px, ox), math.max(y+4, py, oy), math.min(x+w-4, px+pw, ox+ow), math.min(y+h-4, py+ph, oy+oh), false) 
			render.SuppressEngineLighting( false )
		cam.IgnoreZ( false )
	cam.End3D()

	self.LastPaint = RealTime()
end

vgui.Register("ss_hub_store_icon", PANEL, "DModelPanel") 

---------------------------------------------------------
-- Store preview model.
---------------------------------------------------------

local PANEL = {}

AccessorFunc(PANEL, "m_bIsInventory", "IsInventory")

function PANEL:Init() 
	self.Entity = nil 
	self.LastPaint = 0
	self.DirectionalLight = {}

	self.n_EntityYaw = 45 
	self.n_LastYaw = Angle(0, 0, 0) 
	self.StartX = 0 
	self.StartY = 0
	self.n_CamPos = 150
	self.camZ = 135
	
	self:SetCamPos( Vector( self.n_CamPos, self.n_CamPos, 64 ) )
	self:SetLookAt( Vector( 0, 0, 64 ) )
	self:SetFOV( 20 )
	
	self:SetText( "" )
	self:SetAnimSpeed( 0.5 )
	self:SetAnimated( false )
	
	self:SetAmbientLight( Color( 50, 50, 50 ) )
	
	self:SetDirectionalLight(BOX_TOP, color_white)
	self:SetDirectionalLight(BOX_FRONT, color_white)
	
	self:SetColor(color_white) 
end

function PANEL:SetModel( strModelName, Table )
	if (!IsValid(self.Entity)) then
		self.Entity = ClientsideModel( strModelName, RENDER_GROUP_OPAQUE_ENTITY )
		self.Entity.previews = {}
	else
		self.Entity:SetModel(strModelName)
	end
	
	self.Entity:SetNoDraw( true ) 

	self.Entity.Info = Table 
	
	-- Try to find a nice sequence to play
	local iSeq = self.Entity:LookupSequence( "walk_all" );
	if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
	if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end
	
	if (iSeq > 0) then self.Entity:ResetSequence( iSeq ) end
end

function PANEL:SetHat(model, data)
	if (IsValid(self.Entity)) then
		if (self.Entity.previews[data.Slot] and IsValid(self.Entity.previews[data.Slot].entity)) then
			self.Entity.previews[data.Slot].entity:Remove()
		end
		
		self.Entity.previews[data.Slot] = {}
		self.Entity.previews[data.Slot].item = data.ID
		self.Entity.previews[data.Slot].entity = ClientsideModel(model)
		self.Entity.previews[data.Slot].entity:SetNoDraw(true)
		
		if (self:GetIsInventory()) then
			local info = SS.Gear.Get(LocalPlayer(), data.Slot)
			local bodyGroups = info.entity:GetNumBodyGroups()
			
			for i = 1, bodyGroups do
				local id = info.entity:GetBodygroup(i)
				
				self.Entity.previews[data.Slot].entity:SetBodygroup(i, id)
			end
		end
	end
end 

function PANEL:RemoveHat(slot)
	if (IsValid(self.Entity) and self.Entity.previews[slot]) then
		if (IsValid(self.Entity.previews[slot].entity)) then
			self.Entity.previews[slot].entity:Remove()
		end
		
		self.Entity.previews[slot] = nil
	end
end

function PANEL:Paint(w, h) 
	if ( !IsValid( self.Entity ) ) then return end
	
	local x, y = self:LocalToScreen( 0, 0 )
	local w, h = self:GetSize() 

	self:LayoutEntity( self.Entity )
	
	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end
	
	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, 4096 )
		cam.IgnoreZ( true )
			render.SuppressEngineLighting( true )
			render.SetLightingOrigin( self.Entity:GetPos() )
			render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
			render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
			render.SetBlend( self.colColor.a/255 )
			
			for i=0, 6 do
				local col = self.DirectionalLight[ i ]
				if ( col ) then
					render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
				end
			end
		
			self.Entity:DrawModel()
			
			if (self.Entity.Info and self.Entity.Info.Hooks) then
				if (self.Entity.Info.Hooks.Think) then
					self.Entity.Info.Hooks.Think(self.Entity.previews, self.Entity)
				end
				
				if (self.Entity.Info.Hooks.PostDrawOpaqueRenderables) then
					self.Entity.Info.Hooks.PostDrawOpaqueRenderables(self.Entity.previews, self.Entity)
				end
			end
			
			for i = 1, MAXIMUM_SLOTS do
				local data = self.Entity.previews[i]
				
				if (data) then
					if (IsValid(data.entity)) then
						local item = SS.STORE.Items[data.item]
						
						-- Maybe cache this?
						local index = self.Entity:LookupBone(item.Bone or "ValveBiped.Bip01_Head1")
						
						if (index and index > -1) then
							local position, angles = self.Entity:GetBonePosition(index)
							local modelData = item.Models[string.lower(self.Entity:GetModel())]
							
							if (modelData) then
								local positionData = modelData[1]
								
								for i = 1, #modelData do
									local modelBodygroup = self.Entity:GetBodygroup(modelData[i][1])
									local entityBodygroup = data.entity:GetBodygroup(modelData[i][2])
									
									if (bit.bor(modelBodygroup, entityBodygroup) == modelData[i][3]) then
										positionData = modelData[i]
									end
								end
								
								if (positionData) then
									if positionData.pos then
										local up, right, forward = angles:Up(), angles:Right(), angles:Forward()
										
										position = position + up*positionData.pos.z + right*positionData.pos.y + forward*positionData.pos.x -- NOTE: y and x could be wrong way round
									end 
			
									if positionData.ang then 
										angles:RotateAroundAxis(angles:Up(), positionData.ang.p) 
										angles:RotateAroundAxis(angles:Forward(), positionData.ang.y) 
										angles:RotateAroundAxis(angles:Right(), positionData.ang.r) 
									end
									
									if positionData.scale then data.entity:SetModelScale(positionData.scale, 0) end 
								end
							end
		
							data.entity:SetPos(position)
							data.entity:SetAngles(angles)
							
							if (self:GetIsInventory()) then
								local gearEntity = SS.Gear.Get(LocalPlayer(), i).entity
								local color = gearEntity:GetColor()
								local skin = gearEntity:GetSkin()
								
								data.entity:SetSkin(skin)
								
								render.SetColorModulation(color.r /255, color.g /255, color.b /255)
							else
								local color = data.entity:GetColor()
						
								render.SetColorModulation(color.r /255, color.g /255, color.b /255)
							end
	
							data.entity:DrawModel()
							
							if (item.Hooks.Think) then
								item.Hooks.Think(data, self.Entity)
							end
							
							if (item.Hooks.PostDrawOpaqueRenderables) then
								item.Hooks.PostDrawOpaqueRenderables(data, self.Entity)
							end
						end
					end
				end
			end
			
			render.SuppressEngineLighting(false)
		cam.IgnoreZ(false)
	cam.End3D()
	
	self.LastPaint = RealTime()
end

function PANEL:OnMousePressed(mousecode) 
	input.SetCursorPos(input.GetCursorPos())
	
	if mousecode == MOUSE_LEFT then  
		if !self.Entity then return end 
		
		self.n_LastYaw = self.Entity:GetAngles() 
		self.n_LastCam = self.n_CamPos
		self.StartX, self.StartY = input.GetCursorPos()
		self.MouseCapt = true  
		self:MouseCapture(true)
	end 
	
	if (mousecode == MOUSE_RIGHT) then
		self.rightMouse = true
		self.lastY = self.camZ
		
		self:MouseCapture(true)
	end
	
	self:SetCursor("sizeall")
end 

function PANEL:OnMouseReleased(mousecode) 
	if mousecode == MOUSE_LEFT then  
		self.MouseCapt = false 
		self:MouseCapture(false) 
	end 
	
	if (mousecode == MOUSE_RIGHT) then
		self.rightMouse = false
		
		self:MouseCapture(false)
	end
	
	self:SetCursor("hand")
end 

function PANEL:OnCursorMoved(x, y) 
	if self.MouseCapt then
		x, y = input.GetCursorPos() 
		self.n_EntityYaw = self.n_LastYaw.y+(x-self.StartX) 
		self.n_CamPos = math.min(200, math.max(30, self.n_LastCam+(y-self.StartY)))
	end
	
	if (self.rightMouse) then
		x, y = input.GetCursorPos() 
		
		self.camZ = math.min(self:GetTall(), (self.lastY +(y -self.lastY)) *0.25)
	end
end 

function PANEL:LayoutEntity( Entity )
	if ( self.bAnimated ) then
		self:RunAnimation()
	end
	
--	local Z = self.camZ+(30/190*((200-self.n_CamPos)-10))
	local z = self.camZ -100

	Entity:SetAngles(Angle(0, self.n_EntityYaw or 0, 0)) 
	self:SetCamPos(Vector(self.n_CamPos, self.n_CamPos, z)) 
	self:SetLookAt(Vector(0, 0, z)) 
end
vgui.Register("ss_hub_store_preview", PANEL, "DModelPanel") 

---------------------------------------------------------
-- The inventory section.
---------------------------------------------------------

local panel = {}

function panel:Init()
	self.categories = {}
	
	self.categoryList = self:Add("DScrollPanel")
	self.categoryList:Dock(LEFT)
	self.categoryList:SetWide(170)
	self.categoryList:GetCanvas():DockPadding(0, 21, 0, 0)
	
	for k, v in pairs(SS.STORE.Categories) do 
		local button = vgui.Create("ss_hub_store_button") 
		button:SetCursor("hand")
		button:SetTall(44) 
		button:SetTitle(v) 
		
		button.category = k
		
		function button.OnMouseReleased(_self)
			self:SetCategory(_self.category)
		end

		self.categoryList:AddItem(button)
		
		local list = self:Add("DScrollPanel")
		list:Dock(LEFT)
		list:SetWide(HubWidth -175 -440)
		
		list.button = button
		
		util.ReplaceScrollbar(list)
		
		function list:Paint(w, h)
			draw.SimpleRect(0, 0, w, h, Color(19, 19, 19, 255 *0.6))
		end
		
		list.iconLayout = vgui.Create("DIconLayout")
		list.iconLayout:SetSpaceX(12)
		list.iconLayout:SetSpaceY(12)
		list.iconLayout:SetBorder(21)
		list.iconLayout:Dock(TOP)
		
		list:AddItem(list.iconLayout)
		list:SetVisible(false)
		
		self.categories[k] = list
	end 
	
	self.preview = self:Add("ss_hub_store_preview")
	self.preview:Dock(FILL)
	self.preview.camZ = 125
	self.preview:SetIsInventory(true)
	
	local headSlot = self.preview:Add("ss.slot")
	headSlot:SetPos(21, 21)
	headSlot:SetSize(84, 84)
	headSlot:SetSlot(SS.STORE.SLOT.HEAD)
	
	local modelSlot = self.preview:Add("ss.slot")
	modelSlot:SetSize(84, 84)
	modelSlot:SetSlot(SS.STORE.SLOT.MODEL)
	
	local slotContainer = self.preview:Add("Panel")
	slotContainer:SetTall(86)
	
	for i = 4, MAXIMUM_SLOTS do
		local slot = slotContainer:Add("ss.slot")
		slot:SetWide(84)
		slot:Dock(LEFT)
		slot:SetSlot(i)

		slot:DockMargin(0, 0, 21, 0)
	end
	
	function self.preview:PerformLayout()
		local w, h = self:GetSize()
		
		modelSlot:SetPos(w -(84 +21), 21)
		
		slotContainer:SizeToChildren(true)
		slotContainer:SetPos(w /2 -slotContainer:GetWide() /2, h -(84 +21))
	end
	
	self:SetCategory(1)
	
	SS.Hub.InventoryPreview = self.preview
end 

function panel:Update()
	local active = self.lastCategory
	
	if (ValidPanel(active)) then
		active.iconLayout:Clear()
		
		for id, data in pairs(SS.STORE.INVENTORY) do
			local item = SS.STORE.Items[id]
			
			if (!LocalPlayer():HasEquipped(item.ID) and item.Category == active.button.category) then 
				local icon = active.iconLayout:Add("ss_hub_store_icon")
				icon:SetSize(150, 150)
				icon:SetModel(item.Model)
				icon:SetCamPos(item.CamPos)
				icon:SetLookAt(item.LookAt)
				icon:SetFOV(item.Fov)
				icon:SetInventoryIcon(true)
				icon:SetData(item)
				
				icon.Rotate = item.Rotate or 45
				icon.PPanel = active.iconLayout

				icon.Model = item.Type == "model"
			end 
		end
	end
	
	local cache = SS.Gear.GetCacheByPlayer(LocalPlayer())
	
	if (cache) then
		for i = 1, MAXIMUM_SLOTS do
			local data = cache[i]
			
			if (data and data.item and data.item != "") then
				local item = SS.STORE.Items[data.item]
				if (item.Bone) then
					self.preview:SetHat(item.Model, item)
				end
			end
		end
	end
end

function panel:SetCategory(id)
	if (ValidPanel(self.lastCategory)) then
		self.lastCategory:SetVisible(false)
		self.lastCategory.button.Active = false
	end
	
	self.lastCategory = self.categories[id]
	self.lastCategory.button.Active = true
	
	self.lastCategory:SetVisible(true)
	
	self:Update()
end

function panel:Think()
	local model = SS.Gear.Get(LocalPlayer(), SS.STORE.SLOT.MODEL)

	if (model and model.item) then
		model = SS.STORE.Items[model.item]
		
		if (model.Model and self.previewModel != model.Model) then
			self.preview:SetModel(model.Model, model)
			
			self.previewModel = model.Model
			
			self:Update()
		end
	end
	
	local active = self.lastCategory
	
	if (ValidPanel(active)) then
		local highlight
		local children = active.iconLayout:GetChildren()
		
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				if (child.InfoPnl.Hovered or child.InfoPnl:IsChildHovered(1)) then
					highlight = child.Info.Slot
				end
			end
		end
		
		local equipSlots = SS.GetEquipSlots()
		
		for i = 1, #equipSlots do
			local slot = equipSlots[i]
			
			if (ValidPanel(slot)) then
				if (highlight == i) then
					slot:SetHighlight(true)
				else
					slot:SetHighlight(false)
				end
			end
		end
	end
end

vgui.Register("ss_hub_inventory", panel, "Panel")

---------------------------------------------------------
-- The settings section.
---------------------------------------------------------

local panel = {}

function panel:Init()
	self.list = self:Add("DScrollPanel")
	self.list:Dock(FILL)
	self.list:GetCanvas():DockPadding(28, 0, 28, 16)
	
	util.ReplaceScrollbar(self.list)
	
	local checkbox, base = util.CheckboxAndLabel(nil, "Toggle thirdperson")
	base:Dock(TOP)
	
	checkbox:SetConVar("ss_thirdperson")
	
	self.list:AddItem(base)
	
	local slider, base = util.SliderAndLabel(nil, "Thirdperson distance")
	base:Dock(TOP)
	
	base.autoSize = true
	
	slider:SetMin(16)
	slider:SetMax(1024)
	slider:SetValue(SS.ThirdPersonDistance:GetInt())
	
	function slider:OnValueChanged(value)
		RunConsoleCommand("ss_thirdperson_distance", value)
	end
	
	self.list:AddItem(base)
	
	if (SS.Lobby) then
		local slider, base = util.SliderAndLabel(nil, "3D screen distance")
		base:Dock(TOP)
		
		base.autoSize = true
		
		slider:SetMin(16)
		slider:SetMax(8000)
		slider:SetValue(SS.Lobby.ScreenDistance:GetInt())
		
		function slider:OnValueChanged(value)
			RunConsoleCommand("sslobby_screendistance", value)
		end
		
		self.list:AddItem(base)

		local slider, base = util.SliderAndLabel(nil, "Lobby Music Volume")
		base:Dock(TOP)
		
		base.autoSize = true
		
		slider:SetMin(0)
		slider:SetMax(100)
		slider:SetValue(SS.Lobby.MusicVolume:GetInt())
		
		function slider:OnValueChanged(value)
			RunConsoleCommand("sslobby_musicvolume", value)
		end
		
		self.list:AddItem(base)
	end
end	

function panel:Paint(w, h)
	local children = self.list:GetCanvas():GetChildren()
	
	surface.SetDrawColor(Color(0, 0, 0, 140))
	
	for k, child in pairs(children) do
		surface.DrawLine(0, child.y +child:GetTall(), w, child.y +child:GetTall())
	end
end

vgui.Register("ss_hub_settings", panel, "Panel")

---------------------------------------------------------
--
--------------------------------------------------------- 

concommand.Add("ss_store", function()
	if (!ValidPanel(SS.Hub)) then
		SS.Hub = vgui.Create("ss_hub")
		SS.Hub:AddCategories()
		SS.Hub:SetVisible(false)
		
		local cache = SS.Gear.GetCache()
		local steamID = LocalPlayer():SteamID()
		
		-- Request full update.
		if (!cache[steamID]) then
			cache[steamID] = {}
		
			net.Start("ss.gear.rqgrfull")
				net.WriteString(steamID)
			net.SendToServer()
		end
	end
	
	if (ValidPanel(SS.Hub)) then 
		if (!SS.Hub:IsVisible()) then 
			SS.Hub:SetVisible(true) 
			SS.Hub:SetAlpha(0)
			
			GAMEMODE:SetGUIBlur(true) 
			
			gui.EnableScreenClicker(true)
		else 
			GAMEMODE:SetGUIBlur(false)
			
			gui.EnableScreenClicker(false)
		end 
	end
end )

---------------------------------------------------------
-- Network the items that a player owns.
---------------------------------------------------------

net.Receive("ss.store.gtitms", function(bits)
	local count = net.ReadUInt(8)
	
	for i = 1, count do
		local id = net.ReadString()
		
		SS.STORE.INVENTORY[id] = {}
	end
	
	if (ValidPanel(SS.Hub)) then
		local category = SS.Hub:GetCategory(3)
	
		category:Update()
	end
end)

---------------------------------------------------------
-- Player gear/apparel system.
---------------------------------------------------------

SS.Gear = {}

local cache = {}

function SS.Gear.Get(player, slot)
	local steamID = player:SteamID()
	
	return cache[steamID] and cache[steamID][slot]
end

function SS.Gear.GetCache()
	return cache
end

function SS.Gear.GetCacheByPlayer(player)
	local steamID = player:SteamID()
	
	return cache[steamID]
end

function SS.Gear.ShouldDraw()
	if (GetViewEntity() == LocalPlayer() and !LocalPlayer():ShouldDrawLocalPlayer() and !LocalPlayer():GetObserverTarget()) then return false end
	
	return true
end

local hidden = false

local function HideGear(steamID)
	if (!hidden and steamID == LocalPlayer():SteamID()) then
		for i = 1, MAXIMUM_SLOTS do
			local data = cache[steamID][i]
			
			if (data and IsValid(data.entity)) then
				data.entity:AddEffects(EF_NODRAW)
			end
		end
	end
end

---------------------------------------------------------
-- Full gear update.
---------------------------------------------------------

net.Receive("ss.gear.gtgrfull", function(bits)
	local steamID = net.ReadString()

	for i = 1, MAXIMUM_SLOTS do
		cache[steamID][i] = {}

		local unique = net.ReadString()

		if (unique != "") then
			local item = SS.STORE.Items[unique]
			
			if (item) then
				cache[steamID][item.Slot].item = item.ID

				if (item.Bone) then
					if (IsValid(cache[steamID][i].entity)) then
						cache[steamID][i].entity:Remove()
					end
	
					local entity = ClientsideModel(item.Model)
					
					-- Set rendermode for alpha/color support.
					entity:SetRenderMode(RENDERMODE_TRANSALPHA)
					
					local skin = net.ReadUInt(8)
					local color = net.ReadVector()
		
					color = Color(color.x, color.y, color.z)
			
					entity:SetSkin(skin)
					entity:SetColor(color)
					
					local bodygroups = net.ReadUInt(8)

					for i = 1, bodygroups do
						local group = net.ReadUInt(8)
						local value = net.ReadUInt(8)
						
						entity:SetBodygroup(group, value)
					end

					cache[steamID][i].entity = entity
				elseif (item.Model and !item.Bone and SS.Hub and steamID == LocalPlayer():SteamID()) then
					local entity = SS.Hub.InventoryPreview.Entity
					
					if (IsValid(entity)) then
						local skin = net.ReadUInt(8)
						local color = net.ReadVector()
						
						color = Color(color.x, color.y, color.z)
					
						entity:SetSkin(skin)
						entity:SetColor(color)
						
						local bodygroups = net.ReadUInt(8)
						
						for i = 1, bodygroups do
							local group = net.ReadUInt(8)
							local value = net.ReadUInt(8)
							
							entity:SetBodygroup(group, value)
						end
					end
				end
				
				-- Call equip on client?
			end
		end
		
		if (steamID == LocalPlayer():SteamID() and SS.Hub) then
			local category = SS.Hub:GetCategory(3)
			
			category:Update()
		end
	end
end)
 
---------------------------------------------------------
-- Single slot update.
---------------------------------------------------------

net.Receive("ss.gear.gtgrslot", function(bits)
	local item = SS.STORE.Items[net.ReadString()]
	local steamID = net.ReadString()
	local remove = net.ReadBit()

	if (remove == 1) then
		if (IsValid(cache[steamID][item.Slot].entity)) then
			cache[steamID][item.Slot].entity:Remove()
		end
		
		cache[steamID][item.Slot].dirty = nil
		cache[steamID][item.Slot].item = nil
	else
		if (item) then
			cache[steamID][item.Slot].dirty = nil
			cache[steamID][item.Slot].item = item.ID
			
			if (item.Bone) then
				if (IsValid(cache[steamID][item.Slot].entity)) then
					cache[steamID][item.Slot].entity:Remove()
				end
				
				local entity = ClientsideModel(item.Model)
				
				-- Set rendermode for alpha support.
				entity:SetRenderMode(RENDERMODE_TRANSALPHA)
				
				local skin = net.ReadUInt(8)
				local color = net.ReadVector()
				
				color = Color(color.x, color.y, color.z)
			
				entity:SetSkin(skin)
				entity:SetColor(color)
				
				local bodygroups = net.ReadUInt(8)
				
				for i = 1, bodygroups do
					local group = net.ReadUInt(8)
					local value = net.ReadUInt(8)
					
					entity:SetBodygroup(group, value)
				end
				
				cache[steamID][item.Slot].entity = entity
			elseif (item.Model and !item.Bone and SS.Hub and steamID == LocalPlayer():SteamID()) then
				local entity = SS.Hub.InventoryPreview.Entity
				
				if (IsValid(entity)) then
					local skin = net.ReadUInt(8)
					local color = net.ReadVector()
					
					color = Color(color.x, color.y, color.z)
				
					entity:SetSkin(skin)
					entity:SetColor(color)
					
					local bodygroups = net.ReadUInt(8)
					
					for i = 1, bodygroups do
						local group = net.ReadUInt(8)
						local value = net.ReadUInt(8)
						
						entity:SetBodygroup(group, value)
					end
				end
			end
		
			-- Call equip on client?
		end
	end

	if (steamID == LocalPlayer():SteamID()) then
		local category = SS.Hub:GetCategory(3)
		
		category:Update()
	end
end)

---------------------------------------------------------
-- Sets a slot to dirty.
---------------------------------------------------------

net.Receive("ss.gear.gtgrslotd", function(bits)
	local steamID = net.ReadString()
	
	if (cache[steamID]) then
		local slot = net.ReadUInt(8)
	
		cache[steamID][slot].dirty = true
	end
end)

---------------------------------------------------------
-- Draws the gear.
---------------------------------------------------------

hook.Add("PostPlayerDraw", "ss.gear.render", function(player, isRagdoll)
	local steamID = player:SteamID()
	local entity = isRagdoll and player:GetRagdollEntity() or player
	
	-- Request full update.
	if (!cache[steamID]) then
		cache[steamID] = {}

		net.Start("ss.gear.rqgrfull")
			net.WriteString(steamID)
		net.SendToServer()
	else
		for i = 1, MAXIMUM_SLOTS do
			local data = cache[steamID][i]
			
			if (data) then
			
				-- Request update for slot if it's dirty.
				if (data.dirty) then
					cache[steamID][i].dirty = false
					
					net.Start("ss.gear.rqgrslot")
						net.WriteString(steamID)
						net.WriteUInt(i, 8)
					net.SendToServer()
				end
				
				local item = SS.STORE.Items[data.item]
				
				if (item) then
					if (IsValid(data.entity)) then
					
						-- Maybe cache this?
						local index = entity:LookupBone(item.Bone or "ValveBiped.Bip01_Head1")
						
						if (index and index > -1) then
							
							-- Using bone matrix fixes the hat from lagging behind when the player is getting shot. (lol)
							local boneMatrix = entity:GetBoneMatrix(index)
							
							if (boneMatrix) then
								local position, angles = boneMatrix:GetTranslation(), boneMatrix:GetAngles()
								
								local modelData = item.Models[string.lower(entity:GetModel())]
								
								if (modelData) then
									local positionData = modelData[1]
									
									for i = 1, #modelData do
										local modelBodygroup = entity:GetBodygroup(modelData[i][1])
										local entityBodygroup = data.entity:GetBodygroup(modelData[i][2])
										
										if (bit.bor(modelBodygroup, entityBodygroup) == modelData[i][3]) then
											positionData = modelData[i]
										end
									end
									
									if (positionData) then
										if positionData.pos then
											local up, right, forward = angles:Up(), angles:Right(), angles:Forward()
											
											position = position + up*positionData.pos.z + right*positionData.pos.y + forward*positionData.pos.x -- NOTE: y and x could be wrong way round
										end 
					
										if positionData.ang then 
											angles:RotateAroundAxis(angles:Up(), positionData.ang.p) 
											angles:RotateAroundAxis(angles:Forward(), positionData.ang.y) 
											angles:RotateAroundAxis(angles:Right(), positionData.ang.r) 
										end
										
										if positionData.scale then data.entity:SetModelScale(positionData.scale, 0) end 
									end
								end
			
								data.entity:SetPos(position)
								data.entity:SetAngles(angles)
							end
						end
					end
					
					-- This is probably not the right place to call these, but whatever.
					if (item.Hooks.Think) then
						item.Hooks.Think(cache[steamID], entity)
					end
					
					if (item.Hooks.PostDrawOpaqueRenderables) then
						item.Hooks.PostDrawOpaqueRenderables(cache[steamID], entity)
					end
				end
			end
		end
	end
end)

---------------------------------------------------------
-- Hide the gear for the localplayer if we're not in
-- 3rd person.
---------------------------------------------------------

hook.Add("Think", "ss.gear.render", function()
	local steamID = LocalPlayer():SteamID()

	if (cache[steamID]) then
		local shouldDraw = SS.Gear.ShouldDraw()

		if (shouldDraw) then
			if (hidden) then
				for i = 1, MAXIMUM_SLOTS do
					local data = cache[steamID][i]
					
					if (data and IsValid(data.entity)) then
						data.entity:RemoveEffects(EF_NODRAW)
					end
				end
				
				hidden = false
			end
		else
			if (!hidden) then
				for i = 1, MAXIMUM_SLOTS do
					local data = cache[steamID][i]
					
					if (data and IsValid(data.entity)) then
						data.entity:AddEffects(EF_NODRAW)
					end
				end
				
				hidden = true
			end
		end
	end
end)

---------------------------------------------------------
-- A shitty hack to make it draw on the corpse.
-- This might be a bad idea!
---------------------------------------------------------

hook.Add("PostDrawTranslucentRenderables", "ss.gear.render", function()
	local players = player.GetAll()
	
	for k, player in pairs(players) do
		if (!player:Alive()) then
			hook.Run("PostPlayerDraw", player, true)
		end
	end
end)

---------------------------------------------------------
-- Remove the players gear entities.
---------------------------------------------------------

gameevent.Listen("player_disconnect")

hook.Add("player_disconnect", "ss.gear.player_disonnect", function(data)
	local steamID = data.networkid
	
	if (cache[steamID]) then
		for i = 1, MAXIMUM_SLOTS do
			local data = cache[steamID][i]
			
			if (data and IsValid(data.entity)) then
				data.entity:Remove()
			end
		end
		
		cache[steamID] = nil
	end
end)