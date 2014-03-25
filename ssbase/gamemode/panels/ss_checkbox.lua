---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

local panel = {}

local color_outline = Color(243, 243, 243, 100)
local color_outline2 = Color(243, 243, 243, 20)
local color_background = Color(30, 30, 30, 250)
local checkedTexture = Material("icon16/tick.png")

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	local checked = self:GetChecked()
	
	draw.SimpleRect(0, 0, w, h, color_background)
	draw.SimpleOutlined(1, 1, w -2, h -2, color_outline)
	draw.SimpleOutlined(2, 2, w -4, h -4, color_outline2)
	
	if (checked) then
		draw.Material(w /2 -8, h /2 -8, 16, 16, color_white, checkedTexture)
	end
end

vgui.Register("ss.checkbox", panel, "DCheckBox")

---------------------------------------------------------
--
---------------------------------------------------------

local color_shadow = Color(0, 0, 0, 200)

function util.CheckboxAndLabel(parent, text)
	local base = vgui.Create("Panel")
	base:SetParent(parent)
	
	base.label = base:Add("DLabel")
	base.label:SetText(text)
	base.label:SetFont("ss.settings.label")
	base.label:SetColor(color_white)
	base.label:SetExpensiveShadow(1, color_shadow)
	base.label:SizeToContents()
	
	base.checkbox = base:Add("ss.checkbox")
	base.checkbox:SetSize(24, 24)

	function base:PerformLayout()
		local children = self:GetChildren()
		local height = 0
		
		for k, child in pairs(children) do
			height = height +child:GetTall()
		end
		
		self:SetTall(height +16)
		
		local w, h = self:GetSize()
		
		self.label:SetPos(0, h /2 -self.label:GetTall() /2)
		self.checkbox:SetPos(w -(self.checkbox:GetWide() +28), h /2 -self.checkbox:GetTall() /2)
	end
	
	return base.checkbox, base
end