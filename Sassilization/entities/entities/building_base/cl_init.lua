----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

include("shared.lua")

AccessorFunc( ENT, "b_NoDrawModel", "NoDrawModel" )

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Foundation = true

SA.FoundationMat = CreateMaterial( "SassFoundationMaterial", "VertexlitGeneric", {
	["$basetexture"] = "de_cbble/cobbleroad01",
	["$model"] = 1
} );

local renderConvar = CreateClientConVar( "sass_buildingdistance", 640, true, true )

function ENT:Initialize()
	
	--This is a hack because entity models can only be drawn once per render
	self.Model = ClientsideModel( self:GetModel() )
	self.Model:SetNoDraw( true )
	
	if self.Foundation then
		self:CreateFoundation()
	end
	
	if not self:IsBuilt() then
		self.StartBuildTime = CurTime()
	end
	
end

function ENT:Think()
	
	if( not IsValid( self.Model ) ) then
		self.Model = ClientsideModel( self:GetModel() )
		self.Model:SetNoDraw( true )
		self.Model:SetModel( self:GetModel() )

		if self.Foundation then
			self:CreateFoundation()
		end
		return
	end
	
	if( self:GetModel() ~= self.Model:GetModel() ) then
		self.Model:SetModel( self:GetModel() )
	end
    self:CheckForOwnershipChange()
    
    self:NextThink(CurTime() + 0.1)
    return true
	
end

function ENT:OnRemove()
	
	if( IsValid( self.Model ) ) then
		self.Model:Remove()
	end
	if self.FoundationMesh then
		self.FoundationMesh:Destroy()
		self.FoundationMesh = nil
	end

	self.Destroyed = true

	if self.ConnectedWalls then
		for k,v in pairs(self.ConnectedWalls) do
			if k:IsValid() then
				if k:GetNearestSegment(self:GetPos()) then
					k:GetNearestSegment(self:GetPos()):UpdateModel()
				end
			end
		end
	end
	
    self:SetEmpire(nil)
	
end

function ENT:CreateFoundation()
	-- Foundation Recipe:
	--	1 Crumbling Galactic Empire
	--	1 Psycohistorian Head Leader
	--	1 Insanely Old Puppeteering Humaniform Robot
	--	1 Psionic Cabal On Said Empire's Capital
	--	1 Metal Poor Habitable Planet In The Middle Of Nowhere
	--	1 Plan For Freakin' Huge Encyclopedia
	--	5000+ Deported Encyclopedia Writers
	--	3 Rivaling Local Empires Around Said Metal Poor Planet
	--	1 Abandoned Planet Earth (Irradiated To Taste)
	--	
	--	Instructions:
	-- 		Put all ingredients in bowl and mix.
	--		Place in Preheated Galactic Drama Oven at 400 000 Kelvin.
	--		Bake For Three Thousand Years.
	
	self.FoundationMesh = building.CreateFoundation( self )
	
end

function ENT:Draw()

	if( (EyePos()-self:GetPos()):LengthSqr() > renderConvar:GetFloat()*1000 ) then
		return
	end
	
	if( self.RenderOverride ) then
		self:RenderOverride()
	else
		self:DrawBuilding()
	end
	
	if( self.FoundationMesh and not GAMEMODE.NoDrawFoundations ) then
		local matrix = Matrix()
		matrix:SetTranslation(self.Model:GetPos())
		matrix:Rotate(self.Model:GetAngles())
		render.SetMaterial( SA.FoundationMat )
		cam.PushModelMatrix(matrix)
			self.FoundationMesh:Draw()
		cam.PopModelMatrix()
	end
	
end

function ENT:DrawBuilding()
	
	if( not IsValid( self.Model ) ) then
		return
	end
	
	self.Model:SetColor( self:GetColor() )
	self.Model:SetPos( self:GetPos() )
	self.Model:SetAngles( self:GetAngles() )
	
	if( not self:GetNoDrawModel() ) then
		self.Model:DrawModel()
	end
	
end

-- hook.Add( "PreDrawOpaqueRenderables", "SA.DrawBuildingFoundations", function()
	
	-- render.SetMaterial( SA.FoundationMat )
	-- for _, bldg in pairs( ents.FindByClass( "building_*" ) ) do
		
	-- end
	
-- end )

-- hook.Add( "PreDrawOpaqueRenderables", "SA.DrawBuildings", function()
	
	-- for _, bldg in pairs( ents.FindByClass( "building_*" ) ) do
		
		-- local r, g, b = bldg:GetColor()
		-- render.SetColorModulation( r / 255, g / 255, b / 255 )
		-- bldg:DrawBuilding()
		-- render.SetColorModulation( 1, 1, 1 )
		
	-- end
-- end )

function TempnNonRefund(len)
	local ent = net.ReadEntity()
	local bool = net.ReadBit()
	if bool == 1 then
		bool = true
	else
		bool = false
	end
	ent.DamageSell = bool
end
net.Receive("TempnNonRefund", TempnNonRefund)