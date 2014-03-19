include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local texture = surface.GetTextureID("skeyler/graphics/info_developers")

surface.CreateFont("ss.sass.screen.staff", {font = "Arvil Sans", size = 32, weight = 400, blursize = 0})

---------------------------------------------------------
--
---------------------------------------------------------

function ENT:Initialize()
	local angles = self:GetAngles()
	local bounds = Vector(1, 1, 1) *math.Max(1280, 640) *0.36
	
	self.cameraAngle = Angle(0, angles.y +90, angles.p +90)
	self.cameraPosition = self:GetPos() +self:GetForward() *0.2 +self:GetRight() *128 *0.5 +self:GetUp() *71.25 *0.5

	self:SetRenderBounds(bounds *-1, bounds)
end

---------------------------------------------------------
--
---------------------------------------------------------

local staffTeam = {
	{"Knoxed", "Founder / Think Tank / Visionary"},
	{"Ntag ", "Founder / Back-end Administrator"},
	{"Aaron", "Founder / Lua Code"},
	{"Hateful", "Lua Code / RTS"},
	{"Chewgum", "Lua Code / Lobby"},
	{"George", "Lua Code"},
	{"Arcky", "Lua Code"},
	{"Snoipa", "Lead Designer / Mapper"},
	{"CaptainBigButt", "Texture Artist / Modeler / Mapper"},
	{"Obstipator", "Web Programmer"},
	{"Arco", "Website / IT Manager"},
	{"Sassafrass", "Created original RTS"},
	{"Jaanus", "Created original models for the RTS"},
}

local kCount

function ENT:Draw()
	local distance = LocalPlayer():EyePos():Distance(self.cameraPosition)
	local maxDistance = SS.Lobby.ScreenDistance:GetInt()
	
	if (distance <= maxDistance) then
		cam.Start3D2D(self.cameraPosition, self.cameraAngle, 0.1)
			draw.Texture(0, 0, 1280, 640, color_white, texture)
			surface.SetDrawColor(225, 225, 225, 255)
			surface.DrawRect( 633, 166, 2, 354 )

			for k,v in pairs(staffTeam) do
				if k*40 + 135 < 470 then
					surface.SetFont("ss.sass.screen.staff")
					local nameSizeW, nameSizeH = surface.GetTextSize(v[1])
					draw.SimpleText(v[1], "ss.sass.screen.staff", 60, 135 + k*40, Color(37,191,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(" - " .. v[2], "ss.sass.screen.staff", 60 + nameSizeW, 135 + k*40, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				else
					if kCount == nil then
						kCount = k - 1
					end
					surface.SetFont("ss.sass.screen.staff")
					local nameSizeW, nameSizeH = surface.GetTextSize(v[1])
					draw.SimpleText(v[1], "ss.sass.screen.staff", 660, 135 + (k-kCount)*40, Color(37,191,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
					draw.SimpleText(" - " .. v[2], "ss.sass.screen.staff", 660 + nameSizeW, 135 + (k-kCount)*40, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				end
			end
		cam.End3D2D()
	end
end