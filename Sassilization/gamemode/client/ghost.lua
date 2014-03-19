--------------------
--	Sassilization
--	By Sassafrass / Spacetech / LuaPineapple
--------------------
local GM = GM or GAMEMODE
GM.Ghost = GM.Ghost or {}
if not GM.Ghost.Walls then
GM.Ghost.Walls = {}
GM.Ghost.Item = "city"
GM.Ghost.Ang = Angle(0, 0, 0)
GM.Ghost.Table = false
GM.Ghost.Ent = false
GM.Ghost.Building = true
GM.Ghost.Rotating = false
GM.Ghost.TraceLine = false
GM.Ghost.Buildable = false
GM.Ghost.NoDrawEnts = {}
GM.Ghost.NoDraw = true
GM.Ghost.GhostMat = Material( "models/debug/debugwhite" )
end

local ColGhostWhite = Color( 255, 255, 255, 150 )
local ColGhostRed = Color( 255, 0, 0, 150 )

function GM:ItemSelect(Item, IsBuilding)
	self.Ghost.Building = IsBuilding
	self.Ghost.Item = Item
	self:CreateGhost()
end

function GM:CreateGhost()
	self:RemoveGhost()
	if( not self.Ghost.Item ) then return end
	if(self.Ghost.Building) then
		self.Ghost.Table = building.BuildingData[self.Ghost.Item]
	else
		self.Ghost.Table = Unit:GetData(self.Ghost.Item)
	end
	
	if(self.Ghost.Table) then
		if( not IsValid( self.Ghost.Ent ) ) then
			self.Ghost.NoDraw = true
			self.Ghost.Custom = self.Ghost.Table.CustomGhost
			self.Ghost.ModelInfo = self.Ghost.Table.Model
			self.Ghost.OriginalModel = type(self.Ghost.ModelInfo) == "table" and self.Ghost.ModelInfo[1] or self.Ghost.ModelInfo
			local ghost = ClientsideModel(self.Ghost.OriginalModel)
			ghost:SetModel(self.Ghost.OriginalModel)
			ghost:SetColor( ColGhostWhite )
			ghost:SetNoDraw( true )
			ghost:SetRenderMode( RENDERMODE_TRANSALPHA )
			ghost:Spawn()
			self.Ghost.Ent = ghost
			self.Ghost.Table.OBBMins = self.Ghost.Ent:OBBMins()
			self.Ghost.Table.OBBMaxs = self.Ghost.Ent:OBBMaxs()
			self:UpdateGhost()
		end
	end
end

function GM:CreateGhostWalls(CanBuild, Walls, WallAng)
	for k,v in pairs(Walls) do
		local Wall = ClientsideModel("models/mrgiggles/sassilization/wall.mdl")
		Wall:SetPos(v)
		Wall:SetAngles(WallAng)
		Wall:SetColor(255, CanBuild and 255 or 0, CanBuild and 255 or 0, 150)
		table.insert(self.Ghost.Walls, Wall)
	end
	return CanBuild
end

function GM:ClearGhostWalls()
	for k,v in pairs(self.Ghost.Walls) do
		v:Remove()
	end
	self.Ghost.Walls = {}
end

function GM:GhostSetNoDraw(Bool)
	if(self.Ghost.NoDraw == Bool) then
		return
	end
	self.Ghost.NoDraw = Bool
	-- self.Ghost.Ent:SetNoDraw(Bool)
end

function GM:ClearGhostNoDrawEnts()
	if closest != nil then
		if closest:IsValid() then
			closest:SetAllSegmentsDraw()
		end
		closest = nil
	end
	-- Do this because of the new way walls work, each segment is not an entity that can be indexed for clearing the nodraw ents

	for k,v in pairs(self.Ghost.NoDrawEnts) do
		if(IsValid(v)) then
			v.NoDraw = false
		end
	end
	self.Ghost.NoDrawEnts = {}
end

function GM:ClearGhostExtraEnts()
	if(self.Ghost.ExtraEnts) then
		for k,v in pairs(self.Ghost.ExtraEnts) do
			if(IsValid(v)) then
				v:Remove()
			end
		end
		self.Ghost.ExtraEnts = nil
	end
end

