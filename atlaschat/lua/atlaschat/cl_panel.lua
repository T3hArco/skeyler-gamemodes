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

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self.Dragging = {0, 0}
	
	self.m_iMinWidth = 300
	self.m_iMinHeight = 300
	
	self.bottom = self:Add("Panel")
	self.bottom:SetTall(20)
	self.bottom:Dock(BOTTOM)
	self.bottom:DockMargin(0, 8, 0, 0)
	
	self.iconHolder = self.bottom:Add("Panel")
	self.iconHolder:Dock(RIGHT)
	self.iconHolder:DockMargin(2, 0, 0, 0)
	
	function self.iconHolder:PerformLayout()
		local x, children = 4, self:GetChildren()
		
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				child:SetPos(x, self:GetTall() /2 -child:GetTall() /2)
				
				x = x +child:GetWide() +4
			end
		end
	end
	
	function self.iconHolder:Paint(w, h)
		atlaschat.theme.Call("PaintIconHolder", self, w, h)
		
		return true
	end
	
	function self.iconHolder:Resize()
		local width, children = 0, self:GetChildren()
	
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				width = width +child:GetWide() +8
			end
		end

		self:SetWide(width)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:AddIcon(image, callback, tooltip)
	local icon = self.iconHolder:Add("DImageButton")
	icon:SetSize(16, 16)
	icon:SetImage(image)
	icon:SetToolTip(tooltip)
	
	icon.callback = callback
	
	function icon:DoClick()
		self.callback()
	end
	
	self.iconHolder:Resize()
	
	return icon
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:RemoveIcon(icon)
	icon:Remove()
	
	timer.Simple(FrameTime() *2, function() self.iconHolder:InvalidateLayout(true) self.iconHolder:Resize() end)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:GetActiveList()
	return self.activeList
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:ChangeList(container, list)
	if (ValidPanel(self.activeList)) then
		self.activeList:SetVisible(false)
	end
	
	self.activeList = list
	self.activeList:SetVisible(true)
	
	self.entry.key = container.key
	
	if (container.key) then
		if (!ValidPanel(self.userList)) then
			self.userList = self:AddIcon("icon16/group.png", function() atlaschat.theme.Call("ToggleUserList") end, "Chat Userlist")
		end
		
		local userListBase = atlaschat.theme.GetValue("userListBase")
		
		if (IsValid(userListBase)) then
			userListBase:Rebuild(list.players, container.key)
		end
	else
		if (ValidPanel(self.userList)) then
			self:RemoveIcon(self.userList)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:OnMousePressed()
	if (gui.MouseX() > (self.x +self:GetWide() -20) and gui.MouseY() > (self.y +self:GetTall() -20)) then			
		self.Sizing = {gui.MouseX() -self:GetWide(), gui.MouseY() -self:GetTall()}
		self:MouseCapture(true)
		
		return
	end
		
	if (gui.MouseY() < self.y +20) then
		self.Dragging[1] = gui.MouseX() -self.x
		self.Dragging[2] = gui.MouseY() -self.y
		
		self:MouseCapture(true)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:OnMouseReleased()
	self.Dragging = {0, 0}
	self.Sizing = nil
	
	self:MouseCapture(false)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Think()
	local mousex, mousey = gui.MousePos()
	
	if (self.Dragging[1] != 0) then
		local x = mousex -self.Dragging[1]
		local y = mousey -self.Dragging[2]
		
		x = math.Clamp(x, 0, ScrW() -self:GetWide())
		y = math.Clamp(y, 0, ScrH() -self:GetTall())
		
		self:SetPos(x, y)
		self.listContainer:SetPos(x, y +self:GetTall())
		
		local userListBase = atlaschat.theme.GetValue("userListBase")
		
		if (ValidPanel(userListBase) and userListBase:IsVisible()) then
			local width, height = self:GetSize()

			userListBase:SetPos(x +width +4, y +height -userListBase:GetTall())
		end
		
		atlaschat.chat_x:SetInt(x)
		atlaschat.chat_y:SetInt(y)
	end
	
	if (self.Sizing) then
		local x = mousex - self.Sizing[1]
		local y = mousey - self.Sizing[2]
		local px, py = self:GetPos()
		
		if (x < self.m_iMinWidth) then x = self.m_iMinWidth elseif (x > ScrW() -px) then x = ScrW() -px end
		if (y < self.m_iMinHeight) then y = self.m_iMinHeight elseif (y > ScrH() -py) then y = ScrH() -py end
		
		self:SetSize(x, y)
		self:SetCursor("sizenwse")
		
		atlaschat.chat_w:SetInt(x)
		atlaschat.chat_h:SetInt(y)
		
		local x, _y = self:GetPos()
		
		self.listContainer:SetPos(x, _y +y)
		self.listContainer:SetWide(self:GetWide())
		
		local userListBase = atlaschat.theme.GetValue("userListBase")
		
		if (ValidPanel(userListBase) and userListBase:IsVisible()) then
			local width, height = self:GetSize()

			userListBase:SetPos(x +width +4, _y +height -userListBase:GetTall())
		end
		
		return
	end
	
	if (self.Hovered and mousex > (self.x +self:GetWide() -20) and mousey > (self.y +self:GetTall() -20)) then	
		self:SetCursor("sizenwse")
		
		return
	end
	
	if (self.Hovered and gui.MouseY() < self.y +20) then
		self:SetCursor("sizeall")
		
		return
	end
	
	self:SetCursor("arrow")
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	atlaschat.theme.Call("PaintPanel", w, h)
end

