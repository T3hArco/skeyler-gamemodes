----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

include("shared.lua")

ENT.Foundation = false

local renderConvar = CreateClientConVar( "sass_buildingdistance", 640, true, true )

//local RenderOffset = Vector( 0, 0, -2 )
function ENT:Initialize()
	
	self.BaseClass.Initialize( self )
	//self:SetRenderOrigin( self:GetPos() + RenderOffset )
	self.ConnectedWalls = {}
	self.ConnectedGates = {}
	
end

function ENT:AddConnectedWall( building_wall )
	
	self.ConnectedWalls[ building_wall ] = true
	timer.Simple( 0, function()
		building_wall:CallOnRemove( "RemoveConnection"..tostring( self ), function()
			if( IsValid( self ) ) then
				self.ConnectedWalls[ building_wall ] = nil
			end
		end )
	end )
	
end

function NetworkConnectedGates()
	local ent1 = net.ReadEntity()
	local ent2 = net.ReadEntity()

	table.insert(ent1.ConnectedGates, ent2)
end
net.Receive("NetworkConnectedGates", NetworkConnectedGates)

function ENT:Draw()
	if( (EyePos()-self:GetPos()):LengthSqr() > renderConvar:GetFloat()*1000 ) then
		return
	end
	self:DrawModel()
end