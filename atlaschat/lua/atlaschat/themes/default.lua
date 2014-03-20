--          _   _                  _           _   
--     /\  | | | |                | |         | |  
--    /  \ | |_| | __ _ ___    ___| |__   __ _| |_ 
--   / /\ \| __| |/ _` / __|  / __| '_ \ / _` | __|
--  / ____ \ |_| | (_| \__ \ | (__| | | | (_| | |_ 
-- /_/    \_\__|_|\__,_|___/  \___|_| |_|\__,_|\__|
--                                                 
--                                                 
-- © 2014 metromod.net do not share or re-distribute
-- without permission of its author (Chewgum - chewgumtj@gmail.com).
--


-- ADD A WORD FILTER

---------------------------------------------------------
-- Theme variables.
---------------------------------------------------------

-- The theme's unique key.
theme.unique = "default"

-- A pretty name for this theme.
theme.name = "Default Black"

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
theme.messageSpacing = 2

-- Default fonts for this theme.
surface.CreateFont("atlaschat.theme.default.title", {font = "Roboto Lt", size = 20, weight = 400})
surface.CreateFont("atlaschat.theme.userlist", 		{font = "Roboto Lt", size = 18, weight = 400})
surface.CreateFont("atlaschat.theme.userlist.player", {font = "Arial", size = 15, weight = 800})
surface.CreateFont("atlaschat.theme.prefix", 		{font = "Helvetica", size = 16, weight = 800, shadow = true})
surface.CreateFont("atlaschat.theme.list.name", 	{font = "Arial", size = 14, weight = 800})
surface.CreateFont("atlaschat.theme.list.close", 	{font = "Arial", size = 12, weight = 800, antialias = false})
surface.CreateFont("atlaschat.theme.add", 			{font = "Tahoma", size = 18, weight = 800})
surface.CreateFont("atlaschat.theme.invite", 		{font = "Tahoma", size = 12, weight = 400})
surface.CreateFont("atlaschat.theme.row",			 {font = "Arial", size = 18, weight = 800})

---------------------------------------------------------
-- Chat fonts.
---------------------------------------------------------

local chatFonts = {}

function atlaschat.CreateFont(name, unique, font, size, weight)
	surface.CreateFont(unique, {font = font, size = size, weight = weight})
	surface.CreateFont(unique .. ".shadow", {font = font, size = size, weight = weight, antialias = false, outline = true, blursize = 1})
	
	table.insert(chatFonts, {name, unique})
end

atlaschat.CreateFont("Default (DejaVu Sans)", "atlaschat.theme.text", 	"DejaVu Sans", 14, 580)
atlaschat.CreateFont("Tahoma", 			"atlaschat.tahoma", 		"Tahoma", 14, 1000)
atlaschat.CreateFont("Tiny Tahoma", 	"atlaschat.tahoma.tiny", 	"Tahoma", 11, 0)
atlaschat.CreateFont("Huge Tahoma", 	"atlaschat.tahoma.huge",	"Tahoma", 24, 0)
atlaschat.CreateFont("Arial", 			"atlaschat.arial", 			"Arial", 16, 0)
atlaschat.CreateFont("Coolvetica", 		"atlaschat.coolvetica", 	"Coolvetica", 20, 0)
atlaschat.CreateFont("Verdana", 		"atlaschat.verdana", 		"Verdana", 16, 0)
atlaschat.CreateFont("Akbar", 			"atlaschat.akbar", 			"Akbar", 22, 0)
atlaschat.CreateFont("Courier New", 	"atlaschat.courier.new", 	"Courier New", 16, 0)

function atlaschat.GetFonts()
	return chatFonts
end

---------------------------------------------------------
-- Configuration variables.
---------------------------------------------------------

local version = "2.0.4.6"

atlaschat.version 				= atlaschat.config.New(nil, 								"version", 		version, 				true, true)
atlaschat.chat_x 				= atlaschat.config.New(nil, 								"chat_x", 		-1, 					true)
atlaschat.chat_y 				= atlaschat.config.New(nil, 								"chat_y", 		-1, 					true)
atlaschat.chat_w				= atlaschat.config.New(nil, 								"size_width", 	0, 						true)
atlaschat.chat_h 				= atlaschat.config.New(nil, 								"size_height", 	0, 						true)
atlaschat.font 					= atlaschat.config.New("The chat font", 					"font", 		"atlaschat.theme.text", true)
atlaschat.chatSound				= atlaschat.config.New("Play chat sound", 					"chat_sound", 	true, 					true)
atlaschat.fadetime 				= atlaschat.config.New("Message fade out speed",			"fadetime", 	12, 					true)
atlaschat.timestamp 			= atlaschat.config.New("Enable timestamp", 					"timestamp", 	true, 					true)
atlaschat.snowFlakes 			= atlaschat.config.New("Snow flake amount", 				"snow", 		100, 					true)
atlaschat.smallAvatar 			= atlaschat.config.New("Use small avatars", 				"small_avatar", false, 					true)
atlaschat.maxHistory 			= atlaschat.config.New("Max chat history", 					"max_history", 	100, 					true)
atlaschat.extraShadow 			= atlaschat.config.New("Extra font shadow", 				"extra_shadow", false, 					true)
atlaschat.filterJoinDisconnect 	= atlaschat.config.New("Hide join/disconnect messages", 	"filter_jndc", 	false, 					true)
atlaschat.messageFadeIn 		= atlaschat.config.New("Chat message fade in", 				"fadein", 		true, 					true)

if (atlaschat.version:GetString() != version) then atlaschat.version:SetString(version) end

function atlaschat.font:OnChange(value)
	local invalid = atlaschat.FixInvalidFont()
	
	if (!invalid) then
		atlaschat.fontHeight = draw.GetFontHeight(value)
		
		atlaschat.BuildFontCache(" - ")
		atlaschat.BuildFontCache("ACCEPTED")
		atlaschat.BuildFontCache("-> ACCEPT <-")
	end
end

local flakes = {}
local snowMaterial = Material("icon16/bullet_blue.png")

function atlaschat.snowFlakes:OnChange(value)
	value = tonumber(value)
	
	flakes = {}
	
	if (value > 0) then
		local w = atlaschat.chat_w:GetInt()
		
		for i = 1, value do
			flakes[i] = {x = math.random(0, w), y = math.random(-50, 0), sign = math.Round(math.random(-1, 1)), counter = 0, speed = math.random(5, 40), size = math.random(2, 10)}
		end
	end
end

---------------------------------------------------------
-- Called when the chatbox should be created.
---------------------------------------------------------

function theme:Initialize()
	local w, h, x, y = atlaschat.ScaleSize(200, true), atlaschat.ScaleSize(150), atlaschat.ScaleSize(10, true), atlaschat.ScaleSize(230)
	
	local panel = vgui.Create("atlaschat.chat")
	panel:SetSize(w, h)
	panel:SetPos(x, y)
	panel:DockPadding(6, 40, 6, 6)
	panel:MakePopup()
	
	panel.team = false
	
	if (atlaschat.chat_x:GetInt() == -1) 	then atlaschat.chat_x:SetInt(x) end
	if (atlaschat.chat_y:GetInt() == -1) 	then atlaschat.chat_y:SetInt(y) end
	if (atlaschat.chat_w:GetInt() == 0) 	then atlaschat.chat_w:SetInt(w) end
	if (atlaschat.chat_h:GetInt() == 0) 	then atlaschat.chat_h:SetInt(h) end

	panel.prefix = panel.bottom:Add("atlaschat.chat.prefix")
	panel.prefix:Dock(LEFT)
	
	panel.entry = panel.bottom:Add("atlaschat.chat.entry")
	panel.entry:Dock(FILL)
	panel.entry:DockMargin(2, 0, 0, 0)

	panel.list = panel:Add("atlaschat.chat.list")
	panel.list:Dock(FILL)
	panel.list:GetCanvas():DockPadding(0, 2, 0, 2)
	panel.list:SetScrollbarWidth(12)
	
	panel.listContainer = vgui.Create("atlaschat.chat.listcontainer")
	
	self.panel = panel
	
	self.mainChat = panel.listContainer:AddList(nil, panel.list, "GLOBAL")
	self.mainChat:OnMousePressed()
	
	self.settingsIcon = panel:AddIcon("icon16/cog.png", function() atlaschat.theme.Call("ToggleConfigPanel") end, "Configuration")
	
	self.informationIcon = panel:AddIcon("icon16/information.png", function()
		if (!ValidPanel(self.expressionPanel)) then
			self.expressionPanel = vgui.Create("DFrame")
			self.expressionPanel:SetSize(680, 400)
			self.expressionPanel:Center()
			self.expressionPanel:DockPadding(6, 40, 6, 6)
			self.expressionPanel:SetTitle("")
			self.expressionPanel:SetDeleteOnClose(false)
			self.expressionPanel:MakePopup()
		
			self.expressionPanel.dark = true
	
			function self.expressionPanel:Paint(w, h)
				atlaschat.theme.Call("PaintGenericBackground", self, w, h, "Expressions/Emoticons")
				
				return true
			end
			
			self.expressionPanel.list = self.expressionPanel:Add("atlaschat.chat.list")
			self.expressionPanel.list:Dock(FILL)
			self.expressionPanel.list:SetScrollbarWidth(12)
			self.expressionPanel.list:GetCanvas():DockPadding(4, 4, 4, 4)
			
			local top = vgui.Create("Panel")
			top:Dock(TOP)
			top:DockMargin(0, 0, 0, 2)
			top:SetTall(24)
			
			function top:Paint(w, h)
				atlaschat.theme.Call("PaintExpressionRow", self, w, h, self.offset)
				
				return true
			end
			
			self.expressionPanel.list:AddItem(top)
			
			local widest = 0
			local expressions = atlaschat.expression.GetStored()
			
			for i = 1, #expressions do
				local object = expressions[i]
				
				if (object.GetExample) then
					local base = vgui.Create("Panel")
					base:Dock(TOP)
					base:DockMargin(0, 4, 0, 0)
					
					function base:Paint(w, h)
						atlaschat.theme.Call("PaintExpressionRow", self, w, h)
						
						return true
					end
					
					local text, panel = object:GetExample(base)
					
					local label = base:Add("DLabel")
					label:Dock(LEFT)
					label:DockMargin(4, 0, 0, 0)
					label:SetText(text)
					label:SetSkin("atlaschat")
					label:SizeToContents()
					
					if (label:GetWide() > widest) then
						widest = label:GetWide()
					end
					
					base.panel = panel
					base.label = label
					
					function base:PerformLayout()
						if (ValidPanel(self.panel)) then
							local tall = self.panel:GetTall()
							
							self.panel:SetPos(widest +50, self:GetTall() /2 -tall /2)
							
							if (tall > self:GetTall()) then
								self:SetTall(tall)
								
								self.panel:SetPos(widest +50, 0)
								
								self.label:Dock(NODOCK)
								self.label:SetPos(4, tall /2 -self.label:GetTall() /2)
							end
						end
					end
					
					self.expressionPanel.list:AddItem(base)
				end
			end
			
			top.offset = widest +50
		else
			self.expressionPanel:SetVisible(!self.expressionPanel:IsVisible())
		end
	end, "Expressions/Emoticons")
	
	-- Hide the chat panel.
	timer.Simple(0.1, function()
		atlaschat.BuildFontCache(" - ")
		atlaschat.BuildFontCache("ACCEPTED")
		atlaschat.BuildFontCache("-> ACCEPT <-")
		
		self:OnToggle(false)
	end)
	
	local flakeAmount = atlaschat.snowFlakes:GetInt()
	
	if (flakeAmount > 0) then
		local w = atlaschat.chat_w:GetInt()
		
		for i = 1, flakeAmount do
			flakes[i] = {x = math.random(0, w), y = math.random(-50, 0), sign = math.Round(math.random(-1, 1)), counter = 0, speed = math.random(5, 40), size = math.random(2, 10)}
		end
	end
end

---------------------------------------------------------
-- Called when you change the theme.
---------------------------------------------------------

function theme:OnThemeChange()
	surface.CreateFont("atlaschat.theme.default.title", {font = "Roboto Lt", size = 20, weight = 400})
	surface.CreateFont("atlaschat.theme.prefix", 		{font = "Helvetica", size = 16, weight = 800, shadow = true})
	surface.CreateFont("atlaschat.theme.list.name", 	{font = "Arial", size = 14, weight = 800})
	
	self.panel:DockPadding(6, 40, 6, 6)
	self.panel:InvalidateLayout()
end

---------------------------------------------------------
-- Paints a generic background.
---------------------------------------------------------

theme.color.generic_background = Color(10, 10, 10, 160)
theme.color.generic_background_dark = Color(69, 69, 69, 220)

function theme:PaintGenericBackground(panel, w, h, text, x, y, xAlign, yAlign)
	draw.SimpleRect(0, 0, w, h, panel.dark and self.color.generic_background_dark or self.color.generic_background)
	
	if (text) then
		draw.SimpleText(text, "atlaschat.theme.userlist", x or 6, y or 8, self.color.generic_label, xAlign or TEXT_ALIGN_LEFT, yAlign or TEXT_ALIGN_BOTTOM)
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
-- Paints the snow flakes.
---------------------------------------------------------

function theme:PaintSnowFlakes(w, h)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(snowMaterial)

	if (#flakes > 0) then
		local flakeAmount = atlaschat.snowFlakes:GetInt()
		
		for i = 1, flakeAmount do
			flakes[i].counter = flakes[i].counter +flakes[i].speed /500
			flakes[i].x = flakes[i].x +(flakes[i].sign *math.cos(flakes[i].counter) /20)
			flakes[i].y = flakes[i].y +math.sin(flakes[i].counter) /40 +flakes[i].speed /30
			
			if (flakes[i].y > h) then
				flakes[i].y = math.random(-50,0)
				flakes[i].x = math.random(0, w)
			end
		end
		
		for i = 1, flakeAmount do
			surface.DrawTexturedRect(flakes[i].x, flakes[i].y, flakes[i].size, flakes[i].size)
		end
	end
end

---------------------------------------------------------
-- Paints the chatbox base panel (background).
---------------------------------------------------------

theme.color.background = Color(69, 69, 69, 160)

function theme:PaintPanel(w, h)
	draw.SimpleRect(0, 0, w, h, self.color.background)
	
	draw.SimpleText(GetHostName(), "atlaschat.theme.default.title", 8, 20, self.color.generic_label, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	self:PaintSnowFlakes(w, h)
end

---------------------------------------------------------
-- Paints the chatbox text list (where the text is).
---------------------------------------------------------

theme.color.list_background = Color(10, 10, 10, 160)

function theme:PaintList(panel, w, h)
	if (ValidPanel(panel) and panel:IsVisible()) then
		draw.SimpleRect(0, 0, w, h, self.color.list_background)
	end
end

---------------------------------------------------------
-- Paints the chatbox prefix.
---------------------------------------------------------

theme.color.prefix_background = Color(10, 10, 10, 160)

function theme:PaintPrefix(w, h)
	draw.SimpleRect(0, 0, w, h, self.color.entry_background)
	
	local prefix = self.panel.prefix:GetPrefix()
	
	if (prefix) then
		draw.SimpleText(prefix, "atlaschat.theme.prefix", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
-- Paints the chatbox text entry (where you write your text).
---------------------------------------------------------

theme.color.entry_background = Color(10, 10, 10, 160)

function theme:PaintTextEntry(w, h, entry)
	entry = entry or self.panel.entry
	
	draw.SimpleRect(0, 0, w, h, self.color.entry_background)
	
	entry:DrawTextEntryText(self.color.generic_label, entry.m_colHighlight, self.color.generic_label)
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

theme.color.icon_hold_background = Color(10, 10, 10, 160)

function theme:PaintIconHolder(panel, w, h)
	draw.SimpleRect(0, 0, w, h, self.color.icon_hold_background)
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

local function ParseConfig(sorted, list, admin)
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
		end
		
		if (info.index == 3) then
			if (info.name == "theme") then
				local themes = atlaschat.theme.GetStored()
				local comboBox = atlaschat.LabelAndOption(base, "Chatbox theme")
				
				for unique, data in pairs(themes) do
					comboBox:AddChoice(data.name, unique)
				end
				
				function comboBox:OnSelect(index, value, data)
					atlaschat.themeConfig:SetValue(data)
				end
			end
			
			if (info.name == "font") then
				local comboBox = atlaschat.LabelAndOption(base, "Chat message font")
				
				for i = 1, #chatFonts do
					local data = chatFonts[i]
					
					comboBox:AddChoice(data[1], data[2])
				end
				
				function comboBox:OnSelect(index, value, data)
					atlaschat.font:SetValue(data)
				end
			end
		end
		
		base:SizeToContentsY()
		
		list:AddItem(base)
	end
end

function theme:ToggleConfigPanel()
	if (!ValidPanel(self.config)) then
		self.config = vgui.Create("DFrame")
		self.config:SetSize(374, 560)
		self.config:Center()
		self.config:DockPadding(6, 32, 6, 6)
		self.config:SetTitle("")
		self.config:SetDeleteOnClose(false)
		self.config:MakePopup()
	
		self.config.dark = true

		function self.config:Paint(w, h)
			atlaschat.theme.Call("PaintGenericBackground", self, w, h, "Configuration - Chat Version: v" .. atlaschat.version:GetString())
		end
		
		self.config.list = self.config:Add("atlaschat.chat.list")
		self.config.list:Dock(FILL)
		self.config.list:SetScrollbarWidth(12)
		self.config.list:GetCanvas():DockPadding(8, 8, 8, 8)
		
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
		
		ParseConfig(sorted, self.config.list)
		
		---------------------------------------------------------
		-- Reset your own configuration.
		---------------------------------------------------------
		
		local button = vgui.Create("atlaschat.chat.button")
		button:SetText("Reset Configuration")
		button:SetTall(20)
		button:Dock(TOP)
		button:DockMargin(0, 4, 0, 0)
		
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
		
		self.config.list:AddItem(button)
	
		---------------------------------------------------------
		-- Reset everyone's configuration. (ADMIN ONLY)
		---------------------------------------------------------
		
		if (LocalPlayer():IsSuperAdmin()) then
			self.config.resetAll = vgui.Create("atlaschat.chat.button")
			self.config.resetAll:SetText("Reset everyone's configuration")
			self.config.resetAll:SetTall(20)
			self.config.resetAll:Dock(TOP)
			self.config.resetAll:DockMargin(0, 4, 0, 0)
			
			self.config.resetAll.admin = true
			
			function self.config.resetAll:DoClick()
				net.Start("atlaschat.rqclrcfg")
				net.SendToServer()
			end
			
			self.config.list:AddItem(self.config.resetAll)
			
			---------------------------------------------------------
			--
			---------------------------------------------------------
			
			self.config.rankButton = vgui.Create("atlaschat.chat.button")
			self.config.rankButton:SetText("Configure rank icons")
			self.config.rankButton:SetTall(20)
			self.config.rankButton:Dock(TOP)
			self.config.rankButton:DockMargin(0, 4, 0, 0)
			
			self.config.rankButton.admin = true
			
			function self.config.rankButton:DoClick()
				atlaschat.theme.Call("ToggleRankMenu")
			end
			
			self.config.list:AddItem(self.config.rankButton)
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
				
				ParseConfig(sorted, self.config.list, true)
			end
		end
		
		self.config.list:GetCanvas():InvalidateLayout(true)
		
		timer.Simple(FrameTime() *2, function()
			self.config.list:InvalidateLayout(true)
			self.config.list:SizeToChildren(false, true)
			
			self.config:SetTall(math.min(464, self.config.list:GetTall() +40))
			self.config:Center()
		end)
	else
		self.config:SetVisible(!self.config:IsVisible())
		
		if (LocalPlayer():IsSuperAdmin()) then
			if (!ValidPanel(self.config.resetAll)) then
				self.config.resetAll = vgui.Create("atlaschat.chat.button")
				self.config.resetAll:SetText("Reset everyone's configuration")
				self.config.resetAll:SetTall(20)
				self.config.resetAll:Dock(TOP)
				self.config.resetAll:DockMargin(0, 4, 0, 0)
				
				self.config.resetAll.admin = true
				
				function self.config.resetAll:DoClick()
					net.Start("atlaschat.rqclrcfg")
					net.SendToServer()
				end
				
				self.config.list:AddItem(self.config.resetAll)
				
				self.config.rankButton = vgui.Create("atlaschat.chat.button")
				self.config.rankButton:SetText("Configure rank icons")
				self.config.rankButton:SetTall(20)
				self.config.rankButton:Dock(TOP)
				self.config.rankButton:DockMargin(0, 4, 0, 0)
				
				self.config.rankButton.admin = true
				
				function self.config.rankButton:DoClick()
					atlastchat.theme.Call("ToggleRankMenu")
				end
				
				self.config.list:AddItem(self.config.rankButton)
				
				local config = atlaschat.config.GetStored()
				local sorted = {}
				
				local function int(v) return type(tonumber(v)) == "number" end
				local function bool(v) return v == true or v == false or v == "true" or v == "false" end
		
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
					self.config.adminLabel:DockMargin(0, 8, 0, 8)
					self.config.adminLabel:SetFont("atlaschat.theme.userlist")
					self.config.adminLabel:SetText("Server Values")
					self.config.adminLabel:SizeToContents()
					
					self.config.adminLabel.admin = true
					
					self.config.list:AddItem(self.config.adminLabel)
					
					table.sort(sorted, function(a, b) return a.index < b.index end)
					
					ParseConfig(sorted, self.config.list, true)
				end
				
				self.config.list:GetCanvas():InvalidateLayout(true)
				
				timer.Simple(FrameTime() *2, function()
					self.config.list:InvalidateLayout(true)
					self.config.list:SizeToChildren(false, true)
					
					self.config:SetTall(math.min(474, self.config.list:GetTall() +40))
					self.config:Center()
				end)
			end
		else
			local children = self.config.list:GetCanvas():GetChildren()
			
			for k, child in pairs(children) do
				if (ValidPanel(child) and child.admin) then
					child:Remove()
				end
			end

			self.config.list:GetCanvas():InvalidateLayout(true)
			
			timer.Simple(FrameTime() *2, function()
				self.config.list:InvalidateLayout(true)
				self.config.list:SizeToChildren(false, true)
				
				self.config:SetTall(math.min(474, self.config.list:GetTall() +40))
				self.config:Center()
			end)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function theme:ToggleUserList()
	if (!ValidPanel(self.userListBase)) then
		self.userListBase = vgui.Create("Panel")
		self.userListBase:DockPadding(6, 32, 6, 6)

		local x, y = self.panel:GetPos()
		local width, height = self.panel:GetSize()
		
		self.userListBase:SetSize(250, 300)
		self.userListBase:SetPos(x +width +4, y +height -self.userListBase:GetTall())
		
		self.userListBase.dark = true
		
		function self.userListBase:PerformLayout()
			if (ValidPanel(self.button)) then
				local w = self:GetWide()
				
				self.button:SetPos(w -(75 +8), 10)
			end
		end
		
		function self.userListBase:Paint(w, h)
			atlaschat.theme.Call("PaintGenericBackground", self, w, h, "User List")
		end
		
		function self.userListBase:Rebuild(data, key)
			self.list:Clear()
	
			if (IsValid(data.creator)) then
				local nick = data.creator:Nick()
				
				local base = vgui.Create("Panel")
				base:Dock(TOP)
				base:SetTall(16)
				base:DockMargin(4, 2, 4, 0)

				local icon = base:Add("DImage")
				icon:SetImage("icon16/star.png")
				icon:SetSize(12, 12)
				icon:SetPos(0, 2)
				
				local creator = base:Add("DLabel")
				creator:SetPos(18, 1)
				creator:SetText(nick)
				creator:SetFont("atlaschat.theme.userlist.player")
				creator:SizeToContents()
				creator:SetSkin("atlaschat")
				
				self.list:AddItem(base)
			end
			
			for i = 1, #data do
				local player = data[i]
				
				if (IsValid(player) and player != data.creator) then
					local nick = player:Nick()
					
					local base = vgui.Create("Panel")
					base:Dock(TOP)
					base:SetTall(16)
					base:DockMargin(4, 2, 4, 0)
					
					if (data.creator == LocalPlayer()) then
						local icon = base:Add("DImageButton")
						icon:SetImage("icon16/cross.png")
						icon:SetSize(12, 12)
						icon:SetPos(0, 2)
						
						icon.player = player
						
						function icon:DoClick()
							net.Start("atlaschat.kickpm")
								net.WriteUInt(key, 8)
								net.WriteEntity(self.player)
							net.SendToServer()
						end
						
						local label = base:Add("DLabel")
						label:SetPos(18, 1)
						label:SetText(nick)
						label:SetFont("atlaschat.theme.userlist.player")
						label:SizeToContents()
						label:SetSkin("atlaschat")
					else
						local label = base:Add("DLabel")
						label:SetText(nick)
						label:SetFont("atlaschat.theme.userlist.player")
						label:Dock(TOP)
						label:SizeToContents()
						label:SetSkin("atlaschat")
					end
					
					self.list:AddItem(base)
				end
			end
		end
		
		self.userListBase.list = self.userListBase:Add("atlaschat.chat.list")
		self.userListBase.list:Dock(FILL)
		self.userListBase.list:SetScrollbarWidth(12)
		self.userListBase.list:GetCanvas():DockPadding(4, 4, 4, 4)
		
		local active = self.panel:GetActiveList()
	
		if (IsValid(active)) then
			self.userListBase:Rebuild(active.players, active:GetHost().key)
		end
		
		self.userListBase.button = self.userListBase:Add("atlaschat.chat.button")
		self.userListBase.button:SetSize(75, 16)
		self.userListBase.button:SetText("Invite Player")
		self.userListBase.button:SetFont("atlaschat.theme.invite")
		
		function self.userListBase.button.DoClick()
			local active = self.panel:GetActiveList()
			
			if (IsValid(active)) then
				local data = active.players
				local players = player.GetAll()
				
				local menu = DermaMenu()
					for k, player in pairs(players) do
						if (player != LocalPlayer()) then
							local nick = player:Nick()
							local steamID = player:SteamID()
							
							menu:AddOption(nick, function()
								net.Start("atlaschat.invpm")
									net.WriteUInt(active:GetHost().key, 8)
									net.WriteString(steamID)
								net.SendToServer()
							end)
						end
					end
				menu:Open()
			end
		end
	else
		self.userListBase:SetVisible(!self.userListBase:IsVisible())
		
		if (self.userListBase:IsVisible()) then
			local x, y = self.panel:GetPos()
			local width, height = self.panel:GetSize()
		
			self.userListBase:SetPos(x +width +4, y +height -self.userListBase:GetTall())
			
			local active = self.panel:GetActiveList()
		
			if (IsValid(active)) then
				self.userListBase:Rebuild(active.players, active:GetHost().key)
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function theme:ToggleRankMenu()
	if (!ValidPanel(self.rankMenu)) then
		local theme = self
		local icons = file.Find("materials/icon16/*.png", "MOD")
		
		self.rankMenu = vgui.Create("DFrame")
		self.rankMenu:SetSize(384, 304)
		self.rankMenu:Center()
		self.rankMenu:DockPadding(6, 32, 6, 6)
		self.rankMenu:SetTitle("")
		self.rankMenu:SetDeleteOnClose(false)
		self.rankMenu:MakePopup()
	
		self.rankMenu.dark = true

		function self.rankMenu:Paint(w, h)
			atlaschat.theme.Call("PaintGenericBackground", self, w, h, "Rank Configuration")
		end
		
		local top = self.rankMenu:Add("Panel")
		top:Dock(TOP)
		top:SetTall(20)
		
		function top:Paint(w, h)
			atlaschat.theme.Call("PaintGenericBackground", self, w, h)
			
			draw.SimpleText("Usergroup", "atlaschat.theme.list.name", 6, h /2, theme.color.generic_label, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText("Image", "atlaschat.theme.list.name", w /2, h /2, theme.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		function top:PerformLayout()
			local w = self:GetWide()
			
			if (ValidPanel(self.newButton)) then
				self.newButton:SetPos(w -self.newButton:GetWide(), 0)
			end
		end
		
		top.newButton = top:Add("atlaschat.chat.button")
		top.newButton:SetSize(90, 20)
		top.newButton:SetText("Add Usergroup")
		
		function top.newButton.DoClick()
			Derma_StringRequest("Add Usergroup", "Enter the name/unique of the usergroup", "", function(text) if (text != "") then net.Start("atlaschat.crtrnk") net.WriteString(text) net.SendToServer() end end, function(text) end, "Accept")
		end
		
		self.rankMenu.list = self.rankMenu:Add("atlaschat.chat.list")
		self.rankMenu.list:Dock(FILL)
		self.rankMenu.list:SetScrollbarWidth(12)
		self.rankMenu.list:GetCanvas():DockPadding(4, 0, 4, 4)
		
		function self.rankMenu:Rebuild()
			self.list:Clear()
			
			for unique, icon in pairs(atlaschat.ranks) do
				local panel = vgui.Create("Panel")
				panel:SetTall(20)
				panel:Dock(TOP)
				panel:DockMargin(0, 4, 0, 0)
				
				panel.unique = unique
				
				function panel:Paint(w, h)
					atlaschat.theme.Call("PaintGenericBackground", self, w, h)
					
					draw.SimpleText(self.unique, "atlaschat.theme.list.name", 4, h /2, theme.color.generic_label, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
				
				function panel:PerformLayout()
					local w = self:GetWide()
					
					if (ValidPanel(self.icon)) then
						self.icon:SetPos(w /2 -8, 2)
					end
					
					if (ValidPanel(self.removeButton)) then
						self.removeButton:SetPos(w -self.removeButton:GetWide(), 0)
					end
				end
				
				panel.icon = panel:Add("DImageButton")
				panel.icon:SetImage(icon or "icon16/user.png")
				panel.icon:SetSize(16, 16)
				panel.icon:SetToolTip("Click this to change the icon.")
				
				function panel.icon.DoClick()
					local x, y = self:LocalToScreen(panel.icon:GetPos())
					local width = 4
					
					local base = vgui.Create("DFrame")
					base:SetSize(256, 256)
					base:SetPos(x +20, y +20)
					base:DockPadding(6, 32, 6, 6)
					base:SetTitle("")
					base:SetDeleteOnClose(false)
					base:MakePopup()
					
					base.dark = true
					
					function base:Paint(w, h)
						atlaschat.theme.Call("PaintGenericBackground", self, w, h, "Select a new icon")
					end
					
					local iconList = base:Add("atlaschat.chat.list")
					iconList:Dock(FILL)
					iconList:SetScrollbarWidth(12)
					iconList:GetCanvas():DockPadding(4, 4, 4, 4)
		
					local iconBase = vgui.Create("Panel")
					iconBase:SetTall(16)
					iconBase:Dock(TOP)
					iconBase:DockMargin(0, 0, 0, 4)
					
					iconList:AddItem(iconBase)
					
					timer.Simple(0.05, function()
						for k, path in pairs(icons) do
							local image = iconBase:Add("DImage")
							image:SetImage("icon16/" .. path)
							image:SetSize(16, 16)
							image:Dock(LEFT)
							image:DockMargin(0, 0, 4, 0)
							image:SetMouseInputEnabled(true)
							
							image.path = "icon16/" .. path
							
							util.InstallHandHover(image)
							
							function image:OnMousePressed()
								net.Start("atlaschat.chnric")
									net.WriteString(panel.unique)
									net.WriteString(self.path)
								net.SendToServer()
								
								base:Remove()
							end
	
							width = width +20
							
							if (width +16 >= iconList:GetWide() -iconList.VBar.btnGrip:GetWide()) then
								iconBase = vgui.Create("Panel")
								iconBase:SetTall(16)
								iconBase:Dock(TOP)
								iconBase:DockMargin(0, 0, 0, 4)
								
								iconList:AddItem(iconBase)
								
								width = 4
							end
						end
					end)
				end
				
				panel.removeButton = panel:Add("atlaschat.chat.button")
				panel.removeButton:SetSize(65, 20)
				panel.removeButton:SetText("Delete")
			
				function panel.removeButton.DoClick()
					net.Start("atlaschat.rmvrnk")
						net.WriteString(panel.unique)
					net.SendToServer()
				end
		
				self.list:AddItem(panel)
			end
		end
		
		function self.rankMenu:UpdateIcon(unique, image)
			local children = self.list:GetCanvas():GetChildren()
			
			for k, child in pairs(children) do
				if (ValidPanel(child) and child.unique == unique) then
					child.icon:SetImage(image)
				end
			end
		end
		
		self.rankMenu:Rebuild()
	else
		self.rankMenu:SetVisible(!self.rankMenu:IsVisible())
	end
	
	self.config:SetVisible(false)
end

---------------------------------------------------------
-- When we close and open the chatbox.
---------------------------------------------------------

function theme:OnToggle(show)
	self.panel:SetVisible(show)
	
	local list = self.panel:GetActiveList()
	
	if (show) then
		local x, y = atlaschat.chat_x:GetInt(), atlaschat.chat_y:GetInt()
		local w, h = atlaschat.chat_w:GetInt(), atlaschat.chat_h:GetInt()
		
		if (atlaschat.chat_x:GetInt() == -1) then x = atlaschat.ScaleSize(10, true)	atlaschat.chat_x:SetInt(x) end
		if (atlaschat.chat_y:GetInt() == -1) then y  = atlaschat.ScaleSize(230)	 	atlaschat.chat_y:SetInt(y) end
		if (atlaschat.chat_w:GetInt() == 0) then w = atlaschat.ScaleSize(200, true)	atlaschat.chat_w:SetInt(w) end
		if (atlaschat.chat_h:GetInt() == 0) then h = atlaschat.ScaleSize(150) 		atlaschat.chat_h:SetInt(h) end
		
		self.panel:SetPos(x, y)
		self.panel:SetSize(w, h)

		list:SetParent(self.panel)
		list:Dock(FILL)
		list:SetMouseInputEnabled(true)
		list:SetKeyboardInputEnabled(true)
		list:ScrollToBottom()
		
		self.panel.listContainer:SetVisible(true)
		self.panel.listContainer:SetPos(x, y +h)
		self.panel.listContainer:SetSize(w, 18)
		
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
		self.panel.prefix:SetPrefix("PM:")
	else
		if (self.panel.team) then
			self.panel.prefix:SetPrefix("TEAM:")
		else
			self.panel.prefix:SetPrefix("SAY:")
		end
	end
	
	if (ValidPanel(self.userListBase) and self.userListBase:IsVisible()) then
		self.userListBase:SetVisible(show)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

local table = table
local pairs = pairs
local string = string
local unpack = unpack
local GetType = type
local expressions = atlaschat.expression.GetStored()

local function b(parent)
	local base = parent:Add("Panel")
	base:SetTall(atlaschat.fontHeight)
	base:Dock(TOP)
	base:DockMargin(0, 0, 0, 2)
	
	function base:PerformLayout()
		local height = self:GetTall()
		local children = self:GetChildren()
		
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				local x = child:GetPos()
				local childHeight = child:GetTall()
				
				child:SetPos(x, height /2 -childHeight /2)
			end
		end
	end
	
	return base
end

function theme:PlayerLabelPressed(player)
	local theme = self
	
	local menu = DermaMenu()
		menu:AddOption("View Community Profile", function()
			gui.OpenURL("http://steamcommunity.com/profiles/" .. player:SteamID64())
		end)
		
		menu:AddOption("Copy SteamID To Clipboard", function() local steamID = player:SteamID() SetClipboardText(steamID) end)
		
		if (LocalPlayer():IsSuperAdmin()) then
			menu:AddSpacer()
			
			menu:AddOption("Set Title", function()
				local title = player:GetNetworkedString("ac_title", "")
				
				local panel = vgui.Create("DFrame")
				panel:SetSize(600, 320)
				panel:Center()
				panel:DockPadding(10, 40, 10, 10)
				panel:SetTitle("")
				panel:SetDeleteOnClose(false)
				panel:MakePopup()

				panel.dark = true
				panel.steamID = player:SteamID()
				
				function panel:Paint(w, h)
					atlaschat.theme.Call("PaintGenericBackground", self, w, h, "Enter Player Title", w /2, 20, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					
					return true
				end
				
				panel.entry = panel:Add("DTextEntry")
				panel.entry:SetTall(20)
				panel.entry:SetAllowNonAsciiCharacters(true)
				panel.entry:Dock(TOP)
				panel.entry:DockMargin(0, 0, 0, 10)
				panel.entry:SetZPos(-5)
				panel.entry:SetText(title)

				function panel.entry:OnChange()
					local value = self:GetText()
					
					panel.preview:Clear()
					panel.preview:InvalidateLayout(true)
					
					panel.preview.value = value
					panel.preview.nextUpdate = CurTime() +0.2
				end
				
				function panel.entry:Paint(w, h)
					atlaschat.theme.Call("PaintTextEntry", w, h, self)
				end
				
				panel.preview = panel:Add("Panel")
				panel.preview:SetTall(210)
				panel.preview:Dock(TOP)
				panel.preview:DockPadding(10, 44, 10, 10)
				
				function panel.preview:Paint(w, h)
					atlaschat.theme.Call("PaintGenericBackground", self, w, h, "Title Preview ** !! KEEP IT SHORT !! **", w /2, 20, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				
				local accept = panel:Add("atlaschat.chat.button")
				accept:SetSize(75, 20)
				accept:SetText("Accept")
				accept:SetFont("atlaschat.theme.invite")
				
				function accept:DoClick()
					net.Start("atlaschat.stplttl")
						net.WriteString(panel.steamID)
						net.WriteString(panel.preview.value)
					net.SendToServer()
					
					panel:Remove()
				end
				
				local cancel = panel:Add("atlaschat.chat.button")
				cancel:SetSize(75, 20)
				cancel:SetText("Cancel")
				cancel:SetFont("atlaschat.theme.invite")
				
				function cancel:DoClick()
					panel:Remove()
				end
				
				function panel:PerformLayout()
					local w, h = self:GetSize()
					
					cancel:SetPos(w -(cancel:GetWide() +10), h -30)
					accept:SetPos(0, h -30)
					accept:MoveLeftOf(cancel, 12)
				end
				
				panel.entry:OnChange()
				
				function panel.preview:Think()
					if (self.nextUpdate and self.nextUpdate <= CurTime()) then

						local base = b(self)
						
						-- Add the base panel to the list so it'll get a size
						self:InvalidateLayout(true)
						base:InvalidateLayout(true)
						
						local x = 4
						local titleData = {"[" .. self.value .. "] "}

						theme:ParseExpressions(titleData, base, player)
					
						for i = 1, #titleData do
							local value, type = titleData[i], GetType(titleData[i])
							
							if (type == "string" or type == "number") then
								local label = atlaschat.GenericLabel()
								label:SetParent(base)
								label:SetPos(x, 0)
								label:SetText("")
								label:SetColor(color_white)
								label:SizeToContents()
								
								local exploded, start, ending, foundFirst = string.Explode(" ", value), 1, 1, false
						
								while ending <= #exploded do
									local text = table.concat(exploded, " ", start, ending)
									
									label:SetText(text)
									label:SizeToContents()
								
									-- Too much text, let's cut it off.
									if (x +label:GetWide() >= base:GetWide() -4) then
										local previous = ending -1
										
										-- This is when it's in the beginning of the text.
										if (previous < start) then
											base = b(self)
	
											-- Add the base panel to the list so it'll get a size
											self:InvalidateLayout(true)
											base:InvalidateLayout(true)
											
											x = 4
						
											label:SetParent(base)
											label:SetPos(x, 0)
											label:SetText(text .. " ")
											label:SizeToContents()
											
											x = x +label:GetWide()
											
											-- Create the next label.
											label = atlaschat.GenericLabel()
											label:SetParent(base)
											label:SetPos(x, 0)
											label:SetText("")
											label:SetColor(color_white)
											label:SizeToContents()
											
											start, ending, foundFirst = ending +1, start, true
										else
											label:SetText(table.concat(exploded, " ", start, previous))
											label:SizeToContents()
								
											x = 4
							
											base = b(self)
											
											-- Add the base panel to the list so it'll get a size
											self:InvalidateLayout(true)
											base:InvalidateLayout(true)
											
											-- Create the next label.
											label = atlaschat.GenericLabel()
											label:SetParent(base)
											label:SetPos(x, 0)
											label:SetText("")
											label:SetColor(color_white)
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
												
												x = x +label:GetWide()
											else
												label:Remove()
											end
										end
									end
								end
							end
							
							if (type == "Panel") then
								-- Lol hacky.
								if (base != value:GetParent()) then
									value:SetParent(base)
								end
								
								if (value:GetTall() > base:GetTall()) then
									base:SetTall(value:GetTall())
								end
								
								value:SetPos(x, 0)
								
								-- Wrap the label.
								if (value:GetClassName() == "Label") then
									local label, valueText, font = value, value:GetText(), value:GetFont()
									
									label:SetText("")
									label:SizeToContents()
									
									local exploded, start, ending, foundFirst, color = string.Explode(" ", valueText), 1, 1, false, value:GetTextColor()
							
									while ending <= #exploded do
										local text = table.concat(exploded, " ", start, ending)
										
										label:SetText(text)
										label:SizeToContents()
									
										-- Too much text, let's cut it off.
										if (x +label:GetWide() >= base:GetWide() -4) then
											local previous = ending -1
											
											-- This is when it's in the beginning of the text.
											if (previous < start) then
												base = b(self)
												
												-- Add the base panel to the list so it'll get a size
												self:InvalidateLayout(true)
												base:InvalidateLayout(true)
												
												x = 4
							
												label:SetParent(base)
												label:SetPos(x, 0)
												label:SetText(text .. " ")
												label:SizeToContents()
												
												x = x +label:GetWide()
												
												local attributes = label:GetTable()
												
												-- Create the next label.
												label = atlaschat.GenericLabel()
												
												for k, v in pairs(attributes) do
													label[k] = v
												end
												
												label:SetParent(base)
												label:SetPos(x, 0)
												label:SetText("")
												label:SetFont(font)
												label:SetColor(color)
												label:SizeToContents()
												
												if (label:GetTall() > base:GetTall()) then
													base:SetTall(label:GetTall())
												end
												
												start, ending, foundFirst = ending +1, start, true
											else
												label:SetText(table.concat(exploded, " ", start, previous))
												label:SizeToContents()
									
												x = 4
							
												base = b(self)
											
												-- Add the base panel to the list so it'll get a size
												self:InvalidateLayout(true)
												base:InvalidateLayout(true)
												
												local attributes = label:GetTable()
												
												-- Create the next label.
												label = atlaschat.GenericLabel()
												
												for k, v in pairs(attributes) do
													label[k] = v
												end
												
												label:SetParent(base)
												label:SetPos(x, 0)
												label:SetText("")
												label:SetFont(font)
												label:SetColor(color)
												label:SizeToContents()
												
												if (label:GetTall() > base:GetTall()) then
													base:SetTall(label:GetTall())
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
													
													x = x +label:GetWide()
												else
													label:Remove()
												end
											end
										end
									end
								else
									x = x +value:GetWide() +1
								end
							end
						end
						
						self.nextUpdate = nil
					end
				end
			end)
		end
		
		menu:AddSpacer()
		menu:AddOption("Cancel", function() end)
	menu:Open()
end

---------------------------------------------------------
-- This is where we parse all the expressions.
---------------------------------------------------------

function theme:ParseExpressions(data, panel, player)
	local loop = true

	while loop do
		for i = 1, #data do
			local value, type = data[i], GetType(data[i])
	
			if (type == "string" or type == "number") then
			
				-- Break the loop if we don't find anything.
				loop = false
				
				local found, firstType, firstLocation = nil, nil, -1
				
				for i = 1, #expressions do
					local object = expressions[i]
					local expression = object:GetExpression()
					local result = {string.find(value, expression, 0, object.noPattern)}
					
					-- Did we find anything?
					if (result and #result > 1) then
						
						-- If we found something then we want to continue the loop.
						loop = true
						
						-- Set the first location where the expression is in the text.
						if (firstLocation == -1) then
							firstLocation = result[1]
						else
							
							-- If we found an expression that is before the first one we found, use that one.
							firstLocation = math.min(firstLocation, result[1])
						end
						
						-- We have located the first expression!
						if (result[1] == firstLocation) then
							found, firstType = result, object
						end
					end
				end
				
				-- Execute the function of the expression.
				if (firstType) then
					firstType.player = player
					
					local panelObject = firstType:Execute(panel, unpack(found, 3))
					
					if (panelObject != nil) then
						local startPos, endPos = found[1], found[2]
						
						data[i] = string.sub(value, 1, startPos -1)
						
						table.insert(data, i +1, panelObject)
						
						local text = string.sub(value, endPos +1)
						
						if (text != "") then
							table.insert(data, i +2, text)	
						end
					end
				end
			end
		end
	end
end

---------------------------------------------------------
-- This is where we add all the panels.
---------------------------------------------------------

local parseX, parseColor, titleColor, parseBase = nil, nil, nil, nil

function theme:ParseData(data, list, isTitle)
	local realColor = isTitle and titleColor or parseColor
	
	for i = 1, #data do
		local value, type = data[i], GetType(data[i])

		if (type == "Player") then
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
			
			local color, text = ((!DarkRP and i != 4) or (DarkRP and i == 1)) and team.GetColor(value:Team()) or realColor, value:Nick()
			
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