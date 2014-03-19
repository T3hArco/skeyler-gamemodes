include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

---------------------------------------------------------
--
---------------------------------------------------------

surface.CreateFont("ss.sass.screen", {font = "Arvil Sans", size = 152, weight = 400, blursize = 1})
surface.CreateFont("ss.sass.screen.small", {font = "Helvetica", size = 52, weight = 400, blursize = 1})

surface.CreateFont("ss.sass.screen.button", {font = "Arvil Sans", size = 156, weight = 400, blursize = 1})
surface.CreateFont("ss.sass.screen.status", {font = "Arial", size = 52, weight = 400, blursize = 1})

surface.CreateFont("ss.sass.screen.logo", {font = "Arvil Sans", size = 152, weight = 400, blursize = 1})
surface.CreateFont("ss.sass.screen.logo.small", {font = "Arvil Sans", size = 62, weight = 400, blursize = 1})

local backgroundTexture = surface.GetTextureID("skeyler/graphics/sass_board")

local preparingColor = Color(128, 255, 128, 255)
local unavailableColor = Color(243, 121, 142)

local color_blue = Color(39, 207, 255, 255)
local color_blue_light = Color(39 +30, 207 +30, 255, 255)
local color_grey_light = Color(69, 69, 69, 60)
local color_text_dark = Color(69, 69, 69, 200)

local statusMessages = {
	"Waiting for enough players to join: %i / %i",
	"This server is not up at the moment",
	"Game In Progress, you cannot join",
	"The game will be initalized in %i seconds."
}

local screenWidth, screenHeight = 64, 32
local cameraOffset = Vector(0.1, -screenWidth, screenHeight)
local cameraScale = 0.1

local panelUnique = "sass_screen"
 
---------------------------------------------------------
--
---------------------------------------------------------

local background = SS.WorldPanel.NewPanel(panelUnique, 0.1)
background:SetPos(0, 0)
background:SetSize(1280, 640)

---------------------------------------------------------
--
---------------------------------------------------------

function background:Paint(screen, x, y, w, h)
	draw.Texture(x, y, w, h, color_white, backgroundTexture)
	
	draw.SimpleRect(x +w /2 +32, y +h /2 -32, 2, h /2 -10, color_grey_light)
	draw.SimpleRect(x +w /2 +32 +96, y +h /2 -32, 2, h /2 -10, color_grey_light)
	
	draw.SimpleRect(x +w /2 +32 +96 +96, y +h /2 -32, 2, h /2 -10, color_grey_light)
end

---------------------------------------------------------
--
---------------------------------------------------------

local button = SS.WorldPanel.NewPanel(panelUnique, 0.1)
button:SetParent(background)
button:SetSize(1280 *0.19 -4, 75)
button:SetPos(1280 *0.4 +384 +104, 640 *0.25 +366)

---------------------------------------------------------
--
---------------------------------------------------------

function button:Paint(screen, x, y, w, h)
	draw.SimpleRect(x +4, y +4, w -8, h -8, self.hovered and color_blue_light or color_blue)
end

---------------------------------------------------------
--
---------------------------------------------------------

function button:OnMousePressed(screen)
	net.Start("ss.lkngtplr")
		net.WriteUInt(self.screen:GetTriggerID(), 8)
	net.SendToServer()
end

---------------------------------------------------------
--
---------------------------------------------------------

local statusPanel = SS.WorldPanel.NewPanel(panelUnique, 0.03)
statusPanel:SetParent(background)
statusPanel:SetSize(1280 *3.35, 640 *3.35)
statusPanel:SetPos(0, 0)

---------------------------------------------------------
--
---------------------------------------------------------