vgui.Register("atlaschat.chat", panel, "EditablePanel")

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

function panel:Paint(w, h)
	atlaschat.theme.Call("PaintButton", self, w, h)
	
	return true
end

vgui.Register("atlaschat.chat.button", panel, "DButton")

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

AccessorFunc(panel, "m_bScroll", 	"ShouldScroll", FORCE_BOOL)
AccessorFunc(panel, "m_bBottomUp", 	"BottomUp", 	FORCE_BOOL)

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self.history = {}
	
	self:SetShouldScroll(true)
	
	function self.VBar:Paint(w, h)
		atlaschat.theme.Call("PaintScrollbar", self, w, h)
	end
	
	function self.VBar.btnGrip:Paint(w, h)
		atlaschat.theme.Call("PaintScrollbarGrip", self, w, h)
	end
	
	function self.VBar.btnUp:Paint(w, h)
		atlaschat.theme.Call("PaintScrollbarUpButton", self, w, h)
	end
	
	function self.VBar.btnDown:Paint(w, h)
		atlaschat.theme.Call("PaintScrollbarDownButton", self, w, h)
	end
	
	local parent = self
	
	function self.VBar:SetScroll(scroll)
		if ( !self.Enabled ) then self.Scroll = 0 return end
		
		if (scroll < self.CanvasSize) then
			if (parent.m_bScroll) then
				parent:SetShouldScroll(false)
			end
			
			self.__scroll = scroll
		else
			if (scroll >= self.CanvasSize) then
				if (!parent.m_bScroll) then
					parent:SetShouldScroll(true)
					
					self.__scroll = nil
				end
			end
		end
		
		if (self.__scroll) then
			self.Scroll = math.Clamp(self.__scroll, 0, self.CanvasSize)
		else
			self.Scroll = math.Clamp(scroll, 0, self.CanvasSize)
		end
		
		self:InvalidateLayout()
		
		-- If our parent has a OnVScroll function use that, if
		-- not then invalidate layout (which can be pretty slow)
		local func = self:GetParent().OnVScroll
		
		if (func) then
			func(self:GetParent(), self:GetOffset())
		else
			self:GetParent():InvalidateLayout()
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:ScrollToBottom()
	self.VBar:SetScroll(self.VBar.CanvasSize)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetScrollbarWidth(width)
	self.VBar:SetWide(width)
	self.VBar.btnGrip:SetWide(width)
	self.VBar.btnUp:SetWide(width)
	self.VBar.btnDown:SetWide(width)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:AddItem(panel)
	panel:SetParent(self:GetCanvas())
	
	local zPosition = table.insert(self.history, panel)
	
	if (self.deleteHistory) then
		local current, maxHistory = #self.history, atlaschat.maxHistory:GetInt()
		
		if (current > maxHistory) then
			for i = 1, math.max(0, current -maxHistory) do
				local panel = self.history[i]
				
				if (IsValid(panel)) then
					panel:Remove()
				end
				
				table.remove(self.history, i)
			end
			
			self:GetCanvas():InvalidateLayout()
		end
	end
	
	if (!self.m_bBottomUp) then
		panel:SetZPos(zPosition)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Rebuild()
	self.pnlCanvas:SizeToChildren(false, true)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:PerformLayout()
	if (self.m_bBottomUp) then
		local w, h = self:GetSize()
		
		self:Rebuild()
		
		self.VBar:SetUp(h, self.pnlCanvas:GetTall())
		
		if (self.VBar.Enabled) then
			w = w - self.VBar:GetWide()
			
			self.pnlCanvas:SetPos(0, self.VBar:GetOffset())
		else
			self.pnlCanvas:SetPos(0, h -self.pnlCanvas:GetTall())
		end
		
		self.pnlCanvas:SetWide(w)
		
		self:Rebuild()
	else
		DScrollPanel.PerformLayout(self)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	local panel = self:GetParent():GetParent()
	
	atlaschat.theme.Call("PaintList", panel, w, h, self)

	local panel = atlaschat.theme.GetValue("panel")
	
	if (ValidPanel(panel)) then
		local x, y = self:LocalToScreen(0, 0)
		local children = self:GetCanvas():GetChildren()
		
		render.SetScissorRect(x, y, x +w, y +h, true)
			for k, child in pairs(children) do
				if (ValidPanel(child)) then
					child:SetPaintedManually(false)
						child:PaintManual()
					child:SetPaintedManually(true)
				end
			end
		render.SetScissorRect(0, 0, 0, 0, false)
	end
	
	return true