function GM:ClearGhostGlowEnts()
	if(self.Ghost.GlowEnts) then
		for k,v in pairs(self.Ghost.GlowEnts) do
			if(IsValid(v)) then
				v:Remove()
			end
		end
		self.Ghost.GlowEnts = nil
		self.Ghost.GlowEntCount = nil
	end
end

function GM:IsGhostInTerritory()
	return self.Ghost.InTerritory and CurTime() < self.Ghost.InTerritory + 0.3
end

function GM:GhostCustom(Item, CanFit, Pos, Ang, tr) 
	if(self.Ghost.Item == "gate") then
		if(self.Ghost.ExtraEnts) then
			
			for k,v in pairs(self.Ghost.ExtraEnts) do
				if (!v.spawned) then
					v:Spawn()
					v.spawned = true
				end
				if tonumber(k) == 1 then
					neg = 1
				else
					neg = -1
				end
				v:SetPos(self.Ghost.Ent:GetPos() + self.Ghost.Ent:GetAngles():Right() * (26*neg) )
				v:SetAngles(self.Ghost.Ent:GetAngles())
			end
		else
			self.Ghost.ExtraEnts = {ClientsideModel("models/mrgiggles/sassilization/Walltower.mdl"), ClientsideModel("models/mrgiggles/sassilization/Walltower.mdl")}
		end
	end
	
	if(self.Ghost.NextCustom and self.Ghost.NextCustom > CurTime()) then
		return self.Ghost.Item == "gate"
	end
	self.Ghost.NextCustom = CurTime() + 0.025
	
	self.Ghost.NoDraw = false
	
	if(self.Ghost.Item == "walltower") then
		self.Ghost.Buildable = CanFit
		
		if( CanFit and LocalPlayer():KeyDown( IN_SPEED ) ) then
			
			self.Ghost.Ent:SetColor( ColGhostWhite )
			if( self.Ghost.ExtraEnts and self.Ghost.ExtraEnts[1] ) then
				self.Ghost.ExtraEnts[1].NoDraw = true
			end
			
			self.Ghost.WallTower1 = nil
			self.Ghost.WallTower2 = nil
			self.Ghost.GlowEntCount = 0
			
			return
			
		end
		local WallTowers, Walls = self:GetWallsAndWallTowersInSphere( Pos, SA.MAX_WALL_DISTANCE, LocalEmpire() )
		local CanBuild, WallTower1, WallTower2, Positions, Cost = self:CalculateInbetweenWall( LocalEmpire(), Pos, WallTowers, Walls )
		
		if( CanBuild ) then
			--Build inbetween wall preview
			self:GhostSetNoDraw( true )
			
			local ghost;
			if( self.Ghost.ExtraEnts ) then
				ghost = self.Ghost.ExtraEnts[1]
			else
				GHOST_WALL_EFFECT = true
				util.Effect( "ghost_wall", EffectData(), true )
				self.Ghost.ExtraEnts = {GHOST_WALL_EFFECT}
				ghost = GHOST_WALL_EFFECT
				GHOST_WALL_EFFECT = nil
			end
			ghost:CreateWallMesh( Positions )
			
			ghost:SetNoDraw( true )
			ghost.NoDraw = false
			
			self.Ghost.WallTower1 = WallTower1
			self.Ghost.WallTower2 = WallTower2
			self.Ghost.GlowEnts = self.Ghost.GlowEnts or {}
			self.Ghost.GlowEnts[ 1 ] = self.Ghost.GlowEnts[ 1 ] or ClientsideModel( WallTower1:GetModel() )
			self.Ghost.GlowEnts[ 1 ]:SetModel( WallTower1:GetModel() )
			self.Ghost.GlowEnts[ 1 ]:SetPos( WallTower1:GetPos() )
			self.Ghost.GlowEnts[ 1 ]:SetAngles( WallTower1:GetAngles() )
			self.Ghost.GlowEnts[ 2 ] = self.Ghost.GlowEnts[ 2 ] or ClientsideModel( WallTower2:GetModel() )
			self.Ghost.GlowEnts[ 2 ]:SetModel( WallTower2:GetModel() )
			self.Ghost.GlowEnts[ 2 ]:SetPos( WallTower2:GetPos() )
			self.Ghost.GlowEnts[ 2 ]:SetAngles( WallTower2:GetAngles() )
			self.Ghost.GlowEntCount = 2
			
			self.Ghost.Ent:SetColor( ColGhostWhite )
			self.Ghost.Buildable = true
			
			return true
			
		elseif( CanFit ) then
			
			--Check if we can create a new wall.
			CanBuild, WallTower1, Positions, Cost = self:CalculateNewWall( LocalEmpire(), Pos, WallTowers, Walls )
			
			if( CanBuild and self:IsGhostInTerritory() ) then
				
				self.Ghost.Buildable = true
				
				if( WallTower1 ) then
					
					local ghost;
					if( self.Ghost.ExtraEnts ) then
						ghost = self.Ghost.ExtraEnts[1]
					else
						GHOST_WALL_EFFECT = true
						util.Effect( "ghost_wall", EffectData(), true )
						self.Ghost.ExtraEnts = {GHOST_WALL_EFFECT}
						ghost = GHOST_WALL_EFFECT
						GHOST_WALL_EFFECT = nil
					end
					ghost:CreateWallMesh( Positions )
					
					self.Ghost.WallTower1 = WallTower1
					self.Ghost.WallTower2 = nil
					self.Ghost.GlowEnts = self.Ghost.GlowEnts or {}
					self.Ghost.GlowEnts[ 1 ] = self.Ghost.GlowEnts[ 1 ] or ClientsideModel( WallTower1:GetModel() )
					self.Ghost.GlowEnts[ 1 ]:SetModel( WallTower1:GetModel() )
					self.Ghost.GlowEnts[ 1 ]:SetPos( WallTower1:GetPos() )
					self.Ghost.GlowEnts[ 1 ]:SetAngles( WallTower1:GetAngles() )
					self.Ghost.GlowEntCount = 1
					
				else
					
					self.Ghost.Ent:SetColor( ColGhostWhite )
					if( self.Ghost.ExtraEnts and self.Ghost.ExtraEnts[1] ) then
						self.Ghost.ExtraEnts[1].NoDraw = true
					end
					
					self.Ghost.WallTower1 = nil
					self.Ghost.WallTower2 = nil
					self.Ghost.GlowEntCount = 0
					
					return

				end
				
			else
				
				self.Ghost.Buildable = false
				
			end
			
		else
			
			self.Ghost.Buildable = false
			
		end
		
		self:GhostSetNoDraw( false )
		if(self.Ghost.Buildable) then
			self.Ghost.Ent:SetColor( ColGhostWhite )
			if( self.Ghost.ExtraEnts ) then
				for k,v in pairs(self.Ghost.ExtraEnts) do
					v.NoDraw = false
					v:SetColor( ColGhostWhite )
				end
			end
		else
			self.Ghost.Ent:SetColor( ColGhostRed )
			self:ClearGhostGlowEnts()
			if( self.Ghost.ExtraEnts ) then
				for k,v in pairs(self.Ghost.ExtraEnts) do
					v.NoDraw = true
				end
			end
		end

	elseif(self.Ghost.Item == "gate") then
	
		self:ClearGhostNoDrawEnts()

		local vecPos = tr.HitPos
	    for _, e in pairs(ents.FindByClass("building_wall")) do
	    	if e:GetEmpire() == LocalEmpire() then
		    	if closest == nil then
		    		closest = e
		    	end
		    	if closest:GetPos():Distance(vecPos) > e:GetPos():Distance(vecPos) then
		    		closest = e
		    	end
		    end
	    end

		if(closest and closest:IsWall()) then
			local Valid, Walls, Guards = self:CalculateGate(LocalEmpire(), closest, vecPos)
			if(Valid) then
				self.Ghost.Buildable = building.CanBuild(LocalEmpire(), self.Ghost.Item)
				
				self.Ghost.Ent:SetPos(Walls[1]:GetPos() + GATE_OFFSET)
				self.Ghost.Ent:SetAngles(Walls[1]:GetAngles())
				
				for k,v in pairs(Walls) do
					v.NoDraw = true
				end
				for k,v in pairs(Guards) do
					v.NoDraw = true
					table.insert(self.Ghost.NoDrawEnts, v)
				end
			else
				self.Ghost.Buildable = false
				self.Ghost.Ent:SetPos(Pos + GATE_OFFSET)
				self.Ghost.Ent:SetAngles(Ang)
			end
		else
			self.Ghost.Buildable = false
			self.Ghost.Ent:SetPos(Pos + GATE_OFFSET)
			self.Ghost.Ent:SetAngles(Ang)
		end
		

		self:GhostSetNoDraw( false )
		if(self.Ghost.Buildable) then
			self.Ghost.Ent:SetColor( ColGhostWhite )
			for k,v in pairs(self.Ghost.ExtraEnts) do
				v:SetColor( ColGhostWhite )
			end
		else
			self.Ghost.Ent:SetColor( ColGhostRed )
			for k,v in pairs(self.Ghost.ExtraEnts) do
				v:SetColor( ColGhostRed )
			end
		end
		
		return true
		
	end
	
