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

local LeadboardTexture = surface.GetTextureID("sassilization/leaderboards/sass_info")

local ColInGame = Color(255, 38, 28, 255)
local preparingColor = Color(128, 255, 128, 255)

local StatusMessages = {"Ready", "Closed", "In-Game", "Preparing"}
local StatusMessagesEx = {"Waiting for enough players to join: %i/%i", "This server is not up at the moment", "Game In Progress, you cannot join", "The game will be initalized in %i seconds."}
local StatusTextures = {surface.GetTextureID("sassilization/ready"),  surface.GetTextureID("sassilization/closed"), surface.GetTextureID("sassilization/forbidden"), surface.GetTextureID("sassilization/ready")}

local mouseWidth, mouseHeight = 64, 32
local camOffset = Vector(0.1, -mouseWidth, mouseHeight)
local camScale = 0.1

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
	self.CamPos = self.Pos + (self:GetRight() * Width) + (self:GetUp() * Height) + (self:GetForward() * 0.1)
	
	self.Ang = self:GetAngles()
	self.CamAng = Angle(0, self.Ang.y + 90, self.Ang.p + 90)
	
	self.Bounds = Vector(1, 1, 1) * Width
	
	self.intersectPoint = Vector()
	self.projectionPos = self:LocalToWorld(camOffset)
	self.projectionAng = self.CamAng
	self.projectionNorm = self:GetForward()
	self.mousePos = Vector()
end

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Draw()
	self:SetRenderBounds(self.Bounds * -1, self.Bounds)

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
		
		cam.Start3D2D(self.CamPos, self.CamAng, 0.1)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(LeadboardTexture)
			surface.DrawTexturedRect(0, 0, 1280, 640)
			
			-- self.mtxt = ""
			-- self.mx,self.my = MousePos(self)
			
			self:PaintStatus()
			
			if (status == STATUS_LINK_READY) then
				self:PaintCartridge(38, 584)
			--elseif(self.Status == CommLink.Status.INGAME) then
		--		self:PaintScoreboard()
		--		self:PaintChat(614, 184)
		--		self:PaintMap( 924, 277 )
			end
		--	self:PaintMap( 921, 281 )
		--	self:PaintMessage(617, 229)
			self:PaintMap(916, 275)
			
			self:DrawMouse()
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

local defaultMap = surface.GetTextureID("sassilization/leaderboards/new_map")
local width, height = 333, 334

function ENT:PaintMap(x, y)
	local data = SS.Lobby.Link:GetScreen(self:GetTriggerID())
	
	if (data.map != "") then
		draw.Texture(x, y, width, height, color_white, data.map)
		
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
		self.mousePos = self.mousePos /camScale
	end
	
end

function ENT:DrawMouse()
	self:UpdateMouse()
	if( self.mousePos and self.mousePos.x > 0 &&
		self.mousePos.y > 0 &&
		self.mousePos.x < mouseWidth * 2 / camScale &&
		self.mousePos.y < mouseHeight * 2 / camScale) then
		
		surface.SetDrawColor(Color(0,0,0,200))
		surface.DrawRect( self.mousePos.x - 6, self.mousePos.y - 6, 12, 12)
		surface.SetDrawColor(Color(0,0,0,200))
		surface.DrawOutlinedRect( self.mousePos.x - 6, self.mousePos.y - 6, 12, 12)
		
		--DrawText( tostring(math.Round(self.mousePos.x)).." "..tostring(math.Round(self.mousePos.y)), self.mousePos.x, self.mousePos.y+20 )
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