end

vgui.Register("atlaschat.chat.list", panel, "DScrollPanel")

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

AccessorFunc(panel, "m_iKey", "Key")

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self:SetHistoryEnabled(true)
	self:SetAllowNonAsciiCharacters(true)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:OnKeyCodeTyped(code)
	local panel = self:GetParent():GetParent()
	
	if (code == KEY_TAB) then
		local value = self:GetText()
		local newText = hook.Run("OnChatTab", value)

		self:SetText(newText)

		-- Beacuse it loses focus when tabbing.
		timer.Simple(FrameTime() *4, function()
			self:RequestFocus()
			self:SetCaretPos(string.len(self:GetValue()))
		end)
	elseif (code == KEY_ESCAPE) then
		self:SetText("")
		
		atlaschat.theme.Call("OnToggle", false)
		
		hook.Run("FinishChat")
		
		timer.Simple(FrameTime() *0.5, function() RunConsoleCommand("cancelselect") end)
	elseif (code == KEY_ENTER) then
		local value = self:GetText()
	
		-- The "&" character has no size. So let's fix that.
		value = string.gsub(value, "&", "＆")
		
		if (value != "") then
			if (self.key) then
				net.Start("atlaschat.txpm")
					net.WriteUInt(self.key, 8)
					net.WriteString(value)
				net.SendToServer()
			else
				net.Start("atlaschat.chat")
					net.WriteString(value)
					net.WriteBit(panel.team)
				net.SendToServer()
				
				--RunConsoleCommand(panel.team and "say_team" or "say", value)
			end
		end
		
		self:FocusNext()
		self:AddHistory(value)
		self:SetText("")
		
		self.HistoryPos = 0
		
		atlaschat.theme.Call("OnToggle", false)
		
		hook.Run("FinishChat")
	else
		if (self.m_bHistory or IsValid(self.Menu)) then
			if (code == KEY_UP) then
				self.HistoryPos = self.HistoryPos -1
				
				self:UpdateFromHistory()
			end
			
			if (code == KEY_DOWN) then	
				self.HistoryPos = self.HistoryPos +1
				
				self:UpdateFromHistory()
			end
		
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:OnChange()
	local value = self:GetText()

	if (value == "/" or value == "!") then
		local prefix = atlaschat.theme.GetValue("panel").prefix
		
		if (ValidPanel(prefix)) then
			prefix:SetPrefix("COMMAND:")
		end
	elseif (value == "") then
		local prefix = atlaschat.theme.GetValue("panel").prefix
		
		if (ValidPanel(prefix)) then
			prefix:SetPrefix("SAY:")
		end
	end
	
	hook.Run("ChatTextChanged", value)
end
	
---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	atlaschat.theme.Call("PaintTextEntry", w, h)
end

vgui.Register("atlaschat.chat.entry", panel, "DTextEntry")

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self:SetPrefix("SAY:")
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetPrefix(prefix)
	self.prefix = prefix
	
	local w = util.GetTextSize("atlaschat.theme.prefix", prefix)
	
	self:SetWide(w +10)
	self:InvalidateLayout()
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:GetPrefix()
	return self.prefix
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	atlaschat.theme.Call("PaintPrefix", w, h)
end

