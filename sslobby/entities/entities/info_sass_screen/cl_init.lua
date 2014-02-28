include("shared.lua")

surface.CreateFont("SassScreenChat", {
	font 		= "Calibri",
	size 		= 24,
	weight 		= 600
})

surface.CreateFont("SassScreenGeneral", {
	font 		= "Calibri",
	size 		= 30,
	weight 		= 600
})

surface.CreateFont("SassScreenStatusMessage", {
	font 		= "Calibri",
	size 		= 46,
	weight 		= 600
})

surface.CreateFont("SassScreenStatusMessageEx", {
	font 		= "Calibri",
	size 		= 32,
	weight 		= 1000
})

surface.CreateFont("ss.sass.screen", {font = "Arvil Sans", size = 152, weight = 400, blursize = 1})
surface.CreateFont("ss.sass.screen.small", {font = "Helvetica", size = 52, weight = 400, blursize = 1})

surface.CreateFont("ss.sass.screen.logo", {font = "Arvil Sans", size = 152, weight = 400, blursize = 1})
surface.CreateFont("ss.sass.screen.logo.small", {font = "Arvil Sans", size = 62, weight = 400, blursize = 1})

local LeadboardTexture = surface.GetTextureID("sassilization/leaderboards/sass_info")

local ColInGame = Color(255, 38, 28, 255)
local preparingColor = Color(128, 255, 128, 255)

local StatusMessages = {"Ready", "Closed", "In-Game", "Preparing"}
local StatusMessagesEx = {"Waiting for enough players to join: %i/%i", "This server is not up at the moment", "Game In Progress, you cannot join", "The game will be initalized in %i seconds."}
local StatusTextures = {surface.GetTextureID("sassilization/ready"),  surface.GetTextureID("sassilization/closed"), surface.GetTextureID("sassilization/forbidden"), surface.GetTextureID("sassilization/ready")}

local mouseWidth, mouseHeight = 64, 32
local camOffset = Vector(0.1, -mouseWidth, mouseHeight)
local camScale = 0.1

local backgroundTexture = Material("skeyler/graphics/screen_bg.png", "noclamp smooth")


---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	--self:SetStatus(CommLink.Status.CLOSED)
--	self:SetCount(0)
--	self:SetPreparing(false)
--	self:UpdatePlayers({})
	
	local Width = 64
	local Height = 32
	
	self.ID = 0
	
	self.Pos = self:GetPos()
	self.CamPos = self.Pos + (self:GetRight() * Width) + (self:GetUp() * Height) + (self:GetForward() *0.5)
	
	self.Ang = self:GetAngles()
	self.CamAng = Angle(0, self.Ang.y + 90, self.Ang.p + 90)
	
	local bounds = Vector(1024, 1024, 1024)

	self:SetRenderBounds(bounds *-1, bounds)

	self.intersectPoint = Vector()
	self.projectionPos = self:LocalToWorld(camOffset)
	self.projectionAng = self.CamAng
	self.projectionNorm = self:GetForward()
	self.mousePos = Vector()
end

---------------------------------------------------------
--
---------------------------------------------------------

local boundsMousePos = Vector(1, 1, 1)

local function inbounds(x, y, w, h, scale)
	if (!boundsMousePos) then return false end
	
	local pos = boundsMousePos /scale
	
	return pos.x >= x and pos.x <= x +w and pos.y >= y and pos.y <= y +h
end

local stored = {}
local object = {}
object.__index = object

AccessorFunc(object, "scale", "Scale")

function newp(scale)
	local panel = {}
	
	setmetatable(panel, object)
	
	panel:SetScale(scale or 0.1)
	
	table.insert(stored, panel)
	
	return panel
end

function object:SetParent(parent)
	self.x = parent.x
	self.y = parent.y
	
	function self:SetPos(x, y)
		self.x = self.parent.x +x
		self.y = self.parent.y +y
	end
	
	self.parent = parent
end

function object:SetPos(x, y)
	self.x, self.y = x, y
end

function object:SetSize(w, h)
	self.w, self.h = w, h
end

function object:Paint(x, y, w, h)
end

function object:OnMousePressed()
end

function object:__Paint()
	self.hovered = inbounds(self.x, self.y, self.w, self.h, self.scale)
	
	if (self.hovered) then
		if (input.IsMouseDown(MOUSE_LEFT)) then
			if (!self.triggered) then
				self:OnMousePressed()
				
				self.triggered = true
			end
		else
			self.triggered = nil
		end
	end
	
	self:Paint(self.x, self.y, self.w, self.h)
