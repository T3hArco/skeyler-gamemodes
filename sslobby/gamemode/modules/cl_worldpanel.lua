SS.WorldPanel = {}

local stored = {}
local object = {}
object.__index = object

AccessorFunc(object, "scale", "Scale")
AccessorFunc(object, "unique", "Unique")

---------------------------------------------------------
--
---------------------------------------------------------

function SS.WorldPanel.NewPanel(unique, scale)
	stored[unique] = stored[unique] or {}
	stored[unique][scale] = stored[unique][scale] or {}
	
	local panel = {}
	
	setmetatable(panel, object)
	
	panel:SetScale(scale or 0.1)
	panel:SetUnique(unique)
	
	table.insert(stored[unique][scale], panel)
	
	return panel
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.WorldPanel.DrawPanels(unique, screen, scale)
	if (stored[unique]) then
		local data = stored[unique][scale]
		
		for i = 1, #data do
			local panel = data[i]
	
			panel.screen = screen
	
			panel:__Paint(screen)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function SS.WorldPanel.SetMouseBounds(unique, vector)
	if (stored[unique]) then
		stored[unique].mouseBounds = vector
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:SetParent(parent)
	self.x = parent.x
	self.y = parent.y
	
	function self:SetPos(x, y)
		self.x = self.parent.x +x
		self.y = self.parent.y +y
	end
	
	self.parent = parent
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:SetPos(x, y)
	self.x, self.y = x, y
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:SetSize(w, h)
	self.w, self.h = w, h
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:Paint(x, y, w, h)
end

---------------------------------------------------------
--
---------------------------------------------------------

function object:OnMousePressed()
end

---------------------------------------------------------
--
---------------------------------------------------------

local function inBounds(mouseBounds, x, y, w, h, scale)
	if (!mouseBounds) then return false end

	local vector = mouseBounds /scale
	
	return vector.x >= x and vector.x <= x +w and vector.y >= y and vector.y <= y +h
end

function object:__Paint(screen)
	local mouseBounds = stored[self.unique].mouseBounds

	self.hovered = inBounds(mouseBounds, self.x, self.y, self.w, self.h, self.scale)
	
	if (self.hovered) then
		if (input.IsMouseDown(MOUSE_LEFT)) then
			if (!self.triggered) then
				self:OnMousePressed()
				
				self.triggered = true
			end
		else
			self.triggered = nil
		end
	end
	
	self:Paint(screen, self.x, self.y, self.w, self.h)
end