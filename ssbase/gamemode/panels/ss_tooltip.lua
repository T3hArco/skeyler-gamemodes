surface.CreateFont("ss.tooltip.name", {font = "Arvil Sans", size = 24, weight = 400}) 
surface.CreateFont("ss.tooltip.options", {font = "Tahoma", size = 18, weight = 400}) 

local arrowTexture = Material("skeyler/arrow.png", "smooth")

local color_texture = Color(20, 20, 20, 254)
local color_background = Color(20, 20, 20, 254)

local panel = {}

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self:SetDrawOnTop(true)
end

function panel:Paint(w, h)	
	surface.DisableClipping(true)
		draw.Material(-32, 32 +10, 32, 32, color_texture, arrowTexture)
	surface.DisableClipping(false)
	
	draw.SimpleRect(0, 0, w, h, color_background)
end

vgui.Register("ss.tooltip", panel, "EditablePanel")

---------------------------------------------------------
--
---------------------------------------------------------

local registry = debug.getregistry()

function registry.Panel:CreateToolTip()
	if (!ValidPanel(self.tooltip_ss)) then
		self.tooltip_ss = vgui.Create("ss.tooltip")
	end
	
	self.tooltip_ss:DockPadding(8, 8, 8, 8)
	self.tooltip_ss:SetVisible(false)
	
	self.tooltip_ss.targetPanel = self
	
	function self.tooltip_ss:Think()
		local target = self.targetPanel
		
		if (ValidPanel(target)) then
			local alpha = self:GetAlpha()
			
			if (alpha > 0) then
				local w, h = target:GetSize()
				local x, y = target:LocalToScreen(w, 0)
				local h2 = self:GetTall()
				
				x = math.min(ScrW() -10, x +30)
				
				self:SetPos(x, (y +h /2) -64)
			end
		else
			self:Remove()
		end
	end
	
	function self.tooltip_ss:EnableButton()
		if (!self.stay) then
			self:MakePopup()
			
			self.button = self:Add("DImageButton")
			self.button:SetSize(16, 16)
			self.button:SetImage("icon16/circlecross.png")
			
			function self.button.DoClick()
				self:AlphaTo(0, 0.2, 0, function(tbl, panel)
					panel:SetVisible(false)
				end)
				
				self.stay = nil
				self.button:Remove()
			end
			
			function self.button:OnCursorEntered()
				self:SetColor(color_red)
			end
			
			function self.button:OnCursorExited()
				self:SetColor(color_white)
			end
			
			self.stay = true
		end
	end
	
	function self.tooltip_ss:PerformLayout()
		local w = self:GetWide()
		
		if (ValidPanel(self.button)) then
			self.button:SetPos(w -(16 +8), 8)
		end
	end
	
	return self.tooltip_ss
end

_ChangeTooltip = _ChangeTooltip or ChangeTooltip

function ChangeTooltip(panel)
	if (ValidPanel(panel.tooltip_ss) and !panel.tooltip_ss:IsVisible()) then
		panel.tooltip_ss.m_AnimList = {}
		
		panel.tooltip_ss:SetVisible(true)
		panel.tooltip_ss:SetAlpha(0)
		panel.tooltip_ss:AlphaTo(255, 0.2, 0)
	end

	_ChangeTooltip(panel)
end

_EndTooltip = _EndTooltip or EndTooltip

function EndTooltip(panel)
	if (ValidPanel(panel.tooltip_ss) and panel.tooltip_ss:IsVisible() and !panel.tooltip_ss.stay) then
		panel.tooltip_ss:AlphaTo(0, 0.2, 0, function(tbl, panel)
			panel:SetVisible(false)
		end)
	end
	
	_EndTooltip(panel)
end