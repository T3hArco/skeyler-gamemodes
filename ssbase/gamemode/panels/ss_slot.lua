---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

surface.CreateFont("ss.slot.name", {font = "DeJaVu Sans", size = 9, weight = 400})

local backgroundTexture = Material("skeyler/vgui/store/icon_base.png", "noclamp smooth") 
local highlightTexture = Material("skeyler/vgui/store/icon_highlight.png", "noclamp smooth")

local color_shadow = Color(0, 0, 0, 180)
local color_background = Color(249, 249, 249, 250)

---------------------------------------------------------
--
---------------------------------------------------------

local equipSlots = {}

function SS.GetEquipSlot(id)
	return equipSlots[id]
end

function SS.GetEquipSlots()
	return equipSlots
end

local panel = {}

AccessorFunc(panel, "m_iSlot", "Slot")
AccessorFunc(panel, "m_bHightlighted", "Highlight")

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self.green = 0
	
	self:DockPadding(4, 4, 4, 4)
	self:SetZPos(-500)
	
	self.infoPanel = self:Add("Panel")
	self.infoPanel:Dock(FILL)
	self.infoPanel:SetMouseInputEnabled(true)
	self.infoPanel:SetZPos(30)
	
	self.infoPanel.offset = 0

	function self.infoPanel:Paint(w, h)
		local parent = self:GetParent()

		if (parent.Hovered or (self.Hovered or self:IsChildHovered(1) or (ValidPanel(parent.icon) and parent.icon.Hovered)) and parent.lastItem) then 
			self.offset = math.Approach(self.offset, 32, 5) 
		else 
			self.offset = math.Approach(self.offset, 0, 5) 
		end 
		
		if (ValidPanel(self.button)) then
			local y = self:GetTall() -(self.button:GetTall() *(self.offset /32))
			
			self.button:SetPos(0, y)
		end
	end
	
	function self.infoPanel:PerformLayout()
		local w = self:GetWide()
		
		if (ValidPanel(self.button)) then
			self.button:SetWide(w)
		end
	end
	
	function self.infoPanel:OnMousePressed(code)
		if (code == MOUSE_RIGHT) then
			self.tooltip_ss:EnableButton()
		end
	end
	
	self.infoPanel.button = self.infoPanel:Add("Panel")
	self.infoPanel.button:SetTall(20)
	self.infoPanel.button:SetCursor("hand")
	
	function self.infoPanel.button:Paint(w, h)
		self.color = self.Hovered and Color(33 +10, 175 +20, 234 +20, 240) or Color(33, 175, 234, 240)
		
		draw.SimpleRect(0, 0, w, h, self.color) 

		draw.SimpleText("UNEQUIP", "ss_hub_store_buttons", w /2 +1, h /2 +1, Color(0, 0, 0, 255 *0.62), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("UNEQUIP", "ss_hub_store_buttons", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	function self.infoPanel.button:OnMousePressed()
		local parent = self:GetParent():GetParent()
		
		if (parent.lastItem) then
			net.Start("SS_ItemUnequip")
				net.WriteString(parent.lastItem)
			net.SendToServer()
		end
		
		surface.PlaySound("garrysmod/ui_click.wav")
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetSlot(slot)
	self.m_iSlot = slot
	
	equipSlots[slot] = self
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Think()
	local data = SS.Gear.Get(LocalPlayer(), self.m_iSlot)
	
	if (data and data.item and data.item != "") then
		if (data.item != self.lastItem) then
			self.lastItem = data.item
			
			if (ValidPanel(self.icon)) then
				self.icon:Remove()
			end
			
			if (ValidPanel(self.toolTip)) then
				self.toolTip:Remove()
			end
		
			local item = SS.STORE.Items[data.item]
		
			self.icon = self:Add("ss_hub_store_icon")
			self.icon:Dock(FILL)
			self.icon:SetModel(item.Model)
			self.icon:SetCamPos(item.CamPos)
			self.icon:SetLookAt(item.LookAt)
			self.icon:SetFOV(item.Fov)
			self.icon:SetEquipIcon(true)
			
			self.icon.Info = item
			self.icon.PPanel = self
			
			self.toolTip = self.infoPanel:CreateToolTip()
			self.toolTip:SetSize(280, 0)
			self.toolTip:DockPadding(8, 8, 8, 8)

			local label = self.toolTip:Add("DLabel")
			label:Dock(TOP)
			label:DockMargin(0, 0, 0, 8)
			label:SetText(SS.STORE.SLOT.NAME[self.m_iSlot] .. " - " .. item.Name)
			label:SetFont("ss.tooltip.name")
			label:SetColor(color_white)
			label:SizeToContents()
			
			if (item.Colorable) then
				local colorMixer = self.toolTip:Add("DColorMixer")
				colorMixer:Dock(TOP)
				colorMixer:DockMargin(0, 0, 0, 8)
				colorMixer:SetTall(128)
				colorMixer:SetAlphaBar(false)
				
				function colorMixer:ValueChanged(color)
					self.nextUpdate = CurTime() +0.35
				end
				
				function colorMixer:Think()
					self:ConVarThink()
					
					if (self.nextUpdate and self.nextUpdate <= CurTime()) then
						local color = self:GetColor()
						
						color = Vector(color.r, color.g, color.b)
						
						net.Start("ss.store.stcstm")
							net.WriteString(item.ID)
							net.WriteString(SS.STORE.CUSTOM.COLOR)
							net.WriteVector(color)
						net.SendToServer()
						
						self.nextUpdate = nil
					end
				end
			end
			
			if (item.Model) then
				local skinAmount = !item.Bone and LocalPlayer():SkinCount() or data.entity:SkinCount()
				
				if (skinAmount > 1) then
					local slider, base = util.SliderAndLabel(self.toolTip, "Model Skin")
					base:Dock(TOP)
					base:SetTall(34)
					
					base.label:SetFont("ss.tooltip.options")
					base.label:SizeToContents()
					
					slider:SetWide(125)
					
					slider:SetMin(1)
					slider:SetMax(skinAmount)
					slider:SetValue(!item.Bone and LocalPlayer():GetSkin() or data.entity:GetSkin())
					
					function slider:OnValueChanged(value)
						self.nextUpdate = CurTime() +0.3
					end
					
					function slider:Think()
						if (self.nextUpdate and self.nextUpdate <= CurTime()) then
							local value = self:GetValue()
							
							net.Start("ss.store.stcstm")
								net.WriteString(item.ID)
								net.WriteString(SS.STORE.CUSTOM.SKIN)
								net.WriteUInt(value, 8)
							net.SendToServer()
							
							self.nextUpdate = nil
						end
					end
				end
				
				local bodyGroups = !item.Bone and LocalPlayer():GetBodyGroups() or data.entity:GetBodyGroups()
				
				for i = 1, #bodyGroups do
					local data = bodyGroups[i]
					
					local slider, base = util.SliderAndLabel(self.toolTip, "Bodygroup - " .. data.name)
					base:Dock(TOP)
					base:SetTall(34)

					base.label:SetFont("ss.tooltip.options")
					base.label:SizeToContents()
					
					slider:SetWide(125)
					slider:SetMin(0)
					slider:SetMax(#data.submodels)
					slider:SetValue(0)
					
					function slider:OnValueChanged(value)
						self.nextUpdate = CurTime() +0.3
					end
					
					function slider:Think()
						if (self.nextUpdate and self.nextUpdate <= CurTime()) then
							local value = self:GetValue()
							
							net.Start("ss.store.stcstm")
								net.WriteString(item.ID)
								net.WriteString(SS.STORE.CUSTOM.BODYGROUP)
								net.WriteUInt(data.id, 8)
								net.WriteUInt(value, 8)
							net.SendToServer()
							
							self.nextUpdate = nil
						end
					end
				end
			end
			
			self.toolTip:InvalidateLayout(true)
			self.toolTip:SizeToChildren(false, true)
		end
	else
		self.lastItem = nil
		
		local inventory = SS.Hub:GetCategory(3)
		
		inventory.preview:RemoveHat(self.m_iSlot)
		
		if (ValidPanel(self.icon)) then
			self.icon:Remove()
		end
		
		if (ValidPanel(self.toolTip)) then
			self.toolTip:Remove()
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	draw.Material(0, 0, w, h, color_background, backgroundTexture)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:PaintOver(w, h)
	if (self.m_bHightlighted) then
		self.green = math.Approach(self.green, 230, 12)
	else
		self.green = math.Approach(self.green, 0, 7)
	end
	
	if (self.green > 0) then
		draw.SimpleRect(0, 0, w, h, Color(0, 200, 0, self.green))
	end
	
	local name = SS.STORE.SLOT.NAME[self.m_iSlot]
	
	if (name) then
		surface.DisableClipping(true)
			draw.SimpleText(string.upper(name), "ss.slot.name", w +1, h +6, color_shadow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(string.upper(name), "ss.slot.name", w, h +5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		surface.DisableClipping(false)
	end
end

vgui.Register("ss.slot", panel, "EditablePanel")