local panel = {}

local color_line = Color(255, 255, 255, 120)
local color_knob_inner = Color(39, 207, 255, 255)
local color_background = Color(30, 30, 30, 250)
local checkedTexture = Material("icon16/tick.png")

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	function self.Knob:Paint(w, h)
		draw.RoundedBox(8, 0, 0, w, h, color_white)
		draw.RoundedBox(8, 1, 1, w -2, h -2, color_knob_inner)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	draw.SimpleRect(0, h /2 -1, w, 2, color_line)
end

vgui.Register("ss.slider", panel, "DSlider")

---------------------------------------------------------
--
---------------------------------------------------------

local color_shadow = Color(0, 0, 0, 200)

function util.SliderAndLabel(parent, text)
	local base = vgui.Create("Panel")
	base:SetParent(parent)
	
	base.label = base:Add("DLabel")
	base.label:SetText(text)
	base.label:SetFont("ss.settings.label")
	base.label:SetColor(color_white)
	base.label:SetExpensiveShadow(1, color_shadow)
	base.label:SizeToContents()
	
	base.slider = base:Add("ss.slider")
	base.slider:SetSize(300, 24)

	function base:PerformLayout()
		if (self.autoSize) then
			local children = self:GetChildren()
			local height = 0
			
			for k, child in pairs(children) do
				height = height +child:GetTall()
			end
			
			self:SetTall(height +16)
		end
		
		local w, h = self:GetSize()
		
		self.label:SetPos(0, h /2 -self.label:GetTall() /2)
		self.slider:SetPos(w -(self.slider:GetWide() +(self.autoSize and 28 or 0)), h /2 -self.slider:GetTall() /2)
	end
	
	return base.slider, base
end