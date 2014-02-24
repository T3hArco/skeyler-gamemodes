----------------------------------------
--	Sassilization
--	http://sassilization.com
--	By Sassafrass / Spacetech / LuaPineapple
----------------------------------------

include("shared.lua")
TerritoryWhite = CreateMaterial( "TerritoryWhite1", "UnLitGeneric", {
    ["$basetexture"] = "color/white",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1"
} )

function ENT:Initialize()
	
	self.BaseClass.Initialize( self )
	
end

function ENT:OnRemove()
	
	self.BaseClass.OnRemove( self )
	if( IsValid( self.TerritorySphere ) ) then
		self.TerritorySphere:Remove()
	end
	
end

local territories = {}

--THANKS LUAPINEAPPLE
function spline(n1, n2, n3, n4, nPerc)
    --[[
    local nPerc3 = nPerc^3
    return n1 * (((-nPerc  + 2) * nPerc - 1) * nPerc    ) * .5 +
           n2 * ((( nPerc3 - 5) * nPerc    ) * nPerc + 2) * .5 + 
           n3 * (((-nPerc3 + 4) * nPerc + 1) * nPerc    ) * .5 + 
           n4 * ((( nPerc  - 1) * nPerc    ) * nPerc    ) * .5
    --]]
	
    local nPerc2 = nPerc  * nPerc
    local nPerc3 = nPerc2 * nPerc
    return 0.5 * (n1 * (-    nPerc3 + 2 * nPerc2 - nPerc    ) +
                  n2 * ( 3 * nPerc3 - 5 * nPerc2         + 2) + 
                  n3 * (-3 * nPerc3 + 4 * nPerc2 + nPerc    ) + 
                  n4 * (     nPerc3 - 1 * nPerc2            ))
end

local function MakeSmooth( borders, source )

	local count = #source

	if( count < 3 ) then
		return
	end

	local border = {}
	local len = 1
	local bLoop = source[1]:Distance(source[count]) < 0.1
	
	for i = 1, count - 1 do
		local n1 = (source[(i > 2) and (i - 2) or (bLoop and count-2 or i)] +
					source[(i ~= 1) and (i - 1) or (bLoop and count-1 or i)] +
					source[i]) / 3
		
		local n2 = (source[(i ~= 1) and (i - 1) or (bLoop and count-1 or i)] +
					source[i] + 
					source[i+1]) / 3
		
		local n3 = (source[i] +
					source[i+1] +
					source[(i ~= count-1) and (i+2) or (bLoop and 2 or count)]) / 3
		
		local n4 = (source[i+1] +
					source[(i ~= count-1) and (i+2) or (bLoop and 2 or count)] +
					source[(i < count-2) and (i+3) or (bLoop and 3 or count)]) / 3
		
		for j = 1, 4 do
			local perc = (j-1)/(5-1)
			
			border[len] = Vector(	spline( n1.x, n2.x, n3.x, n4.x, perc ),
									spline( n1.y, n2.y, n3.y, n4.y, perc ),
									spline( n1.z, n2.z, n3.z, n4.z, perc ))
			len = len + 1
		end
	end
	
	if( bLoop ) then
		border[len] = (source[count-1] + source[1] + source[2]) / 3
		len = len + 1
	else
		border[1] = border[1] + (border[1] - border[2]) * 2
		border[len-1] = border[len-1] + (border[len-1] - border[len-2]) * 2
	end
	
	border.color = source.color
	
	table.insert( borders, border)
end
--END THANKS

local vertOffset = Vector(0, 0, 1.5)

local function DrawNodeBorders()
	for _, border in ipairs( territories.borders ) do
		--local ColNorm = table.Copy(LocalEmpire():GetColor()) --We don't want to modify the alpha of the empire's color
		local ColNorm = border.color
		
		local beamCount = #border
		
		render.StartBeam( beamCount )
			local i
			local lastpos
			local bLoop = border[1]:Distance(border[beamCount]) < 0.1
			
			for i, vert in ipairs( border ) do
				-- texture coords
				local coordoffset = 0
				local scale = 80
				
				if( lastpos ) then
					coordoffset = lastpos:Distance(vert)
				end
				if( not bLoop and (i == 1 or i == beamCount) ) then
					ColNorm.a = 0
				else
					ColNorm.a = 210
				end
				
				lastpos = vert
	
				local tcoord = CurTime() / 10 + coordoffset / scale
				
				-- add point
				render.AddBeam(vert +vertOffset, 3, tcoord, ColNorm)
			end
		render.EndBeam()
	end
end

local Mat = Material( "trails/smoke" )
local pcall = pcall

hook.Add("RenderScreenspaceEffects", "TerritoryBorderRender", function()
	if(!territories.borders) then return end
	
	render.SetMaterial(Mat)
	
	cam.Start3D(EyePos(), EyeAngles())
		local ok, err = pcall( DrawNodeBorders )
		
		if( not ok ) then
			
			print( err, "\n" )
			
		end
	cam.End3D()
end)

net.Receive("territory.Clear", function( len )
	territories.dirty = {}
end )

net.Receive("territory.Update", function( len )
	if (!territories.dirty) then return end
	
	local eid = net.ReadUInt(8)
	local emp = empire.GetByID(eid)
	if (not emp) then return end

	local count = net.ReadUInt(8)
	local border = {}
	border.color = table.Copy( emp:GetColor() )
	
	for i = 1, count do
		border[i] = net.ReadVector()
	end
	
	territories.dirty[#territories.dirty +1] = border
end )

net.Receive("territory.Finish", function( len )
	if( !territories.dirty ) then return end
	
	territories.borders = {}
	
	for _, border in pairs( territories.dirty ) do
		MakeSmooth( territories.borders, border )
	end

	--MsgN( "There are ", #territories.borders, " territory borders" )
	
	territories.dirty = nil
end )