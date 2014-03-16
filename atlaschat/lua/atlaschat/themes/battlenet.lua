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

---------------------------------------------------------
-- Theme variables.
---------------------------------------------------------

-- The base theme that this theme will use.
theme.base = "default"

-- The theme's unique key.
theme.unique = "battlenet"

-- A pretty name for this theme.
theme.name = "Battle.net Client Style"

-- Holds all the colors.
theme.color = {}

-- The color of the text selection.
theme.color.selection = Color(235, 235, 235, 80)

-- The "X" button on the private chat card.
theme.color.privatecard_close = Color(16, 153, 255)
theme.color.privatecard_close_hover = color_white

-- A generic label color.
theme.color.generic_label = Color(220, 220, 220)

---------------------------------------------------------
-- Called when you change the theme.
---------------------------------------------------------

function theme:OnThemeChange()
	surface.CreateFont("atlaschat.theme.default.title", {font = "Roboto Lt", size = 20, weight = 400})
	surface.CreateFont("atlaschat.theme.prefix", 		{font = "Roboto", size = 16, weight = 400})
	surface.CreateFont("atlaschat.theme.list.name", 	{font = "Arial", size = 14, weight = 400})
	
	self.panel:DockPadding(6, 40, 6, 6)
	self.panel:InvalidateLayout()
end

---------------------------------------------------------
-- Paints a generic background.
---------------------------------------------------------

theme.color.generic_background = Color(245, 245, 245, 255)
theme.color.generic_background_dark = Color(217, 217, 217, 255)

function theme:PaintGenericBackground(panel, w, h, text, x, y, xAlign, yAlign)
	draw.SimpleOutlined(0, 0, w, h, color_black)
	draw.SimpleOutlined(1, 1, w -2, h -2, self.color.background_outline)
	
	draw.SimpleRect(2, 2, w -4, h -4, self.color.background)
	
	if (text) then
		draw.SimpleText(text, "atlaschat.theme.userlist", x or 8, y or 8, self.color.generic_label, xAlign or TEXT_ALIGN_LEFT, yAlign or TEXT_ALIGN_BOTTOM)
	end
end

---------------------------------------------------------
-- Paints a generic button.
---------------------------------------------------------

theme.color.button = Color(27, 36, 48)
theme.color.button_text = Color(16, 153, 255)