end

local function drawp(scale)
	for i = 1, #stored do
		local info = stored[i]
		local pscale = info:GetScale()
		
		if (pscale == scale) then
			info:__Paint()
		end
	end
end


local a=newp(0.1)
a:SetPos(0, 0)
a:SetSize(1280, 640)

function a:Paint(x, y, w, h)
	draw.Material(x, y, w, h, color_white, backgroundTexture)
	
	-- Logo background.
	draw.SimpleRect(x +32, y +32, 245, h *0.25, color_white)
	
	-----------------------------------------
	-- Server information.
	-----------------------------------------
	
	-- Background.
	draw.SimpleRect(x +245 +64, y +32, w -(245 +96), h *0.25, color_white)
	
	-- Green vertical bar.
	draw.SimpleRect(x +245 +66, y +34, 10, h *0.25 -4, Color(195, 218, 86))
	
	-- Dark title background.
	draw.SimpleRect(x +245 +78, y +34, w -(245 +112), h *0.125, Color(59, 59, 59))
	
	-----------------------------------------
	-- Player list.
	-----------------------------------------
	
	-- Background.
	draw.SimpleRect(x +384 +64, y +(h *0.25 +64), w *0.4, 384, color_white)
	
	-- Dark title background.
	draw.SimpleRect(x +384 +66, y +(h *0.25 +66), w *0.4 -4, 384 *0.1, Color(59, 59, 59))
	
	-----------------------------------------
	-- Player queue.
	-----------------------------------------
	
	-- Background.
	draw.SimpleRect(x +w *0.4 +384 +92, y +(h *0.25 +64), w *0.2 +4, 384 -(82 +32), color_white)
	
	-- Dark title background.
	draw.SimpleRect(x +w *0.4 +384 +94, y +(h *0.25 +66), w *0.2, 384 *0.1, Color(59, 59, 59))
end

local button = newp(0.1)
button:SetParent(a)
button:SetSize(1280 *0.2 +4, 82)
button:SetPos(1280 *0.4 +384 +92, 640 *0.25 +366)

function button:Paint(x, y, w, h)
	draw.SimpleRect(x, y, w, h, color_white)
	
	draw.SimpleRect(x +4, y +4, w -8, h -8, self.hovered and Color(39 +20, 207 +20, 255, 255) or Color(39, 207, 255, 255))
end

local b = newp(0.06)
b:SetParent(a)
b:SetSize(300, 120)
b:SetPos(260, 384 *0.25)

