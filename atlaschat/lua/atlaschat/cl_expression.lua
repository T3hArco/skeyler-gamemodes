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

atlaschat.expression = {}

local stored = {}
local object = {}
object.__index = object

---------------------------------------------------------
-- Creates a new expression.
---------------------------------------------------------

function atlaschat.expression.New(text)
	local expression = {}
	
	expression.text = text

	setmetatable(expression, object)
	
	table.insert(stored, expression)

	return expression
end

---------------------------------------------------------
-- Returns all the stored expressions.
---------------------------------------------------------

function atlaschat.expression.GetStored()
	return stored
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:GetPlayer()
	return self.player
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:GetExpression()
	return self.text
end

---------------------------------------------------------
--
---------------------------------------------------------

local function ExtractColor(color)
	if (!color or color == "") then
		return color_white
	else
		if (string.sub(color, 0, 2) == "c=") then
			local info = string.Explode(",", string.sub(color, 3))

			if (info) then
				local r, g, b = tonumber(info[1]) or 0, tonumber(info[2]) or 0, tonumber(info[3]) or 0
				
				return Color(r, g, b)
			end
		else
			return color_white
		end
	end
end

---------------------------------------------------------
-- Emoticons.
---------------------------------------------------------

local emoticons = {}

emoticons[":)"] = "icon16/emoticon_smile.png"
emoticons[":D"] = "icon16/emoticon_happy.png"
emoticons[":O"] = "icon16/emoticon_surprised.png"
emoticons[":p"] = "icon16/emoticon_tongue.png"
emoticons[":P"] = "icon16/emoticon_tongue.png"
emoticons[":("] = "icon16/emoticon_unhappy.png"
emoticons["garry"] = {"atlaschat/emoticons/garry.png", 64, 64}
emoticons["gaben"] = {"atlaschat/emoticons/gaben.png", 64, 64}

emoticons[":smile:"] = "icon16/emoticon_smile.png"
emoticons[":online:"] = "icon16/status_online.png"
emoticons[":tongue:"] = "icon16/emoticon_tongue.png"
emoticons[":offline:"] = "icon16/status_offline.png"
emoticons[":unhappy:"] = "icon16/emoticon_unhappy.png"
emoticons[":suprised:"] = "icon16/emoticon_surprised.png"
emoticons[":exclamation:"] = "icon16/exclamation.png"
emoticons[":information:"] = "icon16/information.png"

for match, data in pairs(emoticons) do
	local expression = atlaschat.expression.New(match)

	expression.noPattern = true
	
	function expression:Execute(base)
		local type = type(data)
		local image = base:Add("DImage")
		
		if (type == "table") then
			image:SetImage(data[1])
			image:SetSize(data[2], data[3])
		else
			image:SetImage(data)
			image:SetSize(16, 16)
		end

		image:SetToolTip(self.text)
		image:SetMouseInputEnabled(true)
		
		image.toolTip = self.text
		
		function image:OnCopiedText()
			return self.toolTip
		end
		
		return image
	end
	
	function expression:GetExample(base)
		return self.text, self:Execute(base)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<noparse>(.-)</noparse>")

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("<red>This would be a red text</red>")
	label:SetSkin("atlaschat")
	label:SizeToContents()
	
	return "<noparse><red>This would be a red text</red></noparse>", label
end

---------------------------------------------------------
-- URL.
---------------------------------------------------------

local color_url = Color(1, 192, 253)
local color_url_visited = Color(2, 107, 141)
local color_url_visited_line = Color(255, 0, 0)

local expression = atlaschat.expression.New("<url>%s*(https?://[%w-_%.%?%.:/%+=&]+)%s*</url>")

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_url)
	label:SizeToContents()
	
	label.cursor = true
	
	function label:PaintOver(w, h)
		surface.SetDrawColor(self.visited and color_url_visited_line or color_url)
		surface.DrawLine(0, h -1, w, h -1)
	end
	
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
			gui.OpenURL(self:GetText())
			
			self:SetColor(color_url_visited)
			
			self.visited = true
		end
		
		self.wasPressed = nil
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("http://www.youtube.com")
	label:SetColor(color_url)
	label:SizeToContents()
	
	label.cursor = true
	
	function label:PaintOver(w, h)
		surface.SetDrawColor(self.visited and color_url_visited_line or color_url)
		surface.DrawLine(0, h -1, w, h -1)
	end
	
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
			gui.OpenURL(self:GetText())
			
			self:SetColor(color_url_visited)
			
			self.visited = true
		end
		
		self.wasPressed = nil
	end
	
	return "<url>http://www.youtube.com</url>", label
