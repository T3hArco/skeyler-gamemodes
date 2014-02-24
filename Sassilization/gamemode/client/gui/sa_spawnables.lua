--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

local PANEL = {}

function PANEL:Init()
	self.ItemX = 5
	self.ItemY = 5
	self.ItemPanels = {}
	self.NextUpdate = CurTime()
end

function PANEL:SetInfo(Name, Real, Order)
	self.TypeName = Name
	self.RealTable = Real
	self.OrderTable = Order
	self.Selection = self.OrderTable [ 1 ]
end

function PANEL:GetItem()
	return self.Selection
end

function PANEL:Setup()
	local Count = table.Count(self.OrderTable)
	
	self.Spacing = (self:GetWide() - (Count * 64)) / Count
	
	self.ItemX = self.Spacing / 2
	self.ItemY = (self:GetTall() / 2) - 32
	
	self.Ready = true
end

function PANEL:Paint()
end

function PANEL:Think()
	if(self.NextUpdate <= CurTime()) then
		self:Update()
	end
end

function PANEL:UnSelect()
	-- if(self.Selection and ValidPanel(self.ItemPanels[self.Selection])) then
		-- self.ItemPanels[self.Selection]:Select(false)
	-- end
	-- self.Selection = false
	-- GAMEMODE:ItemSelect(false)
end

function PANEL:Select(Item)
	local ItemPanel = self.ItemPanels[Item]
	if(not ItemPanel) then
		return
	end
	
	self:UnSelect()
	self:GetParent():UnSelect()
	
	self.Selection = Item
	ItemPanel:Select(true)
	
	GAMEMODE:ItemSelect(Item, ItemPanel:IsBuilding())
	GAMEMODE:CreateGhost()
end

function PANEL:ShouldShow(Item)
	if((self.TypeName == "Buildings" and building.CanBuild(LocalEmpire(), Item, true)) or (self.TypeName == "Units" and Unit:CanSpawn(LocalEmpire(), Item, true))) then
		return true
	end
	return false
end

function PANEL:OnMouseReleased(MouseCode)
	if(MouseCode == MOUSE_LEFT) then
		self:UnSelect()
	end
end

function PANEL:Update()
	if(not self.Ready or not self.RealTable or not self.OrderTable) then
		return
	end
	self.NextUpdate = CurTime() + 2
	for k,v in pairs(self.OrderTable) do
		local Real = self.RealTable[v]
		if(Real) then
			if(self:ShouldShow(v)) then
				if(not self.ItemPanels[v]) then
					local Item = vgui.Create("sa_menuitem", self)
					Item:SetItem(v, Real, self.TypeName)
					Item:SetSize(64, 64)
					Item:SetPos(self.ItemX, self.ItemY)
					self.ItemPanels[v] = Item
					
					if(self.TypeName == "Buildings") then
						Item.Building = true
					end
					
					self.ItemX = self.ItemX + Item:GetWide() + self.Spacing
				end
				self.ItemPanels[v]:SetVisible(true)
			elseif(self.ItemPanels[v]) then
				self.ItemPanels[v]:SetVisible(false)
			end
		end
	end
end

vgui.Register("sa_spawnables", PANEL, "DPanel")
