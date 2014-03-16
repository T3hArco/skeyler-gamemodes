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
theme.unique = "classic"

-- A pretty name for this theme.
theme.name = "Classic White"

-- Holds all the colors.
theme.color = {}

-- The color of the text selection.
theme.color.selection = Color(0, 0, 255, 140)

-- The "X" button on the private chat card.
theme.color.privatecard_close = color_black
theme.color.privatecard_close_hover = color_red

-- A generic label color.
theme.color.generic_label = color_black

---------------------------------------------------------
-- Called when you change the theme.
---------------------------------------------------------

function theme:OnThemeChange()
	surface.CreateFont("atlaschat.theme.default.title", {font = "Roboto Lt", size = 20, weight = 400})
	surface.CreateFont("atlaschat.theme.prefix", 		{font = "Roboto", size = 16, weight = 400})
	surface.CreateFont("atlaschat.theme.list.name", 	{font = "Arial", size = 14, weight = 800})
	
	self.panel:DockPadding(11, 48, 11, 11)
	self.panel:InvalidateLayout()
end

---------------------------------------------------------
-- Paints a generic background.
---------------------------------------------------------

theme.color.generic_background = Color(245, 245, 245, 255)
theme.color.generic_background_dark = Color(217, 217, 217, 255)

function theme:PaintGenericBackground(panel, w, h, text, x, y, xAlign, yAlign)
	draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
	draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.background)
	
	if (text) then
		draw.SimpleText(text, "atlaschat.theme.userlist", x or 8, y or 8, self.color.generic_label, xAlign or TEXT_ALIGN_LEFT, yAlign or TEXT_ALIGN_BOTTOM)
	end
end

---------------------------------------------------------
-- Paints a generic button.
---------------------------------------------------------

theme.color.button = Color(250, 250, 250)
theme.color.button_hovered = Color(210, 210, 210, 220)

function theme:PaintButton(button, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
	draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.background)
	
	if (button.Hovered) then
		draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.button_hovered)
	end
	
	local text, font = button:GetText(), button:GetFont()
	
	draw.SimpleText(text, font, w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

---------------------------------------------------------
-- Paints the chatbox base panel (background).
---------------------------------------------------------

theme.color.top = Color(80, 104, 129)
theme.color.background = Color(250, 250, 250)

function theme:PaintPanel(w, h)
	draw.RoundedBoxEx(4, 1, 35, w -2, h -35, self.color.list_background, false, false, true, true)
	draw.RoundedBoxEx(4, 1, 35, w -3, h -36, self.color.background, false, false, true, true)
	
	self:PaintSnowFlakes(w, h)
	
	draw.RoundedBoxEx(4, 0, 0, w, 36, self.color.top, true, true, false, false)

	draw.SimpleText(GetHostName(), "atlaschat.theme.default.title", 8, 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

---------------------------------------------------------
-- Paints the chatbox text list (where the text is).
---------------------------------------------------------

theme.color.list_background = Color(210, 210, 210)

function theme:PaintList(panel, w, h)
	if (ValidPanel(panel) and panel:IsVisible()) then
		draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
		draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.background)
	end
end

---------------------------------------------------------
-- Paints the chatbox prefix.
---------------------------------------------------------

theme.color.prefix_background = Color(217, 217, 217, 255)

function theme:PaintPrefix(w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
	draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.background)
	
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
	
	draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
	draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.background)
	
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

theme.color.scrollbar = Color(224, 228, 242)

function theme:PaintScrollbarGrip(panel, w, h)
	if (self.panel:IsVisible()) then
		draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
		draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.scrollbar)
	end
end

---------------------------------------------------------
-- Paints the up button of the scrollbar.
---------------------------------------------------------

theme.color.scrollbar_buttonup = Color(162, 163, 162, 40)

function theme:PaintScrollbarUpButton(panel, w, h)
	if (self.panel:IsVisible()) then
		draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
		draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.scrollbar)
	
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
		draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
		draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.scrollbar)
		
		draw.SimpleText("u", "Marlett", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

theme.color.list_container_new = Color(0, 0, 0, 160)
theme.color.list_container_hover = Color(210, 210, 210, 220)
theme.color.list_container_selected = Color(0, 0, 0, 255)
theme.color.list_container_background = Color(250, 250, 250)

function theme:PaintListContainer(panel, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
	draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.background)
	
	if (panel.Hovered) then
		draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.list_container_hover)
	end
	
	if (panel.selected) then
		draw.SimpleRect(0, h -2, w, 2, self.color.list_container_selected)
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
	draw.RoundedBox(4, 0, 0, w, h, self.color.list_background)
	draw.RoundedBox(4, 1, 1, w -2, h -2, self.color.background)
end