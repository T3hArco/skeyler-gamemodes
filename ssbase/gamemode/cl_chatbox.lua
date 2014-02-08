---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

TIMESTAMPS = CreateClientConVar("ss_chat_timestamps", 0, true, false) 
TIMESTAMPS24 = CreateClientConVar("ss_chat_timestamps_24", 0, true, false)

TAG_MAT = Material("skeyler/tag_bg") 

surface.CreateFont("ChatLabel", {font="Arial", size=18, weight=1000})
surface.CreateFont("ChatLabel_Time", {font="Arial", size=15, weight=500})
surface.CreateFont("ChatFont", {font="Open Sans", size=18, weight=500})
surface.CreateFont("TagFont", {font="Myriad Pro", size=14, weight=800})

SCHAT = false
local Lines, AddChatText = {}, chat.AddText 

function chat.AddText(ply, ...) 
	local t, plychanges, add = {...}, {}, 0

	-- Replace players with team colors and names
	for k,v in pairs(t) do 
		if isentity(v) and v:IsPlayer() then 
			plychanges[k] = v 
		end 
	end 
	for k,v in pairs(plychanges) do 
		table.insert(t, k+add, team.GetColor(v:Team())) 
		t[k+1+add] = t[k+1+add]:Nick() 
		add=add+1 
	end 

	local Time = TIMESTAMPS24:GetBool() and os.date("[%H:%M:%S] ") or os.date("[%I:%M:%S] ")
	AddChatText(Color(255, 255, 255), Time, unpack(t))
	table.insert(Lines, 1, {info={ply=ply, Alpha=255, StayTime=CurTime()+3, time=Time, fakerank = ply and ply:IsFakenamed() and ply:GetFakeRank()}, t=t})
end 

hook.Add("HUDPaint", "PaintChatboxLines", function() 
	if !SCHAT then return end 

	local x, y = SCHAT:GetPos() 
	y = y-25
	x = x+1 
	local y2, count = y, 0 
	for k,v in pairs(Lines) do 
		if count < 10 then 
			local x2, String, Col, w, h = x+4, false, Color(255, 255, 255, 255) 
			if SCHAT:IsVisible() or v.info.StayTime >= CurTime() then 
				v.info.Alpha = 255 
				if SCHAT:IsVisible() then v.info.StayTime = CurTime()+3 end 
			else 
				v.info.Alpha = math.Approach(v.info.Alpha, 0, 1) 
			end 

			if v.info.ply and v.info.ply.GetRank and v.info.ply:GetRank() > 0 and ((v.info.fakerank and v.info.fakerank > 0) or !v.info.fakerank) then 
				local Col
				local Text

				local FakeRank = v.info.fakerank

				if FakeRank == 50 then
					Col = Color(255, 72, 72)
					Text = "ADMIN"
				elseif FakeRank == 20 then
					Col = Color(87, 198, 255)
					Text = "DEV"
				elseif FakeRank == 1 then
					Col = Color(255, 216, 0)
					Text = "VIP"
				else
					Col = v.info.ply:GetRankColor() 
					Text = string.upper(v.info.ply:GetRankName()) 
				end
				
				surface.SetDrawColor(Col.r, Col.g, Col.b, v.info.Alpha) 
				surface.SetMaterial(TAG_MAT) 
				surface.DrawTexturedRect(x-58, y2, 64, 16) 
				surface.SetDrawColor(255, 255, 255, v.info.Alpha*0.1) 
				surface.DrawRect(x-58+1, y2+1, 56-2, 7) 

				surface.SetFont("TagFont") 
				local w, h = surface.GetTextSize(Text) 
				surface.SetTextColor(0, 0, 0, v.info.Alpha*0.5)
				surface.SetTextPos(((x-58/2)-w/2)+1, ((y2+16/2)-h/2)+1)
				surface.DrawText(Text)
				surface.SetTextColor(255, 255, 255, v.info.Alpha) 
				surface.SetTextPos((x-58/2)-w/2, (y2+16/2)-h/2)
				surface.DrawText(Text) 
			end 
			if TIMESTAMPS:GetBool() and v.info.time then 
				Col.a = v.info.Alpha
				surface.SetFont("ChatLabel_Time") 
				w, h = surface.GetTextSize(v.info.time) 
				surface.SetTextColor(34, 34, 34, v.info.Alpha) 
				surface.SetTextPos(x2+1, y2+1)
				surface.DrawText(v.info.time) 
				surface.SetTextPos(x2, y2)
				surface.SetTextColor(Col) 
				surface.DrawText(v.info.time)  
				x2 = x2+w
			end 

			for k2,v2 in pairs(v.t) do 
				String = false 
				if isentity(v2) then 
					if v2:IsValid() and v2:IsPlayer() then 
						String = v2:Name()
					end 
				elseif isstring(v2) and string.Trim(v2) != "" then 
					String = v2 
				else 
					Col = v2 
				end 
				Col.a = v.info.Alpha
				if String then 
					surface.SetFont("ChatLabel") 
					w, h = surface.GetTextSize(String) 
					surface.SetTextColor(34, 34, 34, v.info.Alpha) 
					surface.SetTextPos(x2+1, y2+1)
					surface.DrawText(String) 
					surface.SetTextPos(x2, y2)
					surface.SetTextColor(Col) 
					surface.DrawText(String) 
					x2 = x2+w 
				end 
			end 
			count = count+1
			y2 = y2-h-1 
		else 
			break
		end 
	end 
end )

