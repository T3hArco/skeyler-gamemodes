---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

local mmm, rtvpanel, timeleft, maps = 6

surface.CreateFont("ss_mapvote", {font="Arvil Sans", size=36, weight=500})
surface.CreateFont("ss_mapvote_blur", {font="Arvil Sans", size=36, weight=500, blursize=4, antialias=false})
surface.CreateFont("ss_vote_item", {font="Arvil Sans", size=32, weight=400})
surface.CreateFont("ss_vote_item_blur", {font="Arvil Sans", size=32, weight=400, blursize=4, antialias=false})

local function StartTheRTV()
	if(rtvpanel && rtvpanel:IsVisible()) then return end
	
	timer.Simple(28,function()
		if (rtvpanel and rtvpanel:IsVisible()) then 
			rtvpanel:Remove()
		end
		LocalPlayer().canvote = false
	end)
	timeleft = CurTime() + 28
	LocalPlayer().canvote = true
	
	rtvpanel = vgui.Create( "DFrame" )
	rtvpanel:SetSize(300, 240)
	rtvpanel:SetPos(20, 20)
	rtvpanel:SetTitle("")
	rtvpanel:ShowCloseButton(false)
	rtvpanel:SetDraggable(false)
	rtvpanel.Paint = function( self, w, h )
		local t = string.FormattedTime(timeleft-CurTime(), "%02i:%02i")
		surface.SetFont("ss_mapvote") 
		local tw,th = surface.GetTextSize("0:30") --hopefully thats a fatass number
		surface.SetFont("ss_mapvote_blur") 
		surface.SetTextPos(20, 0) 
		surface.SetTextColor(0, 0, 0, 255) 
		surface.DrawText("VOTE FOR THE NEXT MAP") 
		surface.SetTextPos(280-tw+1, 1)
		surface.DrawText(t) 
		surface.SetFont("ss_mapvote") 
		surface.SetTextPos(21, 1) 
		surface.SetTextColor(0, 0, 0, 180) 
		surface.DrawText("VOTE FOR THE NEXT MAP") 
		surface.SetTextPos(20, 0) 
		surface.SetTextColor(238, 220, 104, 255) 
		surface.DrawText("VOTE FOR THE NEXT MAP") 
		surface.SetTextColor(0, 0, 0, 180)
		surface.SetTextPos(280-tw+1, 1)
		surface.DrawText(t)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(280-tw, 0)
		surface.DrawText(t) 
		
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(280-tw, 0)
		surface.DrawText(string.FormattedTime(timeleft-CurTime(), "%02i:%02i")) 
		surface.SetDrawColor(Color(255,255,255,100))
		surface.DrawRect(6,42,288,2)
		surface.SetDrawColor(Color(255,255,255,75))
		surface.DrawRect(4,42,2,2)
		surface.DrawRect(294,42,2,2)
		surface.SetDrawColor(Color(255,255,255,50))
		surface.DrawRect(2,42,2,2)
		surface.DrawRect(296,42,2,2)
		surface.SetDrawColor(Color(255,255,255,25))
		surface.DrawRect(0,42,2,2)
		surface.DrawRect(298,42,2,2)
	end
	
	local option = 1
	rtvpanel.options = {}
	for i=1,mmm,1 do
		local listitem = vgui.Create("DPanel", rtvpanel) 
		listitem:SetPos(0, 60+30*(i-1))
		listitem:SetSize(300, 30)
		listitem.Paint = function(self,w,h)
			surface.SetFont("ss_vote_item")

			if(i == 6) then
				local tw, th = surface.GetTextSize(i..") Extend Current Map")
				surface.SetFont("ss_vote_item_blur")
				surface.SetTextPos(20, h/2-th/2) 
				surface.SetTextColor(0, 0, 0, 255) 
				surface.DrawText(i..") Extend Current Map") 
				surface.SetTextPos(21, h/2-th/2+1) 
				surface.SetFont("ss_vote_item")
				surface.SetTextColor(0, 0, 0, 180) 
				surface.DrawText(i..") Extend Current Map") 
				if(self.votedfor) then
					surface.SetTextColor(238, 220, 104, 255) 
				else
					surface.SetTextColor(255, 255, 255, 255) 
				end
				surface.SetTextPos(20, h/2-th/2) 
				surface.DrawText(i..") Extend Current Map") 
			else
				local tw, th = surface.GetTextSize(i..") "..maps[i]) 
				surface.SetFont("ss_vote_item_blur")
				surface.SetTextPos(20, h/2-th/2)
				surface.SetTextColor(0, 0, 0, 255) 
				surface.DrawText(i..") "..maps[i]) 
				surface.SetFont("ss_vote_item")
				surface.SetTextColor(0, 0, 0, 180) 
				surface.SetTextPos(21, h/2-th/2+1) 				
				surface.DrawText(i..") "..maps[i]) 
				if(self.votedfor) then
					surface.SetTextColor(238, 220, 104, 255) 
				else
					surface.SetTextColor(255, 255, 255, 255) 
				end
				surface.SetTextPos(20, h/2-th/2) 
				surface.DrawText(i..") "..maps[i]) 
			end
		end 
		listitem.votedfor = false
		rtvpanel.options[i] = listitem
	end
end

hook.Add("PlayerBindPress","DoMapVote",function(ply,bind,pressed)
	if(ply.canvote && string.match(bind, "slot%d+")) then
		local num = string.gsub(bind,"slot","")
		local slot = tonumber(num)
		if(slot >= 1 and slot <= mmm) then
			if(!ply.cooldown || (ply.cooldown < CurTime())) then
				if(ply.curopt) then
					rtvpanel.options[ply.curopt].votedfor = false
				end
				rtvpanel.options[slot].votedfor = true
				net.Start("ss_mapvote")
				net.WriteInt(slot,4)
				net.SendToServer()
				ply.curopt = slot
				ply.cooldown = CurTime() + 2
				return true
			end
		end
	end
end)

net.Receive("ss_rtv",function()
	maps = net.ReadTable()
	local ex = (net.ReadBit() == 1)
	if(ex) then
		mmm = 6
	else
		mmm = 5
	end
	timer.Simple(0,function()
		StartTheRTV()
	end)
end)