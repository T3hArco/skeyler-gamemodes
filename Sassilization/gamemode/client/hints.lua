surface.CreateFont("sa_hintText", {
	font = "Roboto",
	size = 18,
	weight = 800
})

local hintsConvar = CreateClientConVar( "sass_disablehints", 0, true, true )

local hints = {}
local hintPanels = {}

local panel = {}

function panel:Init()
	self.startTime = CurTime()
	
	self:SetPos(ScrW(), ScrH() /2)
end

function panel:SetText(text)
	self.text = text
	
	surface.SetFont("sa_hintText")
	
	local width, height = surface.GetTextSize(text)
	
	self:SetSize(width +12, height +4)
end

function panel:UpdatePosition()
	local x, y = ScrW(), ScrH() /2 -35
	
	for k, v in pairs(hintPanels) do
		if (ValidPanel(v)) then
			v:MoveTo(x -(v:GetWide() +10), y, 0.4, 0, 0.9)
			
			y = y +(v:GetTall() +5)
		end
	end
end

function panel:SetTime(length)
	self.time = length
end

function panel:Think()
	if (self.startTime +self.time < CurTime()) then
		hintPanels[self] = nil
		
		self:UpdatePosition()
		
		self:Remove()
	end
end

function panel:Paint(w, h)
	draw.RoundedBox(4, 0, 0, w, h, Color(59, 59, 59, 200))
	
	draw.SimpleText(self.text, "sa_hintText", w /2 +1, h /2 +1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.text, "sa_hintText", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("sa_hint", panel, "EditablePanel")

function GM:AddHint(unique, text, length)
	hints[unique] = {text, length, false}
end

function GM:ThrowHint(unique, delay)
	delay = delay or 0
	
	timer.Simple(delay, function()
		local enableHints = hintsConvar:GetFloat() -- do this here so it updates immediately after someone changes their settings
		if enableHints == 0 then
			local data = hints[unique]
			
			if (data and !data[3]) then
				local hint = vgui.Create("sa_hint")
				hint:SetText(data[1])
				hint:SetTime(data[2])
				
				hintPanels[hint] = hint
				
				hint:UpdatePosition()
				
				data[3] = true
				
				surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")
			end
		end
	end)
end

function GM:SuppressHint(unique)
	hints[unique] = nil
end

net.Receive("SuppressHint", function(bits)
	local hint = net.ReadString()
	
	GAMEMODE:SuppressHint(hint)
end)

net.Receive("AddHint", function(bits)
	local hint = net.ReadString()
	local delay = net.ReadUInt(8)
	
	GAMEMODE:ThrowHint(unique, delay)
end)

--Make these actually happen in a situation where they're useful

GM:ThrowHint("OpenMenu", 5)
GM:ThrowHint("OpenMenu2", 10)
GM:ThrowHint("Annoy1", 30)
GM:ThrowHint("Annoy2", 35)
GM:ThrowHint("UnitSelect1", 50)
GM:ThrowHint("City1", 60)
GM:ThrowHint("Tip2", 120)
GM:ThrowHint("Tip1", 135)
GM:ThrowHint("BuildTip1", 180)
GM:ThrowHint("Upgrade", 210)

GM:AddHint("OpenMenu",		"To open the build menu, hold the Q key.", 										11)
GM:AddHint("OpenMenu2",		"Building units is done by holding the E key.", 								11)
GM:AddHint("Annoy1",		"You can turn off the hints in the scoreboard.", 								11)
GM:AddHint("Annoy2",		"Press and hold tab to view the scoreboard.", 									11)
GM:AddHint("UnitSelect1",	"Select units by holding Primary Fire to drag a selection sphere over them", 	11)
GM:AddHint("City1",			"Cities will automatically grow and populate.", 								11)
GM:AddHint("Tip1",			"To win the round, be the first to get " .. SA.WIN_GOAL .. " gold.", 			11)
GM:AddHint("Tip2",			"1 gold is gained every 7 seconds for each city you have.", 					11)
GM:AddHint("Upgrade",		"Upgrade buildings by building the same one on top of it.", 					11)
GM:AddHint("BuildTip1",		"Hold 'Sprint' while building a wall and it won't make a connection.", 			11)