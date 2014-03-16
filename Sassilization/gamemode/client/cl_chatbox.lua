---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

if (!atlaschat) then Msg("CANNOT LOAD THE ATLAS CHAT THEME: THE ATLAS CHAT ADDON IS MISSING!\n") return end

-- why is this a global?
TAG_MAT = Material("skeyler/tag_bg")

local theme = {}

---------------------------------------------------------
-- Theme variables.
---------------------------------------------------------

-- The base theme that this theme will use.
theme.base = "default"

-- The theme's unique key.
theme.unique = "skeylerservers"

-- A pretty name for this theme.
theme.name = "Skeyler Servers"

-- Holds all the colors.
theme.color = {}

-- The color of the text selection.
theme.color.selection = Color(60, 255, 60, 60)

-- The color of the timestamp.
theme.color.timestamp = Color(140, 189, 255)

-- The "X" button on the private chat card.
theme.color.privatecard_close = color_white
theme.color.privatecard_close_hover = color_red

-- A generic label color.
theme.color.generic_label = color_white

-- How much space between each message.
theme.messageSpacing = 8

---------------------------------------------------------
-- Chat fonts.
---------------------------------------------------------

surface.CreateFont("ss.chat.tag", {font = "Helvetica LT Std Cond", size = 12, weight = 400})
surface.CreateFont("ss.chat.prefix", {font = "Arvil Sans", size = 20, weight = 400})
surface.CreateFont("ss.chat.close", {font = "Tahoma", size = 18, weight = 800})

surface.CreateFont("ss.chat.button", {font = "Helvetica", size = 18, weight = 1000})
surface.CreateFont("atlaschat.theme.generic", {font = "Helvetica LT Std Light", size = 16, weight = 400})
surface.CreateFont("atlaschat.theme.version", {font = "Helvetica LT Std Light", size = 10, weight = 400, italic = true})
surface.CreateFont("atlaschat.theme.checkbox", {font = "Roboto Lt", size = 16, weight = 400})

atlaschat.CreateFont("Skeyler Servers ChatFont", "ss.chatFont", "Open Sans", 16, 800)

---------------------------------------------------------
-- Called when the chatbox should be created.
---------------------------------------------------------

function theme:Initialize()
	self.baseClass.Initialize(self)

	self.panel.listContainer:SetVisible(false)
	self.panel.entry:SetFont("ss.chatFont")
	self.panel:RemoveIcon(self.informationIcon)
	
	self.settingsIcon:SetImage("skeyler/graphics/settings.png")
end

---------------------------------------------------------
-- Called when you change the theme.
---------------------------------------------------------

function theme:OnThemeChange()
	self.panel:DockPadding(0, 4, 0, 0)

	self.panel.bottom:DockMargin(0, 6, 0, 0)
	self.panel.bottom:SetTall(24)
	self.panel.entry:DockMargin(0, 0, 0, 0)
	self.panel.iconHolder:DockMargin(0, 0, 0, 0)

	self.panel.prefix:SetParent()
	self.panel.prefix:Dock(NODOCK)
	
	local oldThink = self.panel.Think
	
	function self.panel:Think()
		oldThink(self)
		
		local x, y = self.entry:LocalToScreen()
		local w, h = self.entry:GetSize()
	
		self.prefix:SetPos(0, y)
		self.prefix:SetSize(x, h)
	end
	
	local oldVisible = self.panel.SetVisible
	
	function self.panel:SetVisible(bool)
		self.prefix:SetVisible(bool)
		
		oldVisible(self, bool)
	end
	
	self.panel:InvalidateLayout()
end

---------------------------------------------------------
-- Paints a generic background.
---------------------------------------------------------

theme.color.generic_background = Color(20, 20, 20, 200)
theme.color.generic_background_dark = Color(0, 0, 0, 230)
theme.color.generic_background_top = Color(35, 150, 229, 204)

function theme:PaintGenericBackground(panel, w, h, text, x, y, xAlign, yAlign)
	draw.SimpleRect(0, 0, w, h, panel.dark and self.color.generic_background_dark or self.color.generic_background)
	draw.SimpleRect(0, 0, w, 5, self.color.generic_background_top)


	if (text) then
		draw.SimpleText(text, "atlaschat.theme.generic", x or 14, y or 20, self.color.generic_label, xAlign or TEXT_ALIGN_LEFT, yAlign or TEXT_ALIGN_BOTTOM)
	end
end

---------------------------------------------------------
-- Paints a generic button.
---------------------------------------------------------

theme.color.button = Color(10, 10, 10, 160)
theme.color.button_hovered = Color(212, 213, 212, 160)

