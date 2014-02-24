----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
--	Models By Jaanus
----------------------------------------

function net.WriteShort( val )
	net.WriteInt( val, 16 )
end

function net.ReadShort()
	return net.ReadInt( 16 )
end

function net.WriteLong( val )
	net.WriteInt( val, 64 )
end

function net.ReadLong()
	return net.ReadInt( 64 )
end

function Vertex( pos, u, v, normal )

    return { pos = pos, u = u, v = v, normal = normal }
    
end

function rpairs( t )
	
	math.randomseed( os.time() )
	
	local keys = {}
	for k,_ in pairs( t ) do table.insert( keys, k ) end
	
	return function()
		if #keys == 0 then return nil end
		
		local i = math.random( 1, #keys )
		local k = keys[ i ]
		local v = t[ k ]
		
		table.remove( keys, i )
		return k, v
	end
	
end

local VEC_META = FindMetaTable( "Vector" )
if( not VEC_META ) then 
	Error( "Couldn't get Vector metatable. Get Sassafrass" )
end

function VEC_META:MidPoint( vec_other )
	return (self + vec_other) * 0.5;
end

VEC_META = nil