---------------------------- 
--        Bunny Hop       -- 
-- Created by Skeyler.com -- 
---------------------------- 

GM.Styles = {} 

function GM:AddStyle(id, blockkeys, cmd, name) 
	GM.Styles[id] = {id=id,blockkeys=blockkeys,cmd=cmd,name=name} 
end 

STYLE_CLASSIC = 1 
STYLE_SW = 2 
STYLE_W = 3 

GM:AddStyle(STYLE_CLASSIC, {cl={},sv={}}, "!normal", "Normal") --erry key
GM:AddStyle(STYLE_SW, {cl={"moveright","moveleft"},sv={IN_MOVERIGHT,IN_MOVELEFT}}, "!sw", "Sideways") --no W or S
GM:AddStyle(STYLE_W, {cl={"moveright","back","moveleft"},sv={IN_MOVERIGHT,IN_BACK,IN_MOVELEFT}}, "!w", "W-Only") --no S or A or D

if CLIENT then 
	hook.Add("PlayerBindPress","CheckIllegalKey",function(ply,bind,pressed)
		if(tonumber(ply:GetNWInt("Style",1)) != 1) then
			local s = GAMEMODE.Styles[ply:GetNWInt("Style",1)]
			for k,v in pairs(s.blockkeys.cl) do
				if(string.find(bind,v)) then
					if(pressed) then
						ply:ChatPrint("This key is not allowed in "..s.name..".")
					end
					return true
				end
			end
		end
	end)
	return 
end

hook.Add("SetupMove","ALLYOURBASEAREBELONGTOUS",function(ply,data)
	local style = tonumber(ply:GetNWInt("Style",1))
	if(ply:Team() == TEAM_BHOP && style != 1) then
		local buttons = data:GetButtons()
		
		local s = GAMEMODE.Styles[style]
		for k,v in pairs(s.blockkeys.sv) do
			if(bit.band(buttons,v)>0) then
				buttons = bit.band(buttons, bit.bnot(v))
			end
		end
	end
end)