
-- should probably make these global
local ROW_LEFT = 1
local ROW_RIGHT = 2

surface.CreateFont("skeyler.scoreboard.title", {font = "Arvil Sans", size = 62, weight = 400})
surface.CreateFont("skeyler.scoreboard.title.blur", {font = "Arvil Sans", size = 62, weight = 400, antialias = false, blursize = 4})

surface.CreateFont("skeyler.scoreboard.row", {font = "Arvil Sans", size = 32, weight = 400})
surface.CreateFont("skeyler.scoreboard.row.blur", {font = "Arvil Sans", size = 32, weight = 400, antialias = false, blursize = 4})

surface.CreateFont("skeyler.scoreboard.row.title", {font = "Arvil Sans", size = 36, weight = 400})
surface.CreateFont("skeyler.scoreboard.row.title.blur", {font = "Arvil Sans", size = 36, weight = 400, antialias = false, blursize = 2})

local panel = {}

function panel:Init()
	self.rows = {[ROW_RIGHT] = {}, [ROW_LEFT] = {}}
	self.startTime = SysTime() -0.6
	
	self:DockPadding(2, 60, 2, 30)
	
	self.list = self:Add("DScrollPanel")
	self.list:Dock(FILL)
	self.list:DockMargin(8, 0, 8, 0)
	
	function self.list:Paint(w, h)
		draw.SimpleRect(0, 0, w, h, Color(245, 246, 247, 50))
	end
	
	self.list.VBar:SetWide(16)
	self.list.VBar:Dock(NODOCK)
	self.list.VBar.btnUp:Remove()
	self.list.VBar.btnDown:Remove()
	
	function self.list.VBar:Paint(w, h) end
	
	function self.list.VBar.btnGrip:Paint(w, h)
		local parent = self:GetParent():GetParent()
		local x, y = parent:ScreenToLocal(gui.MousePos())
		local x2, y2 = parent:GetPos()
		local w2, h2 = parent:GetSize()
		
		if (x >= w2 -75 and x <= w2 +15 and y >= 0 and y <= h2) then
			if (self.Depressed) then
				draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 180))
			elseif (self.Hovered) then
				draw.RoundedBox(8, 0, 0, w, h, Color(191, 192, 193, 180))
			else
				draw.RoundedBox(8, 0, 0, w, h, Color(221, 222, 223, 180))
			end
		end
	end
	
	function self.list.VBar:OnCursorMoved(x, y)
		if (!self.Enabled) then return end
		if (!self.Dragging) then return end
	
		local x = 0
		local y = gui.MouseY()
		local x, y = self:ScreenToLocal(x, y)
		
		y = y -self.HoldPos
		
		local TrackSize = self:GetTall() -self:GetWide() *2 -self.btnGrip:GetTall()
		
		y = y /TrackSize
		
		self:SetScroll(y *self.CanvasSize)	
	end

	function self.list.VBar:PerformLayout()
		local Scroll = self:GetScroll() /self.CanvasSize
		local BarSize = math.max(self:BarScale() *self:GetTall(), 0)
		local Track = self:GetTall() -BarSize
		
		Track = Track +1
		Scroll = Scroll *Track
		
		self.btnGrip:SetPos(0, Scroll)
		self.btnGrip:SetSize(self:GetWide(), BarSize)
	end
	
	function self.list:PerformLayout()
		local width, height = self:GetSize()
	
		self:Rebuild()
	
		self.VBar:SetUp(height, self.pnlCanvas:GetTall())
		self.VBar:SetPos(width -20, 0)
		self.VBar:SetTall(height)
		
		if (self.VBar.Enabled) then
			self.pnlCanvas:SetWide(width)
			self.pnlCanvas:SetPos(0, self.VBar:GetOffset())
		else
			self.pnlCanvas:SetWide(width)
			self.pnlCanvas:SetPos(0, 0)
		
			self.VBar:SetScroll(self.pnlCanvas:GetTall())
		end

		self:Rebuild()
	end
end

function panel:AddRow(name, width, x_align, rowType, callback)
	rowType = rowType or ROW_RIGHT
	
	local id = table.insert(self.rows[rowType], {name = name, width = width, x = (rowType == ROW_LEFT and 71 or rowType == ROW_RIGHT and (self:GetWide() -8) -width), x_align = x_align or TEXT_ALIGN_LEFT, rowType = rowType, callback = callback})
	local rows = self.rows[rowType]
	
	for i = 1, id -1 do
		local previous = rows[i]

		if (previous) then
			if (rows[id].rowType == ROW_RIGHT) then
				rows[id].x = rows[id].x -previous.width
			elseif (rows[id].rowType == ROW_LEFT) then
				rows[id].x = rows[id].x +previous.width
			end
		end
	end
