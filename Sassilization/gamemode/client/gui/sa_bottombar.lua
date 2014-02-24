--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

local PANEL = {}
PANEL.Tab = false
PANEL.Tabs = {}

PANEL.InitWidth = 500
PANEL.InitHeight = 114

PANEL.BorderThick = 4

PANEL.BorderAlpha = 150
PANEL.BackgroundAlpha = 100

PANEL.TabSpacing = 5

PANEL.TabWidth = 150
PANEL.TabHeight = 30
PANEL.TabSelectedAdd = 8

PANEL.InitNoTabHeight = PANEL.InitHeight - PANEL.TabHeight - PANEL.TabSelectedAdd
PANEL.OffsetY = PANEL.InitHeight - PANEL.InitNoTabHeight

function PANEL:Init()
	self:SetSize(self.InitWidth, self.InitHeight)
	self:SetPos((ScrW() / 2) - (self.InitWidth / 2), ScrH() + 1)
	self:SetVisible(false)
	
	self.DoubleBorderThick = self.BorderThick * 2
	
	self.AnimSlide = Derma_Anim("Slide", self, self.AnimSlideFunc)
	
	self.Buildings = vgui.Create("sa_spawnables", self)
	self.Buildings:SetInfo("Buildings", building.BuildingData, building.BuildingOrder)
	
	self:AddTab("Buildings", self.Buildings)
	
	self.Units = vgui.Create("sa_spawnables", self)
	self.Units:SetInfo("Units", Unit:ListUnits(), unit.UnitOrder)
	
	self:AddTab("Units", self.Units)
	
	self:SelectTab("Buildings")
end

function PANEL:AddTab(Name, Panel)
	self.Tabs[Name] = Panel
	
	Panel:SetVisible(false)
	Panel:SetPos(self.BorderThick, self.OffsetY)
	Panel:SetSize(self.InitWidth - self.DoubleBorderThick, self.InitNoTabHeight)
	Panel:Setup()
	Panel.Tab = Name
	Panel.TabNum = table.Count(self.Tabs)
	
	surface.SetFont("Tab")
	local TWidth, THeight = surface.GetTextSize(Name)
	Panel.TWidth = TWidth
	Panel.THeight = THeight
	
	surface.SetFont("TabSelected")
	TWidth, THeight = surface.GetTextSize(Name)
	Panel.TWidthSelected = TWidth
	Panel.THeightSelected = THeight
	
	self.InitTabX = (self.InitWidth - (Panel.TabNum * self.TabSpacing) - (Panel.TabNum * self.TabWidth)) / 2
	self.MaxTabX = self.InitTabX + ((Panel.TabNum - 1) * self.TabSpacing) + (Panel.TabNum * self.TabWidth) + self.TabSelectedAdd
end

function PANEL:SelectTab(Name)
	if(self.Tab == Name) then
		return false
	end
	
	if(self.Tab) then
		local Panel = self.Tabs[self.Tab]
		if(ValidPanel(Panel)) then
			Panel:SetVisible(false)
		end
		if self.Tab == "Units" then
			gamemode.Call( "OnUnitMenuClose" )
		elseif self.Tab == "Buildings" then
			gamemode.Call( "OnBuildingMenuClose" )
		end
	end
	
	self.Tab = Name
	
	local Panel = self.Tabs[self.Tab]
	if(ValidPanel(Panel)) then
		Panel:Update()
		Panel:SetVisible(true)
	end
	if Name == "Units" then
		gamemode.Call( "OnUnitMenuOpen" )
	elseif Name == "Buildings" then
		gamemode.Call( "OnBuildingMenuOpen" )
	end
	
	return true
end

function PANEL:GetItem()
	return self.Tabs[self.Tab]:GetItem()
end

function PANEL:Think()
	self.AnimSlide:Run()
end

function PANEL:UnSelect()
	self.Buildings:UnSelect()
	self.Units:UnSelect()
end
	
function PANEL:Slide(Bool)
	if(self.SlideDirection == Bool) then
		return
	end
	
	self.SlideDirection = Bool
	
	local X, Y = self:GetPos()
	local Width, Height = self:GetSize()
	
	local From = Y
	local To = ScrH() - Height
	
	if(self.SlideDirection) then
		self:SetVisible(true)
		-- self.Buildings.NextUpdate = CurTime()
		-- self.Units.NextUpdate = CurTime()
	else
		From = Y
		To = ScrH() + 1
	end
	
	self.AnimSlide:Start(0.2, {
		X = X,
		To = To,
		From = From,
		EndVisible = self.SlideDirection
	})
