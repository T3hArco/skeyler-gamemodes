----------------------------------------
--    Sassilization
--    http://sassilization.com
--    By Sassafrass
----------------------------------------


function LocalEmpire()
    local pl = LocalPlayer()
    if(IsValid(pl)) then
        return pl:GetEmpire()
    end
    return false
end

local assert = assert
local require = require
local pairs = pairs
local setmetatable = setmetatable
local print = print
local PrintTable = PrintTable
local Msg = Msg
local table = table
local tostring = tostring
local usermessage = usermessage
local net = net
local IsValid = IsValid
local tonumber = tonumber
local Color = Color

local Entity = Entity
local LocalPlayer = LocalPlayer
local hook = hook
local gamemode = gamemode
local LocalEmpire = LocalEmpire

local Material = Material
local GetRenderTarget = GetRenderTarget
local CreateMaterial = CreateMaterial
local render = render
local cam = cam
local surface = surface
local ScrW = ScrW
local ScrH = ScrH
local print = print
local ErrorNoHalt = ErrorNoHalt
local _G = _G

module( "empire" )

if( not _G.sh_empire ) then return end

for k, v in pairs( _G.sh_empire ) do
    if not _M[k] then
        _M[k] = v
    end
end

_G.sh_empire = nil
_G = nil

function Create( id, nick, cid )
    local empire = {}
	
    setmetatable( empire, mt )
	
    print( "Creating Empire "..id.."\n" )
    
    empire.NWVars = table.Copy( methods.NWVars )
    
    empire:SetID( id )
	empire:SetColorID( cid )
    empire:SetName( nick )
    
    empire.structures = {}
    empire.units = {}
    empire.selected = {}
    empire.selected.units = {}
    empire.selected.unitcount = 0
    
	print( "Created "..tostring(empire).."\n" )
    return empire
    
end

net.Receive( "empire.AssociatePlayer", function( len )
    local pl = net.ReadEntity()
    local eid = net.ReadUInt(8)
    print(pl)
    print(eid)
    AssociatePlayer( pl, eid )
end )

function AssociatePlayer( pl, eid )
    if( not IsValid( pl ) ) then return end
  
  for _, e in pairs( GetAll() ) do
        if (e:GetID() == eid) then
            pl:SetEmpire( e )
            e:SetPlayer( pl )
			
            print( "Associated Player ", pl:Nick(), "\n" )
			
            return
        end
    end
end

net.Receive( "empire.Create", function( len )
     
    local pl = net.ReadEntity()
    local id = net.ReadUInt(8)
	local cid = net.ReadUInt(8)
	local nick = net.ReadString()

    assert( pl )
    print( pl, eid, "\n" )

    print( "Loading Empire "..id.."\n" )

    local E = EMPIRES[id] or Create( id, nick, cid )
    EMPIRES[id] = E
    
    AssociatePlayer( pl, id )

    print( pl, "\t", LocalPlayer(), "\n" )
    
    if( pl == LocalPlayer() ) then
    	print(pl)
        gamemode.Call( "OnEmpireCreated", pl, E )
    end
    
end )

-- local MatsToGen = {}
-- local Materials = {}
-- local ColoredTextures = {}
-- local MatRoofRT = Material("models/mrgiggles/sassilization/roof")
-- local RTTexture = GetRenderTarget("SassRoofColor", 256, 256)

-- function UpdateColoredTexture( CID, path )
	
	-- if( Materials[ path ] and ColoredTextures[ path ] and ColoredTextures[ path ][ CID ] ) then
		-- --Materials[ path ]:SetTexture( "$basetexture", ColoredTextures[ path ][ CID ] )
		-- local r, g, b, a = GetColorByID( CID )
		-- Materials[ path ]:SetMaterialString( "$blendtintbybasealpha", r/255 .. " " .. g/255 .. " " .. b/255 )
	-- else
		-- --table.insert( MatsToGen, { path, CID } )
		-- local tex = CreateMaterial( "path"..CID, "VertexlitGeneric", { ['$basetexture'] = path .. "colors/" .. CID } ):GetMaterialTexture( "$basetexture" )
		-- Materials[ path ] = Material( path )
		-- ColoredTextures[ path ] = ColoredTextures[ path ] or {}
		-- ColoredTextures[ path ][ CID ] = tex
	-- end
	
-- end

-- hook.Add( "RenderScreenspaceEffects", "sass.SetupRoofRT", function()
	
	-- if(not RTTexture) then return end
	
	-- if(#MatsToGen == 0) then return end
		
	-- local OldRT = render.GetRenderTarget()
	
	-- render.SetRenderTarget( RTTexture )
	-- render.SetViewPort( 0, 0, 256, 256 )
	
	-- for _, info in pairs( MatsToGen ) do
		
		-- render.Clear( 0, 0, 0, 255 )
		
		-- local path = info[ 1 ]
		-- local cid = info[ 2 ]
		-- print( "Setting up Texture ", path, "\n" )
		
		-- Materials[ path ] = Material( path )
		-- ColoredTextures[ path ] = ColoredTextures[ path ] or {}
		
		-- local refTex = surface.GetTextureID( path )
		-- local tex = CreateMaterial( "path"..cid, "VertexlitGeneric", { ['$basetexture'] = path .. "colors/" .. cid } ):GetMaterialTexture( "$basetexture" )
		
		-- cam.Start2D()
			-- local r, g, b, a = GetColorByID( cid )
			-- print( r, " ", g, " ", b, "\n" )
			-- surface.SetTexture( refTex )
			-- surface.SetDrawColor( 255, 255, 255, 255 )
			-- surface.DrawTexturedRect( 0, 0, 256, 256 )
			-- surface.SetDrawColor( r, g, b, 100 )
			-- surface.DrawRect( 0, 0, 256, 256 )
		-- cam.End2D()
		
		-- render.CopyRenderTargetToTexture( tex )
		
		-- ColoredTextures[ path ][ cid ] = tex
		
		-- print( tex, "\n" )
		
	-- end
	
	-- MatsToGen = {}
		
	-- render.SetRenderTarget(OldRT)
	-- render.SetViewPort(0, 0, ScrW(), ScrH())
	
-- end )