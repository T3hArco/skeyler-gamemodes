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
theme.unique = "simple"

-- A pretty name for this theme.
theme.name = "Simple"

-- Holds all the colors.
theme.color = {}

-- The color of the text selection.
theme.color.selection = Color(235, 235, 235, 80)

---------------------------------------------------------
-- Called when you change the theme.
---------------------------------------------------------

function theme:OnThemeChange()
	surface.CreateFont("atlaschat.theme.default.title", {font = "Roboto Lt", size = 20, weight = 400})
	surface.CreateFont("atlaschat.theme.prefix", 		{font = "Roboto", size = 16, weight = 400})
	surface.CreateFont("atlaschat.theme.list.name", 	{font = "Arial", size = 14, weight = 800})
	
	self.panel:DockPadding(0, 8, 0, 0)
	self.panel:InvalidateLayout()
end

---------------------------------------------------------
-- Paints the chatbox base panel (background).
---------------------------------------------------------

function theme:PaintPanel(w, h)
end

---------------------------------------------------------
-- Paints the chatbox text list (where the text is).
---------------------------------------------------------

function theme:PaintList(panel, w, h, list)
	if (ValidPanel(panel) and panel:IsVisible() and !list:GetBottomUp()) then
		draw.SimpleRect(0, 0, w, h, self.color.list_background)
	end
end

---------------------------------------------------------
-- Paints the chatbox prefix.
---------------------------------------------------------

theme.color.prefix_background = Color(0, 0, 0, 235)

function theme:PaintPrefix(w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.prefix_background)

	local prefix = self.panel.prefix:GetPrefix()
	
	if (prefix) then
		draw.SimpleText(prefix, "atlaschat.theme.prefix", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
-- Paints the chatbox text entry (where you write your text).
---------------------------------------------------------

function theme:PaintTextEntry(w, h, entry)
	entry = entry or self.panel.entry
	
	DTextEntry.Paint(entry, w, h)
end

---------------------------------------------------------
--
---------------------------------------------------------

function theme:PaintIconHolder(panel, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.prefix_background)
end