end

hook.Add( "Think", "Ghost.Think", function()
	GAMEMODE:GhostThink()
end )

function GM:GhostThink()
	self:UpdateGhost()
	if(not self.Ghost.Item) then
		return
	end
	
	if(not IsValid(self.Ghost.Ent)) then
		return
	end
	
	if(self.Ghost.Custom) then
		return
	end
	
	if(self.Ghost.Rotating) then
		if(not input.IsMouseDown(MOUSE_RIGHT)) then
			self.Ghost.Rotating = false
			vgui.GetWorldPanel():SetCursor("blank")
			RestoreCursorPosition()
		end
	else
		if(input.IsMouseDown(MOUSE_RIGHT)) then
			self.Ghost.Rotating = true
			self.Ghost.TraceLine = false
			vgui.GetWorldPanel():SetCursor("hand")
			RememberCursorPosition()
		end
	end
end

function GM:CreateMove(UserCmd)
	if(self.Ghost.Rotating) then
		UserCmd:SetForwardMove(0)
		UserCmd:SetSideMove(0)
		UserCmd:SetUpMove(0)
	end
end

function GM:GhostResetUpgrade()
	if(self.Ghost.Upgrade) then
		self.Ghost.Upgrade:SetNoDrawModel(false)
		self.Ghost.Ent:SetModel(self.Ghost.OriginalModel)
		self.Ghost.Upgrade = false
	end