vgui.Register("atlaschat.chat.prefix", panel, "Panel")

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self.keyList = {}
	
	self.button = self.pnlCanvas:Add("atlaschat.chat.button")
	self.button:SetSize(16, 16)
	self.button:SetText("+")
	self.button:SetFont("atlaschat.theme.add")
	self.button:Dock(LEFT)
	self.button:DockMargin(2, 0, 0, 0)
	self.button:SetZPos(10000)
	
	function self.button.DoClick()
		net.Start("atlaschat.stpm")
		net.SendToServer()
	end
end

---------------------------------------------------------
-- THIS CODE IS A MESS!!
---------------------------------------------------------

function panel:AddList(key, list, name)
	if (!ValidPanel(list)) then
		local panel = atlaschat.theme.GetValue("panel")
		
		list = panel:Add("atlaschat.chat.list")
		list:Dock(FILL)
		list:GetCanvas():DockPadding(0, 2, 0, 2)
		list:SetVisible(false)
	end
	
	list:SetBottomUp(true)
	
	local panel = self.pnlCanvas:Add("Panel")
	panel:SetWide(75)
	panel:Dock(LEFT)
	panel:SetMouseInputEnabled(true)
	
	panel.key = key
	panel.name = name
	panel.list = list
	
	list.host = panel
	list.players = {}
	list.deleteHistory = true
	list.fuckyou = self
	
	function list:Resize()
		local w, players = 4, self.players
		
		for k, player in pairs(players) do
			if (IsValid(player) and k != "creator") then
				local nick = player:Nick()
				local width = util.GetTextSize("atlaschat.theme.list.name", nick)
				
				w = w +width +10
			end
			
			if (w >= 325) then
				break
			end
		end
		
		panel:SetWide(w)
		
		local canvas = panel:GetParent()
		local root = canvas:GetParent()
		
		timer.Simple(FrameTime() *2, function() canvas:InvalidateLayout(true) canvas:SizeToChildren(true) root:InvalidateLayout() end)
		
		local text = ""
		
		for k, player in pairs(players) do
			if (IsValid(player) and k != "creator") then
				local nick = player:Nick()
				
				text = text .. nick .. (k == #players and "" or ", ")
			end
		end
		
		panel:SetToolTip(text)
	end
	
	function list:AddPlayer(player, creator)
		local exists = false
		
		for i = 1, #self.players do
			local info = self.players[i]
			
			if (info == player) then
				exists = true
			end
		end
		
		if (IsValid(player) and !exists) then
			if (player != LocalPlayer()) then
				atlaschat.theme.Call("ParseText", self, ":information: " .. player:Nick() .. " has joined the chatroom.")
			end
			
			table.insert(self.players, player)
		end
		
		if (IsValid(creator)) then
			self.players.creator = creator
		end
		
		local active = atlaschat.theme.GetValue("panel"):GetActiveList()
		
		if (active == self) then
			local userListBase = atlaschat.theme.GetValue("userListBase")
			
			if (IsValid(userListBase)) then
				userListBase:Rebuild(self.players, self:GetHost().key)
			end
		end
		
		if (#self.players > 1) then
			self:Resize()
		end
	end
	
	function list:RemovePlayer(player, noLocal)
		if (player == LocalPlayer()) then
			if (!noLocal) then
				local host = self:GetHost()
				local canvas = host:GetParent()
				local root = self.fuckyou
				
				root.keyList[host.key] = nil
	
				local panel = atlaschat.theme.GetValue("panel")
				local mainChat = atlaschat.theme.GetValue("mainChat")
				
				mainChat:OnMousePressed()
				panel:ChangeList(mainChat, mainChat:GetList())
				
				local userList = atlaschat.theme.GetValue("userListBase")
				
				if (ValidPanel(userList)) then
					userList:SetVisible(false)
				end
				
				host.list:Remove()
				host:Remove()
				
				timer.Simple(FrameTime() *2, function() canvas:InvalidateLayout(true) canvas:SizeToChildren(true) root:InvalidateLayout() end)
				
				chat.AddText(color_red, ":exclamation: You have been kicked from the chat!")
			end
		else
			atlaschat.theme.Call("ParseText", self, ":information: " .. player:Nick() .. " has left the chatroom.")
			
			for i = 1, #self.players do
				local info = self.players[i]
				
				if (info == player) then
					table.remove(self.players, i)
					
					local active = atlaschat.theme.GetValue("panel"):GetActiveList()
		
					if (active == self) then
						local userListBase = atlaschat.theme.GetValue("userListBase")
						
						if (IsValid(userListBase)) then
							userListBase:Rebuild(self.players, self:GetHost().key)
						end
					end
					
					break
				end
			end
			
			if (#self.players > 1) then
				self:Resize()
			end
		end
	end
	
	function list:GetHost()
		return self.host
	end
	
	function panel:GetList()
		return self.list
	end
	
	function panel:SetNew(new)
		self.new = new
		self.blink = CurTime()
	end
	
	function panel:OnCursorEntered()
		self:SetCursor("hand")
		
		local mainChat = atlaschat.theme.GetValue("mainChat")
		
		if (self != mainChat) then
			self.list:Resize()
		end
	end
	
	function panel:OnCursorExited()
		self:SetCursor("arrow")
	end
	
	function panel:OnMousePressed()
		local parent = self:GetParent()
		
		if (ValidPanel(parent.lastSelected)) then
			parent.lastSelected.selected = nil
		end
		
		self.new = nil
		self.selected = true
		
		parent.lastSelected = self
		
		local panel = atlaschat.theme.GetValue("panel")
		
		panel:ChangeList(self, self.list)
	end
	
	function panel:PerformLayout()
		local w = self:GetWide()
		
		if (ValidPanel(self.close)) then
			self.close:SetPos(w -8, 1)
		end
	end
	
	function panel:Paint(w, h)
		atlaschat.theme.Call("PaintListContainer", self, w, h)
	end
	
	if (key) then
		panel.close = panel:Add("Panel")
		panel.close:SetSize(8, 8)
		
		function panel.close:OnCursorEntered()
			self:SetCursor("hand")
		end
		
		function panel.close:OnCursorExited()
			self:SetCursor("arrow")
		end
	
		function panel.close:OnMousePressed()
			local parent = self:GetParent()
			local canvas = parent:GetParent()
			local root = canvas:GetParent()
			
			root.keyList[parent.key] = nil
			
			net.Start("atlaschat.lvpm")
				net.WriteUInt(parent.key, 8)
			net.SendToServer()
			
			local panel = atlaschat.theme.GetValue("panel")
			local mainChat = atlaschat.theme.GetValue("mainChat")
			
			mainChat:OnMousePressed()
			panel:ChangeList(mainChat, mainChat:GetList())
			
			local userList = atlaschat.theme.GetValue("userListBase")
			
			if (ValidPanel(userList)) then
				userList:SetVisible(false)
			end
			
			parent.list:Remove()
			parent:Remove()
			
			timer.Simple(FrameTime() *2, function() canvas:InvalidateLayout(true) canvas:SizeToChildren(true) root:InvalidateLayout() end)
		end
		
		function panel.close:Paint(w, h)
			local color = atlaschat.theme.GetValue("color").privatecard_close
			local color_hovered = atlaschat.theme.GetValue("color").privatecard_close_hover
			
			draw.SimpleText("x", "atlaschat.theme.list.close", w /2, h /2 -1, self.Hovered and color_hovered or color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	self.pnlCanvas:InvalidateLayout(true)
	self.pnlCanvas:SizeToChildren(true)
	
	if (key) then
		self.keyList[key] = list
	end
	
	return panel
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:GetListByKey(key)
	return self.keyList[key]
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:PerformLayout()
	local w, height = self:GetSize()
	
	self.pnlCanvas:SetTall(height)
	
	if ( w < self.pnlCanvas:GetWide() ) then
		self.OffsetX = math.Clamp( self.OffsetX, 0, self.pnlCanvas:GetWide() -w )
	else
		self.OffsetX = 0
	end
	
	self.pnlCanvas.x = self.OffsetX *-1
	
	self.btnLeft:SetSize( 15, 15 )
	self.btnLeft:AlignLeft( 4 )
	self.btnLeft.y = 2
	
	self.btnRight:SetSize( 15, 15 )
	self.btnRight:AlignRight( 4 )
	self.btnRight.y = 2
	
	self.btnLeft:SetVisible( self.pnlCanvas.x < 0 )
	self.btnRight:SetVisible( self.pnlCanvas.x + self.pnlCanvas:GetWide() > self:GetWide() )
end

vgui.Register("atlaschat.chat.listcontainer", panel, "DHorizontalScroller")