---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
--------------------------- 

local HubWidth = math.max(ScrW()*0.6, 800) 
local HubHeight = math.max(ScrH()*0.725, 600) 
SS.Hub = false 
SS.HubTabs = {} 
local StoreCats = {} 

surface.CreateFont("ss_hub", {font="Arvil Sans", size=65, weight=500}) 
surface.CreateFont("ss_hub_header", {font="Arvil Sans", size=42, weight=500}) 
surface.CreateFont("ss_hub_nav", {font="Arial", size=20, weight=800}) 
surface.CreateFont("ss_hub_store_cat", {font="Arvil Sans", size=28, weight=500, antialias=true}) 
surface.CreateFont("ss_hub_store_buttons", {font="Arial", size=14, weight=700}) 
surface.CreateFont("ss_hub_store_price", {font="Arial", size=18, weight=1000}) 

/* The HUB's main panel */
local PANEL = {} 
function PANEL:Init() 
	self.nav = vgui.Create("ss_hub_nav", self) 

	for k,v in pairs(SS.HubTabs) do 
		v.panel = vgui.Create("ss_hub_container", self) 
		v.panel:SetPos(-v.panel:GetWide(), 75)  
		v.panel:SetVisible(false) 
		if v.panelName then 
			v.panel.panel = vgui.Create(v.panelName, v.panel)  
		end 
		v.panel.id = k 
		v.button = vgui.Create("ss_hub_nav_buttons", self.nav) 
		v.button:SetIcon(v.iconPath) 
		v.button:SetLabel(v.name) 
		v.button.t = v  
		v.button.id = k 
	end 
	self:SetTab(#SS.HubTabs) 

	GAMEMODE:SetGUIBlur(true) 
	gui.EnableScreenClicker(true) 
end 

function PANEL:PerformLayout() 
	self:SetSize(HubWidth, HubHeight) 
	self:SetPos(ScrW()/2-HubWidth/2, ScrH()/2-HubHeight/2) 

	local lastX = HubWidth+15
	for k,v in pairs(SS.HubTabs) do 
		lastX = lastX-v.button:GetWide()-15
		v.button:SetPos(lastX, self.nav:GetTall()/2-v.button:GetTall()/2) 
	end 
end 

function PANEL:SetTab(id) 
	self.lasttab = self.curtab or -1
	self.curtab = id 
	self.Right = (self.lasttab == -1 or self.lasttab < id)
	for k,v in pairs(SS.HubTabs) do 
		if k == id then 
			if v.panel and v.panel:IsValid() then 
				if self.Right then 
					v.panel:SetPos(-v.panel:GetWide()-10, 75) 
				else 
					v.panel:SetPos(HubWidth+10, 75) 
				end 
				v.panel:SetVisible(true) 
				v.panel.Active = true 
				v.panel.Right = self.Right
				v.button.Active = true  
			end 
		else 
			if v.panel and v.panel:IsValid() then 
				v.panel.Right = self.Right
				v.panel.Active = false 
				v.button.Active = false 
			end 
		end 
	end 
end 

function PANEL:Paint(w, h) 
end 
vgui.Register("ss_hub", PANEL, "DPanel") 


/* The Hub Navigation */ 
local PANEL = {} 
function PANEL:PerformLayout() 
	self:SetSize(HubWidth, 50) 
	self:SetPos(0, 0) 
end 

function PANEL:Paint(w, h) 
	surface.SetFont("ss_hub") 
	local w, th = surface.GetTextSize("THE HUB") 
	surface.SetTextPos(0+1, h/2-th/2+1)
	surface.SetTextColor(0, 0, 0, 255*0.35) 
	surface.DrawText("THE HUB")
	surface.SetTextColor(255, 255, 255) 
	surface.SetTextPos(0, h/2-th/2) 
	surface.DrawText("THE HUB") 
end 
vgui.Register("ss_hub_nav", PANEL, "DPanel") 

/* The Hub Navigation Buttons */
local PANEL = {} 
function PANEL:Init() 
	self:NoClipping(true) 
end 

function PANEL:PerformLayout() 
	surface.SetFont("ss_hub_nav") 
	local tw, th = surface.GetTextSize(self.Label)
	self:SetSize(7+32+7+tw+10, 36) 
end 

function PANEL:Paint(w, h) 
	if self.Hovered or self.Active then 
		draw.RoundedBox(8, 0, 0, w, h, Color(247, 148, 30, 255*0.7)) 
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
	SS.Hub:SetTab(self.id)  
end 

function PANEL:SetLabel(txt) 
	self.Label = txt 
end 

function PANEL:SetIcon(matPath)  
	self.Icon = Material(matPath) 
end 
vgui.Register("ss_hub_nav_buttons", PANEL, "DPanel") 

/* The HUB's containers */
local PANEL = {} 
function PANEL:Init() 
	self:SetSize(HubWidth, HubHeight-75) 
	self:SetPos(-self:GetWide(), 75) 
end 

function PANEL:PerformLayout() 
end 

function PANEL:Paint(w, h) 
	draw.RoundedBoxEx(4, 0, 0, HubWidth, 54, Color(255, 255, 255, 255), true, true, true, true) 
	draw.RoundedBoxEx(4, 1, 27, HubWidth-2, 27-2, Color(238, 238, 238, 255), false, false, true, true)

	draw.RoundedBoxEx(4, 0, self:GetTall()-30, HubWidth, 30, Color(255, 255, 255, 255), true, true, true, true)
	draw.RoundedBoxEx(4, 1, self:GetTall()-15, HubWidth-2, 14, Color(238, 238, 238, 255), false, false, true, true)
	-- surface.SetDrawColor(238, 238, 238, 255) 
	-- surface.DrawRect(1, 20, HubWidth-2, 20-2) 
	-- surface.DrawRect(1, self:GetTall()-15, HubWidth-2, 9)

	local Text = string.upper(SS.HubTabs[self.id].name) 
	surface.SetFont("ss_hub_header") 
	local tw, th = surface.GetTextSize(Text) 
	surface.SetTextColor(80, 80, 77, 255) 
	surface.SetTextPos(self:GetWide()/2-tw/2, 54/2-th/2)
	surface.DrawText(Text) 

	surface.SetDrawColor(255, 255, 255, 255*0.25) 
	surface.DrawRect(1, 54, HubWidth-2, self:GetTall()-54-30) 
end 

function PANEL:Think() 
	if !self:IsVisible() then return end 
	local x, y = self:GetPos() 
	if !self.Active then 
		x = math.Approach(x, self.Right and HubWidth or (-self:GetWide()), 70) 
		if x >= HubWidth or x <= (-self:GetWide()) then 
			self:SetVisible(false) 
		end 
	else 
		x = math.Approach(x, 0, 70) 
	end 
	self:SetPos(x, y) 
end 
vgui.Register("ss_hub_container", PANEL, "DPanel")

/* The HUB's store */ 
local PANEL = {} 
function PANEL:Init() 
	local LastY = 55 
	for k,v in pairs(SS.STORE.Categories) do 
		StoreCats[v] = {} 
		local t = StoreCats[v] 
		t.button = vgui.Create("ss_hub_store_button", self) 
		t.button:SetSize(HubWidth*0.18, 40) 
		t.button:SetPos(0, LastY) 
		t.button:SetTitle(v) 
		t.button.t = t 
		LastY = LastY+t.button:GetTall()
		t.id = k 

		t.Panel = vgui.Create("DScrollPanel", self) 
		t.Panel.VBar.btnUp:SetVisible(false) 
		t.Panel.VBar.btnDown:SetVisible(false) 
		t.Panel.VBar:Dock(NODOCK) 
		function t.Panel.VBar.btnGrip:Paint(w, h) 
			draw.RoundedBox(8, 0, 0, w, h, Color(234, 234, 234, 255*0.5)) 
		end 
		t.Panel.VBar.Paint = function() end  

		t.List = vgui.Create("DIconLayout", t.Panel)  
		t.Panel:AddItem(t.List)  

		for i=1, 30 do 
			local Panel = t.List:Add("ss_hub_store_icon")  
			Panel:SetSize(150, 150) 
			Panel:SetModel("models/player/breen.mdl") 
			Panel.PPanel = t.Panel 
			Panel.Price = 1578948
		end 
	end 
	self:SetCat(1) 


end 

function PANEL:PerformLayout() 
	self:SetSize(self:GetParent():GetSize()) 

	for k,v in pairs(StoreCats) do 
		v.Panel:SetPos(HubWidth*0.18, 60) 
		v.Panel:SetSize(HubWidth-HubWidth*0.18-HubWidth*0.367, self:GetTall()-65-30)

		v.Panel.VBar:SetSize(17, v.Panel:GetTall()) 
		v.Panel.VBar:SetPos(v.Panel:GetWide()-v.Panel.VBar:GetWide()-10 , 0)

		v.List:SetWide(v.Panel:GetWide()-v.Panel.VBar:GetWide()-10) 

		v.List.n_Columns = math.floor(v.List:GetWide()/150)
		v.List:SetSpaceX(((v.List:GetWide()-v.List.n_Columns*150)/v.List.n_Columns)/2) 
		v.List:SetSpaceY(v.List:GetSpaceX()) 
		v.List:SetBorder(v.List:GetSpaceX()) 
	end 
end 

function PANEL:Paint(w, h) 
	surface.SetDrawColor(19, 19, 19, 255*0.6)
	surface.DrawRect(HubWidth*0.18, 55, HubWidth-HubWidth*0.18-HubWidth*0.367, self:GetTall()-55-30)
end 

function PANEL:SetCat(i) 
	for k,v in pairs(StoreCats) do 
		if v.id == i then 
			v.active = true 
			v.Panel:SetVisible(true) 
		else 
			v.active = false 
			v.Panel:SetVisible(false) 
		end 
	end 
end 
vgui.Register("ss_hub_store", PANEL, "DPanel") 

/* The store buttons */ 
local PANEL = {} 
function PANEL:Init() 

end 

function PANEL:SetTitle(txt) 
	self.Title = txt 
end 

function PANEL:Paint(w, h) 
	if self.t.active or self.Hovered then 
		surface.SetDrawColor(19, 19, 19, 255*0.6) 
		surface.DrawRect(0, 1, w, h-2) 
	end 
	surface.SetDrawColor(19, 19, 19, 255*0.2)
	surface.DrawRect(0, 0, w, 1) 
	surface.DrawRect(0, h-1, w, 1) 

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
	self:GetParent():SetCat(self.t.id) 
end 
vgui.Register("ss_hub_store_button", PANEL, "DPanel") 

/* The store icons */ 
local PANEL = {} 
local bgmat = Material("skeyler/store/icon_base.png") 
function PANEL:Init() 
	self:SetCamPos( Vector( 15, 15, 64 ) )
	self:SetLookAt( Vector( 0, 0, 64 ) )
	self:SetFOV( 50 )

	self.InfoPnl = vgui.Create("DPanel", self) 
	self.InfoPnl.Offset = 0 
	function self.InfoPnl:Paint(w, h) 
		if self.Hovered or self:IsChildHovered(1) then 
			self.Offset = math.Approach(self.Offset, 32, 5) 
		else 
			self.Offset = math.Approach(self.Offset, 0, 5) 
		end 
		surface.SetDrawColor(0, 0, 0, 255*0.58) 
		surface.DrawRect(4, 4, w-8, self.Offset-5) 
		surface.DrawRect(4, h-4-self.Offset, w-8, self.Offset) 

		local x, y = self:LocalToScreen(4, 4) 
		render.SetScissorRect(x, y, x+self:GetParent():GetWide(), y+self:GetParent():GetTall(), true) 
		surface.SetMaterial(HUD_COIN) 
		surface.SetDrawColor(255, 255, 255, 255) 
		surface.DrawTexturedRect(11, 5-32+self.Offset, 32, 32) 

		local Text = FormatNum(self:GetParent().Price or "100") 
		surface.SetFont("ss_hub_store_price") 
		local tw, th = surface.GetTextSize(Text) 
		surface.SetTextPos(11+16+8, 5+27/2-th/2-32+self.Offset) 
		surface.SetTextColor(255, 255, 255, 255) 
		surface.DrawText(Text) 
		render.SetScissorRect(x, y, x+self:GetParent():GetWide(), y+self:GetParent():GetTall(), false) 
	end 

	self.BPreview = vgui.Create("DPanel", self.InfoPnl) 
	self.BPreview:SetSize(62, 22) 
	function self.BPreview:Paint(w, h) 
		draw.RoundedBox(4, 0, 0, w, h, Color(156, 156, 156, 255*0.4)) 

		surface.SetFont("ss_hub_store_buttons") 
		local tw, th = surface.GetTextSize("PREVIEW") 
		surface.SetTextPos(w/2-tw/2, h/2-th/2) 
		surface.SetTextColor(255, 255, 255, 255) 
		surface.DrawText("PREVIEW")
	end 

	function self.BPreview:Think() 
		self:SetPos(5, self:GetParent():GetTall()-4-self:GetParent().Offset+5)
	end 

	self.BPurchase = vgui.Create("DPanel", self.InfoPnl) 
	self.BPurchase:SetSize(62, 22)
	function self.BPurchase:Paint(w, h) 
		
		draw.RoundedBox(4, 0, 0, w, h, Color(221, 187, 94, 255*0.4)) 

		surface.SetFont("ss_hub_store_buttons") 
		local tw, th = surface.GetTextSize("PURCHASE") 
		surface.SetTextPos(w/2-tw/2, h/2-th/2) 
		surface.SetTextColor(255, 255, 255, 255) 
		surface.DrawText("PURCHASE")  
	end 

	function self.BPurchase:Think() 
		self:SetPos(72, self:GetParent():GetTall()-4-self:GetParent().Offset+5)
	end 
end 

function PANEL:PerformLayout() 
	self.InfoPnl:SetSize(self:GetSize()) 
end 

function PANEL:LayoutEntity( Entity )
	Entity:SetAngles( Angle( 0, 45,  0) )
end

function PANEL:Paint(w, h) 
	surface.SetMaterial(bgmat) 
	surface.SetDrawColor(255, 255, 255, 255) 
	surface.DrawTexturedRect(0, 0, 150, 150)  

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

	render.SetScissorRect(math.max(x+4, px, ox), math.max(y+4, py, oy), math.min(x+w-4, px+pw, ox+ow), math.min(y+h-4, py+ph, oy+oh), true) 
	self.Entity:DrawModel()
	render.SetScissorRect(math.max(x+4, px, ox), math.max(y+4, py, oy), math.min(x+w-4, px+pw, ox+ow), math.min(y+h-4, py+ph, oy+oh), false) 

	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()
	
	self.LastPaint = RealTime()
end
vgui.Register("ss_hub_store_icon", PANEL, "DModelPanel") 

-----------------------------------------------
-----------------------------------------------
-----------------------------------------------

function SS:AddHubTab(name, iconPath, panelName) 
	table.insert(self.HubTabs, 1, {name=name, iconPath=iconPath, panelName=panelName}) 
end 

SS:AddHubTab("Store", "skeyler/icons/store.png", "ss_hub_store") 
SS:AddHubTab("Profile", "skeyler/icons/profile.png", "ss_hub_profile") 
SS:AddHubTab("Settings", "skeyler/icons/settings.png", "ss_hub_settings") 
SS:AddHubTab("Help", "skeyler/icons/help.png", "ss_hub_help") 

concommand.Add("ss_store", function()  
	if SS.Hub then 
		if !SS.Hub:IsVisible() then 
			SS.Hub:SetVisible(true) 
			GAMEMODE:SetGUIBlur(true) 
			gui.EnableScreenClicker(true)
		else 
			GAMEMODE:SetGUIBlur(false)
			gui.EnableScreenClicker(false)
			SS.Hub:SetVisible(false) 
		end 
		return  
	end 
	SS.Hub = vgui.Create("ss_hub")  
end )
