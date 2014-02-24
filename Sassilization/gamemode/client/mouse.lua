--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

local TotalMice = 0
local MX, MY = false, false

function ShowMouse()
	if MouseHidden then
		MouseHidden = false
		TotalMice = TotalMice + 1
		if(MX and MY and not vgui.CursorVisible()) then
			gui.SetMousePos(MX, MY)
		end
		if(TotalMice > 0) then
			gui.EnableScreenClicker(true)
		end
	end
end

function HideMouse()
	if !MouseHidden then
		MouseHidden = true
		TotalMice = math.Max(TotalMice - 1, 0)
		MX, MY = gui.MousePos()
		if(TotalMice == 0) then
			gui.EnableScreenClicker(false)
		end
	end
end