function statusPanel:Paint(screen, x, y, w, h)
	draw.SimpleText("[SS #1] SASSILIZATION SERVER 1", "ss.sass.screen.button", x +1164, y +164, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	
	if (screen.statusMessage) then
		local status, players = screen:GetStatus(), SS.Lobby.Link:GetQueue(screen:GetTriggerID())
		
		if (status == STATUS_LINK_PREPARING) then
			if (!screen.prepareTime) then
				screen.prepareTime = CurTime() +4
			end
			
			screen:DrawText(string.format(screen.statusMessage, math.max(math.Round(screen.prepareTime -CurTime()), 0)), "ss.sass.screen.status", x +1164, y +306, preparingColor)
		elseif (status == STATUS_LINK_UNAVAILABLE) then
			screen:DrawText(screen.statusMessage, "ss.sass.screen.status", x +1164, y +306, unavailableColor)
		else
			screen:DrawText(string.format(screen.statusMessage, #players, SS.Lobby.Link.MinPlayers), "ss.sass.screen.status", x +1164, y +306, color_yellow)
			
			screen.prepareTime = nil
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

local labelsPanel = SS.WorldPanel.NewPanel(panelUnique, 0.02)
labelsPanel:SetParent(background)
labelsPanel:SetSize(1280 *5 +14, 640 *5 +14)
labelsPanel:SetPos(0, 0)

---------------------------------------------------------
--
---------------------------------------------------------

function labelsPanel:Paint(screen, x, y, w, h)
	draw.SimpleText("PLAYER NAME", "ss.sass.screen.button", x +w /2 -932, y +h /2 -354, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("GOLD", "ss.sass.screen.button", x +w /2 +32 +364, y +h /2 -354, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("FOOD", "ss.sass.screen.button", x +w /2 +512 +364, y +h /2 -354, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("IRON", "ss.sass.screen.button", x +w /2 +1024 +320, y +h /2 -354, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	
	draw.SimpleText("PLAYER QUEUE", "ss.sass.screen.button", x +w -1330, y +h /2 -354, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	
	local queue = SS.Lobby.Link:GetQueue(screen:GetTriggerID())
	local nameY = 0
	
	for i = 1, 5 do
		local steamID = queue[i]
		
		if (steamID) then
			local player = util.FindPlayer(steamID)
			
			if (IsValid(player)) then
				local name = player:Nick()
				
				draw.SimpleText(name, "ss.sass.screen.button", x +w -1330, y +h /2 -144 +nameY, color_blue, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				
				nameY = nameY +198
			end
		end
	end
	
	local information = SS.Lobby.Link:GetPlayerInfo(screen:GetTriggerID())
	local infoY = 0
	
	for i = 1, 8 do
		local data = information[i]
		
		if (data) then
			draw.SimpleText(data.name, "ss.sass.screen.button", x +w /2 -932, y +h /2 -144 +infoY, color_blue, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(data.gold, "ss.sass.screen.button", x +w /2 +32 +364, y +h /2 -144 +infoY, color_text_dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(data.food, "ss.sass.screen.button", x +w /2 +512 +364, y +h /2 -144 +infoY, color_text_dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(data.food, "ss.sass.screen.button", x +w /2 +1024 +320, y +h /2 -144 +infoY, color_text_dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			
			infoY = infoY +196
		end
	end
	
	local hasQueue = SS.Lobby.Link:HasQueue(screen:GetTriggerID(), LocalPlayer():SteamID())
	
	if (hasQueue) then
		draw.SimpleText("LEAVE QUEUE", "ss.sass.screen.button", x +w -800, y +h -462, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	else
		draw.SimpleText("JOIN QUEUE", "ss.sass.screen.button", x +w -800, y +h -462, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	local position = self:GetPos()
	local angles = self:GetAngles()
	local bounds = Vector(1024, 1024, 1024)
	
	self.cameraAngles = Angle(0, angles.y +90, angles.p +90)
	self.cameraPosition = position +(self:GetRight() *screenWidth) +(self:GetUp() *screenHeight) +(self:GetForward() *0.2)
	
	self:SetRenderBounds(bounds *-1, bounds)

	self.mousePosition = Vector(0, 0, 0)
	self.projectionPos = self:LocalToWorld(cameraOffset)
	self.intersectPoint = Vector(0, 0, 0)
end
	
---------------------------------------------------------
--
---------------------------------------------------------

local DrawPanels = SS.WorldPanel.DrawPanels

function ENT:Draw()
	if (!self.registered) then
	 	local id = self:GetTriggerID()

	 	SS.Lobby.Link:AddScreen(id)
	
	 	net.Start("ss.lbgtscr")
	 		net.WriteUInt(id, 8)
	 	net.SendToServer()
	
	 	self.registered = true
	 else
	 	local status = self:GetStatus()
	
	 	if (self.__status != status) then
	 		self.statusMessage = statusMessages[status] or statusMessages[STATUS_LINK_UNAVAILABLE]

	 		self.__status = status
	 	end
	
	 	local distance = LocalPlayer():EyePos():Distance(self.cameraPosition)
	 	local maxDistance = SS.Lobby.ScreenDistance:GetInt()
	
	 	if (distance <= maxDistance) then
	 		self:UpdateMouse()
		
	 		cam.Start3D2D(self.cameraPosition, self.cameraAngles, 0.1)
	 			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	 			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			
	 			DrawPanels(panelUnique, self, 0.1)
		
	 			self:PaintMap(42, 640 *0.25 +82)
	 			self:PaintCartridge(321, 177)
	 			self:DrawMouse()
			
	 			render.PopFilterMin()
	 			render.PopFilterMag()
	 		cam.End3D2D()
		
	 		cam.Start3D2D(self.cameraPosition, self.cameraAngles, 0.03)
	 			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	 			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		
	 			DrawPanels(panelUnique, self, 0.03)
			
	 			render.PopFilterMin()
	 			render.PopFilterMag()
	 		cam.End3D2D()
		
	 		cam.Start3D2D(self.cameraPosition, self.cameraAngles, 0.02)
	 			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	 			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			
	 			DrawPanels(panelUnique, self, 0.02)
		
	 			render.PopFilterMin()
	 			render.PopFilterMag()
	 		cam.End3D2D()
	 	end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:PaintScoreboard(x, y)

end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:PaintCartridge(x, y)
	local status = self:GetStatus()
	
	if (status == STATUS_LINK_UNAVAILABLE or status == STATUS_LINK_IN_PROGRESS) then
		surface.SetDrawColor(unavailableColor)
		surface.DrawRect(x, y -136, 14, 156)
	else
		local players = SS.Lobby.Link:GetQueue(self:GetTriggerID())
		
		self.approachC = self.approachC or 0
		self.approachC = math.Approach(self.approachC, #players, 0.05)
		
		local percent = self.approachC /SS.Lobby.Link.MaxPlayers
		
		if (percent > 0) then
			surface.SetDrawColor(195, 218, 86)
			surface.DrawRect(x, y -percent *136, 14, 20 +percent *136)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:DrawText(text, font, x, y, color)
	draw.SimpleText(text, font, x +2, y +2, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

---------------------------------------------------------
--
---------------------------------------------------------

local defaultMap = surface.GetTextureID("skeyler/graphics/icon_newmap")
local width, height = 356, 356

function ENT:PaintMap(x, y)
	local data = SS.Lobby.Link:GetScreen(self:GetTriggerID())
	
	if (data.map != "") then
		draw.Texture(x, y, width, height, color_white, data.map or defaultMap)
		
		for i = 1, #data.minimap do
			local object = data.minimap[i]
			
			if (object.unit) then
				local target = Vector(object.dirx, object.diry, 0)
				local position = Vector(object.x, object.y, 0)
	
				local direction = (target -position):GetNormal()
				local distance = position:Distance(target)
				
				if (distance <= 0.2) then
					object.x = object.dirx
					object.y = object.diry
				else
					object.x = object.x +direction.x *0.04
					object.y = object.y +direction.y *0.04
				end
			end
			
			local objectX = 20+x +((object.x /width) *(width-43)) -object.width /2
			local objectY = 9+y +((object.y /height) *(height-4)) -object.height /2
			
			surface.SetDrawColor(object.color or color_white)
			surface.DrawRect(objectX, objectY, object.width, object.height)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:UpdateMouse()
	self.intersectPoint = intersectRayPlane(EyePos(), EyePos() +(LocalPlayer():GetAimVector() *2000), self.cameraPosition, self:GetForward())

	if (self.intersectPoint)then
		self.mousePosition = self:WorldToLocal(self.intersectPoint) -cameraOffset
	
		self.mousePosition.x = self.mousePosition.y
		self.mousePosition.y = -self.mousePosition.z
		
		SS.WorldPanel.SetMouseBounds(panelUnique, Vector(self.mousePosition.x, self.mousePosition.y, self.mousePosition.z))

		self.mousePosition = self.mousePosition /cameraScale
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

local cursor = Material("icon16/bullet_white.png", "alphatest")
local color_cursor = Color(169, 69, 69)

function ENT:DrawMouse()
	if (self.mousePosition and self.mousePosition.x > 0 and self.mousePosition.y > 0 and self.mousePosition.x < screenWidth *2 /cameraScale and self.mousePosition.y < screenHeight *2 /cameraScale) then
		draw.Material(self.mousePosition.x -6, self.mousePosition.y -6, 12, 12, color_cursor, cursor)
	end
end