---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

surface.CreateFont("ss.notify", {font = "Helvetica LT Std Cond", size = 21, weight = 400})
surface.CreateFont("ss.notify.blur", {font = "Helvetica LT Std Cond", size = 21, weight = 400, blursize = 2})

local notifications = {}

local panel = {}

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self:SetDrawOnTop(true)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetText(text, color)
	self.label = self:Add("DLabel")
	self.label:SetText(text)
	self.label:SetFont("ss.notify")
	self.label:SetColor(color)
	self.label:SizeToContents()

	local w, h = self.label:GetSize()
	
	self:SetSize(w, h)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetTime(time)
	self:AlphaTo(0, 0.6, time, function(tbl, panel)
		table.remove(notifications, panel.id)
		
		panel:Remove()
		
		timer.Simple(0.1, function()
			local y = ScrH() *0.9
			
			for i = 0, #notifications do
				local panel = notifications[#notifications -i]
				
				if (ValidPanel(panel)) then
					local x = panel:GetPos()
		
					panel:MoveTo(x, y, 1, 0, 0.7)
		
					y = y -(panel:GetTall() +8)
				end
			end
		end)
	end)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetIcon(icon)
	local image = self:Add("DImage")
	image:SetPos(0, 0)
	image:SetSize(32, 32)
	image:SetImage(icon)
	
	self:SetTall(32)
	self:SetWide(image:GetWide() +self.label:GetWide() +14)
	
	self.label:SetPos(image:GetWide() +14, image:GetTall() /2 -self.label:GetTall() /2)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	local text, font, color, x, y = self.label:GetText(), self.label:GetFont(), self.label:GetTextColor(), self.label:GetPos()
	
	draw.SimpleText(text, font .. ".blur", x, y, Color(color.r, color.g, color.b, 80), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

vgui.Register("ss.notification", panel, "Panel")

---------------------------------------------------------
--
---------------------------------------------------------

function SS.Notify(text, color, time, image)
	local notify = vgui.Create("ss.notification")
	notify:SetText(text, color)
	notify:SetTime(time)
	notify:SetAlpha(0)
	notify:AlphaTo(255, 0.6, 0)
	
	if (image) then
		notify:SetIcon(image)
	end
	
	notify:SetPos(ScrW() /2 -notify:GetWide() /2, ScrH() *0.92)
	
	panel.id = table.insert(notifications, notify)

	local y = ScrH() *0.9
	
	for i = 0, #notifications do
		local panel = notifications[#notifications -i]
		
		if (ValidPanel(panel)) then
			local x = panel:GetPos()

			panel:MoveTo(x, y, 1, 0, 0.7)

			y = y -(panel:GetTall() +8)
		end
	end
end