end

function panel:AddPlayer(player)
	local panel = vgui.Create("Panel")
	panel:SetTall(50)
	panel:Dock(TOP)
	
	AccessorFunc(panel, "m_bAltLine", "AltLine")
	
	panel.player = player
	
	function panel:Paint(w, h)
		if (!self.m_bAltLine) then
			draw.SimpleRect(0, 0, w, h, Color(21, 22, 23, 120))
			
			surface.SetDrawColor(Color(0, 0, 0, 50))
		else
			surface.SetDrawColor(Color(0, 0, 0, 130))
		end
		
		surface.DrawLine(0, h -1, w, h -1)
	end
	
	local avatar = panel:Add("Panel")
	avatar:SetWide(50)
	avatar:Dock(LEFT)
	
	function avatar:Paint(w, h)
		draw.SimpleRect(0, 0, w, h, color_white)
	end
	
	avatar.avatar = avatar:Add("AvatarImage")
	avatar.avatar:SetSize(48, 48)
	avatar.avatar:SetPos(1, 1)
	avatar.avatar:SetPlayer(player, 48)
	
	self.list:AddItem(panel)
	self.list:InvalidateLayout(true)
	
	local height, children = 90, self.list:GetCanvas():GetChildren()
	
	for k, child in pairs(children) do
		if (ValidPanel(child)) then
			height = height +50
			
			if (k % 2 == 1) then
				child:SetAltLine(true)
			end
		end
	end
	
	height = math.min(ScrH() *0.7, height)
	
	self:SetTall(height)
	self:Center()
	
	-- Add all the row functions.
	for i = 1, #self.rows do
		local row = self.rows[i]
		
		for i2 = 1, #row do
			local data = row[i2]
			
			if (data.callback) then
				data.callback(panel, panel.player, data)
			end
		end
	end
end

function panel:Think()
	local players = player.GetAll()
	
	for k, player in pairs(players) do
		if (!player.ssbase_scoreboard) then
			self:AddPlayer(player)
			
			player.ssbase_scoreboard = true
		end
	end
end

function panel:Paint(w, h)
	Derma_DrawBackgroundBlur(self, self.startTime)
	
	draw.RoundedBox(4, 0, 0, w, 60, Color(194, 193, 198, 160))
	draw.SimpleRect(1, 1, w -2, 60 -2, Color(251, 251, 251))
	draw.SimpleRect(2, 25, w -4, 60 -27, Color(245, 245, 245))
	
	draw.RoundedBox(4, 0, h -30, w, 30, Color(194, 193, 198, 160))
	draw.SimpleRect(1, h -(30 -1), w -2, 28, Color(251, 251, 251))
	draw.SimpleRect(2,  h -15, w -4, 13, Color(245, 245, 245))
end

