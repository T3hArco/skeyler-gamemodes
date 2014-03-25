---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

local IsValid, ValidPanel = IsValid, ValidPanel

local color_label = Color(242, 242, 242)
local color_shadow = Color(0, 0, 0, 180)

SS.Scoreboard = {}

SS.Scoreboard.ROW_LEFT = 1
SS.Scoreboard.ROW_RIGHT = 2
SS.Scoreboard.Color_Shadow = color_shadow
SS.Scoreboard.Color_Label = color_label

local stored = {[SS.Scoreboard.ROW_RIGHT] = {}, [SS.Scoreboard.ROW_LEFT] = {}}

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Scoreboard.RegisterRow(name, width, x_align, rowType, callback)
	rowType = rowType or SS.Scoreboard.ROW_RIGHT
	
	table.insert(stored[rowType], {name = name, width = width, x_align = x_align, rowType = rowType, callback = callback})
end

-- I add it here so it'll add it first.
SS.Scoreboard.RegisterRow("Rank", 164, TEXT_ALIGN_CENTER, SS.Scoreboard.ROW_RIGHT, function(panel, player, row)
	local rankPanel = panel:Add("Panel")
	rankPanel:SetSize(row.width, 50)
	rankPanel:Dock(RIGHT)
	
	function rankPanel:Paint(w, h)
		if (IsValid(player)) then
			local name, color = string.upper(player:GetRankName()), player:GetRankColor()
			
			if (name) then
				if (player:GetRank() > 0) then
					draw.SimpleRect(1, 1, w -1, h -2, color)
				end
				
				draw.SimpleText(name, "skeyler.scoreboard.row", w /2 +1, h /2 +1, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(name, "skeyler.scoreboard.row", w /2, h /2, color_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText("UNKNOWN RANK", "skeyler.scoreboard.row", w /2 +1, h /2 +1, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("UNKNOWN RANK", "skeyler.scoreboard.row", w /2, h /2, color_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
end)

SS.Scoreboard.RegisterRow("Pixels", 164, TEXT_ALIGN_CENTER, SS.Scoreboard.ROW_RIGHT, function(panel, player, row)
	local rankPanel = panel:Add("Panel")
	rankPanel:SetSize(row.width, 50)
	rankPanel:Dock(RIGHT)
	
	function rankPanel:Paint(w, h)
		if (IsValid(player)) then
			local money = FormatNum(player:GetMoney())
			local width = util.GetTextSize("skeyler.scoreboard.row", money)
			
			width = width /2

			draw.SimpleRect(w /2 -(width +18), h /2 -8, 5, 5, Color(69, 192, 255, 120))
			draw.SimpleRect(w /2 -(width +13), h /2 -2, 5, 5, Color(69, 192, 255, 200))
			draw.SimpleRect(w /2 -(width +18), h /2 +3, 5, 5, Color(69, 192, 255, 255))
			
			draw.SimpleText(money, "skeyler.scoreboard.row", w /2 +1, h /2 +1, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(money, "skeyler.scoreboard.row", w /2, h /2, color_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end)

SS.Scoreboard.RegisterRow("TEAM", 125, TEXT_ALIGN_CENTER, nil, function(panel, player, row)
	local teamPanel = panel:Add("Panel")
	teamPanel:SetSize(row.width, 50)
	teamPanel:Dock(RIGHT)

	panel.team = 1
	
	function teamPanel:Paint(w, h)
		if (IsValid(player)) then
			local index = player:Team()
			local name, color = string.upper(team.GetName(index)), team.GetColor(index)
			
			if (name) then
				if (index != TEAM_READY) then
					draw.SimpleRect(1, 1, w -1, h -2, color)
				end
				
				draw.SimpleText(name, "skeyler.scoreboard.row", w /2 +1, h /2 +1, SS.Scoreboard.Color_Shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(name, "skeyler.scoreboard.row", w /2, h /2, SS.Scoreboard.Color_Label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			panel.team = index
		end
	end
end)

surface.CreateFont("skeyler.scoreboard.title", {font = "Arvil Sans", size = 62, weight = 400})
surface.CreateFont("skeyler.scoreboard.title.blur", {font = "Arvil Sans", size = 62, weight = 400, antialias = false, blursize = 4})

surface.CreateFont("skeyler.scoreboard.row", {font = "Helvetica LT Std Cond", size = 18, weight = 800})
surface.CreateFont("skeyler.scoreboard.row.blur", {font = "Helvetica LT Std Cond", size = 18, weight = 800, antialias = false, blursize = 4})

surface.CreateFont("skeyler.scoreboard.row.title", {font = "Arvil Sans", size = 36, weight = 400})
surface.CreateFont("skeyler.scoreboard.row.title.blur", {font = "Arvil Sans", size = 36, weight = 400, antialias = false, blursize = 2})

surface.CreateFont("skeyler.scoreboard.ping", {font = "Arvil Sans", size = 24, weight = 400})
surface.CreateFont("skeyler.scoreboard.ping.small", {font = "Arvil Sans", size = 18, weight = 400})

local panel = {}

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self.rows = {[SS.Scoreboard.ROW_RIGHT] = {}, [SS.Scoreboard.ROW_LEFT] = {}}
	self.startTime = SysTime() -0.6
	
	self:DockPadding(2, 60, 2, 30)
	self:SetDrawOnTop(true)
	
	self.list = self:Add("DScrollPanel")
	self.list:Dock(FILL)
	self.list:DockMargin(8, 0, 8, 0)
	
	local color_background = Color(245, 246, 247, 50)
	
	function self.list:Paint(w, h)
		draw.SimpleRect(0, 0, w, h, color_background)
	end

	util.ReplaceScrollbar(self.list)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Resize()
	local height, children, index = 90, self.list:GetCanvas():GetChildren(), 1
	
	for k, child in pairs(children) do
		if (ValidPanel(child)) then
			height = height +32
			
			if (index % 2 == 1) then
				child:SetAltLine(true)
			else
				child:SetAltLine(false)
			end
			
			index = index +1
		end
	end
	
	height = math.min(ScrH() *0.7, height)
	
	self:SetTall(height)
	self:Center()
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:AddRow(name, width, x_align, rowType, callback)
	rowType = rowType or SS.Scoreboard.ROW_RIGHT
	
	local id = table.insert(self.rows[rowType], {name = name, width = width, x = (rowType == SS.Scoreboard.ROW_LEFT and 51 or rowType == SS.Scoreboard.ROW_RIGHT and (self:GetWide() -8) -width), x_align = x_align or TEXT_ALIGN_LEFT, rowType = rowType, callback = callback})
	local rows = self.rows[rowType]
	
	for i = 1, id -1 do
		local previous = rows[i]

		if (previous) then
			if (rows[id].rowType == SS.Scoreboard.ROW_RIGHT) then
				rows[id].x = rows[id].x -previous.width
			elseif (rows[id].rowType == SS.Scoreboard.ROW_LEFT) then
				rows[id].x = rows[id].x +previous.width
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:AddPlayer(player)
	local base = self
	
	local panel = vgui.Create("Panel")
	panel:SetTall(32)
	panel:Dock(TOP)
	
	AccessorFunc(panel, "m_bAltLine", "AltLine")
	
	panel.player = player
	
	function panel:Paint(w, h)
		if (!self.m_bAltLine) then
			draw.SimpleRect(0, 0, w, h, Color(21, 22, 23, 120))
			
			surface.SetDrawColor(Color(0, 255, 0, 50))
		else
			surface.SetDrawColor(Color(255, 0, 0, 130))
		end
		
		surface.DrawLine(0, h, w, h)
	end
	
	function panel:Think()
		if (!IsValid(self.player)) then
			self:Remove()
			
			timer.Simple(FrameTime() *2, function()
				base.list:GetCanvas():InvalidateLayout()
				base:Resize()
			end)
		end
	end
	
	local avatar = panel:Add("AvatarImage")
	avatar:Dock(LEFT)
	avatar:SetSize(32, 32)
	avatar:SetPlayer(player, 32)
	
	self.list:AddItem(panel)
	self.list:InvalidateLayout(true)
	
	self:Resize()
	
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

---------------------------------------------------------
--
---------------------------------------------------------

SS.Scoreboard.SortRight = false -- invert the sorting

function panel:SortRows()
	local children = self.list:GetCanvas():GetChildren()

	for k, child in pairs(children) do
		if (ValidPanel(child)) then
			if child.team == 1 then 
				child:SetZPos(-10) -- This is spectator, it should always be on bottom.
			else 
				child:SetZPos(child.team * (SS.Scoreboard.SortRight and 1 or -1))
			end 
		end
	end
	
	self.list:GetCanvas():InvalidateLayout(true)
	
	timer.Simple(0, function()
		local index = 1
		local children = self.list:GetCanvas():GetChildren()
	
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				if (index % 2 == 1) then
					child:SetAltLine(true)
				else
					child:SetAltLine(false)
				end
				
				index = index +1
			end
		end
	end)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Think()
	local players = player.GetAll()
	
	for k, player in pairs(players) do
		if (!player.ssbase_scoreboard) then
			self:AddPlayer(player)
			
			timer.Simple(0, function() self:SortRows() end)
			
			player.ssbase_scoreboard = true
		end
	end
	
	if (self:IsVisible()) then
		if (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) then
			if (!self.mouseEnabled) then
				gui.EnableScreenClicker(true)
				
				self.mouseEnabled = true
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	Derma_DrawBackgroundBlur(self, self.startTime)
	
	draw.RoundedBox(4, 0, 0, w, 60, Color(194, 193, 198, 160))
	draw.SimpleRect(1, 1, w -2, 60 -2, Color(251, 251, 251))
	draw.SimpleRect(2, 25, w -4, 60 -27, Color(245, 245, 245))
	
	draw.RoundedBox(4, 0, h -30, w, 30, Color(194, 193, 198, 160))
	draw.SimpleRect(1, h -(30 -1), w -2, 28, Color(251, 251, 251))
	draw.SimpleRect(2,  h -15, w -4, 13, Color(245, 245, 245))
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:PaintOver(w, h)
	for i = 1, #self.rows do
		local rows = self.rows[i]
		
		for i2 = 1, #rows do
			local row = rows[i2]
			local x = row.x_align == TEXT_ALIGN_CENTER and row.x +row.width /2 or row.x
			
			draw.SimpleText(row.name, "skeyler.scoreboard.row.title.blur", x, 30, Color(0, 0, 0, 160), row.x_align, TEXT_ALIGN_CENTER)
			draw.SimpleText(row.name, "skeyler.scoreboard.row.title", x, 30, Color(87, 87, 87), row.x_align, TEXT_ALIGN_CENTER)
			
			if (row.rowType == SS.Scoreboard.ROW_LEFT) then
			--	draw.SimpleRect(row.x +row.width, 2, 2, h -32, Color(0, 0, 0, 30)) -- need to fix the right rows
			elseif (row.rowType == SS.Scoreboard.ROW_RIGHT) then
				draw.SimpleRect(row.x -2, 1, 1, h -31, Color(0, 0, 0, 50))
			end
		end
	end
	
	surface.DisableClipping(true)
		util.PaintShadow(w, 60, -w, -60, 4, 0.35)
		util.PaintShadow(w, h, -w, -30, 4, 0.35)
		
		draw.SimpleText("SCOREBOARD", "skeyler.scoreboard.title.blur", 51, -10, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("SCOREBOARD", "skeyler.scoreboard.title", 52, -9, color_shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("SCOREBOARD", "skeyler.scoreboard.title", 51, -10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	surface.DisableClipping(false)
end

vgui.Register("ss.scoreboard", panel, "EditablePanel")

local scoreboard
local arrowTexture = Material("skeyler/vgui/arrow.png", "noclamp smooth")

---------------------------------------------------------
--
---------------------------------------------------------
 
function GM:ScoreboardShow()
	if (!ValidPanel(scoreboard)) then
		scoreboard = vgui.Create("ss.scoreboard")
		scoreboard:SetSize(math.Clamp(ScrW() *0.95, 800, 1100), 90)
		scoreboard:Center()
		
		SS.Scoreboard.RegisterRow("PLAYER", scoreboard:GetWide() *0.3, nil, SS.Scoreboard.ROW_LEFT, function(panel, player, row)
			local name = string.upper(player:Nick())
			
			local label = panel:Add("DLabel")
			label:SetSize(row.width, 50)
			label:SetText(name)
			label:SetFont("skeyler.scoreboard.row")
			label:SetColor(color_white)
			label:SetExpensiveShadow(1, color_shadow)
			label:Dock(LEFT)
			label:DockMargin(8, 0, 0, 0)
			
			function label:Think()
				if (IsValid(player)) then
					local text = self:GetText()
					local name = string.upper(player:Nick())
					
					if (text != name) then
						self:SetText(name)
					end
				end
			end
		end)
	
		local color_bar_background = Color(0, 0, 0, 140)
		
		-- This needs to be on the last row so we add it here.
		SS.Scoreboard.RegisterRow("PING", 85, TEXT_ALIGN_CENTER, nil, function(panel, player, row)
			local barPanel = panel:Add("Panel")
			barPanel:SetSize(row.width , 50)
			barPanel:Dock(RIGHT)
		
			function barPanel:Paint(w, h)
				if (IsValid(player)) then
					local ping, width, height = player:Ping(), 4, 4
					local multiplier = 1 -math.Clamp((ping -50) /400, 0, 1)
					
					for i = 1, 4 do
						local x, barHeight = w /2 -10 +(i -1) *(width +1), i *height
						local y = (h -barHeight) -h /4
						
						draw.SimpleRect(x, y, width, barHeight, color_bar_background)
						
						if (i == 1 or multiplier >= i /4) then
							surface.SetDrawColor(color_white)
							surface.DrawRect(x, y, width, barHeight)
						end
					end
					
					if (self.Hovered) then
						local pingWidth = util.GetTextSize("skeyler.scoreboard.ping", ping)
						local width, height = pingWidth +40, h
						local x, y = w +4, h /2 -height /2
						
						surface.DisableClipping(true)
							draw.Material(x -32, y +height /2 -32 /2, 32, 32, Color(0, 0, 0, 230), arrowTexture)
							draw.SimpleRect(x, y, width, height, Color(0, 0, 0, 200))
							
							draw.SimpleText(ping, "skeyler.scoreboard.ping", x +12, y +height /2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
							draw.SimpleText("ms", "skeyler.scoreboard.ping.small", x +12 +pingWidth, y +height /2 +2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						surface.DisableClipping(false)
					end
				end
			end
		end)
		
		for i = 1, #stored[SS.Scoreboard.ROW_LEFT] do
			local data = stored[SS.Scoreboard.ROW_LEFT][i]
			
			scoreboard:AddRow(data.name, data.width, data.x_align, data.rowType, data.callback)
		end
		
		for i = 0, #stored[SS.Scoreboard.ROW_RIGHT] do
			local data = stored[SS.Scoreboard.ROW_RIGHT][#stored[SS.Scoreboard.ROW_RIGHT] -i]
			
			if (data) then
				scoreboard:AddRow(data.name, data.width, data.x_align, data.rowType, data.callback)
			end
		end
	end
	
	scoreboard:SetVisible(true)
	scoreboard:SortRows()
end

---------------------------------------------------------
--
---------------------------------------------------------

function GM:ScoreboardHide()
	if (ValidPanel(scoreboard)) then
		scoreboard:SetVisible(false)
		
		if (scoreboard.mouseEnabled) then
			gui.EnableScreenClicker(false)
		end
		
		scoreboard.mouseEnabled = false
	end
end

---------------------------------------------------------
-- Scrolling without mouse enabled.
---------------------------------------------------------

hook.Add("PlayerBindPress", "ss.scoreboard.scroll", function(player, bind, pressed)
	if (ValidPanel(scoreboard) and scoreboard:IsVisible() and !scoreboard.mouseEnabled) then
		if (bind == "invprev") then
			scoreboard.list.VBar:SetScroll(scoreboard.list.VBar:GetScroll() -14)
			
			return true
		end
		
		if (bind == "invnext") then
			scoreboard.list.VBar:SetScroll(scoreboard.list.VBar:GetScroll() +14)
			
			return true
		end
	end
end)