function b:Paint(x, y, w, h)
	draw.SimpleText("SKEYLER", "ss.sass.screen.logo", x, y, Color(39, 207, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("GMOD COMMUNITY", "ss.sass.screen.logo.small", x, y +h, Color(99, 99, 99, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

function b:OnMousePressed()
LocalPlayer():ChatPrint("You pressed it!!")
end

function ENT:Draw()
	if (!self.registered) then
		local id = self:GetTriggerID()

		SS.Lobby.Link:AddScreen(id)
		
		self.registered = true
	else
		local status = self:GetStatus()
		
		if (self.__status != status) then
			self.StatusMessage = StatusMessages[status] or StatusMessages[STATUS_LINK_UNAVAILABLE]
			self.StatusTexture = StatusTextures[status] or StatusTextures[STATUS_LINK_UNAVAILABLE]
			self.StatusMessageEx = StatusMessagesEx[status] or StatusMessagesEx[STATUS_LINK_UNAVAILABLE]
			
			self.StatusCol = color_white
			if (Status == STATUS_LINK_IN_PROGRESS) then
				self.StatusCol = ColInGame
			else
				self.Chat = {}
			end
			
			self.__status = status
		end
		
		local w, h = 1280, 640
		local x, y = 0, 0
	
		self:UpdateMouse()
		
		cam.Start3D2D(self.CamPos, self.CamAng, 0.1)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)

			drawp(0.1)
			
			--[[draw.SimpleRect(x, y, w, h, Color(191, 191, 191))
			draw.Material(x +32, y +32, w -64, h -64, color_white, backgroundTexture)
			--draw.SimpleRect(x +32, y +32, w -64, h -64, Color(230, 230, 229))
			
			-- Logo background.
			draw.SimpleRect(x +64, y +64, w *0.19, h *0.25, color_white)
			
			-- Server name and amount of players background.
			draw.SimpleRect(x +(w *0.19 +96), y +64, w -(w *0.19 +160), h *0.25, color_white)
			draw.SimpleRect(x +(w *0.19 +98), y +66, 12, h *0.25 -4, Color(195, 218, 86))
			draw.SimpleRect(x +(w *0.19 +112), y +66, w -(w *0.19 +178), h *0.19 /2 -4, Color(59, 59, 59))
			
			-- Minimap/map background.
			draw.SimpleRect(x +64, y +(h *0.25 +96), 320, h -(h *0.25 +160), color_white)
			
			-- Player list background.
			draw.SimpleRect(x +(320 +96), y +(h *0.25 +96), w *0.4, h -(h *0.25 +160), color_white)
			draw.SimpleRect(x +(322 +96), y +(h *0.25 +98), w *0.4 -4, 40, Color(59, 59, 59))
			
			local b = 0
			
			for i = 1, 8 do
				draw.SimpleRect(x +(322 +96), y +(h *0.25 +140) +b, w *0.4 -4, 32, i % 2 == 1 and Color(59, 59, 59, 24) or color_white)
				
				
				b = b +34
			end
			
			-- Player queue background.
			draw.SimpleRect(x +(w *0.4 +(320 +128)), y +(h *0.25 +96), w -(w *0.4 +(320 +192)), h -(h *0.25 +160*2), color_white)
			]]
			
			--self:PaintStatus()
			
			if (status == STATUS_LINK_READY) then
			--	self:PaintCartridge(38, 584)
			--elseif(self.Status == CommLink.Status.INGAME) then
		--		self:PaintScoreboard()
		--		self:PaintChat(614, 184)
		--		self:PaintMap( 924, 277 )
			end
			
			self:PaintMap(x +32, y +(h *0.25 +64))
			self:DrawMouse()
			
		--	self:PaintMessage(617, 229)
			--self:PaintMap(916, 275)
			
		--	self:DrawMouse()
			
			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
		
		cam.Start3D2D(self.CamPos, self.CamAng, 0.021)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			--[[
			draw.SimpleText("[SS #1] SASSILIZATION SERVER 1", "ss.sass.screen", x +(320 +28) *5, y +(h *0.25 +192), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText("192.168.200.100", "ss.sass.screen.small", x +(320 +28) *5, y +(h *0.25 +332), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText("PLAYER NAME", "ss.sass.screen", x +(320 +87) *5, y +(h *0.25 +92) *5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			
			local b = 0
			
			for i = 1, 8 do
				draw.SimpleText(LocalPlayer():Nick(), "ss.sass.screen", x +(320 +87) *5, y +((h *0.25 +127) *5) +b, Color(39, 207, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			
				b = b +162
			end
			]]
			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
		
		cam.Start3D2D(self.CamPos, self.CamAng, 0.06)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			
			drawp(0.06)
			--	draw.SimpleText("SKEYLER", "ss.sass.screen.logo", x +374, y +(h *0.25 +32), Color(39, 207, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	--draw.SimpleText("GMOD COMMUNITY", "ss.sass.screen.logo.small", x +374, y +(h *0.25 +156), Color(99, 99, 99, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
	end
end
 
---------------------------------------------------------
--
---------------------------------------------------------

function ENT:PaintStatus(x, y)
	if (self.StatusTexture) then
		surface.SetDrawColor(color_white)
		surface.SetTexture(self.StatusTexture)
		surface.DrawTexturedRect(170, 425, 160, 160)
		
		local status, players = self:GetStatus(), SS.Lobby.Link:GetPlayers(self:GetTriggerID())
		
		self:DrawText(self.StatusMessage, "SassScreenStatusMessage", 110, 325)
		
		if (status == STATUS_LINK_PREPARING) then
			if (!self.prepareTime) then
				self.prepareTime = CurTime() +4
			end
			
			self:DrawText(string.format(self.StatusMessageEx, math.max(math.Round(self.prepareTime -CurTime()), 0)), "SassScreenStatusMessageEx", 614, 225, preparingColor)
		else
			self:DrawText(string.format(self.StatusMessageEx, #players, SS.Lobby.Link.MinPlayers), "SassScreenStatusMessageEx", 614, 225, color_yellow)
			
			self.prepareTime = nil
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:PaintScoreboard(mx, my)

end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:PaintCartridge(x, y)
	local players = SS.Lobby.Link:GetPlayers(self:GetTriggerID())
	
	self.approachC = self.approachC or 0
	self.approachC = math.Approach(self.approachC, #players, 0.05)
	
	surface.SetDrawColor(60, 60, 60, 220)
	surface.DrawRect(x, y -(SS.Lobby.Link.MinPlayers /SS.Lobby.Link.MaxPlayers) *263, 43, 3)
	
	local percent = self.approachC /SS.Lobby.Link.MaxPlayers
	
	if (percent > 0) then
		surface.SetDrawColor(0, 200, 0, 255)
		surface.DrawRect(x, y -percent *263, 43, 20 +percent *263)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:PaintChat(x, y)

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
--[[
local matNewMap = Material( "sassilization/mapicons/new_map" )
local texNewMap = surface.GetTextureID( "sassilization/mapicons/new_map" )

SERVERS = {}
for i=0, 10 do
	SERVERS[i] = {}
	SERVERS[i].chat = {}
	SERVERS[i].scoreboard = {}
	SERVERS[i].buildboard = {}
	SERVERS[i].minimap = {}
	SERVERS[i].minimap.buildbldg = {}
	SERVERS[i].minimap.buildunit = {}
	SERVERS[i].status = "Closed"
	SERVERS[i].state = "closed"
	SERVERS[i].message = ""
	SERVERS[i].reload = function( server )
		server.scoreboard={}
		server.buildboard={}
		server.minimap.available=nil
		server.minimap.builtbldg=nil
		server.minimap.builtunit=nil
		server.minimap.buildbldg=nil
		server.minimap.buildunit=nil
		server.chat={}
	end
end]]

---------------------------------------------------------
--
---------------------------------------------------------

local defaultMap = Material("skeyler/graphics/newmap.png", "noclamp smooth")

local width, height = 384, 384

function ENT:PaintMap(x, y)
	local data = SS.Lobby.Link:GetScreen(self:GetTriggerID())
	
	if (data.map != "") then
		draw.Material(x, y, width, height, color_white, defaultMap)
		--draw.Texture(x, y, width, height, color_white, data.map)
		
		--[[for i = 1, #data.minimap do
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
					object.x = object.x +direction.x *0.1
					object.y = object.y +direction.y *0.1
				end
			end
			
			local objectX = x +((object.x /width) *width) -object.width /2
			local objectY = y +((object.y /height) *height) -object.height /2
			
			surface.SetDrawColor(object.color or color_white)
			surface.DrawRect(objectX, objectY, object.width, object.height)
		end]]
	else
		draw.Texture(x, y, width, height, color_white, defaultMap)
	end
	

	
	
	--[[
	if SERVERS[self.ID].minimap.available then
		if !matTable["sassilization/minimaps/"..SERVERS[self.ID].map] then
			matTable["sassilization/minimaps/"..SERVERS[self.ID].map]=Material("sassilization/minimaps/"..SERVERS[self.ID].map)
		end
		if !texTable["sassilization/minimaps/"..SERVERS[self.ID].map] then
			texTable["sassilization/minimaps/"..SERVERS[self.ID].map]=surface.GetTextureID("sassilization/minimaps/"..SERVERS[self.ID].map)
		end
		
		surface.SetTexture( texTable["sassilization/minimaps/"..SERVERS[self.ID].map] )
		surface.DrawTexturedRect( x, y, 320, 320 )
		
		//Draw the buildings
		local items = SERVERS[self.ID].minimap.builtbldg
		if items and table.Count(items)>0 then
			for _, item in pairs( items ) do
				if ValidItem( item ) then
					if item.c then
						surface.SetDrawColor(item.c.r,item.c.g,item.c.b,item.c.a)
						surface.DrawRect(x+item.x*320/512-item.s*0.5,y+item.y*320/512-item.s*0.5,item.s,item.s)
						if item.a == 1 then
							surface.SetDrawColor(230, 0, 25,255*math.abs(math.sin(RealTime()*5)))
							surface.DrawRect(x+item.x*320/512-item.s*0.5,y+item.y*320/512-item.s*0.5,item.s,item.s)
						end
					end
				end
			end
		end
			
		//Draw the units
		local items = SERVERS[self.ID].minimap.builtunit
		if items and table.Count(items)>0 then
			for _, item in pairs( items ) do
				if ValidItem( item ) then
					local dir = (Vector( item.x, item.y, 0 )-Vector( item.px, item.py, 0 )):GetNormal()
					local dis = Vector( item.x, item.y, 0 ):Distance(Vector( item.px, item.py, 0 ))
					if dis < .2 then
						item.px = item.x
						item.py = item.y
					else
						item.px = item.px + dir.x*0.05
						item.py = item.py + dir.y*0.05
					end
					surface.SetDrawColor(item.c.r,item.c.g,item.c.b,item.c.a)
					surface.DrawRect(x+item.px*320/512-item.s*0.5,y+item.py*320/512-item.s*0.5,item.s,item.s)
					if item.a == 1 then
						surface.SetDrawColor(230, 0, 25,255*math.abs(math.sin(RealTime()*5)))
						surface.DrawRect(x+item.px*320/512-item.s*0.5,y+item.py*320/512-item.s*0.5,item.s,item.s)
					end
				end
			end
		end
		
	elseif SERVERS[self.ID].map then
		
		if !matTable["sassilization/mapicons/"..SERVERS[self.ID].map] then
			if(file.Exists("../materials/sassilization/mapicons/"..SERVERS[self.ID].map..".vmt")) then
				matTable["sassilization/mapicons/"..SERVERS[self.ID].map] = Material( "sassilization/mapicons/"..SERVERS[self.ID].map )
			else
				matTable["sassilization/mapicons/"..SERVERS[self.ID].map] = matNewMap
			end
		end
		if !texTable["sassilization/mapicons/"..SERVERS[self.ID].map] then
			if(file.Exists("../materials/sassilization/mapicons/"..SERVERS[self.ID].map..".vmt")) then
				texTable["sassilization/mapicons/"..SERVERS[self.ID].map] = surface.GetTextureID("sassilization/mapicons/"..SERVERS[self.ID].map)
			else
				texTable["sassilization/mapicons/"..SERVERS[self.ID].map] = texNewMap
			end
		end
		
		surface.SetDrawColor(255,255,255,255)
		surface.SetTexture( texTable["sassilization/mapicons/"..SERVERS[self.ID].map] )
		surface.DrawTexturedRect( x, y, 320, 320 )
		
	end
	if SERVERS[self.ID].map then
		surface.SetFont("font_spray")
		local mapname =  SERVERS[self.ID].map
		mapname = mapname:gsub( "sa_", "" )
		mapname = mapname:gsub( "_", " " )
		DrawText( mapname, x + 10, y, Color( 60, 60, 60, 255 ), 0.75 )
		surface.SetFont("Tb0")
	end
	]]
end

function ENT:UpdateMouse()
	self.intersectPoint = false
	self.intersectPoint = intersectRayPlane(EyePos(), EyePos() +(LocalPlayer():GetAimVector() *2000), self.projectionPos, self.projectionNorm )

	if(self.intersectPoint)then
		self.mousePos = self:WorldToLocal(self.intersectPoint) -camOffset
	
		self.mousePos.x = self.mousePos.y
		self.mousePos.y = -self.mousePos.z
		
		boundsMousePos = Vector(self.mousePos.x, self.mousePos.y, self.mousePos.z)
		
		self.mousePos = self.mousePos /camScale
	end
	--print("X:",self.mousePos.x,"Y:",self.mousePos.y)
end

local cursor = Material("icon16/cursor.png")

function ENT:DrawMouse()
	if( self.mousePos and self.mousePos.x > 0 &&
		self.mousePos.y > 0 &&
		self.mousePos.x < mouseWidth * 2 / camScale &&
		self.mousePos.y < mouseHeight * 2 / camScale) then
		
		draw.Material(self.mousePos.x -8, self.mousePos.y -8, 16, 16, color_white, cursor)

		--draw.SimpleText( tostring(math.Round(self.mousePos.x)).." "..tostring(math.Round(self.mousePos.y)), "DermaDefault", self.mousePos.x, self.mousePos.y+20 ,color_red,EXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end
	
end

--[[

local matNewMap = Material( "sassilization/mapicons/new_map" )
local texNewMap = surface.GetTextureID( "sassilization/mapicons/new_map" )

SERVERS = {}
for i=0, 10 do
	SERVERS[i] = {}
	SERVERS[i].chat = {}
	SERVERS[i].scoreboard = {}
	SERVERS[i].buildboard = {}
	SERVERS[i].minimap = {}
	SERVERS[i].minimap.buildbldg = {}
	SERVERS[i].minimap.buildunit = {}
	SERVERS[i].status = "Closed"
	SERVERS[i].state = "closed"
	SERVERS[i].message = ""
	SERVERS[i].reload = function( server )
		server.scoreboard={}
		server.buildboard={}
		server.minimap.available=nil
		server.minimap.builtbldg=nil
		server.minimap.builtunit=nil
		server.minimap.buildbldg=nil
		server.minimap.buildunit=nil
		server.chat={}
	end
end

local function ValidItem( item )
	if type(item)!="table" then return false end
	if !(item.x and item.y and item.s and item.c) then return false end
	return true
end

usermessage.Hook("UpdScr", function( um )
	
	local sid = tonumber(um:ReadChar())
	local new = um:ReadBool()
	local count = um:ReadShort()
	if !SERVERS[sid] then return end
	
	if new then SERVERS[sid].buildboard = {} end
	
	for i=1, count do
		local pl = {}
		pl.n = um:ReadString()
		pl.c = Color( um:ReadChar()+128, um:ReadChar()+128, um:ReadChar()+128, 255 )
		pl.g = um:ReadShort()
		pl.f = um:ReadShort()
		pl.i = um:ReadShort()
		pl.ci = um:ReadChar()
		pl.cr = um:ReadChar()
		pl.s = um:ReadChar()
		pl.fa = um:ReadChar()
		pl.mi = um:ReadChar()
		pl.u = um:ReadChar()
		table.insert( SERVERS[sid].buildboard, pl )
	end
	
	local fin = um:ReadBool()
	if fin then
		for i, pl in pairs( SERVERS[sid].buildboard ) do
			for k, v in pairs( SERVERS[sid].scoreboard ) do
				if pl.n == v.n then
					pl.placement = k - i
					break
				end
			end
			pl.placement = pl.placement or 0
		end
		SERVERS[sid].scoreboard = SERVERS[sid].buildboard
		RunConsoleCommand("_updateoverride", sid)
	end
	
end )

usermessage.Hook("UpdMM", function( um )
	
	local sid = tonumber(um:ReadChar())
	local type = um:ReadString()
	local count = um:ReadShort()
	if !SERVERS[sid] then return end
	
	SERVERS[sid].minimap.available = true
	SERVERS[sid].minimap["build"..type] = SERVERS[sid].minimap["build"..type] or {}
	
	for i=1, count do
		local item = {}
		item.i = um:ReadShort()
		item.s = um:ReadChar()
		item.c = Color( um:ReadChar()+128, um:ReadChar()+128, um:ReadChar()+128, um:ReadChar()+128 )
		item.a = um:ReadBool()
		item.r = um:ReadBool()
		item.x = um:ReadChar()*2+256
		item.y = um:ReadChar()*2+256
		if type == "unit" then
			item.px = um:ReadChar()*2+256
			item.py = um:ReadChar()*2+256
		end
		if item.r then
			SERVERS[sid].minimap["build"..type][item.i] = nil
		else
			SERVERS[sid].minimap["build"..type][item.i] = item
		end
	end
	
	SERVERS[sid].minimap["built"..type] = table.Copy(SERVERS[sid].minimap["build"..type])
	
end )

function UpdateStatus( um )
	local sid = tonumber(um:ReadChar())
	local status = tonumber(um:ReadChar())
	if (status != 2) then
		SERVERS[sid]:reload()
	end
	SERVERS[sid].status = ServerStatus[status][1]
	SERVERS[sid].state = ServerStatus[status][2]
	SERVERS[sid].map = um:ReadString()
end
usermessage.Hook("UpdateStatus", UpdateStatus)

function AddServerChat( server, speaker, chat, wrap )
	if !chat or chat == "" then return end
	if !wrap then
		wrap = 0
		chat = speaker..": "..string.Trim(chat)
	else
		chat = string.Trim(chat)
	end
	server = tonumber(server) or 1
	surface.SetFont("Tb0")
	local wlen = 620
	local txt = ""
	local words = string.Explode(" ",chat)
	local size = 0
	local spacer = surface.GetTextSize(" ")
	local pos = 0
	local w, h = surface.GetTextSize( chat )
	for i, word in pairs( words ) do
		w, h = surface.GetTextSize( word )
		if size+w+spacer < wlen then
			pos = pos + string.len(word) + 1
			size = size+w+spacer
			txt = txt.." "..word
		elseif w > wlen then
			local available = wlen - size
			local str = ""
			for i=1, string.len(word) do
				str = string.sub( word, 1, i )
				w, h = surface.GetTextSize( str )
				if w > available then
					txt = txt.." "..str
					pos = pos+string.len(str)
					timer.Simple(0.01*wrap, function() AddServerChat(server, nil, string.sub( chat, pos ), wrap + 1 ) end)
					break
				end
			end
			break
		else
			timer.Simple(0.01*wrap, function() AddServerChat(server, nil, string.sub( chat, pos+1 ), wrap + 1) end)
			break
		end
	end
	local colour
	for k, v in pairs( SERVERS[server].scoreboard ) do
		if speaker == v.n then
			colour = Color(v.c.r,v.c.g,v.c.b,255)
			break
		end
	end
	SERVERS[server].chat[ #SERVERS[server].chat+1 ] = {n=(wrap==0 and speaker),c=colour,msg=txt,time=os.clock()}
end

local function MousePos(self,scale)
	
	scale = scale or 10
	local pl = LocalPlayer()
	local tr = util.TraceLine({start=pl:EyePos(),endpos=pl:EyePos()+pl:GetAimVector()*200,mask=MASK_SOLID_BRUSHONLY})
	
	if !tr.Hit then return 0, 0 end
	
	tr.HitPos = self:WorldToLocal( tr.HitPos )
	
	if tr.HitPos.x < self.mins.x then return 0, 0 end
	if tr.HitPos.x > self.maxs.x then return 0, 0 end
	if tr.HitPos.y < self.mins.y then return 0, 0 end
	if tr.HitPos.y > self.maxs.y then return 0, 0 end
	if tr.HitPos.z < self.mins.z then return 0, 0 end
	if tr.HitPos.z > self.maxs.z then return 0, 0 end
	
	return (tr.HitPos.y + self.maxs.y)*scale, (tr.HitPos.z + self.mins.z)*-scale
	
end

function ENT:PaintMap(x,y)
	if SERVERS[self.sid].status == "Closed" then return end
	if SERVERS[self.sid].minimap.available then
		
		if !matTable["sassilization/minimaps/"..SERVERS[self.sid].map] then
			matTable["sassilization/minimaps/"..SERVERS[self.sid].map]=Material("sassilization/minimaps/"..SERVERS[self.sid].map)
		end
		if !texTable["sassilization/minimaps/"..SERVERS[self.sid].map] then
			texTable["sassilization/minimaps/"..SERVERS[self.sid].map]=surface.GetTextureID("sassilization/minimaps/"..SERVERS[self.sid].map)
		end
		
		surface.SetTexture( texTable["sassilization/minimaps/"..SERVERS[self.sid].map] )
		surface.DrawTexturedRect( x, y, 320, 320 )
		
		//Draw the buildings
		local items = SERVERS[self.sid].minimap.builtbldg
		if items and table.Count(items)>0 then
			for _, item in pairs( items ) do
				if ValidItem( item ) then
					if item.c then
						surface.SetDrawColor(item.c.r,item.c.g,item.c.b,item.c.a)
						surface.DrawRect(x+item.x*320/512-item.s*0.5,y+item.y*320/512-item.s*0.5,item.s,item.s)
						if item.a == 1 then
							surface.SetDrawColor(230, 0, 25,255*math.abs(math.sin(RealTime()*5)))
							surface.DrawRect(x+item.x*320/512-item.s*0.5,y+item.y*320/512-item.s*0.5,item.s,item.s)
						end
					end
				end
			end
		end
			
		//Draw the units
		local items = SERVERS[self.sid].minimap.builtunit
		if items and table.Count(items)>0 then
			for _, item in pairs( items ) do
				if ValidItem( item ) then
					local dir = (Vector( item.x, item.y, 0 )-Vector( item.px, item.py, 0 )):GetNormal()
					local dis = Vector( item.x, item.y, 0 ):Distance(Vector( item.px, item.py, 0 ))
					if dis < .2 then
						item.px = item.x
						item.py = item.y
					else
						item.px = item.px + dir.x*0.05
						item.py = item.py + dir.y*0.05
					end
					surface.SetDrawColor(item.c.r,item.c.g,item.c.b,item.c.a)
					surface.DrawRect(x+item.px*320/512-item.s*0.5,y+item.py*320/512-item.s*0.5,item.s,item.s)
					if item.a == 1 then
						surface.SetDrawColor(230, 0, 25,255*math.abs(math.sin(RealTime()*5)))
						surface.DrawRect(x+item.px*320/512-item.s*0.5,y+item.py*320/512-item.s*0.5,item.s,item.s)
					end
				end
			end
		end
		
	elseif SERVERS[self.sid].map then
		
		if !matTable["sassilization/mapicons/"..SERVERS[self.sid].map] then
			if(file.Exists("../materials/sassilization/mapicons/"..SERVERS[self.sid].map..".vmt")) then
				matTable["sassilization/mapicons/"..SERVERS[self.sid].map] = Material( "sassilization/mapicons/"..SERVERS[self.sid].map )
			else
				matTable["sassilization/mapicons/"..SERVERS[self.sid].map] = matNewMap
			end
		end
		if !texTable["sassilization/mapicons/"..SERVERS[self.sid].map] then
			if(file.Exists("../materials/sassilization/mapicons/"..SERVERS[self.sid].map..".vmt")) then
				texTable["sassilization/mapicons/"..SERVERS[self.sid].map] = surface.GetTextureID("sassilization/mapicons/"..SERVERS[self.sid].map)
			else
				texTable["sassilization/mapicons/"..SERVERS[self.sid].map] = texNewMap
			end
		end
		
		surface.SetDrawColor(255,255,255,255)
		surface.SetTexture( texTable["sassilization/mapicons/"..SERVERS[self.sid].map] )
		surface.DrawTexturedRect( x, y, 320, 320 )
		
	end
	if SERVERS[self.sid].map then
		surface.SetFont("font_spray")
		local mapname =  SERVERS[self.sid].map
		mapname = mapname:gsub( "sa_", "" )
		mapname = mapname:gsub( "_", " " )
		DrawText( mapname, x + 10, y, Color( 60, 60, 60, 255 ), 0.75 )
		surface.SetFont("Tb0")
	end
end

local triTex = surface.GetTextureID( "VGUI/white" )

local function triUp( x, y )
	
	x = x or 0
	y = y or 0
	
	local tri = {{},{},{}}
		tri[1]["x"] = x
		tri[1]["y"] = y-6
		tri[1]["u"] = 0
		tri[1]["v"] = 0
		tri[2]["x"] = x+10
		tri[2]["y"] = y+6
		tri[2]["u"] = 1
		tri[2]["v"] = 1
		tri[3]["x"] = x-10
		tri[3]["y"] = y+6
		tri[3]["u"] = 0
		tri[3]["v"] = 1
	return tri
	
end

local function triDown( x, y )
	
	x = x or 0
	y = y or 0
	
	local tri = {{},{},{}}
		tri[1]["x"] = x-10
		tri[1]["y"] = y-6
		tri[1]["u"] = 0
		tri[1]["v"] = 0
		tri[2]["x"] = x+10
		tri[2]["y"] = y-6
		tri[2]["u"] = 1
		tri[2]["v"] = 0
		tri[3]["x"] = x
		tri[3]["y"] = y+6
		tri[3]["u"] = 0
		tri[3]["v"] = 1
	return tri
	
end

function ENT:PaintChat(x,y)
	if SERVERS[self.sid].status == "Closed" then return end
	if !SERVERS[self.sid].chat then return end
	if #SERVERS[self.sid].chat <= 0 then return end
	local num = 0
	local total = 0
	for k, v in pairs( SERVERS[self.sid].chat ) do
		if v.time + 60 > os.clock() and k > #SERVERS[self.sid].chat - 7 then
			total = total + 1
		end
	end
	for k, v in pairs( SERVERS[self.sid].chat ) do
		if v.time + 60 > os.clock() and k > #SERVERS[self.sid].chat - 7 then
			if v.n and v.c then
				local w, h = surface.GetTextSize( v.n )
				DrawText( v.n, x, y - total*24 + num*24, v.c )
				DrawText( string.sub( v.msg, string.len( v.n ) + 2 ), x+w, y - total*24 + num*24 )
			else
				DrawText( v.msg, x, y - total*24 + num*24 )
			end
			num = num + 1
		end
	end
end
]]

RunConsoleCommand("ias")