function theme:PaintButton(button, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.background_outline)
	draw.SimpleRect(1, 1, w -2, h -2, self.color.button)
	
	local text, font = button:GetText(), button:GetFont()
	
	if (button.Hovered) then
		draw.SimpleText(text, font, w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(text, font, w /2, h /2, self.color.button_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
-- Paints the chatbox base panel (background).
---------------------------------------------------------

theme.color.top = Color(80, 104, 129)
theme.color.background = Color(36, 48, 64)
theme.color.background_outline = Color(68, 78, 92)

function theme:PaintPanel(w, h)
	draw.SimpleOutlined(0, 0, w, h, color_black)
	draw.SimpleOutlined(1, 1, w -2, h -2, self.color.background_outline)
	
	draw.SimpleRect(2, 2, w -4, h -4, self.color.background)
	
	self:PaintSnowFlakes(w, h)
	
	draw.SimpleText(GetHostName(), "atlaschat.theme.default.title", 8, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

---------------------------------------------------------
-- Paints the chatbox text list (where the text is).
---------------------------------------------------------

theme.color.list_background = Color(29, 38, 51)

function theme:PaintList(panel, w, h)
	if (ValidPanel(panel) and panel:IsVisible()) then
		draw.RoundedBox(4, 0, 0, w, h, self.color.background_outline)
		draw.SimpleRect(1, 1, w -2, h -2, self.color.list_background)
	end
end

---------------------------------------------------------
-- Paints the chatbox prefix.
---------------------------------------------------------

theme.color.prefix_background = Color(27, 33, 41, 255)

function theme:PaintPrefix(w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.background_outline)
	draw.SimpleRect(1, 1, w -2, h -2, self.color.prefix_background)
	
	local prefix = self.panel.prefix:GetPrefix()
	
	if (prefix) then
		draw.SimpleText(prefix, "atlaschat.theme.prefix", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
-- Paints the chatbox text entry (where you write your text).
---------------------------------------------------------

theme.color.entry_background = Color(217, 217, 217, 220)

function theme:PaintTextEntry(w, h, entry)
	entry = entry or self.panel.entry
	
	draw.RoundedBox(4, 0, 0, w, h, self.color.background_outline)
	draw.SimpleRect(1, 1, w -2, h -2, self.color.prefix_background)

	entry:DrawTextEntryText(self.color.generic_label, entry.m_colHighlight, self.color.generic_label)
end

---------------------------------------------------------
-- Paints the background of the scrollbar.
---------------------------------------------------------

function theme:PaintScrollbar(panel, w, h)
end

---------------------------------------------------------
-- Paints the scrollbar grip.
---------------------------------------------------------

theme.color.scrollbar = Color(63, 70, 81)
theme.color.scrollbar_hovered = Color(97, 104, 113)

function theme:PaintScrollbarGrip(panel, w, h)
	if (self.panel:IsVisible()) then
		if (panel.Hovered) then
			draw.RoundedBox(4, 0, 0, w, h, self.color.scrollbar_hovered)
		else
			draw.RoundedBox(4, 0, 0, w, h, self.color.scrollbar)
		end
	end
end

---------------------------------------------------------
-- Paints the up button of the scrollbar.
---------------------------------------------------------

function theme:PaintScrollbarUpButton(panel, w, h)
	if (self.panel:IsVisible()) then
		if (panel.Hovered) then
			draw.RoundedBox(4, 0, 0, w, h, self.color.scrollbar_hovered)
		else
			draw.RoundedBox(4, 0, 0, w, h, self.color.scrollbar)
		end
	
		draw.SimpleText("t", "Marlett", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
-- Paints the down button of the scrollbar.
---------------------------------------------------------

function theme:PaintScrollbarDownButton(panel, w, h)
	if (self.panel:IsVisible()) then
		if (panel.Hovered) then
			draw.RoundedBox(4, 0, 0, w, h, self.color.scrollbar_hovered)
		else
			draw.RoundedBox(4, 0, 0, w, h, self.color.scrollbar)
		end
		
		draw.SimpleText("u", "Marlett", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

theme.color.list_container_new = Color(16, 153, 255)
theme.color.list_container_hover = Color(25 +20, 32 +20, 43 +20)
theme.color.list_container_selected = Color(10, 240, 10)
theme.color.list_container_background = Color(25, 32, 43)

function theme:PaintListContainer(panel, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.background_outline)

	if (panel.Hovered) then
		draw.SimpleRect(1, 1, w -2, h -2, self.color.list_container_hover)
	else
		draw.SimpleRect(1, 1, w -2, h -2, self.color.list_container_background)
	end
	
	if (panel.selected) then
		draw.SimpleRect(1, h -2, w -2, 2, self.color.list_container_selected)
	end
	
	if (panel.new) then
		if (panel.blink <= CurTime()) then
			draw.SimpleRect(1, 1, w -2, h -2, self.color.list_container_new)
			
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
	draw.RoundedBox(4, 0, 0, w, h, self.color.background_outline)
	draw.SimpleRect(1, 1, w -2, h -2, self.color.prefix_background)
end

---------------------------------------------------------
--
---------------------------------------------------------

function theme:PaintExpressionRow(panel, w, h, offset)
	draw.RoundedBox(4, 0, 0, w, h, self.color.background_outline)
	draw.SimpleRect(1, 1, w -2, h -2, self.color.button)
	
	if (offset) then
		draw.SimpleText("Expression", "atlaschat.theme.row", 4, h /2, self.color.generic_label, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Result", "atlaschat.theme.row", offset, h /2, self.color.generic_label, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end