end

function GM:UpdateGhost()
	if(not self.Ghost) then
		return
	end
	if(not IsValid(self.Ghost.Ent)) then
		return
	end
	
	local trace = {}
	trace.start = LocalPlayer():EyePos()
	trace.endpos = trace.start + gui.ScreenToVector( gui.MousePos() ) * 2048
	trace.filter = LocalPlayer()
	local tr = util.TraceLine( trace )
	
	local Upgrade = false
	if(tr.Entity and tr.Entity:IsBuilding()) then
		if(tr.Entity:GetEmpire() == LocalEmpire()) then
			if(tr.Entity:IsUpgradeable() and building.CanUpgrade( LocalEmpire(), tr.Entity:GetType(), tr.Entity:GetLevel() + 1 )) then
				if(self.Ghost.Item == tr.Entity:GetType()) then
					Upgrade = tr.Entity
				end
			end
		end
	end
	
	if(Upgrade) then
		
		self.Ghost.NoDraw = false
		if(self.Ghost.Rotating) then
			self.Ghost.Rotating = false
		end
		
		if(self.Ghost.Buildable ~= Upgrade) then
			if(type(self.Ghost.Buildable) == "Entity" and IsValid(self.Ghost.Buildable)) then
				self:GhostResetUpgrade()
			end
			self.Ghost.Buildable = Upgrade
		end
		
		self.Ghost.Upgrade = Upgrade
		self.Ghost.Upgrade:SetNoDrawModel(true)
		
		self.Ghost.UpgradeLevel = self.Ghost.Upgrade:GetLevel() + 1
		
		if( building.CanBuild(LocalEmpire(), self.Ghost.Item) ) then
			self.Ghost.Ent:SetColor( ColGhostWhite )
		else
			self.Ghost.Ent:SetColor( ColGhostRed )
		end
		
		self.Ghost.Ent:SetPos(self.Ghost.Upgrade:GetPos())
		self.Ghost.Ent:SetAngles(self.Ghost.Upgrade:GetAngles())
		
		self.Ghost.Ent:SetModel(self.Ghost.ModelInfo[self.Ghost.UpgradeLevel])
		
	else
		if(self.Ghost.Building) then
			trace.mask = CHECK_MASK
		else
			trace.mask = CHECK_MASK + CONTENTS_GRATE
		end
		tr = util.TraceLine( trace )
		
		self:GhostResetUpgrade()
		
		if(self.Ghost.Rotating and self.Ghost.Ang) then
			if(self.Ghost.TraceLine) then
				self.Ghost.Pos = tr.HitPos - (tr.HitNormal * self.Ghost.Table.OBBMins.z)
				tr = self.Ghost.TraceLine
			else
				self.Ghost.TraceLine = tr
			end
		end
		
		-- if(not self.Ghost.Ang or not self.Ghost.TraceLine) then
			-- self.Ghost.Ang = Angle(0, 0, 0)
		-- end
		
		if(self.Ghost.Rotating and self.Ghost.Ang and self.Ghost.Pos) then
			self.Ghost.Ang.y = (self.Ghost.Pos - self.Ghost.TraceLine.HitPos):Angle().y
			--self.Ghost.Ang:RotateAroundAxis( tr.HitNormal, (self.Ghost.Pos - self.Ghost.TraceLine.HitPos):Angle().y );
		end
		
		local mins, maxs = self.Ghost.Ent:OBBMins(), self.Ghost.Ent:OBBMaxs()
		
		if(self.Ghost.Custom) then
			local CanFit, Pos, Ang = self:CanFit(tr, mins, maxs, self.Ghost.Ang, "wall", false)
			
			if(not self:GhostCustom(Item, CanFit, Pos, Ang, tr)) then
				self.Ghost.Ent:SetPos(Pos)
				self.Ghost.Ent:SetAngles(Ang)
			end

		else

			local CanFit, Pos, Ang = self:CanFit(tr, mins, maxs, self.Ghost.Ang, self.Ghost.Ent, true)
			
			self.Ghost.NoDraw = false
			self.Ghost.Ent:SetPos(Pos)
			self.Ghost.Ent:SetAngles(Ang)
			
			local bCanBuild = false
			local bCityProx = false

			if self.Ghost.Building then 
					bCanBuild = building.CanBuild(LocalEmpire(), self.Ghost.Item)
			else
                    bCanBuild = Unit:CanSpawn(LocalEmpire(), self.Ghost.Item)
            end

			if self.Ghost.Table.Require and self.Ghost.Table.Require["city"] != nil then 
				bCityProx = self.Ghost.InTerritory// and CurTime() < self.Ghost.InTerritory + 0.3
			else
				bCityProx = not building.NearCity(false, Pos, SA.CITY_DISTANCE_MIN) 
			end
			
			if CanFit and bCanBuild and bCityProx /*and (self.Ghost.Building or tr.HitWorld)*/ then
				self.Ghost.Buildable = true
				self.Ghost.Ent:SetColor( ColGhostWhite )
			else
				self.Ghost.Buildable = false
				self.Ghost.Ent:SetColor( ColGhostRed )
			end
		end

		self:SendTerritoryCheck()

	end
	