function panel:PaintOver(w, h)
	for i = 1, #self.rows do
		local rows = self.rows[i]
		
		for i2 = 1, #rows do
			local row = rows[i2]
			local x = row.x_align == TEXT_ALIGN_CENTER and row.x +row.width /2 or row.x
			
			draw.SimpleText(row.name, "skeyler.scoreboard.row.title.blur", x, 30, Color(0, 0, 0, 160), row.x_align, TEXT_ALIGN_CENTER)
			draw.SimpleText(row.name, "skeyler.scoreboard.row.title", x, 30, Color(87, 87, 87), row.x_align, TEXT_ALIGN_CENTER)
			
			if (row.rowType == ROW_LEFT) then
			--	draw.SimpleRect(row.x +row.width, 2, 2, h -32, Color(0, 0, 0, 30))
			elseif (row.rowType == ROW_RIGHT) then
				draw.SimpleRect(row.x -2, 1, 1, h -31, Color(0, 0, 0, 50))
			end
		end
	end
	
	surface.DisableClipping(true)
		util.PaintShadow(w, 60, -w, -60, 4, 0.35)
		util.PaintShadow(w, h, -w, -30, 4, 0.35)
		
		draw.SimpleText("SCOREBOARD", "skeyler.scoreboard.title.blur", 62, -10, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("SCOREBOARD", "skeyler.scoreboard.title", 63, -9, Color(0, 0, 0, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("SCOREBOARD", "skeyler.scoreboard.title", 62, -10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	surface.DisableClipping(false)
end

vgui.Register("ssbase.scoreboard", panel, "EditablePanel")

local scoreboard

function GM:ScoreboardShow()
	if (!ValidPanel(scoreboard)) then
		scoreboard = vgui.Create("ssbase.scoreboard")
		scoreboard:SetSize(math.Clamp(ScrW() *0.95, 800, 1280), 90)
		scoreboard:Center()
		
		scoreboard:AddRow("PLAYER", scoreboard:GetWide() *0.3, nil, ROW_LEFT, function(panel, player, row)
			local name = player:Nick()
			
			local label = panel:Add("DLabel")
			label:SetSize(row.width, 50)
			label:SetText(name)
			label:SetFont("skeyler.scoreboard.row")
			label:SetColor(color_white)
			label:SetExpensiveShadow(1, Color(0, 0, 0, 210))
			label:Dock(LEFT)
			label:DockMargin(10, 0, 0, 0)
		end)
		
		local color_bar_background = Color(0, 0, 0, 140)
		
		scoreboard:AddRow("PING", 85, TEXT_ALIGN_CENTER, nil, function(panel, player, row)
			local barPanel = panel:Add("Panel")
			barPanel:SetSize(row.width , 50)
			barPanel:Dock(RIGHT)
		
			barPanel.color_bar_ping = Color(0, 0, 60, 255)
			
			function barPanel:Paint(w, h)
				local ping, width, height = player:Ping(), 5, 5
				local multiplier = 1 -math.Clamp((ping -50) /400, 0, 1)
				
				self.color_bar_ping.r = (1 -multiplier) *255
				self.color_bar_ping.g = multiplier *255
			
				for i = 1, 4 do
					local x, barHeight = w /2 -10 +(i -1) *(width +1), i *height
					local y = (h -barHeight) -h /4
					
					draw.SimpleRect(x, y, width, barHeight, color_bar_background)
					
					if (i == 1 or multiplier >= i /4) then
						surface.SetDrawColor(self.color_bar_ping)
						surface.DrawRect(x, y, width, barHeight)
					end
				end
			end
		end)
		
		scoreboard:AddRow("TIME", 110, TEXT_ALIGN_CENTER, ROW_RIGHT, function(panel, player, row)
			local label = panel:Add("DLabel")
			label:SetSize(row.width, 50)
			label:SetText(string.FormattedTime(RealTime(), "%02i:%02i:%02i") )
			label:SetFont("skeyler.scoreboard.row")
			label:SetColor(Color(242, 242, 242))
			label:SetExpensiveShadow(1, Color(0, 0, 0, 210))
			label:SetContentAlignment(5)
			label:Dock(RIGHT)
		end)
		
		scoreboard:AddRow("DIFFICULTY", 132, TEXT_ALIGN_CENTER, ROW_RIGHT, function(panel, player, row)
			local label = panel:Add("DLabel")
			label:SetSize(row.width, 50)
			label:SetText("EXTREME")
			label:SetFont("skeyler.scoreboard.row")
			label:SetColor(Color(242, 242, 242))
			label:SetExpensiveShadow(1, Color(0, 0, 0, 210))
			label:SetContentAlignment(5)
			label:Dock(RIGHT)
		end)
		
		scoreboard:AddRow("SCORE", 110, TEXT_ALIGN_CENTER, ROW_RIGHT, function(panel, player, row)
			local label = panel:Add("DLabel")
			label:SetSize(row.width, 50)
			label:SetText(math.random(100, 99999))
			label:SetFont("skeyler.scoreboard.row")
			label:SetColor(Color(242, 242, 242))
			label:SetExpensiveShadow(1, Color(0, 0, 0, 210))
			label:SetContentAlignment(5)
			label:Dock(RIGHT)
		end)
		
		scoreboard:AddRow("Rank", 164, TEXT_ALIGN_CENTER, ROW_RIGHT, function(panel, player, row)
			local rankPanel = panel:Add("Panel")
			rankPanel:SetSize(row.width, 50)
			rankPanel:Dock(RIGHT)
			
			function rankPanel:Paint(w, h)
				local name = player == LocalPlayer() and "DEVELOPER" or "DIrT-SHIRT"
				
				if (player == LocalPlayer()) then
					local color = Color(77, 150, 187, 255)
				
					draw.SimpleRect(1, 1, w -1, h -2, color)
				end
				
				draw.SimpleText(name, "skeyler.scoreboard.row", w /2 +1, h /2 +1, Color(0, 0, 0, 160), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(name, "skeyler.scoreboard.row", w /2, h /2, Color(242, 242, 242), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end)
	end
	
	scoreboard:SetVisible(true)
	
	gui.EnableScreenClicker(true)
end

function GM:ScoreboardHide()
	if (ValidPanel(scoreboard)) then
		scoreboard:SetVisible(false)
	end
	
	gui.EnableScreenClicker(false)
end