function theme:PaintButton(button, w, h)
	draw.SimpleRect(0, 0, w, h, self.color.button)
	
	if (button.Hovered) then
		draw.SimpleRect(0, 0, w, h, self.color.button_hovered)
	end
	
	local text, font, color = button:GetText(), button:GetFont(), button:GetTextColor()
	
	draw.SimpleText(text, font, w /2, h /2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

---------------------------------------------------------
-- Paints the chatbox base panel (background).
---------------------------------------------------------

theme.color.background = Color(69, 69, 69, 160)

function theme:PaintPanel(w, h)
end

---------------------------------------------------------
-- Paints the chatbox text list (where the text is).
---------------------------------------------------------

theme.color.list_background = Color(10, 10, 10, 160)

function theme:PaintList(panel, w, h)
	if (ValidPanel(panel) and panel:IsVisible()) then
		--draw.SimpleRect(0, 0, w, h, self.color.list_background)
	end
end

---------------------------------------------------------
-- Paints the chatbox prefix.
---------------------------------------------------------

theme.color.prefix_background = Color(0, 0, 0, 230)
theme.color.prefix_background_inner = Color(10, 10, 10, 240)
theme.color.prefix_background_white = Color(255, 255, 255, 255 *0.05)

function theme:PaintPrefix(w, h)
	draw.SimpleRect(0, 0, w, h, self.color.prefix_background)

	local prefix = self.panel.prefix:GetPrefix()
	
	if (prefix) then
		draw.SimpleText(prefix, "ss.chat.prefix", w -5, h /2 +1, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText(prefix, "ss.chat.prefix", w -6, h /2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
-- Paints the chatbox text entry (where you write your text).
---------------------------------------------------------

theme.color.entry_background = Color(245, 245, 245, 255)
theme.color.entry_text = Color(7, 7, 7, 247)

function theme:PaintTextEntry(w, h, entry)
	entry = entry or self.panel.entry
	
	draw.SimpleRect(0, 0, w, h, self.color.entry_background)
	
	entry:DrawTextEntryText(self.color.entry_text, entry.m_colHighlight, self.color.entry_text)
end

---------------------------------------------------------
-- Paints the background of the scrollbar.
---------------------------------------------------------

theme.color.scrollbar_background = Color(69, 69, 69, 160)

function theme:PaintScrollbar(panel, w, h)
end

---------------------------------------------------------
-- Paints the scrollbar grip.
---------------------------------------------------------

theme.color.scrollbar_grip = Color(162, 163, 162, 40)
theme.color.scrollbar_grip_hovered = Color(162, 163, 162, 160)

function theme:PaintScrollbarGrip(panel, w, h)
	if (self.panel:IsVisible()) then
		if (panel.Hovered) then
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_grip_hovered)
		else
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_grip)
		end
	end
end

---------------------------------------------------------
-- Paints the up button of the scrollbar.
---------------------------------------------------------

theme.color.scrollbar_buttonup = Color(162, 163, 162, 40)
theme.color.scrollbar_buttonup_hovered = Color(162, 163, 162, 160)

function theme:PaintScrollbarUpButton(panel, w, h)
	if (self.panel:IsVisible()) then
		if (panel.Hovered) then
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_buttonup_hovered)
		else
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_buttonup)
		end
	
		draw.SimpleText("t", "Marlett", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
-- Paints the down button of the scrollbar.
---------------------------------------------------------

theme.color.scrollbar_buttondown = Color(162, 163, 162, 40)
theme.color.scrollbar_buttondown_hovered = Color(162, 163, 162, 160)

function theme:PaintScrollbarDownButton(panel, w, h)
	if (self.panel:IsVisible()) then
		if (panel.Hovered) then
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_buttondown_hovered)
		else
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_buttondown)
		end
		
		draw.SimpleText("u", "Marlett", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

theme.color.list_container_new = Color(255, 165, 0, 160)
theme.color.list_container_hover = Color(211, 211, 211, 160)
theme.color.list_container_selected = Color(255, 165, 0, 255)
theme.color.list_container_background = Color(10, 10, 10, 160)

function theme:PaintListContainer(panel, w, h)
	draw.SimpleRect(0, 0, w, h, self.color.list_container_background)
	
	if (panel.selected) then
		draw.SimpleRect(0, h -2, w, 2, self.color.list_container_selected)
	end
	
	if (panel.Hovered) then
		draw.SimpleRect(0, 0, w, h, self.color.list_container_hover)
	end
	
	if (panel.new) then
		if (panel.blink <= CurTime()) then
			draw.SimpleRect(0, 0, w, h, self.color.list_container_new)
			
			if (panel.blink +1 <= CurTime()) then
				panel.blink = CurTime() +1.5
			end
		end
	end

	local players = panel.list.players

	if (#players > 1) then
		local text = ""
		
		for k, player in pairs(players) do
			if (IsValid(player)) then
				local nick = player:Nick()
				
				text = text .. nick .. (k == #players and "" or ", ")
			end
		end
		
		local x, y = panel:LocalToScreen(0, 0)
		local w2, h2 = panel:GetSize()

		render.SetScissorRect(x, y, x +(w2 -12), y +h2, true)
			draw.SimpleText(text, "atlaschat.theme.list.name", 4, h /2, self.color.generic_label, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		render.SetScissorRect(0, 0, 0, 0, false)
	else
		draw.SimpleText(panel.name, "atlaschat.theme.list.name", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

theme.color.icon_hold_background = Color(35, 150, 229, 204)
theme.color.icon_hold_background_hover = Color(71, 71, 71)

function theme:PaintIconHolder(panel, w, h)
	draw.SimpleRect(0, 0, w, h, self.settingsIcon.Hovered and self.color.icon_hold_background_hover or self.color.icon_hold_background)
end

---------------------------------------------------------
--
---------------------------------------------------------

function theme:PaintExpressionRow(panel, w, h, offset)
	self:PaintGenericBackground(panel, w, h)
	
	if (offset) then
		draw.SimpleText("Expression", "atlaschat.theme.row", 4, h /2, self.color.generic_label, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Result", "atlaschat.theme.row", offset, h /2, self.color.generic_label, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

local color_line = Color(255, 255, 255, 5)

local function ParseConfig(sorted, list, sliderList, admin)
	local chatFonts = atlaschat.GetFonts()
	
	for i = 1, #sorted do
		local info = sorted[i]
		local object = atlaschat.config.Get(info.name)
		local text = object:GetText()

		local base = vgui.Create("Panel")
		base:Dock(TOP)
		
		base.admin = admin
		
		if (info.index == 1) then
			local value = object:GetBool()
			
			local checkBox = atlaschat.LabelAndCheckbox(base, text)
			checkBox:SetChecked(value)
			
			checkBox.object = object
			
			function checkBox:OnChange(value)
				if (admin) then
					net.Start("atlaschat.gtcfg")
						net.WriteString(self.object:GetName())
						net.WriteType(value)
					net.SendToServer()
				else
					self.object:SetBool(value)
				end
			end
		end
		
		if (info.index == 2) then
			base:DockMargin(0, 0, 0, 4)
			
			local value = object:GetInt()
			
			local slider = atlaschat.LabelAndNumSlider(base, text)
			slider:SetMinMax(0, 1000)
			slider:SetValue(value)
			
			slider.object = object
			
			function slider:OnValueChanged(value)
				if (admin) then
					self.nextUpdate = CurTime() +0.5
				else
					self.object:SetInt(math.Round(value))
				end
			end
			
			if (admin) then
				function slider:Think()
					if (self.nextUpdate and self.nextUpdate <= CurTime()) then
						local value = self:GetValue()
						
						net.Start("atlaschat.gtcfg")
							net.WriteString(self.object:GetName())
							net.WriteType(value)
						net.SendToServer()
						
						self.nextUpdate = nil
					end
				end
			end
			
			base:SizeToContentsY()
			
			sliderList:AddItem(base)
		end

		if (info.index == 3) then
			base:Remove()
		end
		
		if (info.index != 2 and info.index != 3) then
			base:SizeToContentsY()
		
			list:AddItem(base)
		end
	end
end

local color_version = Color(255, 255, 255, 75)
local closeTexture = surface.GetTextureID("gui/close_32")
local color_blue = Color(35, 150, 229, 224)
local color_blue_light = Color(35 +20, 150 +20, 229 +20, 224)

function theme:ToggleConfigPanel()
	if (!ValidPanel(self.config)) then
		self.config = vgui.Create("DFrame")
		self.config:SetSize(374, 560)
		self.config:Center()
		self.config:DockPadding(6, 52, 6, 6)
		self.config:SetTitle("")
		self.config:SetDeleteOnClose(false)
		self.config:MakePopup()
	
		self.config.dark = true
		
		self.config.btnMaxim:Remove()
		self.config.btnMinim:Remove()
		self.config.btnClose:SetSize(16, 16)
		
		function self.config.btnClose:Paint(w, h)
			draw.SimpleText("x", "ss.chat.close", w /2, h /2, self.Hovered and color_red or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		function self.config:PerformLayout()
			local w = self:GetWide()
			
			self.btnClose:SetPos(w -22, 12)
		end
		
		function self.config:Paint(w, h)
			atlaschat.theme.Call("PaintGenericBackground", self, w, h, "Chatbox Configuration")
			
			draw.SimpleText("Chat Version: " .. atlaschat.version:GetString(), "atlaschat.theme.version", 14, 39, color_version, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		end
		
		self.config.list = self.config:Add("atlaschat.chat.list")
		self.config.list:Dock(TOP)
		self.config.list:SetScrollbarWidth(12)
		self.config.list:DockMargin(0, 0, 0, 2)
		self.config.list:GetCanvas():DockPadding(8, 12, 8, 0)
		
		function self.config.list:Paint(w, h)
			surface.SetDrawColor(color_line)
			surface.DrawLine(9, 2, w -9, 2)
		end
		
		self.config.sliderList = self.config:Add("atlaschat.chat.list")
		self.config.sliderList:Dock(TOP)
		self.config.sliderList:SetScrollbarWidth(12)
		self.config.sliderList:GetCanvas():DockPadding(8, 16, 8, 0)
	
		function self.config.sliderList:Paint(w, h)
			surface.SetDrawColor(color_line)
			surface.DrawLine(9, 0, w -9, 0)
		end
		
		local config = atlaschat.config.GetStored()
		local sorted = {}
		
		local function int(v) return type(tonumber(v)) == "number" end
		local function bool(v) return v == true or v == false or v == "true" or v == "false" end
		
		for name, object in pairs(config) do
			if (object:GetText() and !object.server) then
				local value = object:GetValue()
				local isNumber, isBool = int(value), bool(value)
				local index
				
				if (isBool) then index = 1 end
				if (isNumber) then index = 2 end
				
				-- It has to be a string!
				if (!isBool and !isNumber) then index = 3 end
				
				table.insert(sorted, {name = name, index = index})
			end
		end
		
		table.sort(sorted, function(a, b) return a.index < b.index end)
		
		ParseConfig(sorted, self.config.list, self.config.sliderList)
		
		local buttonBase = self.config:Add("Panel")
		buttonBase:Dock(TOP)
		buttonBase:SetTall(28)
		buttonBase:DockMargin(7, 12, 7, 7)
		
		---------------------------------------------------------
		-- Reset your own configuration.
		---------------------------------------------------------
		
		local button = buttonBase:Add("atlaschat.chat.button")
		button:SetText("RESET")
		button:SetFont("ss.chat.button")
		button:SetSize(170, 28)
		button:SetColor(color_white)
		button:Dock(LEFT)
		button:DockMargin(0, 0, 0, 0)
		
		function  button:Paint(w, h)
			draw.SimpleRect(0, 0, w, h, self.Hovered and Color(91, 91, 91) or  Color(71, 71, 71))
		end
		
		function button:DoClick()
			if (LocalPlayer():IsAdmin()) then
				local menu = DermaMenu()
					local players = player.GetAll()
					
					for k, v in pairs(players) do
						menu:AddOption(v:Nick(), function()
							local steamID = v:SteamID()
				
							net.Start("atlaschat.rqclrcfg")
								net.WriteString(steamID)
							net.SendToServer()
						end)
					end
				menu:Open()
			else
				local steamID = LocalPlayer():SteamID()
				
				net.Start("atlaschat.rqclrcfg")
					net.WriteString(steamID)
				net.SendToServer()
			end
		end
		
		self.config.resetButton = button

		---------------------------------------------------------
		-- Save button.
		---------------------------------------------------------
	
		self.config.saveButton = buttonBase:Add("atlaschat.chat.button")
		self.config.saveButton:SetText("SAVE")
		self.config.saveButton:SetFont("ss.chat.button")
		self.config.saveButton:SetColor(color_white)
		self.config.saveButton:SetTall(28)
		self.config.saveButton:Dock(FILL)
		self.config.saveButton:DockMargin(4, 0, 0, 0)

		function self.config.saveButton:Paint(w, h)
			draw.SimpleRect(0, 0, w, h, self.Hovered and color_blue_light or color_blue)
		end
		
		function self.config.saveButton.DoClick()
			self.config:SetVisible(false)
		end
		
		---------------------------------------------------------
		--
		---------------------------------------------------------
		
		if (LocalPlayer():IsSuperAdmin()) then
			local sorted = {}
		
			for name, object in pairs(config) do
				if (object:GetText() and object.server) then
					local value = object:GetValue()
					local isNumber, isBool = int(value), bool(value)
					local index
					
					if (isBool) then index = 1 end
					if (isNumber) then index = 2 end
					
					-- It has to be a string!
					if (!isBool and !isNumber) then index = 3 end
					
					table.insert(sorted, {name = name, index = index})
				end
			end
			
			if (#sorted > 0) then
				self.config.adminLabel = vgui.Create("DLabel")
				self.config.adminLabel:Dock(TOP)
				self.config.adminLabel:DockMargin(0, 12, 0, 8)
				self.config.adminLabel:SetFont("atlaschat.theme.userlist")
				self.config.adminLabel:SetText("Global Values")
				self.config.adminLabel:SizeToContents()
				
				self.config.adminLabel.admin = true
				
				self.config.list:AddItem(self.config.adminLabel)
				
				table.sort(sorted, function(a, b) return a.index < b.index end)
				
				ParseConfig(sorted, self.config.list, self.config.sliderList, true)
			end
		end
		
		self.config.list:GetCanvas():InvalidateLayout(true)
		self.config.sliderList:GetCanvas():InvalidateLayout(true)
		
		timer.Simple(FrameTime() *2, function()
			self.config.list:InvalidateLayout(true)
			self.config.list:SizeToChildren(false, true)
			
			self.config.sliderList:InvalidateLayout(true)
			self.config.sliderList:SizeToChildren(false, true)
			
			self.config:SetTall(self.config.list:GetTall() +self.config.sliderList:GetTall() +106)
			self.config:Center()
		end)
	else
		self.config:SetVisible(!self.config:IsVisible())
		
		if (LocalPlayer():IsSuperAdmin()) then
		else
			local children = self.config.list:GetCanvas():GetChildren()
			
			for k, child in pairs(children) do
				if (ValidPanel(child) and child.admin) then
					child:Remove()
				end
			end

			self.config.list:GetCanvas():InvalidateLayout(true)
			
			local children = self.config.sliderList:GetCanvas():GetChildren()
			
			for k, child in pairs(children) do
				if (ValidPanel(child) and child.admin) then
					child:Remove()
				end
			end

			self.config.sliderList:GetCanvas():InvalidateLayout(true)
			
			timer.Simple(FrameTime() *2, function()
				self.config.list:InvalidateLayout(true)
				self.config.list:SizeToChildren(false, true)
				
				self.config.sliderList:InvalidateLayout(true)
				self.config.sliderList:SizeToChildren(false, true)
				
				self.config:SetTall(self.config.list:GetTall() +self.config.sliderList:GetTall() +106)
				self.config:Center()
			end)
		end
	end
end

---------------------------------------------------------
-- This is where we add all the panels.
---------------------------------------------------------

local table = table
local pairs = pairs
local string = string
local unpack = unpack
local GetType = type
local parseX, parseColor, titleColor, parseBase = nil, nil, nil, nil

local color_tag_shadow = Color(0, 0, 0, 200)

function theme:ParseData(data, list, isTitle)
	local realColor = isTitle and titleColor or parseColor
	
	for i = 1, #data do
		local value, type = data[i], GetType(data[i])

		if (type == "Player") then
			if (value.GetRank and value:GetRank() > 0 and ((value.fakerank and value.fakerank > 0) or !value.fakerank)) then
				local tagPanel = vgui.Create("Panel")
				
				tagPanel.base = self.panel
				tagPanel.parseBase = parseBase
				
				local text, color, fakeRank = nil, nil, value.fakerank
		
				if (fakeRank == 50) then
					text, color = "ADMIN", Color(255, 72, 72)
				elseif (fakeRank == 20) then
					text, color = "DEVeloper", Color(87, 198, 255)
				elseif (fakeRank == 1) then
					text, color = "VIP", Color(255, 216, 0)
				else
					text, color = string.upper(value:GetRankName()), value:GetRankColor()
				end
				
				text = string.upper(text)
				
				function tagPanel:Paint(w, h)
					local renderX, renderY = self.base.list:LocalToScreen()
					local renderW, renderH = self.base.list:GetSize()
					
					self:SetAlpha(self.parseBase:GetAlpha())
					
					render.SetScissorRect(0, renderY, renderX +renderW, renderY +renderH, true)
						local x, y = self.parseBase:LocalToScreen()
						
						self:SetPos(0, y)
						self:SetSize(x -4, 16)
	
						draw.SimpleRect(0, 0, w, h, Color(color.r, color.g, color.b, 200))
						
						draw.SimpleText(text, "ss.chat.tag", w -3, h /2 +1, color_tag_shadow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
						draw.SimpleText(text, "ss.chat.tag", w -4, h /2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					render.SetScissorRect(0, 0, 0, 0, false)
				end
			end
			
			local avatarsEnabled = atlaschat.enableAvatars:GetBool()
			local rankIconsEnabled = atlaschat.enableRankIcons:GetBool()
			
			if (!DarkRP or (DarkRP and (data[2] == "(OOC) " or i == 1))) then
				if (avatarsEnabled) then
					local size = atlaschat.smallAvatar:GetBool() and 24 or 32
					
					if (parseBase:GetTall() < size) then
						parseBase:SetTall(size)
					end
					
					local avatar = parseBase:Add("AvatarImage")
					avatar:SetPos(parseX, 0)
					avatar:SetSize(size, size)
					avatar:SetPlayer(value, size)
					
					avatar.steamID = value:SteamID()
					
					function avatar:OnCopiedText()
						return "<avatar=" .. self.steamID .. ">"
					end
					
					parseX = parseX +avatar:GetWide() +4
				end
				
				if (rankIconsEnabled) then
					for userGroup, image in pairs(atlaschat.ranks) do
						local isUserGroup = value:IsUserGroup(userGroup)
						
						if (isUserGroup) then
							local icon = parseBase:Add("DImage")
							icon:SetImage(image)
							icon:SetSize(16, 16)
							icon:SetPos(parseX, 0)
							icon:SetToolTip(userGroup)
							
							function icon:OnCopiedText()
								return userGroup
							end
							
							parseX = parseX +icon:GetWide() +4
						end
					end
				end
				
				local title = value:GetNetworkedString("ac_title", "")
				
				if (title != "") then
					local titleData = {color_white, "[", title, color_white, "] "}
		
					self:ParseExpressions(titleData, parseBase, value)
					self:ParseData(titleData, list, true)
				end
			end
			
			local color, text = ((!DarkRP and i != 4) or (DarkRP and i == 1)) and value:GetPlayerChatColor() or realColor, value:Nick()
			
			local label = atlaschat.GenericLabel()
			label:SetParent(parseBase)
			label:SetPos(parseX, 0)
			label:SetText(text)
			label:SetColor(color)
			label:SizeToContents()
			label:SetMouseInputEnabled(true)
			
			label.cursor = true
			label.player = value
			
			function label:OnCursorEntered()
				self:SetCursor("hand")
			end
			
			function label:OnCursorExited()
				self:SetCursor("arrow")
			end
			
			function label:OnMousePressed(code)
				if (code == MOUSE_LEFT) then
					self.wasPressed = CurTime()
				end
			end
			
			function label:OnMouseReleased()
				if (self.wasPressed and CurTime() -self.wasPressed <= 0.16) then
					atlaschat.theme.Call("PlayerLabelPressed", self.player)
				end
				
				self.wasPressed = nil
			end
			
			atlaschat.BuildFontCache(text)
			
			parseX = parseX +label:GetWide()
		end
		
		if (type == "table") then
			if (value.r and value.g and value.b) then
				realColor = value
			end
		end
		
		if (type == "string" or type == "number") then
			atlaschat.BuildFontCache(value)
			
			local label = atlaschat.GenericLabel()
			label:SetParent(parseBase)
			label:SetPos(parseX, 0)
			label:SetText("")
			label:SetColor(realColor)
			label:SizeToContents()
			
			local exploded, start, ending, foundFirst, seperator = string.Explode(" ", value), 1, 1, false, " "
			
			if (#exploded <= 2) then
				exploded, seperator = string.Explode("", value), ""
			end
			
			while ending <= #exploded do
				local text = table.concat(exploded, seperator, start, ending)
				
				label:SetText(text)
				label:SizeToContents()
			
				-- Too much text, let's cut it off.
				if (parseX +label:GetWide() >= parseBase:GetWide() -(list.VBar.btnGrip:GetWide() +2)) then
					local previous = ending -1
					
					-- This is when it's in the beginning of the text.
					if (previous < start) then
						parseBase = atlaschat.NewBasePanel()
						
						-- Add the base panel to the list so it'll get a size
						list:AddItem(parseBase)
						list:GetCanvas():InvalidateLayout(true)
	
						parseBase:InvalidateLayout(true)
						
						parseX = 4

						label:SetParent(parseBase)
						label:SetPos(parseX, 0)
						label:SetText(text .. " ")
						label:SizeToContents()
						
						parseX = parseX +label:GetWide()
						
						-- Create the next label.
						label = atlaschat.GenericLabel()
						label:SetParent(parseBase)
						label:SetPos(parseX, 0)
						label:SetText("")
						label:SetColor(realColor)
						label:SizeToContents()
						
						start, ending, foundFirst = ending +1, start, true
					else
						label:SetText(table.concat(exploded, seperator, start, previous))
						label:SizeToContents()
			
						parseX = 4
	
						parseBase = atlaschat.NewBasePanel()
						
						-- Add the base panel to the list so it'll get a size
						list:AddItem(parseBase)
						list:GetCanvas():InvalidateLayout(true)
	
						parseBase:InvalidateLayout(true)
						
						-- Create the next label.
						label = atlaschat.GenericLabel()
						label:SetParent(parseBase)
						label:SetPos(parseX, 0)
						label:SetText("")
						label:SetColor(realColor)
						label:SizeToContents()

						start, ending, foundFirst = ending, start, false
					end
				else
					ending = ending +1
					
					-- We're at the end.
					if (ending > #exploded) then
						if (text != "") then
							label:SetText(text)
							label:SizeToContents()
							
							parseX = parseX +label:GetWide()
						else
							label:Remove()
						end
					end
				end
			end
		end
		
		if (type == "Panel") then
			-- Lol hacky.
			if (parseBase != value:GetParent()) then
				value:SetParent(parseBase)
			end
			
			if (value:GetTall() > parseBase:GetTall()) then
				parseBase:SetTall(value:GetTall())
			end
			
			value:SetPos(parseX, 0)
			
			-- Wrap the label.
			if (value:GetClassName() == "Label") then
				local label, valueText, font = value, value:GetText(), value:GetFont()
				
				atlaschat.BuildFontCache(valueText, font)
				
				label:SetText("")
				label:SizeToContents()
				
				local exploded, start, ending, foundFirst, color, seperator = string.Explode(" ", valueText), 1, 1, false, value:GetTextColor(), " "
	
				if (#exploded <= 2) then
					exploded, seperator = string.Explode("", valueText), ""
				end
			
				while ending <= #exploded do
					local text = table.concat(exploded, seperator, start, ending)
					
					label:SetText(text)
					label:SizeToContents()
				
					-- Too much text, let's cut it off.
					if (parseX +label:GetWide() >= parseBase:GetWide() -(self.panel.list.VBar.btnGrip:GetWide() +2)) then
						local previous = ending -1
						
						-- This is when it's in the beginning of the text.
						if (previous < start) then
							parseBase = atlaschat.NewBasePanel()
							
							-- Add the base panel to the list so it'll get a size
							list:AddItem(parseBase)
							list:GetCanvas():InvalidateLayout(true)
		
							parseBase:InvalidateLayout(true)
							
							parseX = 4
	
							label:SetParent(parseBase)
							label:SetPos(parseX, 0)
							label:SetText(text .. " ")
							label:SizeToContents()
							
							parseX = parseX +label:GetWide()
							
							local attributes = label:GetTable()
							
							-- Create the next label.
							label = atlaschat.GenericLabel()
							
							for k, v in pairs(attributes) do
								label[k] = v
							end
							
							label:SetParent(parseBase)
							label:SetPos(parseX, 0)
							label:SetText("")
							label:SetFont(font)
							label:SetColor(color)
							label:SizeToContents()
							
							if (label:GetTall() > parseBase:GetTall()) then
								parseBase:SetTall(label:GetTall())
							end
							
							start, ending, foundFirst = ending +1, start, true
						else
							label:SetText(table.concat(exploded, seperator, start, previous))
							label:SizeToContents()
				
							parseX = 4
		
							parseBase = atlaschat.NewBasePanel()
							
							-- Add the base panel to the list so it'll get a size
							list:AddItem(parseBase)
							list:GetCanvas():InvalidateLayout(true)
		
							parseBase:InvalidateLayout(true)
							
							local attributes = label:GetTable()
							
							-- Create the next label.
							label = atlaschat.GenericLabel()
							
							for k, v in pairs(attributes) do
								label[k] = v
							end
							
							label:SetParent(parseBase)
							label:SetPos(parseX, 0)
							label:SetText("")
							label:SetFont(font)
							label:SetColor(color)
							label:SizeToContents()
							
							if (label:GetTall() > parseBase:GetTall()) then
								parseBase:SetTall(label:GetTall())
							end
							
							start, ending, foundFirst = ending, start, false
						end
					else
						ending = ending +1
						
						-- We're at the end.
						if (ending > #exploded) then
							if (text != "") then
								label:SetText(text)
								label:SizeToContents()
								
								parseX = parseX +label:GetWide()
							else
								label:Remove()
							end
						end
					end
				end
			else
				parseX = parseX +value:GetWide() +1
			end
		end
	end
end

---------------------------------------------------------
-- When text is added this is where we add it to the
-- chatbox text list.
---------------------------------------------------------

function theme:ParseText(list, ...)
	local data = {...}
	local list = list or self.panel.list
	
	-- This is the panel that the text rests on.
	parseBase = atlaschat.NewBasePanel()

	-- We'll use this to set the position of the next item and to see if width is overflowing.
	parseX = 4
	
	-- This is the color of the text.
	parseColor = Color(255, 255, 255)
	
	-- Special for the title.
	titleColor = Color(255, 255, 255)
	
	-- Add the base panel to the list so it'll get a size
	list:AddItem(parseBase)
	list:GetCanvas():InvalidateLayout(true)
	
	parseBase:InvalidateLayout(true)
	
	-- Parse expressions first.
	local expressionPlayer
	
	for i = 1, #data do
		local value, type = data[i], GetType(data[i])
	
		if (type == "Player") then
			expressionPlayer = value
			
			break
		else
			if (DarkRP and i == 2 and type == "string") then
				expressionPlayer = util.FindPlayerAtlaschat(value)
				
				break
			end
		end
	end
	
	self:ParseExpressions(data, parseBase, expressionPlayer)

	-- DarkRP support...
	if (DarkRP and GetType(data[2]) == "string") then
		local player = util.FindPlayerAtlaschat(data[2])
	
		if (IsValid(player)) then
			local nick = player:Nick()
			local nickStart, nickEnd = string.find(data[2], nick, 1, true)
			
			if (nickStart and nickEnd) then
				local leftOver = string.sub(data[2], nickEnd +1)
				
				data[2] = string.sub(data[2], 1, nickStart -1)
				
				table.insert(data, 3, player)
				
				if (leftOver and leftOver != "") then
					table.insert(data, 4, leftOver)
				end
			end
		end
	
	-- TTT Support.
	elseif (GAMEMODE.round_state) then
		if (GetType(data[4]) == "string" and GetType(data[2]) == "string" and data[2] == "(TRAITOR) ") then
			local player = util.FindPlayerAtlaschat(data[4])
	
			if (IsValid(player)) then
				data[4] = player
			end
		end
	end
	
	-- A nice little timestamp!
	if (atlaschat.timestamp:GetBool()) then
		local date = os.date("%H:%M:%S", os.time())
		
		local label = atlaschat.GenericLabel()
		label:SetParent(parseBase)
		label:SetPos(parseX, 0)
		label:SetText(date)
		label:SetColor(self.color.timestamp)
		label:SizeToContents()
		
		atlaschat.BuildFontCache(date)
		
		parseX = parseX +label:GetWide()
		
		local label = atlaschat.GenericLabel()
		label:SetParent(parseBase)
		label:SetPos(parseX, 0)
		label:SetText(" - ")
		label:SetColor(color_white)
		label:SizeToContents()

		parseX = parseX +label:GetWide()
	end
	
	-- Add all the panels.
	self:ParseData(data, list)
	
	-- Make the chat category blink.
	if (self.panel:GetActiveList() != list) then
		list:GetHost():SetNew(true)
	end
	
	list:GetCanvas():InvalidateLayout(true)
	list:GetCanvas():InvalidateChildren(true)
	
	if (self.panel:IsVisible()) then
		if (list:GetShouldScroll()) then
			timer.Simple(0, function() list.VBar:SetScroll(list:GetCanvas():GetTall()) end)
		end
	else
		timer.Simple(0, function() list.VBar:SetScroll(list:GetCanvas():GetTall()) end)
	end
	
	local playSound = atlaschat.chatSound:GetBool()
	
	if (playSound) then
		chat.PlaySound()
	end
	
	-- Reset the values.
	parseX, parseColor, titleColor, parseBase = nil, nil, nil, nil
end

---------------------------------------------------------
-- When we close and open the chatbox.
---------------------------------------------------------

function theme:OnToggle(show)
	self.panel:SetVisible(show)
	
	local list = self.panel:GetActiveList()
	
	if (show) then
		local x, y = 85, ScrH() -545
		local w, h = atlaschat.chat_w:GetInt(), atlaschat.chat_h:GetInt()
		
		if (atlaschat.chat_w:GetInt() == 0) then w = atlaschat.ScaleSize(200, true)	atlaschat.chat_w:SetInt(w) end
		if (atlaschat.chat_h:GetInt() == 0) then h = atlaschat.ScaleSize(150) 		atlaschat.chat_h:SetInt(h) end
		
		self.panel:SetPos(x, y)
		self.panel:SetSize(w, h)

		list:SetParent(self.panel)
		list:Dock(FILL)
		list:SetMouseInputEnabled(true)
		list:SetKeyboardInputEnabled(true)
		list:ScrollToBottom()
		
		self.panel.listContainer:SetVisible(false)
		--self.panel.listContainer:SetPos(x, y +h)
		--self.panel.listContainer:SetSize(w, 18)
		
		self.panel:MakePopup()
		self.panel.entry:RequestFocus()
		
		local children = list:GetCanvas():GetChildren()
		
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				child:SetAlpha(255)
				
				child.m_AnimList = nil
			end
		end
	else
		local x, y = self.panel:LocalToScreen(list:GetPos())
		local w, h = list:GetSize()
		
		self.panel.listContainer:SetVisible(false)
		
		list:SetParent()
		list:Dock(NODOCK)
		list:SetPos(x, y )
		list:SetSize(w, h)
		list:SetMouseInputEnabled(false)
		list:SetKeyboardInputEnabled(false)
		list:ScrollToBottom()
		
		local children = list:GetCanvas():GetChildren()
		
		for k, child in pairs(children) do
			if (ValidPanel(child) and (child.fade and child.fade <= CurTime()) or !child.fade) then
				child:SetAlpha(0)
			end
		end
	end
	
	if (self.panel.entry.key) then
		self.panel.prefix:SetPrefix("PM")
	else
		if (self.panel.team) then
			self.panel.prefix:SetPrefix("TEAM")
		else
			self.panel.prefix:SetPrefix("CHAT")
		end
	end
	
	if (ValidPanel(self.userListBase) and self.userListBase:IsVisible()) then
		self.userListBase:SetVisible(show)
	end
end

atlaschat.theme.Register(theme)

-- Let's force a theme.
atlaschat.themeConfig = atlaschat.config.New(nil, "theme", "skeylerservers", true, true, true, true)

-- Development autorefresh.
hook.Add("OnReloaded", "ss.chat.OnReloaded", function()

	---------------------------------------------------------
	-- Create the chatbox.
	---------------------------------------------------------

	hook.Add("HUDPaint", "atlaschat.CreateChatbox", function()
		if (atlaschat.theme.loaded and system.HasFocus()) then
			local panel = atlaschat.theme.GetValue("panel")
			
			if (!ValidPanel(panel)) then
				atlaschat.theme.DeriveThemes()
				
				atlaschat.theme.Call("Initialize")
				
				atlaschat.themeConfig:OnChange(atlaschat.themeConfig:GetString())
	
				atlaschat.FixInvalidFont()
				
				atlaschat.fontHeight = draw.GetFontHeight(atlaschat.font:GetString())
				
				net.Start("atlaschat.plload")
				net.SendToServer()
			end
			
			hook.Remove("HUDPaint", "atlaschat.CreateChatbox")
		end
	end)
end)

---------------------------------------------------------
-- Creates a label and a DCheckBox.
---------------------------------------------------------

local color_blue = Color(35, 150, 229, 224)
local color_blue_inner = Color(35, 150, 229, 64)
local color_knob_inner = Color(39, 207, 255, 255)
local checkedTexture = Material("icon16/tick.png")

function atlaschat.LabelAndCheckbox(parent, name)
	local base = parent:Add("Panel")
	base:SetTall(16)
	base:Dock(TOP)
	base:DockMargin(0, 0, 0, 10)
	
	local checkbox = base:Add("DCheckBox")
	checkbox:Dock(LEFT)
	
	function checkbox:Paint(w, h)
		local checked = self:GetChecked()
		
		draw.SimpleRect(1, 1, w -2, h -2, color_white)
		draw.SimpleOutlined(1, 1, w -2, h -2, color_blue)
		draw.SimpleOutlined(2, 2, w -4, h -4, color_blue_inner)
		
		if (checked) then
			draw.Material(w /2 -5, h /2 -5, 10, 10, color_white, checkedTexture)
		end
	end
	
	local label = base:Add("DLabel")
	label:SetText(name)
	label:SetFont("atlaschat.theme.checkbox")
	label:SizeToContents()
	label:Dock(LEFT)
	label:DockMargin(10, 0, 8, 0)
	label:SetSkin("atlaschat")
	
	return checkbox
end

---------------------------------------------------------
-- Creates a label and a Slider.
---------------------------------------------------------

function atlaschat.LabelAndNumSlider(parent, name)
	local slider, base = util.SliderAndLabel(parent, name)
	base:Dock(TOP)

	base.label:SetFont("atlaschat.theme.checkbox")
	base.label:SizeToContents()
	
	slider.Knob:SetSize(8, 8)
	
	function slider.Knob:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, color_white)
		draw.RoundedBox(4, 1, 1, w -2, h -2, color_knob_inner)
	end
	
	function base:PerformLayout()
		local w, h = self:GetSize()
		
		self.label:SetPos(0, h /2 -self.label:GetTall() /2)

		self.slider:SetWide(w /2)
		self.slider:SetPos(w -self.slider:GetWide(), h /2 -self.slider:GetTall() /2)
	end
	
	return slider
end