end

---------------------------------------------------------
-- Text color. <c=r,g,b> Text </c>
---------------------------------------------------------

local expression = atlaschat.expression.New("<c=(%d+,%d+,%d+)>(.-)</c>")

function expression:Execute(base, color, text)
	local color = string.Explode(",", color)
	color = Color(color[1], color[2], color[3])

	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color)
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a red colored text")
	label:SetColor(color_red)
	label:SizeToContents()
	
	return "<c=255,0,0>This is a red colored text</c>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<avatar>")

expression.noPattern = true

function expression:Execute(base)
	local player = self:GetPlayer()
	local size = atlaschat.smallAvatar:GetBool() and 24 or 32
	
	local avatar = vgui.Create("AvatarImage")
	avatar:SetParent(base)
	avatar:SetSize(size, size)
	avatar:SetPlayer(player, size)
	
	function avatar:OnCopiedText()
		return "<avatar>"
	end
	
	return avatar
end

function expression:GetExample(base)
	local size = atlaschat.smallAvatar:GetBool() and 24 or 32
	
	local avatar = base:Add("AvatarImage")
	avatar:SetSize(size, size)
	avatar:SetPlayer(LocalPlayer(), size)
	
	return "<avatar>", avatar
end

local expression = atlaschat.expression.New("<avatar=(STEAM_[0-5]:[01]:%d+)>")

function expression:Execute(base, steamID)
	if (steamID) then
		local size = atlaschat.smallAvatar:GetBool() and 24 or 32
		local communityID = util.SteamIDTo64(steamID)
		
		local avatar = vgui.Create("AvatarImage")
		avatar:SetParent(base)
		avatar:SetSize(size, size)
		avatar:SetSteamID(communityID, size)
		
		avatar.steamID = steamID

		function avatar:OnCopiedText()
			return "<avatar=" .. self.steamID .. ">"
		end
		
		return avatar
	end
end

function expression:GetExample(base)
	local size = atlaschat.smallAvatar:GetBool() and 24 or 32
	
	local avatar = base:Add("AvatarImage")
	avatar:SetSize(size, size)
	avatar:SetPlayer(LocalPlayer(), size)
	
	return "<avatar=" .. LocalPlayer():SteamID() .. ">", avatar
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<font=(.-)>(.-)</font>")

function expression:Execute(base, font, text)
	local ok = pcall(draw.SimpleText, text, font, 0, 0, color_transparent, 1, 1)
	local font = font
	
	if (!ok) then
		local eugh = font
		
		timer.Simple(0.05, function() chat.AddText(":exclamation: The font \"" .. eugh .. "\" is invalid!") end)
		
		font = atlaschat.font:GetString()
	end
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetFont(font)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a different font")
	label:SetSkin("atlaschat")
	label:SetFont("DermaDefaultBold")
	label:SizeToContents()
	
	return "<font=DermaDefaultBold>This is a different font</font>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("OverRustle")

expression.noPattern = true

function expression:Execute(base)
	local image = base:Add("DImage")
	image:SetImage("atlaschat/emoticons/overrustle.png")
	image:SetSize(32, 32)
	image:SetToolTip("OverRustle")
	image:SetMouseInputEnabled(true)
	
	function image:Paint(w, h)
		if (vgui.GetHoveredPanel() == self) then
			local x = math.sin(CurTime() *80) *3
			local y = math.cos(CurTime() *60) *1.5
			
			self:PaintAt(x, y, self:GetWide(), self:GetTall())
		else
			self:PaintAt(0, 0, self:GetWide(), self:GetTall())
		end
	end
	
	function image:OnCopiedText()
		return "OverRustle"
	end
	
	return image
end

