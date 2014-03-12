surface.CreateFont("ss.slider.text", {font = "DeJaVu Sans", size = 12, weight = 400})

local panel = {}

local color_line = Color(255, 255, 255, 120)
local color_knob_inner = Color(39, 207, 255, 255)
local color_background = Color(30, 30, 30, 250)
local checkedTexture = Material("icon16/tick.png")

AccessorFunc(panel, "m_iMin", "Min")
AccessorFunc(panel, "m_iMax", "Max")
AccessorFunc(panel, "m_iRange", "Range")
AccessorFunc(panel, "m_iValue", "Value")
AccessorFunc(panel, "m_iDecimals", "Decimals")
AccessorFunc(panel, "m_fFloatValue", "FloatValue")

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self:SetMin(2)
	self:SetMax(10)
	self:SetDecimals(0)
	
	local min = self:GetMin()
	
	self.Dragging = true
	self.Knob.Depressed = true
	
	self:SetValue(min)
	self:SetSlideX(self:GetFraction())
	
	self.Dragging = false
	self.Knob.Depressed = false
	
	function self.Knob:Paint(w, h)
		draw.RoundedBox(8, 0, 0, w, h, color_white)
		draw.RoundedBox(8, 1, 1, w -2, h -2, color_knob_inner)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetMinMax(min, max)
	self:SetMin(min)
	self:SetMax(max)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetValue(value)
	value = math.Round(math.Clamp(tonumber(value) or 0, self:GetMin(), self:GetMax()), self.m_iDecimals)
	
	self.m_iValue = value
	
	self:SetFloatValue(value)
	self:OnValueChanged(value)
	self:SetSlideX(self:GetFraction())
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:GetFraction()
	return (self:GetFloatValue() -self:GetMin()) /self:GetRange()
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:GetRange()
	return (self:GetMax() -self:GetMin())
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:TranslateValues(x, y)
	self:SetValue(self:GetMin() +(x *self:GetRange()))
	
	return self:GetFraction(), y
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:OnValueChanged(value)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	draw.SimpleRect(0, h /2 -1, w, 2, color_line)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:PaintOver(w, h)
	surface.DisableClipping(true)
		draw.SimpleText(self:GetValue(), "ss.slider.text", self.Knob.x -1 +self.Knob:GetWide() /2 +1, self.Knob.y -9, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(self:GetValue(), "ss.slider.text", self.Knob.x -1 +self.Knob:GetWide() /2, self.Knob.y -10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.DisableClipping(false)
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

		if (self.autoSize) then
			self.slider:SetPos(w -(self.slider:GetWide() +28), h /2 -self.slider:GetTall() /2)
		else
			self.slider:SetWide(w -(self.label:GetWide() +8))
			self.slider:SetPos(self.label:GetWide() +8, h /2 -self.slider:GetTall() /2)
		end
	end
	
	return base.slider, base
end