end

local nextTerritoryCheck = 0
function GM:SendTerritoryCheck()
	
	if( CurTime() < nextTerritoryCheck ) then
		return
	end
	nextTerritoryCheck = CurTime() + 0.1 --ten times a second?

	net.Start( "territory.GhostCheck" )
		net.WriteVector( self.Ghost.Ent:GetPos() )
	net.SendToServer()
	
end

net.Receive( "territory.GhostCheck", function( len )
	local bool = net.ReadUInt(1)
	
	local result = tobool(bool)
	GAMEMODE.Ghost.InTerritory = result and CurTime() or false
end )

function GM:GUIMousePressed(MouseCode)
	if(not self.Ghost.Item) then
		return
	end
	if( not self.Ghosting ) then return end
	if(MouseCode == MOUSE_LEFT) then
		if(self.Ghost.Buildable and not self.Ghost.Rotating and ((self.Ghost.Building and building.CanBuild(LocalEmpire(), self.Ghost.Item)) or (not self.Ghost.Building and Unit:CanSpawn(LocalEmpire(), self.Ghost.Item)))) then
			if(self.Ghost.Building and IsValid(self.Ghost.Upgrade)) then
				RunConsoleCommand("sa_upgradebuilding", self.Ghost.Item, self.Ghost.Upgrade:EntIndex())
			elseif(self.Ghost.Item == "walltower" and self.Ghost.WallTower1) then
				local Vec = gui.ScreenToVector( gui.MousePos() )
				if( self.Ghost.WallTower2 ) then
					RunConsoleCommand( "sa_buildwall", Vec.x, Vec.y, Vec.z, self.Ghost.WallTower1:EntIndex(), self.Ghost.WallTower2:EntIndex() )
				else
					RunConsoleCommand( "sa_buildwall", Vec.x, Vec.y, Vec.z, self.Ghost.WallTower1:EntIndex() )
				end
			elseif( self.Ghost.Ang ) then
				if self.Ghost.Item != "gate" then
					Vec = gui.ScreenToVector( gui.MousePos() )
				else
					Vec = self.Ghost.Ent:GetPos()
				end
				RunConsoleCommand(self.Ghost.Building and "sa_buildbuilding" or "sa_spawnunit", self.Ghost.Item, Vec.x, Vec.y, Vec.z, self.Ghost.Ang.p, self.Ghost.Ang.y, self.Ghost.Ang.r, self.Ghost.Table.OBBMins.x, self.Ghost.Table.OBBMins.y, self.Ghost.Table.OBBMins.z, self.Ghost.Table.OBBMaxs.x, self.Ghost.Table.OBBMaxs.y, self.Ghost.Table.OBBMaxs.z)
			end
		end
	end
