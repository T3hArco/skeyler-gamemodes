util.AddNetworkString("GAS2M")

local pm = FindMetaTable("Player")

local function G2M(p,n,s,t)
	net.Start("GAS2M")
	net.WriteString(tostring(n))
	net.WriteString(tostring(s))
	net.WriteString(tostring(t))
	net.Send(p)
end

function pm:ReportMe(r)
	print("reporting: "..self:Nick().." now for "..r)
	local p = {}
	for k,v in pairs(player.GetAll()) do
		if(v:IsAdmin()) then
			table.insert(p,v)
		end
	end
	if(p[1]) then
		G2M(p,self:Nick(),self:SteamID(),r)
	end
end

local lastscrolltime = {}
local thisscrolltime = {}
local canrecord = {}
local onground = {}
local bhop = {}
local timebetween = {}
local timebetweeno = {}
local dirty = {}
local dirty2 = {}
--local dirty3 = {}
local det = {}

hook.Add("StartCommand","CheckScripters",function(ply,cmd)
	local b = cmd:GetButtons()
	if(canrecord[ply] && !thisscrolltime[ply] && bit.band(b,IN_JUMP)>0) then
		thisscrolltime[ply] = CurTime() --first scroll
	end
	
	if(timebetweeno[ply] && lastscrolltime[ply] && thisscrolltime[ply]) then
		--dirty3[ply] = 0
		local n = (thisscrolltime[ply] - lastscrolltime[ply])-(timebetween[ply]-timebetweeno[ply])
		lastscrolltime[ply] = nil
		local na = math.Clamp(n,-0.2,0.2)
		if(n == 0) then
			if(!dirty2[ply]) then
				dirty2[ply] = 0
			end
			if(dirty2[ply] == 0) then
				timer.Simple(10,function()
					det[ply] = false
					dirty2[ply] = 0
				end)
			end
			dirty2[ply] = dirty2[ply] + 1
		elseif(n != na) then
			dirty[ply] = 0
		end
		if(!dirty[ply]) then
			dirty[ply] = 0
		end
		dirty[ply] = dirty[ply] + 1
	end
	
	if(dirty[ply] && dirty[ply] >= 50) then
		dirty[ply] = 0
		ply:ReportMe("Possible Scripter - 50 sequential jumps with little variance.")
	end
	
	if(dirty2[ply] && dirty2[ply] > 4) then
		if(!det[ply]) then
			det[ply] = true
			ply:ReportMe("Possible Scripter - 5 jumps with 0 variance within 10 seconds.")
		end
	end
	
	--[[if(dirty3[ply] && dirty3[ply] >= 2) then
		dirty3[ply] = 0
		ply:ReportMe("Possible Scripter - 2 sequential jumps with no detectable variance.")
	end]]
	
	if(bhop[ply] && bit.band(b,IN_JUMP)>0) then
		bhop[ply] = false
		if(timebetween[ply]) then
			timebetweeno[ply] = timebetween[ply]
		end
		timebetween[ply] = CurTime()
		timer.Simple(0.1,function() 
			canrecord[ply] = true
		end)
	end
	
	if(!onground[ply] && ply:OnGround()) then
		onground[ply] = true
		--[[if(canrecord[ply] && !lastscrolltime[ply] && !thisscrolltime[ply]) then
			if(!dirty3[ply]) then
				dirty3[ply] = 0
			end
			dirty3[ply] = dirty3[ply] + 1
		end]]
		canrecord[ply] = false
		bhop[ply] = true
		lastscrolltime[ply] = nil
		if(thisscrolltime[ply]) then
			lastscrolltime[ply] = thisscrolltime[ply]
			thisscrolltime[ply] = nil
		end
		timer.Simple(0.1,function() 
			bhop[ply] = false
		end)
	elseif(!ply:OnGround()) then
		onground[ply] = false
	end
end)