local la032sdt13d92f1a3h13 = 0 
local b2ida82ks34d6u23j8d = 0 
local b1ida82ks34d6u23j8d = 0 
local i2na832jd7s6a91k = 0
local p9j2usd3gh478dus8 = nil
local jk49a82js84us82or0 = false
local b01aj298sl29alf34 = false
local b02aj298sl29alf34 = false

local ns = _G["net"]["Start"]
local nw = _G["net"]["WriteString"]
local ns2 = _G["net"]["SendToServer"]
local ht = _G["hook"]["GetTable"]
local hr = _G["hook"]["Remove"]

local didjump = false

local function makeString(l)
        if l < 1 then return nil end -- Check for l < 1
        local s = "" -- Start string
        for i = 1, l do
                s = s .. string.char(math.random(32, 126)) -- Generate random number from 32 to 126, turn it into character and add to string
        end
        return s -- Return string
end

local l20aksd2iel29sl = makeString(10)
local g92ixks82k89s920 = makeString(10)

function loa92lzsd20p4o6i34(l2ka83)
	ns("182kasdl321")
	nw(l2ka83)
	ns2()
end

function hook.Remove(hook,arg)
	if(hook == "PlayerBindPress" and arg == "CheckIllegalKey") then
		loa92lzsd20p4o6i34("Trying to overwrite hooks.")
		return
	elseif(hook == "PlayerBindPress" and arg == l20aksd2iel29sl) then
		loa92lzsd20p4o6i34("Trying to overwrite hooks.")
		return
	elseif(hook == "CreateMove" and arg == g92ixks82k89s920) then
		loa92lzsd20p4o6i34("Trying to overwrite hooks.")
		return
	end
	hr(hook,arg)
end

function j18ak28sj2k3i4u5j32()
	if(b2ida82ks34d6u23j8d > 10) then
		b2ida82ks34d6u23j8d = 0
		loa92lzsd20p4o6i34("10 1 scroll jumps - possible scripter.")
	end
	if(i2na832jd7s6a91k > 10) then
		i2na832jd7s6a91k = 0
		loa92lzsd20p4o6i34("10 emulated scroll jumps - possible scripter.")
	end
	if(b1ida82ks34d6u23j8d > 10) then
		b1ida82ks34d6u23j8d = 0
		loa92lzsd20p4o6i34("10 11 scroll jumps - possible macro/hyperscroll.")
	end
	if(!ht()["PlayerBindPress"][l20aksd2iel29sl]) then
		loa92lzsd20p4o6i34("Trying to remove hooks.")
	end
	if(!ht()["CreateMove"][g92ixks82k89s920]) then
		loa92lzsd20p4o6i34("Trying to remove hooks.")
	end
	timer.Simple(1,j18ak28sj2k3i4u5j32)
end
timer.Simple(15,j18ak28sj2k3i4u5j32) -- 15 seconds of no scripts :D

hook.Add("PlayerBindPress",l20aksd2iel29sl,function(p,bind,pr)
	if(p == LocalPlayer() && string.find(bind, "+jump")) then
		la032sdt13d92f1a3h13 = la032sdt13d92f1a3h13 + 1
	end
end)

local ground = false
local jump2 = false
local bhop = false

local function abababababababab()
	if(jk49a82js84us82or0) then return end
	jk49a82js84us82or0 = true
	timer.Simple(.01,function()
		jk49a82js84us82or0 = false
	end)
	if(p9j2usd3gh478dus8 && ((CurTime()-p9j2usd3gh478dus8) > 0.4)) then
		timer.Simple(0.1,function()
			if(!LocalPlayer():IsOnGround() && (LocalPlayer():WaterLevel() == 0)) then
				i2na832jd7s6a91k = i2na832jd7s6a91k + 1
				if(!b03aj298sl29alf34) then
					b03aj298sl29alf34 = true
					timer.Simple(15,function()
						i2na832jd7s6a91k = 0
						b03aj298sl29alf34 = false
					end)
				end
			end
		end)
	end
	if(la032sdt13d92f1a3h13 < 2) then
		if(!b01aj298sl29alf34) then
			b01aj298sl29alf34 = true
			timer.Simple(15,function()
				b2ida82ks34d6u23j8d = 0
				b01aj298sl29alf34 = false
			end)
		end
		b2ida82ks34d6u23j8d = b2ida82ks34d6u23j8d + 1
	elseif(la032sdt13d92f1a3h13 > 11) then
		if(!b02aj298sl29alf34) then
			b02aj298sl29alf34 = true
			timer.Simple(15,function()
				b1ida82ks34d6u23j8d = 0
				b02aj298sl29alf34 = false
			end)
		end
		b1ida82ks34d6u23j8d = b1ida82ks34d6u23j8d + 1
	end
	la032sdt13d92f1a3h13 = 0
	p9j2usd3gh478dus8 = nil
end

hook.Add("CreateMove",g92ixks82k89s920,function(cmd)
	if(!LocalPlayer():IsOnGround() && bit.band(cmd:GetButtons(),IN_JUMP) > 0) then
		if(!jk49a82js84us82or0) then
			p9j2usd3gh478dus8 = CurTime()
		end
	end
	if(LocalPlayer():IsOnGround()) then
		if(!ground) then
			ground = true
			didjump = false
			jump2 = true
			timer.Simple(.05,function()
				jump2 = false
				if(LocalPlayer():IsOnGround()) then
					bhop = false
				end
			end)
			if(bhop) then
				abababababababab()
			end
		end
		if(bit.band(cmd:GetButtons(),IN_JUMP) > 0) then
			didjump = true
			if(jump2) then
				bhop = true
			end
		end
		ground = true
	else
		ground = false
	end
	if(LocalPlayer():WaterLevel() > 0) then
		didjump = false
	end
end)

net.Receive("GAS2M",function()
	local n = net.ReadString()
	local s = net.ReadString()
	local t = net.ReadString()
	chat.AddText(Color(255,255,255),"[",Color(200,100,50),"GAS2",Color(255,255,255),"] ("..n.." - "..s..") "..t)
end)