end

hook.Add( "PreDrawEffects", "Ghost.PreDrawEffects", function()
	
	if( IsValid( GAMEMODE.Ghost.Ent ) ) then
		GAMEMODE:DrawGhost()
	end

end )


local GLOW_ENABLED = true
local EntityHalos = {}
local HaloColor = Color(255, 255, 255, 255)

hook.Add( "PreDrawHalos", "AddEntityHalos", function()

	if ( not EntityHalos ) then return end
	
	local size = math.random( 1.5, 1.8 )
	effects.halo.Add( EntityHalos, HaloColor, size, size, 3, true, false )

	EntityHalos = {}

end )

function GM:DrawGhost()
	
	local entsToGlow = {}
	local entsToGlowCount = 0
	local col = self.Ghost.Ent:GetColor()
	HaloColor.r = col.r
	HaloColor.g = col.g
	HaloColor.b = col.b

	if(self.Ghost.Item == "city") then
		for k,v in pairs(ents.FindInSphere(self.Ghost.Ent:GetPos(), 60)) do
			if v:IsResource() then
				entsToGlowCount = entsToGlowCount + 1
				entsToGlow[entsToGlowCount] = v
			end
		end
	end

	render.SetBlend(col.a/255)
	if( not self.Ghost.NoDraw ) then
		local c = LocalEmpire():GetColor()
		render.SetColorModulation( c.r / 255, c.g / 255, c.b / 255 )
			self.Ghost.Ent:DrawModel()
		render.SetColorModulation( 1, 1, 1 )
		entsToGlowCount = entsToGlowCount + 1
		entsToGlow[entsToGlowCount] = self.Ghost.Ent
	end
    
	if( self.Ghost.ExtraEnts ) then
		for _, ent in pairs( self.Ghost.ExtraEnts ) do
			if( not ent.NoDraw ) then
				ent:DrawModel()
				entsToGlowCount = entsToGlowCount + 1
				entsToGlow[entsToGlowCount] = ent
			end
		end
	end
	
	if( self.Ghost.GlowEntCount and self.Ghost.GlowEntCount > 0 ) then
		for i = 1, self.Ghost.GlowEntCount do
			entsToGlowCount = entsToGlowCount + 1
			entsToGlow[entsToGlowCount] = self.Ghost.GlowEnts[ i ]
		end
	end
	render.SetBlend(1)
	
	EntityHalos = entsToGlow
	
end

function GM:RemoveGhost()
	self.Ghost.Pos = false
	-- self.Ghost.Ang = false
	self.Ghost.Table = false
	self.Ghost.Rotating = false
	self.Ghost.TraceLine = false
	self.Ghost.NoDraw = true
	self:GhostResetUpgrade()
	-- self:ClearGhostWalls()
	self:ClearGhostNoDrawEnts()
	self:ClearGhostExtraEnts()
	self:ClearGhostGlowEnts()
	if(IsValid(self.Ghost.Ent)) then
		self.Ghost.Ent:Remove()
		self.Ghost.Ent = false
	end
end