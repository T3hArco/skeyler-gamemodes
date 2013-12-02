---------------------------
--       Bunny Hop       -- 
-- Created by xAaron113x --
---------------------------

GM.Styles = {} 

function GM:AddStyle(id, blockkeys, cmd, name) 
	GM.Styles[id] = {id=id,blockkeys=blockkeys,cmd=cmd,name=name} 
end 

STYLE_NORMAL = 1 
STYLE_SW = 2 
STYLE_W = 3 

GM:AddStyle(STYLE_NORMAL, {cl={},sv={}}, "!normal", "Normal") --erry key
GM:AddStyle(STYLE_SW, {cl={"moveright","moveleft"},sv={IN_MOVERIGHT,IN_MOVELEFT}}, "!sw", "Sideways") --no W or S
GM:AddStyle(STYLE_W, {cl={"moveright","back","moveleft"},sv={IN_MOVERIGHT,IN_BACK,IN_MOVELEFT}}, "!w", "W-Only") --no S or A or D

if CLIENT then 
	hook.Add("PlayerBindPress","CheckIllegalKey",function(ply,bind,pressed)
		if(ply:GetNWInt("Style",1) != 1) then
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

hook.Add("KeyPress","CheckMode",function(ply,key)
	if not IsFirstTimePredicted() then return end
	if not IsValid(ply) then return end
	
	if(ply:Team() == TEAM_BHOP && ply.Style && ply.Style != 1) then
		local s = GAMEMODE.Styles[ply.Style]
		for k,v in pairs(s.blockkeys.sv) do
			if(key == v) then
				timer.Simple(0.1,function() if(ply && ply:IsValid()) then ply:SetLocalVelocity(Vector(0,0,-100)) end end)
			end
		end
	end
end)