function expression:GetExample(base)
	return "OverRustle", self:Execute(base)
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<lg>(.-)</lg>")

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_limegreen)
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a limegreen text")
	label:SetColor(color_limegreen)
	label:SizeToContents()

	return "<lg>This is a limegreen text</lg>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<spoiler>(.-)</spoiler>")

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	label:SetMouseInputEnabled(true)
	
	function label:PaintOver(w, h)
		if (!self.clicked) then
			draw.SimpleRect(0, 0, w, h, color_black)
		end
	end
	
	function label:OnMousePressed()
		self.clicked = true
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a spoiler text")
	label:SetSkin("atlaschat")
	label:SizeToContents()
	label:SetMouseInputEnabled(true)
	
	function label:PaintOver(w, h)
		if (!self.clicked) then
			draw.SimpleRect(0, 0, w, h, color_black)
		end
	end
	
	function label:OnMousePressed()
		self.clicked = true
	end

	return "<spoiler>This is a spoiler text</spoiler>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<hsv>(.-)</hsv>")

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	
	label.color = color_white
	
	function label:Think()
		local hue = math.abs(math.sin(CurTime() *0.9) *335)

		self.color = HSVToColor(hue, 1, 1)
		
		self:SetColor(self.color)
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a hsv text")
	label:SetColor(color_white)
	label:SizeToContents()

	label.color = color_white
	
	function label:Think()
		local hue = math.abs(math.sin(CurTime() *0.9) *335)

		self.color = HSVToColor(hue, 1, 1)
		
		self:SetColor(self.color)
	end

	return "<hsv>This is a hsv text</hsv>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<flash%s*(c?=?%d-,-%d-,-%d-)>(.-)</flash>")

function expression:Execute(base, color, text)
	color = ExtractColor(color)
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color)
	label:SizeToContents()
	
	local hue, saturation = ColorToHSV(color)
	
	label.hue = hue
	label.color = saturation
	label.saturation = saturation
	
	function label:Think()
		local value = math.abs(math.sin(CurTime() *0.9) *1)

		self.color = HSVToColor(self.hue, self.saturation, value)
		
		self:SetColor(self.color)
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a red flashing text")
	label:SetColor(color_white)
	label:SizeToContents()

	local hue, saturation = ColorToHSV(color_red)
	
	label.hue = hue
	label.color = saturation
	label.saturation = saturation
	
	function label:Think()
		local value = math.abs(math.sin(CurTime() *0.9) *1)

		self.color = HSVToColor(self.hue, self.saturation, value)
		
		self:SetColor(self.color)
	end

	return "<flash c=255,0,0>This is a red flashing text</flash>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<vscan%s*(c?=?%d-,-%d-,-%d-)>(.-)</vscan>")

function expression:Execute(base, color, text)
	color = ExtractColor(color)
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()

	label.scanColor = color
	
	function label:PaintOver(w, h)
		local y = -h +(h *2) *((CurTime() %1) ^2)

		draw.SimpleRect(0, y, w, h, self.scanColor)
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a vertical scan")
	label:SetSkin("atlaschat")
	label:SizeToContents()

	label.scanColor = color_red
	
	function label:PaintOver(w, h)
		local y = -h +(h *2) *((CurTime() *0.8 %1) ^2)

		draw.SimpleRect(0, y, w, h, self.scanColor)
	end

	return "<vscan c=255,0,0>This is a vertical scan</vscan>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<hscan%s*(c?=?%d-,-%d-,-%d-)>(.-)</hscan>")

function expression:Execute(base, color, text)
	color = ExtractColor(color)
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	
	label.scanX = -4
	label.scanColor = color
	
	function label:PaintOver(w, h)
		local width = math.max(1, w *0.2)
		local x = (CurTime() %1) ^2 *(w +width) -width
		
		draw.SimpleRect(x, 0, width, h, self.scanColor)
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a horizontal scan")
	label:SetSkin("atlaschat")
	label:SizeToContents()

	label.scanColor = color_red
	
	function label:PaintOver(w, h)
		local width = math.max(1, w *0.2)
		local start = (CurTime() %1) ^2 *(w +width) -width
	
		draw.SimpleRect(start, 0, width, h, self.scanColor)
	end

	return "<hscan c=255,0,0>This is a horizontal scan</hscan>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<reverse>(.-)</reverse>")

function expression:Execute(base, text)
	local text = string.utf8reverse(text)
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetSkin("atlaschat")
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local text = string.utf8reverse("This is a reversed text")
	
	local label = base:Add("DLabel")
	label:SetText(text)
	label:SetSkin("atlaschat")
	label:SizeToContents()

	return "<reverse>This is a reversed text</reverse>", label
end