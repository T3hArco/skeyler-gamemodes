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

atlaschat = atlaschat or {}
atlaschat.ranks = {}

---------------------------------------------------------
--
---------------------------------------------------------

function atlaschat.FixInvalidFont()
	local ok = pcall(draw.SimpleText, "shit", atlaschat.font:GetString(), 0, 0, color_transparent, 1, 1)
	
	if (!ok) then
		atlaschat.font:SetString("atlaschat.theme.text")
		
		Msg("Reverting atlaschat font because it is invalid!\n")
		
		return true
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

include("sh_utilities.lua")
include("sh_config.lua")
include("cl_expression.lua")
include("cl_theme.lua")
include("cl_panel.lua")

---------------------------------------------------------
--
---------------------------------------------------------

function atlaschat.ScaleSize(amount, x)
	amount = amount *(x and ScrW() or ScrH()) /(x and 640 or 480)

	return amount
end

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

---------------------------------------------------------
-- Draw "Copied text!" notifications.
---------------------------------------------------------

local copiedNotify = {}

hook.Add("DrawOverlay", "atlaschat.DrawCopiedNotify", function()
	for i = 1, #copiedNotify do
		local data = copiedNotify[i]
		
		if (data) then
			draw.SimpleText("Copied text!", "atlaschat.theme.text.shadow", data.x, data.y, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText("Copied text!", "atlaschat.theme.text", data.x +1, data.y +1, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText("Copied text!", "atlaschat.theme.text", data.x, data.y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			
			data.x = data.origin +math.sin(CurTime() *2) *10
			data.y = data.y -0.2
			
			if (data.time <= CurTime()) then
				table.remove(copiedNotify, i)
			end
		end
	end
end)

---------------------------------------------------------
-- Hides the default chatbox.
---------------------------------------------------------

hook.Add("HUDShouldDraw", "atlaschat.HUDShouldDraw", function(id)
	local panel = atlaschat.theme.GetValue("panel")
	
	if (ValidPanel(panel) and id == "CHudChat") then
		return false
	end
end)

---------------------------------------------------------
-- Opens the atlas chatbox.
---------------------------------------------------------

hook.Add("PlayerBindPress", "atlaschat.PlayerBindPress", function(player, bind, pressed)
	if (bind == "messagemode" and pressed) then
		local panel = atlaschat.theme.GetValue("panel")
		
		if (ValidPanel(panel)) then
		
			-- TTT support.
			if (GAMEMODE.round_state) then
				if (player:IsSpec() and GAMEMODE.round_state == ROUND_ACTIVE and DetectiveMode()) then
					LANG.Msg("spec_teamchat_hint")
				else
					panel.team = false
					
					atlaschat.theme.Call("OnToggle", true)
					
					hook.Run("StartChat", false)
				end
			else
				panel.team = false
				
				atlaschat.theme.Call("OnToggle", true)
				
				hook.Run("StartChat", false)
			end
			
			return true
		end
	end
	
	if (bind == "messagemode2" and pressed) then
		local panel = atlaschat.theme.GetValue("panel")
		
		if (ValidPanel(panel)) then
			panel.team = true
			
			atlaschat.theme.Call("OnToggle", true)
			
			hook.Run("StartChat", true)
			
			return true
		end
	end
end)

---------------------------------------------------------
-- Player connect/disconnect message.
---------------------------------------------------------

gameevent.Listen("player_disconnect")

hook.Add("player_disconnect", "atlaschat.DisconnectMessage", function(data)
	local filtered = atlaschat.filterJoinDisconnect:GetBool()

	if (!filtered) then
		chat.AddText(color_white, ":offline: Player ", color_red, data.name, color_grey, " (" .. data.networkid	.. ") ", color_white, "has left the server: " .. data.reason)
	end
end)

net.Receive("atlaschat.plcnt", function(bits)
	local name = net.ReadString()
	local steamID = net.ReadString()
	local filtered = atlaschat.filterJoinDisconnect:GetBool()
	
	if (!filtered) then
		chat.AddText(color_white, ":online: Player ", color_limegreen, name, color_grey, " (" .. steamID .. ") ", color_white, "has joined the game.")
	end
end)

---------------------------------------------------------
-- Other chat messages.
---------------------------------------------------------

hook.Add("ChatText", "atlaschat.ChatText", function(index, name, text, filter)
	if (tonumber(index) == 0) then
		if (filter == "joinleave") then -- Does this even work anymore?
			return ""
		elseif (filter == "none") then
			chat.AddText(color_white, text)
		elseif (filter == "chat") then
			if (name and name != "") then
				chat.AddText(color_grey, name, color_white, text)
			else
				chat.AddText(color_white, text)
			end
		end
	end
end)

---------------------------------------------------------
-- Override chat.GetChatBoxPos to return our chatbox position.
---------------------------------------------------------

function chat.GetChatBoxPos()
	local panel = atlaschat.theme.GetValue("panel")
	
	if (ValidPanel(panel)) then
		local x, y = panel:GetPos()
	
		return x, y
	else
		return 0, 0
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

if (!atlaschat.chatAddText) then atlaschat.chatAddText = chat.AddText end

function chat.AddText(...)
	local panel = atlaschat.theme.GetValue("panel")
	
	if (ValidPanel(panel)) then
		atlaschat.theme.Call("ParseText", nil, ...)
	end
	
	atlaschat.chatAddText(...)
end

---------------------------------------------------------
--
---------------------------------------------------------

atlaschat.fontCache = atlaschat.fontCache or {}

function atlaschat.BuildFontCache(text, font)
	font = font or atlaschat.font:GetString()
	
	local surface, string = surface, string
	local lowered = string.lower(font)
	local len = string.utf8len(text)
	
	if (!atlaschat.fontCache[lowered]) then atlaschat.fontCache[lowered] = {} end

	surface.SetFont(font)
	
	for i = 1, len do
		local character = string.utf8sub(text, i, i)
		
		if (!atlaschat.fontCache[lowered][character]) then
			local width = surface.GetTextSize(character)
			
			atlaschat.fontCache[lowered][character] = width
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

local copiedText = false
local currentPanel
local previousPanel
local lastMouseDown

function atlaschat.NewBasePanel()
	local spacing = atlaschat.theme.GetValue("messageSpacing") or 2
	
	local panel = vgui.Create("Panel")
	panel:SetTall(atlaschat.fontHeight)
	panel:Dock(TOP)
	panel:DockMargin(0, 0, 0, spacing)
	
	panel.fade = CurTime() +atlaschat.fadetime:GetInt()
	panel.selection = {}
	
	function panel:GetChildrenWidth()
		local children = self:GetChildren()
		local childrenWidth = 0
		
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				childrenWidth = childrenWidth +child:GetWide()
			end
		end
		
		return childrenWidth +8
	end
	
	function panel:Think()
		local x, y = self:LocalCursorPos()

		if (x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()) then
			local children = self:GetChildren()
			local childrenWidth = self:GetChildrenWidth()
			
			if (x >= 0 and x <= childrenWidth +8) then
				self:SetCursor("beam")
				
				for k, child in pairs(children) do
					if (ValidPanel(child) and !child.cursor) then
						child:SetCursor("beam")
					end
				end
				
				if (input.IsMouseDown(MOUSE_LEFT)) then
					currentPanel = self
					
					if (!ValidPanel(previousPanel)) then
						previousPanel = self
					else
						local list = atlaschat.theme.GetValue("panel"):GetActiveList()
						local children = list:GetCanvas():GetChildren()
						local _, y = previousPanel:GetPos()
						local _, y2 = self:GetPos()
						
						if (y2 == y and previousPanel.selection.backup) then
							previousPanel.selection.width = previousPanel.selection.backup
							
							previousPanel.selection.backup = nil
						end
						
						-- previousPanel is lower down.
						if (y > y2) then
							self.selection.x = childrenWidth
							previousPanel.selection.backup = previousPanel.selection.width
							previousPanel.selection.width = 4
							
							for k, child in pairs(children) do
								local _, y3 = child:GetPos()

								if (y3 < y and y3 > y2) then
									child.selection.x = 4
									child.selection.width = child:GetChildrenWidth()
								end
								
								-- Reset everything that is below or above.
								if (y3 > y or y3 < y2) then
									child.selection.x = nil
									child.selection.width = nil
								end
							end 
						else
							if (y2 > y) then
								self.selection.x = 4
								previousPanel.selection.width = previousPanel:GetChildrenWidth()
							end
							
							for k, child in pairs(children) do
								local _, y3 = child:GetPos()
		
								if (y3 > y and y3 < y2) then
									child.selection.x = 4
									child.selection.width = child:GetChildrenWidth()
								end
								
								-- Reset everything that is above or below.
								if (y3 < y or y3 > y2) then
									child.selection.x = nil
									child.selection.width = nil 
								end
							end
						end 
					end
					
					if (!self.selection.x) then
						for k, child in pairs(children) do
							if (ValidPanel(child)) then
								local x2 = child:GetPos()
								
								if (x >= x2 and x <= x2 +child:GetWide()) then
									if (child:GetClassName() == "Label") then
										local text, start, font, totalWidth = child:GetText(), 1, string.lower(child:GetFont()), 0
										local len = string.utf8len(text)
										
										while start <= len do
											local character = string.utf8sub(text, start, start)
											local width = atlaschat.fontCache[font][character]
											
											if (x2 +totalWidth +width >= x) then
												self.selection.x = x2 +totalWidth

												break
											end
											
											totalWidth, start = totalWidth +width, start +1
										end
									else
										self.selection.x = x2
									end
								end
							end
						end
					else
						for k, child in pairs(children) do
							if (ValidPanel(child)) then
								local x2 = child:GetPos()
								local wide = child:GetWide()
								
								if (x >= x2 and x <= x2 +wide) then
									if (child:GetClassName() == "Label") then
										local text, start, font, totalWidth = child:GetText(), 1, string.lower(child:GetFont()), 0
										local len = string.utf8len(text)
	
										while start <= len do
											local character = string.utf8sub(text, start, start)
											local width = atlaschat.fontCache[font][character]
											
											if (x >= x2 +(totalWidth -width /2)) then
												self.selection.width = x2 +totalWidth
											end
											
											start = start +1
	
											if (start > len and x2 +totalWidth +width >= x2 +wide and x >= x2 +wide) then
												self.selection.width = x2 +wide
											end
											
											totalWidth = totalWidth +width
										end
									else
										if (x >= x2 +wide) then
											self.selection.width = x2 +wide
										end
									end
								end
							end
						end
					end
				end
			else
				self:SetCursor("arrow")
				
				for k, child in pairs(children) do
					if (ValidPanel(child) and !child.cursor) then
						child:SetCursor("arrow")
					end
				end
			end
		end
		
		local panel = atlaschat.theme.GetValue("panel")
		
		if (ValidPanel(panel) and !panel:IsVisible()) then
			if (self.fade and self.fade <= CurTime()) then
				self:AlphaTo(0, 1.5, 0)
				
				self.fade = nil
			end
		end
	end
	
	function panel:PaintOver(w, h)
		if (self.selection and self.selection.width and self.selection.x) then
			local color = atlaschat.theme.GetValue("color").selection
			
			if (self.selection.width < self.selection.x) then
				draw.SimpleRect(self.selection.width, 0, self.selection.x -self.selection.width, h, color)
			else
				draw.SimpleRect(self.selection.x, 0, self.selection.width -self.selection.x, h, color)
			end
		end
	end
	
	function panel:PerformLayout()
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
	
	if (atlaschat.messageFadeIn:GetBool()) then
		panel:SetAlpha(0)
		panel:AlphaTo(255, 0.12, 0)
	end
	
	return panel
end

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("Think", "atlaschat.TextSelection", function()
	if (input.IsMouseDown(MOUSE_LEFT)) then
		if (!lastMouseDown) then
			lastMouseDown = CurTime()
			
			copiedText = false
		end
	else
		if (lastMouseDown and CurTime() -lastMouseDown <= 0.16) then
			local list = atlaschat.theme.GetValue("panel")
			
			if (ValidPanel(list)) then
				list = list:GetActiveList()
				local children = list:GetCanvas():GetChildren()
				
				currentPanel = nil
				previousPanel = nil
				
				for k, child in pairs(children) do
					if (ValidPanel(child)) then
						child.selection = {}
					end
				end
			end
		end
		
		lastMouseDown = nil
	end

	if (input.IsKeyDown(KEY_LCONTROL) and input.IsKeyDown(KEY_C) and ValidPanel(previousPanel) and ValidPanel(currentPanel)) then
		if (!copiedText) then
			local table, string = table, string
			local list = atlaschat.theme.GetValue("panel"):GetActiveList()
			local children = list:GetCanvas():GetChildren()
			
			-- The order of the base panels should always be correct
			-- so I don't think we need this.
			--[[
			
			local sorted = {}
			local _, minY = currentPanel:GetPos()
			local _, maxY = previousPanel:GetPos()
			
			for k, child in pairs(children) do
				if (ValidPanel(child)) then
					local _, childY = child:GetPos()
					
					-- Going down.
					if (minY > maxY) then
						if (childY >= maxY and childY <= minY) then
							table.insert(sorted, {child = child, y = childY})
						end
					else
						if (childY >= minY and childY <= maxY) then
							table.insert(sorted, {child = child, y = childY})
						end
					end
				end
			end
			
			table.sort(sorted, function(a, b) return a.y < b.y end)
			
			]]
			
			local clipboardText = ""

			for i = 1, #children do
				local base = children[i] --.child
				local children = base:GetChildren()
				local x, width = base.selection.x, base.selection.width

				if (x and width) then
					local sortedChildren = {}
					
					for k, child in pairs(children) do
						if (ValidPanel(child)) then
							table.insert(sortedChildren, child)
						end
					end
					
					table.sort(sortedChildren, function(a, b) return a.x < b.x end)
					
					-- Going backwards or upwards.
					if (x > width) then
						x = base.selection.width
						width = base.selection.x
					end
					
					for i = 1, #sortedChildren do
						local child = sortedChildren[i]
						local x2, wide = child:GetPos(), child:GetWide()

						if ((x >= x2 or x2 >= x) and (width <= x2 +wide or width >= x2 +wide)) then
							if (child:GetClassName() == "Label") then
								local text, start, font, totalWidth, final = child:GetText(), 1, string.lower(child:GetFont()), 0, ""
								local len = string.utf8len(text)
								
								while start <= len do
									local character = string.utf8sub(text, start, start)
									local characterWidth = atlaschat.fontCache[font][character]
									
									if (x2 +totalWidth >= x and x2 +totalWidth +characterWidth <= width) then
										final = final .. character
									end
									
									totalWidth, start = totalWidth +characterWidth, start +1
								end
								
								clipboardText = clipboardText .. final
							else
								if (x2 >= x and width >= x2 +wide) then
									if (child.OnCopiedText) then
										local text = child:OnCopiedText()
										
										clipboardText = clipboardText .. text
									end
								end
							end
						end
					end
				end
			end
			
			-- TextEntry hack thanks to Python1320
			local clipboard = vgui.Create("DTextEntry")
			clipboard:SetAllowNonAsciiCharacters(true)
			clipboard:SetText(clipboardText)
			clipboard:SelectAllText()
			clipboard:CutSelected()
			clipboard:Remove()
			
			local x, y = gui.MousePos()
			local time = CurTime() +4
			
			table.insert(copiedNotify, {origin = x, x = x, y = y, time = time})
			
			copiedText = true
		end
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------
 
local color_shadow = Color(0, 0, 0, 220)

local function shadow(text, font)
	surface.SetFont(font .. ".shadow")
	surface.SetTextPos(0, 0)
	surface.SetTextColor(color_shadow)
	surface.DrawText(text)
end

function atlaschat.GenericLabel()
	local font = atlaschat.font:GetString()

	local label = vgui.Create("DLabel")
	label:SetFont(font)
	label:SetMouseInputEnabled(false)
	
	function label:Paint(w, h)
		local shadow, text, font, extraShadow, pcall = shadow, self:GetText(), self:GetFont(), atlaschat.extraShadow:GetBool(), pcall
		
		if (extraShadow) then
			draw.SimpleText(text, font, 1, 1, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		end
		
		surface.DisableClipping(true)
		
			-- The font used might not have a shadow font to it and we don't want a bunch of lua errors.
			pcall(shadow, text, font)
		surface.DisableClipping(false)
	end

	return label
end
 
---------------------------------------------------------
-- Creates a label and a DCheckBox.
---------------------------------------------------------

function atlaschat.LabelAndCheckbox(parent, name)
	local base = parent:Add("Panel")
	base:SetTall(15)
	base:Dock(TOP)
	base:DockMargin(0, 0, 0, 10)
	
	local checkbox = base:Add("DCheckBox")
	checkbox:Dock(LEFT)
	
	local label = base:Add("DLabel")
	label:SetText(name)
	label:SizeToContents()
	label:Dock(LEFT)
	label:DockMargin(6, 0, 8, 0)
	label:SetSkin("atlaschat")
	
	return checkbox
end

---------------------------------------------------------
-- Creates a label and a Slider.
---------------------------------------------------------

function atlaschat.LabelAndNumSlider(parent, name)
	local base = parent:Add("Panel")
	base:SetTall(20)
	base:Dock(TOP)
	base:DockMargin(0, 0, 0, 10)
	
	local label = base:Add("DLabel")
	label:SetText(name)
	label:SizeToContents() 
	label:Dock(LEFT)
	label:SetSkin("atlaschat")
	
	local slider = base:Add("Slider")
	slider:Dock(FILL)
	slider:SetDecimals(0)
	
	return slider
end
  
---------------------------------------------------------
-- Creates a label and a DComboBox.
---------------------------------------------------------
 
function atlaschat.LabelAndOption(parent, name)
	local base = vgui.Create("Panel")
	base:SetParent(parent)
	base:SetTall(16)
	base:Dock(TOP)
	base:DockMargin(0, 0, 0, 10)
	
	local label = base:Add("DLabel")
	label:SetText(name)
	label:SizeToContents()
	label:Dock(LEFT)
	label:DockMargin(0, 0, 8, 0)
	label:SetSkin("atlaschat")
	
	local comboBox = base:Add("DComboBox")
	comboBox:Dock(FILL)
	
	return comboBox
end

---------------------------------------------------------
-- Creating a private chat.
---------------------------------------------------------

net.Receive("atlaschat.nwpm", function(bits)
	local key = net.ReadUInt(8)
	local panel = atlaschat.theme.GetValue("panel").listContainer
	
	panel:AddList(key, nil, LocalPlayer():Nick())
end)
 
---------------------------------------------------------
-- Receiving a text message in a private chat.
---------------------------------------------------------
 
net.Receive("atlaschat.rxpm", function(bits)
	local key = net.ReadUInt(8)
	local text = net.ReadString()
	local player = net.ReadEntity()
	local panel = atlaschat.theme.GetValue("panel").listContainer
	
	-- Add it to the "GLOBAL" chat.
	if (player != LocalPlayer()) then
		atlaschat.theme.Call("ParseText", nil, color_red, "(PM) ", player, color_white, ": ", text)
	end
	
	-- Add it to the private chat.
	atlaschat.theme.Call("ParseText", panel:GetListByKey(key), player, color_white, ": ", text)
end)

---------------------------------------------------------
-- Joining a private chat.
---------------------------------------------------------

net.Receive("atlaschat.gtplpm", function(bits)
	local key = net.ReadUInt(8)
	local numPlayers = net.ReadUInt(8)
	local panel = atlaschat.theme.GetValue("panel").listContainer
	local list = panel:GetListByKey(key)
	
	if (!ValidPanel(list)) then
		local thing = panel:AddList(key, nil, LocalPlayer():Nick())
		
		list = thing:GetList()
	end
	
	for i = 1, numPlayers do
		local player = net.ReadEntity()
		
		if (IsValid(player)) then
			list:AddPlayer(player)
		end
	end
	
	local creator = net.ReadEntity()
	
	if (IsValid(creator)) then
		list:AddPlayer(nil, creator)
	end
end)

---------------------------------------------------------
-- Kicking a player a private chat.
---------------------------------------------------------

net.Receive("atlaschat.nkickpm", function(bits)
	local key = net.ReadUInt(8)
	local target = net.ReadEntity()
	local noLocal = net.ReadBit() == 1
	local panel = atlaschat.theme.GetValue("panel").listContainer:GetListByKey(key)
	
	if (ValidPanel(panel)) then
		panel:RemovePlayer(target, noLocal)
	end
end)

---------------------------------------------------------
-- Accepting an invite to a private chat.
---------------------------------------------------------

net.Receive("atlaschat.sinvpm", function(bits)
	local key = net.ReadUInt(8)
	local player = net.ReadEntity()
	
	local accept = atlaschat.GenericLabel()
	accept:SetText("-> ACCEPT <-")
	accept:SetColor(color_limegreen)
	accept:SetMouseInputEnabled(true)
	
	accept.cursor = true
	
	function accept:OnCursorEntered()
		self:SetCursor("hand")
	end
	
	function accept:OnCursorExited()
		self:SetCursor("arrow")
	end
	
	function accept:OnMousePressed()
		net.Start("atlaschat.jnpm")
			net.WriteUInt(key, 8)
		net.SendToServer()
		
		self:SetText("ACCEPTED")
		self:SetColor(color_red)
		self:SetMouseInputEnabled(false)
	end
	
	chat.AddText(color_limegreen, player:Nick(), color_white, " has invited you to a private chat. Click this to ", accept)
end)

---------------------------------------------------------
-- Atlas chat messages.
---------------------------------------------------------

net.Receive("atlaschat.msg", function(bits)
	local text = net.ReadString()
	
	chat.AddText(color_red, "[atlashchat] ", color_white, text)
end)

function atlaschat.Notify(text)
	chat.AddText(color_red, "[atlashchat] ", color_white, text)
end

---------------------------------------------------------
-- Clears your configuration.
---------------------------------------------------------

net.Receive("atlaschat.clrcfg", function(bits)
	file.Delete("atlaschat_config.cfg", "DATA")
	
	atlaschat.config.ResetValues()
	
	local config = atlaschat.theme.GetValue("config")
	
	if (ValidPanel(config)) then
		config:Remove()
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

net.Receive("atlaschat.crtrnkgt", function(bits)
	local userGroup = net.ReadString()
	local icon = net.ReadString()
	local special = net.ReadUInt(8)
	
	if (special == 1) then
		atlaschat.ranks[userGroup] = nil
	else
		atlaschat.ranks[userGroup] = icon
	end
	
	if (LocalPlayer():IsSuperAdmin()) then
		local rankMenu = atlaschat.theme.GetValue("rankMenu")
		
		if (ValidPanel(rankMenu) and rankMenu:IsVisible()) then
			if (special == 2) then
				rankMenu:UpdateIcon(userGroup, icon)
			else
				rankMenu:Rebuild()
			end
		end
	end
end)

---------------------------------------------------------
-- The chat message.
---------------------------------------------------------

net.Receive("atlaschat.chatText", function(bits)
	local text = net.ReadString()
	local player = net.ReadEntity()
	local team = util.tobool(net.ReadBit())
	local dead = IsValid(player) and !player:Alive() or false

	hook.Run("OnPlayerChat", player, text, team, dead)
end)