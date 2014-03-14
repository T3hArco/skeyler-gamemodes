--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

surface.CreateFont("sa_itemInfo_Name", {
	font = "Roboto",
	size = 20,
	weight = 1000
})

surface.CreateFont("sa_itemInfo_Requirements", {
	font = "Roboto",
	size = 14,
	weight = 1000
})

local generatedIcons = {}
local textureLines = surface.GetTextureID("sassilization/stripedBG")
local textureGradient = surface.GetTextureID("gui/gradient_up")
local texw, texh = 32, 32
local tex = Material("sassilization/icons/gold.png")
local tex2 = Material("sassilization/icons/food.png")
local tex3 = Material("sassilization/icons/iron.png")
local tex4 = Material("sassilization/icons/supply.png")
local textureWidth, textureHeight = 1024, 256
local arrowTexture = Material("vgui/arrow")
local hoverPanels = {}

local PANEL = {}

function PANEL:Init()
	self.Selected = false
	
	self.model = self:Add("SpawnIcon")
	self.model:SetMouseInputEnabled(false)
end

function PANEL:SetItem(Item, ItemTable, Type)
	self.Item = Item
	self.CType = Type
	self.ItemTable = ItemTable
	
	local model = istable(ItemTable.Model) and ItemTable.Model[1] or ItemTable.Model
	
	self.model:InvalidateLayout(true)
	self.model:SetModel(model)

	if (!generatedIcons[string.lower(model)]) then
		local iconData = {}
		
		iconData.cam_pos = ItemTable.camPos
		iconData.cam_ang = ItemTable.angle
		iconData.cam_fov = ItemTable.fov
	
		self.model:RebuildSpawnIconEx(iconData)
		
		generatedIcons[string.lower(model)] = true
	end
	
	--[[
	if (Type == "Buildings") then
		if(GAMEMODE.BuildingTextures[Item]) then
			self.TexID = surface.GetTextureID(GAMEMODE.BuildingTextures[Item])
		else
			print("Missing Building Texture: ", Item, "\n")
		end
	elseif (Type == "Units") then
		if(GAMEMODE.UnitTextures[Item]) then
			self.TexID = surface.GetTextureID(GAMEMODE.UnitTextures[Item])
		else
			print("Missing Unit Texture: ", Item, "\n")
		end
		
	end
	]]
end

function PANEL:IsBuilding()
	return self.CType == "Buildings"
end

function PANEL:Select(Bool)
	self.Selected = Bool
	surface.PlaySound(GAMEMODE.ButtonRelease)
end

function PANEL:Paint(w, h)
	surface.SetMaterial(Material("sassilization/q_e_icon_background_54x54.png"))
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect( 0, 0, w, h )
end

