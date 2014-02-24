local mShrine = Material("sassilization/shrinehud/spells_bg.png")

local spells = {"Gravitate", "Bombard", "Heal", "Decimate", "Blast", "Paralyze", "Plummet"}
local mSpells = {}
local cooldowns = {}
local overlay = {}

for k,v in pairs(spells) do
	mSpells[v] = Material("sassilization/shrinehud/sp_" .. k .. ".png")

	cooldowns[string.lower(v)] = 0
end

local selected = 1
local numberpadreuse = CurTime()
	
function GM:DrawShrineHud( le, sw, sh, scale )
	local scale = scale*0.85
	local x, y = sw-250, sh-165
	local i = math.Clamp(math.sin(CurTime())*35, 0, 255)
	

	w, h = 566, 78
	x, y = sw - w * scale, sh - h * scale
	surface.SetMaterial(mShrine)
	surface.DrawTexturedRect(x, y, w * scale, h * scale)

	surface.SetDrawColor(Color(255, 255, 255))

	for k, v in pairs(spells) do

		w, h = 64, 64
		--Using 538 instead of 566 here because of the little circle at the end of the shrine bar
		x, y = sw - 538 * scale - w * scale + 50*scale, sh - 5 * scale - h * scale
		
		if k == selected then
			surface.SetDrawColor(Color(255, 255, 255))
		else
			surface.SetDrawColor(Color(150, 150, 255))
		end
		
		surface.SetMaterial(mSpells[v])
		surface.DrawTexturedRect(x+k*(w*scale)+((k*5)*scale), y, w * scale, h * scale)

		local cooldown = cooldowns[string.lower(v)] -CurTime()
		if (cooldown > 0 and !overlay[k]) then
			overlay[k] = cooldown
		end

		if cooldown <= 0 then
			overlay[k] = nil
		end
		
		if overlay[k] then
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(x+k*(w*scale)+((k*5)*scale), y, w * scale, (h * scale)*(cooldown/overlay[k]))
		end

		if k == selected then
			selx, sely = x+k*w, y
			selsx, selsy = w * scale, h * scale
			
			draw.SimpleText(spells[selected], SA.HUD.FONTS["ShrineName"], x+k*(w*scale)+((k*5)*scale) + w*scale/2, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end

	surface.SetDrawColor(Color(255, 255, 255))
	
	w, h = 25, 64
	x, y = sw - 538 * scale + w * scale, sh - h * scale - 5
	surface.SetMaterial(Material("sassilization/shrinehud/bar_bg.png"))
	surface.DrawTexturedRect(x, y, w * scale, h * scale)

	local creedBar = math.Clamp( LocalEmpire():GetCreed()/100, 0, 1 )
	surface.SetDrawColor(LocalEmpire():GetColor())
	w, h = 25, creedBar*64
	x, y = sw - 538 * scale + w * scale, sh - h * scale - 5
	surface.SetMaterial(Material("sassilization/shrinehud/bar.png"))
	surface.DrawTexturedRect(x, y, w * scale, h * scale)


	surface.SetDrawColor(Color(255, 255, 255))
	w, h = 25, 64
	x, y = sw - 538 * scale + w * scale, sh - h * scale - 5
	surface.SetMaterial(Material("sassilization/shrinehud/bar_border.png"))
	surface.DrawTexturedRect(x, y, w * scale, h * scale)
	
	if input.IsKeyDown(KEY_1) then
		selected = 1
	elseif input.IsKeyDown(KEY_2) then
		selected = 2
	elseif input.IsKeyDown(KEY_3) then
		selected = 3
	elseif input.IsKeyDown(KEY_4) then
		selected = 4
	elseif input.IsKeyDown(KEY_5)  then
		selected = 5
	elseif input.IsKeyDown(KEY_6) or input.IsKeyDown(KEY_PAD_6) then
		selected = 6
	elseif input.IsKeyDown(KEY_7) or input.IsKeyDown(KEY_PAD_7) then
		selected = 7
	end
	
	if numberpadreuse <= CurTime() then
		if input.IsKeyDown(KEY_PAD_1) then
			selected = 1
			numberpadreuse = CurTime() + 1

			net.Start("sa_domiracle")
				net.WriteString(string.lower(spells[selected]))
			net.SendToServer()
		elseif input.IsKeyDown(KEY_PAD_2) then		
			selected = 2
			numberpadreuse = CurTime() + 1

			net.Start("sa_domiracle")
				net.WriteString(string.lower(spells[selected]))
			net.SendToServer()
		elseif input.IsKeyDown(KEY_PAD_3) then
			selected = 3
			numberpadreuse = CurTime() + 1

			net.Start("sa_domiracle")
				net.WriteString(string.lower(spells[selected]))
			net.SendToServer()
		elseif input.IsKeyDown(KEY_PAD_4) then
			selected = 4
			numberpadreuse = CurTime() + 1

			net.Start("sa_domiracle")
				net.WriteString(string.lower(spells[selected]))
			net.SendToServer()
		elseif input.IsKeyDown(KEY_PAD_5) then
			selected = 5
			numberpadreuse = CurTime() + 1

			net.Start("sa_domiracle")
				net.WriteString(string.lower(spells[selected]))
			net.SendToServer()
		elseif input.IsKeyDown(KEY_PAD_6) then
			selected = 6
			numberpadreuse = CurTime() + 1

			net.Start("sa_domiracle")
				net.WriteString(string.lower(spells[selected]))
			net.SendToServer()
		elseif input.IsKeyDown(KEY_PAD_7) then
			selected = 7
			numberpadreuse = CurTime() + 1

			net.Start("sa_domiracle")
				net.WriteString(string.lower(spells[selected]))
			net.SendToServer()
		end
	end
end

hook.Add("PlayerBindPress", "shrine.PlayerBindPress", function(ply, bind, pressed)
	if string.find(bind, "invprev") then
		if pressed then
			if selected - 1 <= 0 then
				selected = 7
			else
				selected = selected - 1
			end
		end
		
		return true
	end
	
	if string.find(bind, "invnext") then
		if pressed then
			if selected + 1 >= 8 then
				selected = 1
			else
				selected = selected + 1
			end
		end
		
		return true
	end
	
	if string.find(bind, "+menu_context") then
		if pressed then
			net.Start("sa_domiracle")
				net.WriteString(string.lower(spells[selected]))
			net.SendToServer()
		end
		
		return true
	end
end)

net.Receive("sa.GetMiracleCooldown", function(bits)
	local unique = net.ReadString()
	local cooldown = net.ReadUInt(8)
	
	cooldowns[unique] = CurTime() +cooldown
end)