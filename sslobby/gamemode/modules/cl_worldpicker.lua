SS.Lobby.WorldPicker = {}

local enabled = false
local lastEntity
local rotation = 0

---------------------------------------------------------
--
---------------------------------------------------------

local classes = {
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

function SS.Lobby.WorldPicker:CanPickup(entity)
	if !LocalPlayer():IsAdmin() then return false end 

	local class = entity:GetClass()
	
	return classes[class]
end

---------------------------------------------------------
--
---------------------------------------------------------

function GM:OnSpawnMenuOpen()
	enabled = true

	gui.EnableScreenClicker(true)
end

---------------------------------------------------------
--
---------------------------------------------------------

function GM:OnSpawnMenuClose()
	enabled = false

	gui.EnableScreenClicker(false)
end

---------------------------------------------------------
--
---------------------------------------------------------

function GM:GUIMousePressed(player, trace)
	local trace = LocalPlayer():EyeTrace(348)
	
	if (IsValid(trace.Entity)) then
		local canPickup = SS.Lobby.WorldPicker:CanPickup(trace.Entity)
		
		if (canPickup) then
			rotation = trace.Entity:GetAngles().y
			lastEntity = trace.Entity
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function GM:GUIMouseReleased(player, trace)
	if (IsValid(lastEntity)) then
		local position, angle = lastEntity:GetRenderOrigin(), lastEntity:GetRenderAngles()
		
		net.Start("sslb.wpstps")
			net.WriteEntity(lastEntity)
			net.WriteVector(position)
			net.WriteAngle(angle)
		net.SendToServer()

		lastEntity:SetRenderOrigin()
		lastEntity:SetRenderAngles()
	end
	
	rotation = 0
	lastEntity = nil
end

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("PostDrawOpaqueRenderables", "SS.Lobby.WorldPicker", function()
	if (enabled) then
		local trace = LocalPlayer():EyeTrace(348, {LocalPlayer(), lastEntity})

		if (IsValid(trace.Entity) and SS.Lobby.WorldPicker:CanPickup(trace.Entity) and !IsValid(lastEntity)) then
			vgui.GetWorldPanel():SetCursor("hand")
			
			render.SetColorModulation(0, 0.8, 0)
			render.SetBlend(1)
				trace.Entity:DrawModel()
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(1)
		else
			vgui.GetWorldPanel():SetCursor("arrow")
		end
		
		if (IsValid(lastEntity)) then
			local trace = {}
			trace.start = LocalPlayer():GetShootPos()
			trace.endpos = trace.start +gui.ScreenToVector(gui.MousePos()) *348
			trace.filter = {LocalPlayer(), lastEntity}
			
			trace = util.TraceLine(trace)
			
			local angle = trace.HitNormal:Angle()

			if (angle.p < 270 +0.2 and angle.p > 90 -0.2) then
				angle.y = 0
			end
			
			angle:RotateAroundAxis(angle:Right(), -90)
			angle:RotateAroundAxis(angle:Up(), rotation)

			lastEntity:SetRenderOrigin(trace.HitPos)
			lastEntity:SetRenderAngles(angle)
			
			vgui.GetWorldPanel():SetCursor("sizeall")
		end
	end
	
	if (!enabled) then
		vgui.GetWorldPanel():SetCursor("arrow")
		
		lastEntity = nil
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

local worldPanel = vgui.GetWorldPanel()
worldPanel:SetMouseInputEnabled(true)

function worldPanel:OnMouseWheeled(scroll)
	rotation = rotation +scroll *6
end