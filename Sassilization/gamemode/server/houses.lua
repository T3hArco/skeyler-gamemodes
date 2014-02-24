----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

SA.Houses = {}
SA.HouseCount = 0

function GM:GetHouses()
	local houses, count = {}, 0
	for _, house in pairs( ents.FindByClass( "building_house" ) ) do
		table.insert( houses, house )
		count = count + 1
	end
	SA.HouseCount = count
	return houses
end

util.AddNetworkString( "house.Create" )
function GM:AddHouse( house )
	SA.HouseCount = SA.HouseCount + 1
	
	net.Start( "house.Create" )
		-- Bool
		net.WriteUInt( 1, 8 )
		self:NETHouse( house )
	net.Broadcast()
end

util.AddNetworkString( "house.Remove" )
function GM:RemoveHouse( house )
	SA.HouseCount = SA.HouseCount - 1
	
	net.Start( "house.Remove" )
		-- UByte
		net.WriteUInt( house:EntIndex(), 8 )
		-- Bool
		net.WriteUInt( 1, 8 )
	net.Broadcast()
end

function GM:NETHouse( house )
	
	net.WriteVector( house:GetPos() )
	net.WriteAngle( house:GetAngles() )
	-- 2 UByte
	net.WriteUInt( house:EntIndex(), 8 )
	net.WriteUInt( house:GetEmpire():GetID(), 8 )
	net.WriteUInt( tonumber(house:GetModel():sub( 28, 28 )) or 1 )
	
end