local PANEL = {} 
function PANEL:Init() 
	self.On = false 
	self:SetHistoryEnabled( false )
	self.History = {}
	self.HistoryPos = 0
	self.Lines = {} 
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackgroundEnabled( false )
	self:SetDrawBorder( false )
	self:SetDrawBackground( false )
	self:SetEnterAllowed( true )
	self:SetUpdateOnType( false )
	self:SetNumeric( false )
	self.m_bLoseFocusOnClickAway = false
	self:SetCursor( "beam" )	
	self:SetFont( "ChatFont" )
	self:SetTabbingDisabled(true) 
	self:SetTextColor(Color(34, 34, 34, 255)) 
	self:SetHighlightColor(Color(34, 34, 34, 255))

	self:NoClipping(true)  

	self.Options = vgui.Create("DPanel")

	self.Options.Timestamps = vgui.Create("DCheckBoxLabel", self.Options) 
	self.Options.Timestamps:SetText("Enable Timestamps")  
	self.Options.Timestamps:SetWide(130) 
	self.Options.Timestamps:SetConVar("ss_chat_timestamps")
	self.Options.Timestamps:SetChecked(TIMESTAMPS:GetBool()) 

	self.Options.HourFormat = vgui.Create("DCheckBoxLabel", self.Options) 
	self.Options.HourFormat:SetText("24 Hour Timestamps")  
	self.Options.HourFormat:SetWide(200) 
	self.Options.HourFormat:SetConVar("ss_chat_timestamps_24")
	self.Options.HourFormat:SetChecked(TIMESTAMPS24:GetBool()) 

	function self.Options.Paint(w, h) 
		local w, h = self.Options:GetSize()  
		surface.SetDrawColor(85, 85, 85, 255*0.8) 
		surface.DrawRect(0, 0, w, h) 
	end  
	
	derma.SkinHook( "Scheme", "TextEntry", self )
	self:PerformLayout() 
	self.Options:SetVisible(false) 
	self:SetVisible(false)
end 

function PANEL:Toggle(override) 
	if self.On or override == true then 
		self:SetVisible(false) 
		self:SetText("")
		self.Options:SetVisible(false) 
	else 
		self:SetVisible(true) 
		self:MakePopup() 
		self.Options:SetVisible(true) 
	end 
end 

function PANEL:PerformLayout()
	surface.SetFont("ChatLabel") 
	local w, h = surface.GetTextSize("Chat") 

	self:SetSize(500, 25) 
	self:SetPos(80+w+10+4, ScrH()-145-70) 

	self.Options:SetSize(self:GetWide(), 25)  
	self.Options:SetPos(80+w+10+4, ScrH()-145-70+25) 

	self.Options.Timestamps:SetPos(5, self.Options:GetTall()/2-self.Options.Timestamps:GetTall()/2)
	self.Options.HourFormat:SetPos(5+self.Options.Timestamps:GetWide()+5, self.Options:GetTall()/2-self.Options.HourFormat:GetTall()/2)

	derma.SkinHook( "Layout", "TextEntry", self )
end

function PANEL:OnEnter()
	self:UpdateConvarValue()
	self:OnValueChange( self:GetText() )

	local chat = string.Trim(self:GetValue()) 
	if chat and chat != "" then 
		RunConsoleCommand("say", chat) 
	end 
	self:Toggle(true)  
end

local Label, Skip = "Chat", false 
function PANEL:Paint(w, h)
	surface.SetFont("ChatLabel") 
	local tw, th = surface.GetTextSize(Label) 

	draw.RoundedBox( 2, 0-tw-4-20, 0, w+tw+4+20, h, Color(255, 255, 255, 255) )

	surface.SetDrawColor(54, 54, 54, 255) 
	surface.DrawRect(0-tw-20-2, 2, tw+20, h-4)
	surface.SetDrawColor(85, 85, 85, 255)
	surface.DrawRect(0-tw-20-2, 2, tw+20, (h-4)/2)

	surface.SetTextColor(255, 255, 255, 255) 
	surface.SetTextPos((0-2-10)-tw, h/2-th/2)
	surface.DrawText(Label) 

	derma.SkinHook( "Paint", "TextEntry", self, w, h )

	return false
end
vgui.Register("SChatbox_Bar", PANEL, "DTextEntry") 

hook.Add("InitPostEntity", "CreateSChat", function() SCHAT = vgui.Create("SChatbox_Bar") end)

function GM:StartChat(team) 
	return true 
end 

function GM:OnPlayerChat( ply, text, Team, dead )
	if dead then 
		chat.AddText(ply, Color(255, 226, 109), "*DEAD* ", ply, Color(255, 255, 255), ": ", text) 
	elseif Team then 
		chat.AddText(ply, Color(255, 226, 109), "*TEAM* ", ply, Color(255, 255, 255), ": ", text)
	else 
		chat.AddText(ply, ply, Color(255, 255, 255), ": ", text) 
	end 
	return true 
end 

function GM:ChatText( id, name, text, type ) 
	if id == 0 then 
		chat.AddText(false, Color(255, 226, 109), text) 
	end 
	return true 
end

function GM:PlayerBindPress(ply, bind, pressed) 
	if(bind == "messagemode" or bind == "messagemode2") then
		SCHAT:Toggle() 
		return true
	end
end 

function GM:OnAchievementAchieved( ply, achid )	
	chat.AddText( false, team.GetColor(ply:Team()), ply:Name(), Color( 230, 230, 230 ), " earned the achievement ", Color( 255, 200, 0 ), achievements.GetName( achid ) );
end