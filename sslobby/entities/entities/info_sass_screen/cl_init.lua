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

function button:OnMousePressed()
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
	
	draw.SimpleText("JOIN QUEUE", "ss.sass.screen.button", x +w -800, y +h -462, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
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
		
		self.registered = true
	else
		local status = self:GetStatus()
		
		if (self.__status != status) then
			self.statusMessage = statusMessages[status] or statusMessages[STATUS_LINK_UNAVAILABLE]

			self.__status = status
		end
		
		self:UpdateMouse()
		
		cam.Start3D2D(self.cameraPosition, self.cameraAngles, 0.1)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			
			DrawPanels(panelUnique, self, 0.1)
	
			self:PaintMap(40, 640 *0.25 +80)
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
	
	if (status == STATUS_LINK_UNAVAILABLE) then
		surface.SetDrawColor(unavailableColor)
		surface.DrawRect(x, y -136, 14, 156)
	else
		local players = SS.Lobby.Link:GetQueue(self:GetTriggerID())
		
		self.approachC = self.approachC or 0
		self.approachC = math.Approach(self.approachC, #players, 0.05)
		
		surface.SetDrawColor(60, 60, 60, 220)
		surface.DrawRect(x, y -(SS.Lobby.Link.MinPlayers /SS.Lobby.Link.MaxPlayers) *136, 14, 2)
		
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

local defaultMap = surface.GetTextureID("skeyler/graphics/icon_newmap")
local width, height = 359, 360

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
					object.x = object.x +direction.x *0.1
					object.y = object.y +direction.y *0.1
				end
			end
			
			local objectX = x +((object.x /width) *width) -object.width /2
			local objectY = y +((object.y /height) *height) -object.height /2
			
			surface.SetDrawColor(object.color or color_white)
			surface.DrawRect(objectX, objectY, object.width, object.height)
		end
	else
		--draw.Texture(x, y, width, height, color_white, defaultMap)
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

local cursor = Material("icon16/cursor.png")

function ENT:DrawMouse()
	if (self.mousePosition and self.mousePosition.x > 0 and self.mousePosition.y > 0 and self.mousePosition.x < screenWidth *2 /cameraScale and self.mousePosition.y < screenHeight *2 /cameraScale) then
		draw.Material(self.mousePosition.x -8, self.mousePosition.y -8, 16, 16, color_white, cursor)
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

local function mousePosition(self,scale)
	
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

--RunConsoleCommand("ias")