function PANEL:OnCursorEntered()
	for k, panel in pairs(hoverPanels) do
		if (ValidPanel(panel)) then
			panel:Remove()
		end
	end
	
	hoverPanels = {}
	
	local data = self.ItemTable
	local x, y = self:LocalToScreen()

	local hoverPanel = vgui.Create("DPanel")
	hoverPanel:SetPos(x -90, y -38)
	x = 0
	surface.SetFont("sa_itemInfo_Name")
	textWidth = surface.GetTextSize(data.Name)
	x = x + textWidth +22
	if (data.Food and data.Food > 0) then
		surface.SetFont("sa_itemInfo_Requirements")
		textWidth = surface.GetTextSize(data.Food)
		x = x +40 +textWidth
	end
	if (data.Iron and data.Iron > 0) then
		surface.SetFont("sa_itemInfo_Requirements")
		textWidth = surface.GetTextSize(data.Iron)
		x = x +40 +textWidth
	end
	if (data.Gold and data.Gold > 0) then
		surface.SetFont("sa_itemInfo_Requirements")
		textWidth = surface.GetTextSize(data.Gold)
		x = x +40 +textWidth
	end
	if (data.Supply and data.Supply > 0) then
		surface.SetFont("sa_itemInfo_Requirements")
		textWidth = surface.GetTextSize(data.Supply)
		x = x +40 +textWidth
	end

	hoverPanel:SetSize(x, 32)
	
	local totalWidth, u, v, uw, vh, w, h, x, y, x1, y1, textWidth
	local scale = 1
	
	function hoverPanel:Paint(w, h)
		DisableClipping(true)
		
		surface.SetMaterial(Material("sassilization/q_e_hover.png"))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect( 0, 0, w, h )
		
		totalWidth = 540
	
		u, v = 288 /textureWidth, 0 --U, V Coord
		uw, vh = 720, 80 --U width, V height
		w, h = totalWidth, 60 --width, height
		x, y = -10, 0 --screen x, screen y
		
		surface.SetDrawColor(color_white)

		hoverPanel.name = hoverPanel:Add("DLabel")
		hoverPanel.name:SetPos(5, 8)
		hoverPanel.name:SetText(data.Name)
		hoverPanel.name:SetFont("sa_itemInfo_Name")
		hoverPanel.name:SetColor(color_white)
		hoverPanel.name:SetExpensiveShadow(1.8, Color(0, 0, 0, 240))
		hoverPanel.name:SizeToContents()
		hoverPanel.name:SetWide(hoverPanel.name:GetWide() +12)
		
		table.insert(hoverPanels, hoverPanel)

		x = x + hoverPanel.name:GetWide() +17
		

		color_red = Color(255, 0, 0, 255)
		-- Food cost.
		if (data.Food and data.Food > 0) then
			surface.SetMaterial(tex2)
			w, h = 32, 32
		
			surface.DrawTexturedRect(x, y, w * scale, h * scale)
			
			draw.SimpleText(data.Food, "sa_itemInfo_Requirements", x +36 *scale, y +20 *scale, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			if LocalPlayer():GetEmpire():GetFood() >= data.Food then
				draw.SimpleText(data.Food, "sa_itemInfo_Requirements", x +35 *scale, y +19 *scale, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(data.Food, "sa_itemInfo_Requirements", x +35 *scale, y +19 *scale, color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			
			surface.SetFont("sa_itemInfo_Requirements")
	
			textWidth = surface.GetTextSize(data.Food)
			
			x = x +40 +textWidth
		end
		
		-- Iron cost.
		if (data.Iron and data.Iron > 0) then
			surface.SetMaterial(tex3)

			surface.DrawTexturedRect(x, y, w * scale, h * scale)
			
			draw.SimpleText(data.Iron, "sa_itemInfo_Requirements", x +36 *scale, y +20 *scale, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			if LocalPlayer():GetEmpire():GetIron() >= data.Iron then
				draw.SimpleText(data.Iron, "sa_itemInfo_Requirements", x +35 *scale, y +19 *scale, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(data.Iron, "sa_itemInfo_Requirements", x +35 *scale, y +19 *scale, color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			
			surface.SetFont("sa_itemInfo_Requirements")
	
			textWidth = surface.GetTextSize(data.Iron)
			
			x = x +40 +textWidth
		end
		
		-- Gold cost.
		if (data.Gold and data.Gold > 0) then
			surface.SetMaterial(tex)
			
			surface.DrawTexturedRect(x, y, w * scale, h * scale)
			
			draw.SimpleText(data.Gold, "sa_itemInfo_Requirements", x +36 *scale, y +20 *scale, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			if LocalPlayer():GetEmpire():GetGold() >= data.Gold then
				draw.SimpleText(data.Gold, "sa_itemInfo_Requirements", x +35 *scale, y +19 *scale, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(data.Gold, "sa_itemInfo_Requirements", x +35 *scale, y +19 *scale, color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			
			surface.SetFont("sa_itemInfo_Requirements")
	
			textWidth = surface.GetTextSize(data.Gold)
			
			x = x +40 +textWidth
		end
		
		-- Supply cost.
		if (data.Supply and data.Supply > 0) then
			surface.SetMaterial(tex4)
			w, h = 32, 32
			
			surface.DrawTexturedRect(x, y, w * scale, h * scale)
			
			draw.SimpleText(data.Supply, "sa_itemInfo_Requirements", x +36 *scale, y +23, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			if (LocalPlayer():GetEmpire():GetSupply() - LocalPlayer():GetEmpire():GetSupplied()) >= data.Supply then
				draw.SimpleText(data.Supply, "sa_itemInfo_Requirements", x +35 *scale, y +22, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(data.Supply, "sa_itemInfo_Requirements", x +35 *scale, y +22, color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			
			surface.SetFont("sa_itemInfo_Requirements")
	
			textWidth = surface.GetTextSize(data.Supply)
		end
		
		DisableClipping(false)
	end
end

function PANEL:OnCursorExited()
	for k, panel in pairs(hoverPanels) do
		if (ValidPanel(panel)) then
			panel:Remove()
		end
	end
	
	hoverPanels = {}
end

function PANEL:OnMouseReleased(MouseCode)
	if (MouseCode == MOUSE_LEFT) then
		self:GetParent():Select(self.Item)
	end
end

function PANEL:PerformLayout()
	local w, h = self:GetSize()
	
	self.model:SetSize(w - 10, h - 10)
	self.model:SetPos(5, 5)
end

vgui.Register("sa_menuitem", PANEL, "EditablePanel")

hook.Add("OnBuildingMenuClose", "sa_CleanHoverPanels_Buildings", function()
	for k, panel in pairs(hoverPanels) do
		if (ValidPanel(panel)) then
			panel:Remove()
		end
	end
	
	hoverPanels = {}
end)

hook.Add("OnUnitMenuClose", "sa_CleanHoverPanels_Units", function()
	for k, panel in pairs(hoverPanels) do
		if (ValidPanel(panel)) then
			panel:Remove()
		end
	end
	
	hoverPanels = {}
end)