end

function PANEL:AnimSlideFunc(anim, delta, data)
	if(anim.Started) then
		self:SetVisible(true)
	end
	self:SetPos(data.X, Lerp(delta, data.From, data.To))
	if(anim.Finished) then
		self:SetVisible(data.EndVisible)
	end
end

function PANEL:DrawBorder(x, y, width, height)
	surface.SetDrawColor(39, 39, 39, self.BorderAlpha)
	surface.DrawRect(x, y, width, height)
end

function PANEL:DrawBackground(x, y, width, height)
	-- surface.SetDrawColor(149, 149, 149, self.BackgroundAlpha)
	surface.SetDrawColor(220, 220, 220, self.BackgroundAlpha)
	surface.DrawRect(x, y, width, height)
end

function PANEL:DrawTabBox(Panel, Font, TWidth, THeight, x, y, width, height, NoBottomBorder)

	surface.SetDrawColor(255, 255, 255, 255)
	if Font == "TabSelected" then
		surface.SetMaterial(Material("sassilization/q_e_tab_large.png"))
	else
		surface.SetMaterial(Material("sassilization/q_e_tab_small.png"))
	end
	surface.DrawTexturedRect( x, y, width, height )
	
	surface.SetFont(Font)
	surface.SetTextPos(x + ((width / 2) - (Panel.TWidth / 2)), y + ((height / 2) - (Panel.THeight / 2)))
	surface.DrawText(Panel.Tab)
end

function PANEL:Paint()
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(Material("sassilization/q_e_background.png"))
	surface.DrawTexturedRect( 0, self.OffsetY, self.InitWidth, self.InitNoTabHeight )
	
	surface.SetTextColor(255, 255, 255, 255)
	
	self.TabX = self.InitTabX
	
	--self:DrawBorder(0, self.OffsetY - self.BorderThick, self.TabX, self.BorderThick)
	for k,v in pairs(self.Tabs) do
		v.MinTabX = self.TabX + self.BorderThick
		if(self.Tab == k) then
			self:DrawTabBox(v, "TabSelected", v.TWidthSelected, v.THeightSelected, self.TabX, 0, self.TabWidth + self.TabSelectedAdd, self.TabHeight + self.TabSelectedAdd, true)
			self.TabX = self.TabX + self.TabSelectedAdd
		else
			self:DrawTabBox(v, "Tab", v.TWidth, v.THeight, self.TabX, self.TabSelectedAdd, self.TabWidth, self.TabHeight)
		end
		v.MaxTabX = self.TabX + self.TabWidth + self.BorderThick
		self.TabX = self.TabX + self.TabWidth + self.TabSpacing
		--self:DrawBorder(self.TabX - self.TabSpacing, self.OffsetY - self.BorderThick, self.TabSpacing, self.BorderThick)
	end
	
	--self:DrawBorder(self.TabX, self.OffsetY - self.BorderThick, self.InitWidth, self.BorderThick)
end

function PANEL:KillHand()
	if(self.Hand) then
		self.Hand = false
		self.HoverTab = false
		self:SetCursor("none")
		GAMEMODE:GhostSetNoDraw(false)
	end
end

function PANEL:OnMousePressed(MouseCode)
	if(MouseCode == MOUSE_LEFT) then
		if(self.HoverTab) then
			if(self:SelectTab(self.HoverTab)) then
				surface.PlaySound(GAMEMODE.ButtonRelease)
			end
		end
	end
end

function PANEL:OnCursorMoved(x, y)
	if(y < self.OffsetY) then
		if(x > self.InitTabX and x < self.MaxTabX) then
			for k,v in pairs(self.Tabs) do
				if(x > v.MinTabX and x < v.MaxTabX) then
					self.HoverTab = k
					if(not self.Hand) then
						self.Hand = true
						-- self:SetCursor("hand")
						GAMEMODE:GhostSetNoDraw(true)
					end
					return
				end
			end
		end
	end
	self:KillHand()
end

function PANEL:OnCursorExited()
	self:KillHand()
end

vgui.Register("sa_bottombar", PANEL, "DPanel")
