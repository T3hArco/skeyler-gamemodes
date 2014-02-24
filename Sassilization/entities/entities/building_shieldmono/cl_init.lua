----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

local laserMaterial = Material("cable/blue_elec")
local glowSprite = Material("effects/energyball")
local topVector = Vector(0, 0, 23)
local color_glow = Color(95, 250, 240, 255)

include("shared.lua")

local renderConvar = CreateClientConVar( "sass_buildingdistance", 640, true, true )

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.size = 2
	self.neighbors = {}
end

function ENT:Draw()
	self.BaseClass.Draw(self)
	
	if ((EyePos()-self:GetPos()):LengthSqr() >= renderConvar:GetFloat()*1000) then return end
	if !ValidEmpire( LocalEmpire() ) then return end

	local color = LocalEmpire():GetColor()
	local startPos = self:GetPos() +topVector

	render.SetMaterial(glowSprite)
	render.DrawSprite(startPos, 6 +math.sin((CurTime() -15) *0.5), 6 +math.sin((CurTime() -15) *0.5), color_glow)
	
	render.SetMaterial(laserMaterial)

	cam.Start3D(EyePos(), EyeAngles())
		for k, v in pairs(self.neighbors) do
			if (IsValid(v) and v:GetClass() == "building_shieldmono" and v != self) then
				local endPos = v:GetPos() +topVector
				
				render.DrawBeam(startPos, endPos, self.size, 0, 0, color)
			end
		end
	cam.End3D()
	
	if (self:CanProtect()) then
		self.size = math.Approach(self.size, 2, 0.005)
	else
		self.size = 0
	end
end