-- taken from sassilization lobby

local MONEY = {}
MONEY.coins = {}
MONEY.cps = 3 --Coins per Second
MONEY.timeleft = CurTime()
MONEY.w = 187
MONEY.h = 81
MONEY.velx = 0
MONEY.vely = 0
MONEY.x = 187
MONEY.y = ScrH()-MONEY.h

local HUDCoin_b = 0
local HUDCoin_c = 0
local HUDCoin_d = 0
local HUDCoin_i = 1
local HUDCoins = {}

local function PlayTink()
	surface.PlaySound("test001.wav")
end

function GM:AddCoin()

	local coin = {}
	coin.recv 	= SysTime()
	coin.income	= true
	coin.velx	= math.random(-5, -2)
	coin.vely	= 0
	coin.x		= ScrW()
	coin.y		= ScrH() - (MONEY.h * 1.5) + MONEY.h * 0.5 + math.random( -64, 64 ) 
	
	local diff	= LocalPlayer():GetMoney() - MONEY.amount + HUDCoin_b

	coin.value	= diff > 100 and math.min( math.Round( math.sqrt( diff ) * 0.5 ), diff ) or math.min( 1, diff )

	HUDCoin_b = HUDCoin_b + coin.value
	
	table.insert( HUDCoins, coin )
	
	HUDCoin_c = HUDCoin_c + 1
	HUDCoin_i = HUDCoin_i + 1
	
end

function GM:RemoveCoin()

	local coin = {}
	coin.recv 	= SysTime()
	coin.outcome	= true
	coin.velx	= math.random(-75, 75)
	coin.vely	= math.random( 50, 100 ) - 500
	coin.x		= MONEY.w
	coin.y		= MONEY.y
	
	PlayTink()
	local diff	= MONEY.amount - LocalPlayer():GetMoney()
	MONEY.amount	= MONEY.amount - math.min( math.Round( math.sqrt( diff ) * 0.5 ), diff + HUDCoin_b )
	
	table.insert( HUDCoins, coin )
	
	HUDCoin_d = HUDCoin_d + 1
	HUDCoin_i = HUDCoin_i + 1
	
end

local function DrawCoin(v)
	local x = v.x
	local y = v.y
	
	v.w = v.w or (v.outcome and math.random( 24, 32 ) or MONEY.w)
	local w,h = v.w, v.w

	draw.SimpleRect(x, y, 5, 5, Color(69, 192, 255, 140))
	draw.SimpleRect(x +5, y +5, 5, 5, Color(69, 192, 255, 220))
	draw.SimpleRect(x, y +10, 5, 5, Color(69, 192, 255, 255))

	local spd = RealFrameTime()
	
	v.y = v.y + v.vely * spd
	v.x = v.x + v.velx * spd
	
	if v.income then
		
		local ideal_y = ScrH() - MONEY.h 
		local ideal_x = v.w
		
		local dist = ideal_y - v.y
		
		v.vely = v.vely + dist * spd * 1
		
		if (math.abs(dist) < 2 && math.abs(v.vely) < 0.1) then v.vely = 0 end
		
		local dist = ideal_x - v.x
		
		v.velx = v.velx + dist * spd * 1
		
		if (math.abs(dist) < 2 && math.abs(v.velx) < 0.1) then v.velx = 0 end
		
	elseif v.outcome then
		v.vely = v.vely + spd * 500
	end
end

function GM:PaintPixels()
	if (!MONEY.amount) then
		MONEY.amount = LocalPlayer():GetMoney()
	end
	
	local v = MONEY

	if HUDCoin_c > 0 or HUDCoin_d > 0 then
		v.timeleft = CurTime() + 2
	end
	
	if v.amount then
		Text = FormatNum(v.amount)
		
		surface.SetFont("HUD_Money") 
		
		tw, th = surface.GetTextSize(Text)
		
		surface.SetTextPos(205, ScrH()-73-th/2)
		surface.SetTextColor(110, 110, 110, self.HudAlpha) 
		surface.DrawText(Text) 
	end

	local x = v.x
	local y = v.y

	local w = v.w
	local h = v.h
	local ideal_y = ScrH()-v.h
	local ideal_x = v.w

	local timeleft = v.timeleft - CurTime()

	if timeleft <= 0 then
		ideal_x = -v.w
	else
		ideal_x = 0
	end
	
	local spd = FrameTime() * 8
	
	v.y = v.y + v.vely * spd
	v.x = v.x + v.velx * spd
	
	local dist = ideal_y - v.y
	
	v.vely = v.vely + dist * spd * 1
	
	if (math.abs(dist) < 2 && math.abs(v.vely) < 0.1) then v.vely = 0 end
	
	local dist = ideal_x - v.x
	
	v.velx = v.velx + dist * spd * 1
	
	if (math.abs(dist) < 2 && math.abs(v.velx) < 0.1) then v.velx = 0 end
	
	v.velx = v.velx * (0.95 - RealFrameTime() * 5 )
	v.vely = v.vely * (0.95 - RealFrameTime() * 5 )
	
	if v.x > 0 then
		v.x = 0
		v.velx = 0
	end
	
	if !MONEY.amount then return end
	
	local ft = FrameTime()
	
	if (MONEY.amount + HUDCoin_b) < LocalPlayer():GetMoney() then
		for i=1, math.min( 1, math.Round( MONEY.cps * ft * 64 ) ) do
			if (LocalPlayer():GetMoney() - MONEY.amount + HUDCoin_b) > 0 then
				self:AddCoin()
			else break end
		end
	elseif MONEY.amount > LocalPlayer():GetMoney() then
		if MONEY.x > MONEY.w*-0.5 then
			for i=1, math.min( 1, math.Round( MONEY.cps * ft * 64 ) ) do
				if (MONEY.amount - LocalPlayer():GetMoney()) > 0 then
					self:RemoveCoin()
				else break end
			end
		else
			MONEY.timeleft = CurTime() + 2
		end
	end
	
	if ( !HUDCoins ) then return end
	
	for k, v in pairs( HUDCoins ) do
		if (v != 0) then
			DrawCoin(v)
		end
	end
	
	for k, v in pairs( HUDCoins ) do
	
		if ( v != 0 and (v.x <= v.w or v.y > ScrH()) ) then
			
			if v.income then
				PlayTink()
			
				local value = LocalPlayer():GetMoney() - MONEY.amount
				
				value = math.min( v.value, value )
				
				MONEY.amount = MONEY.amount + value
				
				HUDCoin_b = HUDCoin_b - value
				HUDCoin_c = HUDCoin_c - 1
			elseif v.outcome then
				HUDCoin_d = HUDCoin_d - 1
			end
			
			HUDCoins[ k ] = 0
			
			if (HUDCoin_c == 0 and HUDCoin_d == 0) then HUDCoins = {} HUDCoin_b = 0 end
		
		end

	end

end