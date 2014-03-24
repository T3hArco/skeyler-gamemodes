---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

local net = net 
local surface = surface 
local vgui = vgui 
local math = math 
local hook = hook 
local string = string 
local tonumber = tonumber 
local unpack = unpack 
local pairs = pairs 
local tostring = tostring 
local print = print 
local ScrH = ScrH 


module("vote") 

local isVoting = false 
local currentvote = false 
local votepanel = false 
local outsidepadding = 14
local padding = 5 
local maxw, maxh = 50, outsidepadding 
local myvote = false 

function StartVote() 
	isVoting = true 

	CreateVote() 
end 

function EndVote() 
	isVoting = false 
	currentvote = false 

	DeleteVote()
end 

net.Receive("ss_startvote", function() 
	currentvote = {} 
	currentvote.name = net.ReadString() 
	currentvote.ply = net.ReadString() 
	currentvote.options  = net.ReadTable() 
	currentvote.votes = 0

	StartVote() 
end )

net.Receive("ss_endvote", function() EndVote() end )

---------------
---------------

surface.CreateFont("ss_votenormal", {font = "Helvetica LT Std Light", size = 16, weight = 400})
surface.CreateFont("ss_votesmall", {font = "Helvetica LT Std Light", size = 10, weight = 400, italic = true})

function DeleteVote() 
	if votepanel and votepanel:IsValid() then 
		votepanel:Remove() 
		votepanel = false 
	end 
end 

function CreateVote() 
	DeleteVote() -- make sure the last one is gone 

	local w, h
	local textinfo = {} 
	local lasty = 20

	-- We're basically going to cache all the data
	for k,v in pairs({currentvote.name, "Vote called by "..currentvote.ply, "Press the corresponding numpad key to vote.", unpack(currentvote.options)}) do 
		if k == 2 or k == 3 then surface.SetFont("ss_votesmall") else surface.SetFont("ss_votenormal") end 
		
		if k >= 4 then 
			v = tostring(k-3)..". "..v
			w, h = surface.GetTextSize(v) 
		else 
			w, h = surface.GetTextSize(v) 
		end 

		textinfo[k] = {} 
		textinfo[k].text = v 
		textinfo[k].w = w 
		textinfo[k].h = h 
		textinfo[k].y = lasty 

		lasty = lasty+h+padding 
		if k == 2 then lasty=lasty+7 end 
		maxw = math.max(maxw, w)+outsidepadding*2 
	end 
	maxh = lasty-padding+outsidepadding 

	votepanel = vgui.Create("DFrame")
	votepanel:SetSize(maxw, maxh) 
	votepanel:SetPos(padding, ScrH()*0.25)   
	votepanel:SetTitle("")
	votepanel:SetDeleteOnClose(false)
	votepanel:ShowCloseButton(false) 
	votepanel:SetDraggable(false) 
	votepanel:SetVisible(true) 

	function votepanel:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 230) 
		surface.DrawRect(0, 0, w, h) 

		surface.SetDrawColor(35, 150, 229, 204) 
		surface.DrawRect(0, 0, w, 5) 

		for k,v in pairs(textinfo) do 
			if k == 2 or k == 3 then 
				surface.SetFont("ss_votesmall") 
				surface.SetTextColor(255, 255, 255, 75) 
			else 
				surface.SetFont("ss_votenormal") 
				if k == currentvote.votes+3 then 
					surface.SetTextColor(143, 230, 101) 
				else 
					surface.SetTextColor(255, 255, 255, 255) 
				end  
			end 

			if k == 2 then 
				local string1, string2 
				string1 = string.sub(v.text, 1, 15) 
				string2 = string.sub(v.text, 15)  
				surface.SetTextPos(outsidepadding, v.y) 
				surface.DrawText(string1) 
				local w2,h2 = surface.GetTextSize(string1) 
				surface.SetTextColor(35, 150, 229) 
				surface.SetTextPos(outsidepadding+w2, v.y) 
				surface.DrawText(string2) 

				surface.SetDrawColor(255, 255, 255, 5) 
				surface.DrawLine(outsidepadding, v.y+h2+5, w-outsidepadding, v.y+h2+5) 
			else 
				surface.SetTextPos(outsidepadding, v.y) 
				surface.DrawText(v.text) 
			end 
		end 
	end

	maxw, maxh = 50, outsidepadding --reset to default 
end 

---------------------
---------------------

hook.Add("PlayerBindPress","ss_vote",function(ply,bind,pressed)
	if isVoting and string.match(bind, "slot%d+") then 
		local num = string.gsub(bind,"slot","")
		num = tonumber(num) 

		if num >= 1 and num <= #currentvote.options then 
			if currentvote.votes != num then 
				currentvote.votes = num 
				net.Start("ss_vote") 
					net.WriteInt(num, 4) 
				net.SendToServer() 
			end 
		end 
	end 
end)