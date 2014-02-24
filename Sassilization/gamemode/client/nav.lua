---------------
-- gm_navigation
-- Spacetech
---------------

do return end

require("navigation")
require("sassilization")

-- If running clientside hold down alt to see it.

local GridSize = 12 -- Space between the nodes

local Nav = nav.Create(GridSize)

local Diagonal = true

-- Diagonal Linking is disabled by default
Nav:SetDiagonal(Diagonal) -- Enable / Disable Diagonal linking (Will DOUBLE the time it takes for the generation)

-- Nav:SetGridSize(256) -- You can also set grid size this way (But its required to at least put some number in CreateNav

-- The module will ignore COLLISION_GROUP_PLAYER

function GetNav()
	return Nav
end

local PrintPath = {}
local Start, End
local NormalUp = Vector(0, 0, 1)
local Mask = MASK_PLAYERSOLID
local HitWorld, Pos, ONormal

Nav:SetMask(Mask) -- Set the mask for the nav traces - Default is MASK_PLAYERSOLID_BRUSHONLY

local mins = Vector(-16, -16, 20) -- min z should be > 0 so that it doesn't get stuck in ground / screw up on angles
local maxs = Vector(16, 16, 72)

local function TraceDown(Pos)
	local trace = {}
	trace.start = Pos + Vector(0, 0, 1)
	trace.endpos = trace.start - Vector(0, 0, 9000)
	trace.mask = Mask
	local tr = util.TraceLine(trace)
	return tr.HitWorld, tr.HitPos, tr.HitNormal
end

local function ComputePath()
	print("ComputePath\n")
	local StartTime = os.time()
	Nav:FindPath(function(Nav, FoundPath, Path)
		if(FoundPath) then
			print("Found Path in "..string.ToMinutesSeconds(os.time() - StartTime).." Path Size: "..table.Count(Path).."\n")
			-- PrintTable(Path)
		else
			print("Failed to Find Path "..table.Count(Path).."\n")
			PrintTable(Path)
			if(table.Count(Path) > 0) then
				MsgN(Path[1]:GetPos(), Path[table.Count(Path)]:GetPos())
			end
		end
		PrintPath = Path
		Start = Nav:GetStart()
		End = Nav:GetEnd()
	end)
end

local function ComputePathHull()
	print("ComputePathHull\n")
	local StartTime = os.time()
	Nav:FindPathHull(mins, maxs, function(Nav, FoundPath, Path)
		if(FoundPath) then
			print("Found Path in "..string.ToMinutesSeconds(os.time() - StartTime).." Path Size: "..table.Count(Path).."\n")
			-- PrintTable(Path)
		else
			print("Failed to Find Path "..table.Count(Path).."\n")
			PrintTable(Path)
			if(table.Count(Path) > 0) then
				MsgN(Path[1]:GetPos(), Path[table.Count(Path)]:GetPos())
			end
		end
		PrintPath = Path
		Start = Nav:GetStart()
		End = Nav:GetEnd()
	end)
end

local function OnGenerated(Loaded)
	MsgN("\n")
	-- I'm using node:GetPos() because it makes it easier to see what node is which
	
	local LinkTotal = 0
	
	for k,v in pairs(Nav:GetNodes()) do
		LinkTotal = LinkTotal + table.Count(v:GetConnections())
	end
	
	MsgN("Node Total", Nav:GetNodeTotal(), "Link Total", LinkTotal)
	
	local Node = Nav:GetNodes()[math.random(1, Nav:GetNodeTotal())]
	
	MsgN("GetNode", Nav:GetNode(Node:GetPos()):GetPos(), Node:GetPos())
	
	MsgN("GetNodeByID", Nav:GetNodeByID(1), Nav:GetNodeByID(Nav:GetNodeByID(1):GetID()), Nav:GetNodeByID(1) == Nav:GetNodeByID(Nav:GetNodeByID(1):GetID())) 
	
	MsgN("GetClosestNode", Nav:GetClosestNode(Vector(0, 0, 0)))
	
	MsgN("Node Info", Nav:GetNodes(), Nav:GetNodeTotal(), table.Count(Nav:GetNodes()))
	
	MsgN("First Node", Nav:GetNodes()[1]:GetPos(), Nav:GetNodeByID(1):GetPos())
	MsgN("Last Node", Nav:GetNodes()[Nav:GetNodeTotal()]:GetPos(), Nav:GetNodeByID(Nav:GetNodeTotal()):GetPos())
	
	MsgN("GetNodeTotal 1", Nav:GetNodeTotal())
	Nav:SetStart(Nav:GetNodeByID(1))
	MsgN("GetNodeTotal 2", Nav:GetNodeTotal())
	
	Nav:SetEnd(Nav:GetNodeByID(Nav:GetNodeTotal()))
	
	MsgN("Start", Nav:GetStart():GetPos(), "End", Nav:GetEnd():GetPos())
	
	MsgN("Diagonal 1", Nav:GetDiagonal())
	
	Nav:SetDiagonal(!Diagonal)
	
	MsgN("Diagonal 2", Nav:GetDiagonal())
	
	Nav:SetDiagonal(Diagonal)

	MsgN("GridSize 1", Nav:GetGridSize())
	
	Nav:SetGridSize(256)
	
	MsgN("GridSize 2", Nav:GetGridSize())
	
	Nav:SetGridSize(GridSize)
	
	-- HEURISTIC_MANHATTAN
	-- HEURISTIC_EUCLIDEAN
	Nav:SetHeuristic(nav.HEURISTIC_MANHATTAN)
	
	-- ComputePath()
	
	MsgN("Save", Nav:Save("data/test.nav"))
	
	if(!Loaded) then
		MsgN("Load", Nav:Load("data/test.nav"), "\n")
		OnGenerated(true)
	end
end

-- Make sure you are nocliped and above the ground (Not sure if I need to do this anymore?)
concommand.Add("snav_generate", function(ply)
	HitWorld, Pos, Normal = TraceDown((IsValid(ply) and ply:GetPos()) or Vector(0, 0, 1))
	
	if(HitWorld) then
		MsgN("Creating Nav\n")
		
		if(IsValid(ply)) then
			-- Remove this line if you don't want a max distance
			--Nav:SetupMaxDistance(ply:GetPos(), 1024) -- All nodes must stay within 256 vector distance from the players position
		end
		
		Nav:ClearWalkableSeeds()
		
		-- Once 1 seed runs out, it will go onto the next seed
		Nav:AddWalkableSeed(Pos, Normal)
		
		HitWorld, Pos, Normal = TraceDown(Vector(0, 0, 0))
		
		Nav:AddWalkableSeed(Pos, Normal)
		
		-- The module will account for node overlapping
		Nav:AddWalkableSeed(Pos, NormalUp)
		Nav:AddWalkableSeed(Pos, NormalUp)
		
		local StartTime = os.time()
		
		Nav:Generate(function(Nav)
			MsgN("Generated "..Nav:GetNodeTotal().." nodes in "..string.ToMinutesSeconds(os.time() - StartTime).."\n")
		end)
		
		--print("Generated in "..string.ToMinutesSeconds(Nav:FullGeneration()).."\n")
	end
end)

concommand.Add("snav_setstart", function(ply)
	Nav:SetStart(Nav:GetClosestNode(ply:GetPos()))
	Start = Nav:GetStart()
end)

concommand.Add("snav_setend", function(ply)
	Nav:SetEnd(Nav:GetClosestNode(ply:GetPos()))
	End = Nav:GetEnd()
	-- ComputePath()
	ComputePathHull()
end)

concommand.Add("snav_disable_node", function(ply)
	Nav:GetClosestNode(ply:GetPos()):SetDisabled(true)
end)

concommand.Add("snav_remove_node", function(ply)
	local ClosestNode = Nav:GetClosestNode(ply:GetPos())
	Nav:RemoveNode(ClosestNode)
end)

concommand.Add("snav_debug", function(ply)
	MsgN(Nav:GetNodes(), Nav:GetStart(), Nav:GetEnd(), table.Count(Nav:GetNodes()))
	
	-- local ClosestNode = Nav:GetClosestNode(ply:GetPos())
	-- ClosestNode:RemoveConnection(NORTH)
	
	-- local NodeA = Nav:GetNodeByID(1)
	
	-- local DIR = NORTH
	-- for k,NodeB in ipairs(Nav:GetNodes()) do
		-- if(NodeA != NodeB) then
			-- NodeA:ConnectTo(NodeB, DIR)
			-- DIR = DIR + 1
		-- end
		-- if(DIR == NUM_DIRECTIONS_DIAGONAL) then
			-- break
		-- end
	-- end
	
	-- PrintTable(NodeA:GetConnections())
end)

concommand.Add("snav_debug_2", function()
	for k,v in pairs(Nav:GetNodes()) do
		MsgN(v, v:GetPos(), table.Count(v:GetConnections()))
	end
end)

concommand.Add("snav_manual", function(ply)
	local HitWorld, Pos, Normal = TraceDown((IsValid(ply) and ply:GetPos()) or Vector(0, 0, 1))
	
	if(!HitWorld) then
		return
	end
	
	local Node1 = Nav:CreateNode(Pos, Normal)
	
	if(!Node1) then
		MsgN("I went out of the max distance. I'm so sorry!!")
		return
	end
	
	MsgN("GetPos", Node1:GetPos())
	MsgN("GetNormal", Node1:GetNormal())
	
	Node1:SetPosition(Vector(333, 444, 555))
	Node1:SetNormal(Normal * -1)
	
	MsgN("GetPos", Node1:GetPos())
	MsgN("GetNormal", Node1:GetNormal())
	
	Node1:SetPosition(Pos)
	Node1:SetNormal(Normal)
	
	Node1:ConnectTo(table.Random(Nav:GetNodes()), NORTH)
end)

concommand.Add("snav_save", function()
	MsgN("Save", Nav:Save("data/nav/"..game.GetMap()..".nav"))
end)

concommand.Add("snav_load", function()
	MsgN("Load", Nav:Load("data/nav/"..game.GetMap()..".nav"))
end)

concommand.Add("snav_debug_2", function()
	for k,v in pairs(Nav:GetNodes()) do
		MsgN(v, v:GetPos(), table.Count(v:GetConnections()))
	end
end)

if(SERVER) then
	return
end

local Alpha = 200
local ColNORMAL = Color(255, 255, 255, Alpha) -- White
local ColNORTH = Color(255, 255, 0, Alpha) -- Pink?
local ColSOUTH = Color(255, 0, 0, Alpha) -- RED
local ColEAST = Color(0, 255, 0, Alpha) -- GREEN
local ColWEST = Color(0, 0, 255, Alpha) -- BLUE
local ColOTHER = Color(0, 255, 255, Alpha) -- Black
local ColDisabled = Color(50, 50, 50, Alpha)

local PathOffset = Vector(0, 0, 1.5)
local ColPath = Color(255, 0, 0, 255)
local lineWidth = 1
local currentIndex = nil

local ColorTable = {
	Color(0, 0, 0, 255),     -- Grey
	Color(200, 0, 0, 255),      -- Red
	Color(0, 200, 0, 255),       -- Green
	Color(0, 0, 200, 255),       -- Blue
	Color(200, 0, 200, 255),     -- Magenta
	-- Color(200, 200, 0, 255),     -- Yellow
	Color(0, 200, 200, 255),     -- Cyan
	Color(255, 140, 50, 255),    -- Orange
	Color(100, 0, 200, 255),     -- Purple
	Color(0, 128, 128, 255),     -- Teal
	Color(100, 64, 0, 255),      -- Brown
	Color(128, 200, 0, 255),     -- Olive
	Color(90, 150, 59, 255),   -- Green-Gray
	Color(155, 166, 200, 255),   -- Light Purple
	Color(0, 144, 200, 255),     -- Sky blue
	Color(200, 150, 160, 255),    -- Pink
	Color(255, 255, 0, 255),     -- Pineapple Yellow (LuaPineapple Only)
}

local function DrawNodeLines(Table)
	
	for k, v in pairs( Table ) do
		local ColNorm = Color( 
							ColorTable[v:GetScoreF()+1].r,
							ColorTable[v:GetScoreF()+1].g,
							ColorTable[v:GetScoreF()+1].b,
							200 )
		-- surface.SetDrawColor( ColNorm.r, ColNorm.g, ColNorm.b, 255 )
		-- local pos = v:GetPos():ToScreen()
		-- local pos2 = v:GetPos() + v:GetNormal() * 13
		-- if( pos.visible and pos2.visible ) then
		-- 	surface.DrawLine( pos.x, pos.y, pos2.x, pos2.y )
		-- end
		-- debugoverlay.Line(v:GetPos(), v:GetPos() + (v:GetNormal() * 13), 1.01, ColNorm)
		render.DrawBeam( v:GetPos(), v:GetPos() + v:GetNormal() * ((v:GetScoreG() / 135) * 8 + 2), 1, 1, 1, ColNorm)
	end

end

local function DrawNodeConnectionLines(Table)
	
	for k, v in pairs( Table ) do
		for k2,v2 in pairs(v:GetConnections()) do
			local Col = ColOTHER
			if(k2 == nav.NORTH) then
				Col = ColNORTH
			elseif(k2 == nav.SOUTH) then
				Col = ColSOUTH
			elseif(k2 == nav.EAST) then
				Col = ColEAST
			elseif(k2 == nav.WEST) then
				Col = ColWEST
			end
			
			-- surface.SetDrawColor( Col.r, Col.g, Col.b, 255 )
			-- local pos = v:GetPos():ToScreen()
			-- local pos2 = v:GetPos() + (v2:GetPos() - v:GetPos()) * 0.3
			-- if( pos.visible and pos2.visible ) then
			-- 	surface.DrawLine( pos.x, pos.y, pos2.x, pos2.y )
			-- end
			-- debugoverlay.Line(v:GetPos(), v:GetPos() + (v2:GetPos() - v:GetPos()) * 0.3, 1.01, Col)
			render.DrawBeam( v:GetPos(), v:GetPos() + (v2:GetPos() - v:GetPos()) * 0.3, 1, 1, 1, Col)
			//DrawNodeLines(v2, visited, count)
		end
	end

end

local function DrawNodePath(Table)
	for k,v in pairs(Table) do
		if(Table[k + 1]) then
			render.DrawBeam(v:GetPos() + PathOffset, Table[k + 1]:GetPos() + PathOffset, lineWidth, 0.25, 0.75, ColPath)
		end
	end
end

local testpositions = {}
local borders = {}

local function DrawNodeBorders()
	
	for _, border in pairs( borders ) do
		local ColNorm = ColorTable[border.empireID+1]
		ColNorm.a = 200
		local beamCount = #border
		render.StartBeam( beamCount )
		local i
		for i, vert in ipairs( border ) do
			// texture coords
			local tcoord = CurTime() + ( i / beamCount )
		 	
			// add point
			render.AddBeam(
				vert + PathOffset,
				2,
				tcoord,
				ColNorm
			);
		end
		render.EndBeam()
	end

end

concommand.Add("snav_addcity", function(ply, cmd, args)
	if( !Nav ) then return end
	args[1] = args[1] and tonumber(args[1]) or 1 --player id 
	args[2] = args[2] and tonumber(args[2]) or 0 --starting score
	MsgN("adding city ", args[1], " ", args[2])
	testpositions[#testpositions+1] = {Nav:GetClosestNode(ply:GetEyeTrace().HitPos), tonumber(args[1]), tonumber(args[2])}
end )

concommand.Add("snav_clear", function( pl, cmd, args )
	testpositions = {}
end )

concommand.Add("snav_genborders", function(ply)
	if( !Nav ) then return end
	borders = Nav:FloodTerritory(testpositions)
end )

local Mat = CreateMaterial( "NodeLines", "UnLitGeneric", {
	["$basetexture"] = "color/white",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1" } )

hook.Add("RenderScreenspaceEffects", "NavRenderScreenspaceEffects", function()
	if(!Nav) then
		return
	end
	local alt = input.IsKeyDown(KEY_LALT)
	local shift = input.IsKeyDown(KEY_LSHIFT)
	--if(alt || shift) then
		render.SetMaterial(Mat)
		cam.Start3D(EyePos(), EyeAngles())
			--if(alt) then
				DrawNodeBorders()
				DrawNodeLines(Nav:GetNearestNodes(LocalPlayer():GetPos(), 200))
			--end
			if(shift) then
				DrawNodePath(PrintPath)
				if(Start) then
					render.DrawBeam(Start:GetPos(), Start:GetPos() + (Start:GetNormal() * 64), lineWidth*2, 0.25, 0.75, ColPath)
				end
				if(End) then
					render.DrawBeam(End:GetPos(), End:GetPos() + (End:GetNormal() * 64), lineWidth*2, 0.25, 0.75, ColPath)
				end
			end
		cam.End3D()
	--end
end)