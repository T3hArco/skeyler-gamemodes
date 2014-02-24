--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------

require("navigation")
require("sassilization")

local flood
local GridSize = 16 -- Space between the nodes 12
Nav = nav.Create(GridSize)

Nav:SetDiagonal(true)

MsgN("Loading navigation: ", Nav:Load("data/nav/"..game.GetMap()..".nav") and "Successful" or "Failed")

local TerritoryBorders = {}

util.AddNetworkString( "territory.GhostCheck" )

net.Receive( "territory.GhostCheck", function( len, pl )
	if( not pl:GetEmpire() ) then return end
	pl.nextGhostCheck = pl.nextGhostCheck or CurTime()
	if( CurTime() < pl.nextGhostCheck ) then return end
	pl.nextGhostCheck = CurTime() + 0.1

	local position = net.ReadVector()
	net.Start( "territory.GhostCheck" )
		net.WriteUInt( GAMEMODE:IsPosInTerritory( position, pl:GetEmpire():GetID() ) and 1 or 0, 1 )
	net.Send( pl )
end )

function GM:IsPosInTerritory( pos, eid )
	return Nav:GetTerritory( pos ) == eid
end

util.AddNetworkString( "territory.Clear" )
util.AddNetworkString( "territory.Update" )
util.AddNetworkString( "territory.Finish" )

local nextupdate = CurTime()
local updatetimer = false

function GM:UpdateTerritories()

	if( CurTime() < nextupdate ) then
		if( not updatetimer ) then
			timer.Simple( 1, function() self:UpdateTerritories() end )
		end
		updatetimer = true
		return
	end
	
	nextupdate = CurTime() + 0.3
	updatetimer = false

	local origins = {}
	local count = 1
	
	for _, bldg in pairs( ents.FindByClass("building_city") ) do
        if ( ValidBuilding( bldg ) and bldg:IsBuilt() and bldg.TerritoryInfo and bldg.TerritoryInfo[2] != -1 ) then
        	origins[count] = bldg.TerritoryInfo
			count = count + 1
        end
    end
    
	for _, bldg in pairs( ents.FindByClass("building_shrine") ) do
        if ( ValidBuilding( bldg ) and bldg:IsBuilt() and bldg.TerritoryInfo and bldg.TerritoryInfo[2] != -1 ) then
        	origins[count] = bldg.TerritoryInfo
			count = count + 1
        end
    end
   
   for _, bldg in pairs( ents.FindByClass("building_workshop") ) do
        if ( ValidBuilding( bldg ) and bldg:IsBuilt() and bldg.TerritoryInfo and bldg.TerritoryInfo[2] != -1 ) then
        	origins[count] = bldg.TerritoryInfo
			count = count + 1
        end
    end
    
	for _, bldg in pairs( ents.FindByClass("building_house") ) do
        if ( ValidBuilding( bldg ) and bldg:IsBuilt() and bldg.TerritoryInfo and bldg.TerritoryInfo[2] != -1 ) then
        	origins[count] = bldg.TerritoryInfo
			count = count + 1
        end
    end

	for _, bldg in pairs( ents.FindByClass("building_wall") ) do
        if ( ValidBuilding( bldg ) and bldg:IsBuilt() and bldg.TerritoryLineInfo ) then
        	for _, TerritoryInfo in ipairs( bldg.TerritoryLineInfo ) do
	        	origins[count] = TerritoryInfo
				count = count + 1
			end
        end
    end
	
	TerritoryBorders = {}

	TerritoryBorders = Nav:FloodTerritory(origins);

	self:NetworkTerritories()
end

function GM:NetworkTerritories(rf)

	net.Start("territory.Clear")
	if( rf ) then
		net.Send(rf)
	else
		net.Broadcast()
	end
	for _, border in pairs( TerritoryBorders ) do
		--local emp = empire.GetByID( border.empireID )
		--if( emp and (not rf or rf == emp:GetPlayer()) ) then
			self:NetworkTerritory(border, nil) --emp:GetPlayer())
		--end
	end
	net.Start("territory.Finish")
	if( rf ) then
		net.Send(rf)
	else
		net.Broadcast()
	end

end

function GM:NetworkTerritory(border, rf)
	net.Start("territory.Update")
		net.WriteUInt(border.empireID, 8)
		net.WriteUInt(#border, 8)
		for _, vert in ipairs( border ) do
			net.WriteVector(vert)
		end
	if( rf ) then
		net.Send(rf)
	else
		net.Broadcast()
	end

end

function GM:GetTerritories()
	return TerritoryBorders
end