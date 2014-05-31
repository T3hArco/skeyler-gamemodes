----------------------------------------
--    Sassilization
--    http://sassilization.com
--    By Sassafrass / Spacetech
----------------------------------------

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local Debug = {}
	Debug.BuildSpawn = false

function ENT:Setup(Name, OverrideModel, OverrideSpawn)
    local Building = building.GetBuilding(Name)
    if(not Building) then
        return
    end
    
    if(Building.Levels) then
        self:SetModel(Building.Model[self:GetLevel()])
    else
        self:SetModel(OverrideModel or Building.Model)
    end
	
	self:EmitSound( "sassilization/buildascend.wav" )
    
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInit( SOLID_VPHYSICS )
    --local ang = self:GetAngles()
    --self:PhysicsInitBox( self:OBBMins(), self:OBBMaxs() )
    --self:SetAngles( ang )
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    
    self:DrawShadow(false)
    
    local Phys = self:GetPhysicsObject()
    if(Phys:IsValid()) then
        Phys:EnableMotion(false)
    end

    self.Influence = Building.Influence
    
    if(Building.Levels) then
        self:SetCHealth(Building.Health[self:GetLevel()])
        self:SetMaxCHealth(self:GetHealth())
    else
        self:SetCHealth(Building.Health)
        self:SetMaxCHealth(Building.Health)
    end
  
    self.DestroyGold = Building.DestroyGold
    
    if(OverrideSpawn or game.SinglePlayer() and not Debug.BuildSpawn) then
        self:Built()
    elseif( Building.BuildTime ) then
        self:StartSpawn( Building.BuildTime )
    else
		self:Built()
	end
    
    if( not Building.Foundation ) then return end
	if( Phys:IsValid() ) then
        Phys:EnableCollisions(false)
	end
    
    --[[
    --DISABLING THE PHYSICS, THEY CRASH & are kinda useless
    if( building.CreateFoundation( self ) ) then
        local mins, maxs = self:OBBMins(), self:OBBMaxs()
        maxs.z = mins.z
        mins.z = mins.z - SA.FOUNDATION_HEIGHT
        
        local tblMergedMesh     = Phys:GetMesh()
        local tblFoundationMesh = SA.CreateConvexMeshBox(mins, maxs)
        local iPointCount       = #tblMergedMesh
        --PrintTable(tblFoundationMesh)
        
        for iIdx, tblPoint in pairs(tblFoundationMesh) do
            tblMergedMesh[iPointCount + iIdx] = tblPoint
            debugoverlay.Cross(Phys:LocalToWorld(tblPoint.pos), 1, 8, Color(100,0,255,255),true)
        end
        
        assert((#tblMergedMesh % 3) == 0)
        
        self:EnableCustomCollisions(false)
        self:PhysicsFromMesh( tblMergedMesh )
        self:EnableCustomCollisions( true )
        MsgN( "Created foundation physics" )
    end
    ]]
    
    local Phys = self:GetPhysicsObject()
    if(Phys:IsValid()) then
        Phys:EnableMotion(false)
        Phys:EnableCollisions(true)
    end
    
end

function ENT:SetCHealth(health)
	self.health = health
end

function ENT:GetHealth()
	return self.health
end

function ENT:Health()
	return self:GetHealth()
end

function ENT:SetMaxCHealth(maxHealth)
	self.maxHealth = maxHealth
end

function ENT:GetMaxCHealth()
	return self.maxHealth
end

function ENT:StartSpawn( duration )
	
	self.dt.bBuilt = false
	self.BuiltTime = CurTime() + duration
	
    local Effect = EffectData()
    Effect:SetEntity(self)
	Effect:SetMagnitude(duration)
    Effect:SetOrigin(self:GetPos())
    util.Effect("rivera", Effect, true, true)
	
    self:EmitSound("sassilization/buildsound0"..math.random(1, 3)..".wav")
	
end

function ENT:Materialize()
    local Effect = EffectData()
    Effect:SetEntity(self)
    util.Effect("materialize", Effect, true, true)
end

function ENT:Built()
	self.dt.bBuilt = true

    if( Nav ) then
        self.TerritoryInfo = {Nav:GetClosestNode(self:GetPos()), self:GetEmpire():GetID(), self.Influence}
        GAMEMODE:UpdateTerritories()
    end

	self:OnBuilt(self:GetEmpire())
end

function ENT:NearestAttackPoint( pos )
	return self:NearestPoint( pos )
end

function ENT:Upgrade()
    
    local NewLevel = self:GetLevel() + 1
    
    self:SetModel(building.GetBuildingKey(self:GetType(), "Model")[NewLevel])
    
    self:SetLevel( NewLevel )
    
    timer.Simple(0.01, function()
        if(IsValid(self)) then
            self:Materialize()
        end
    end)
    
end

function ENT:RandomYaw()
    return Angle(0, math.random(0, 360), 0)
end

function ENT:UpdateControl()
    for k,v in ipairs(ents.FindInSphere(self:GetPos(), 60)) do
        if(v:IsResource() or v:IsWall() or v:IsWallTower()) then
            v:UpdateControl()
        end
    end
end

function ENT:SetAlpha(Alpha)
    local c = self:GetColor()
	c.a = Alpha
    self:SetColor(c)
end

function ENT:SpawnUnits(Name, Amount)
    for i=1,Amount do
        local px = (i * 10) - (Amount * 0.5) * 10 - 10
        local py = math.Rand(-16, 16)
		
        local trace = {}
        trace.start = self:GetPos() + Vector(px, py, 20)
        trace.endpos = self:GetPos() + Vector(px, py, -100)
        trace.filter = self
		trace.mask = CHECK_MASK
		
        if self:GetClass() != "building_tower" then
            local tr = util.TraceLine(trace)
            if(tr.Hit and not tr.HitSky) then
                local CanFit, Pos, Ang = GAMEMODE:CanFit(tr, Vector(-3.25, -3.25, -3.25), Vector(3.25, 3.25, 3.25), Angle(0, 90, 0), true, false)
                if CanFit then
                    GAMEMODE:SpawnUnit(Name, tr.HitPos + (tr.HitNormal * 5), self:RandomYaw(), self:GetEmpire())
                end
            end
        else
            GAMEMODE:SpawnUnit(Name, self.UpPos, self:RandomYaw(), self:GetEmpire())
        end
    end
end

function ENT:SV_Think( time )
    if(self.Destroyed) then
        return
    end
    
    if(not self:IsBuilt()) then
		
        if self.BuiltTime then
            if( time >= self.BuiltTime ) then
                self.BuiltTime = nil
                self:Materialize()
    			self:Built()
            end
		end
    end
    
    if(not self.NextOnThink or self.NextOnThink <= time) then
        self.NextOnThink = time + (self:OnThink() or 0)
    end
    
    self:NextThink(time + 0.1)
    return true
end

util.AddNetworkString( "TempnNonRefund" )

function ENT:Damage( dmginfo )
	
    if(self.Destroyed) then
        return
    end
    
    self:SetCHealth(self:GetHealth() -dmginfo.damage)
    self:OnDamaged( dmginfo.damage, self:GetHealth(), dmginfo.attacker )
    if self:GetClass() != "walltower" or self:GetClass() != "wall" then
        self.DamageSell = true
        if self:GetEmpire() and self:GetEmpire():GetPlayer() then
            net.Start("TempnNonRefund")
                net.WriteEntity(self)
                net.WriteBit(true)
            net.Send(self:GetEmpire():GetPlayer())
        end
        if timer.Exists(tostring(self)) then
            timer.Destroy(tostring(Self))
        end
        timer.Create(tostring(self), 10, 1, function()
            if self:IsValid() then
                self.DamageSell = nil
                if self:GetEmpire() and self:GetEmpire():GetPlayer() then
                    net.Start("TempnNonRefund")
                        net.WriteEntity(self)
                        net.WriteBit(false)
                    net.Send(self:GetEmpire():GetPlayer())
                end
            end
        end)
    end
	
	if( dmginfo.dmgtype == DMG_SLASH ) then
		self:EmitSound( SA.Sounds.GetBuildingHitSound() )
	elseif( dmginfo.dmgtype == DMG_BULLET ) then
		self:EmitSound( SA.Sounds.GetArrowHitBuildingSound() )
	end
    
    if(self:GetHealth() <= 0) then
        self:Destroy(building.BUILDING_DESTROY, dmginfo.attacker:GetEmpire())
    else
        if(self:GetHealth() <= self:GetMaxCHealth() * 0.5) then
            if(not self.NextFire or self.NextFire < CurTime()) then
                local effect = EffectData()
					effect:SetEntity(self)
					effect:SetScale(1)
					effect:SetMagnitude(self:GetHealth())
                util.Effect("fire_trail", effect, true, true)
				
                self.NextFire = CurTime() +self:GetHealth()
            end
        end
    end
end

function ENT:SetLevel(Level)
    self.dt.iLevel = Level
    self:OnLevel(Level)
    return Level
end

function ENT:SetControl( Empire )

    if( self:GetEmpire() ) then
        self:RemoveControl()
    end

    self:SetColor( Empire:GetColor())
    self:SetEmpire( Empire )
    self:OnControl( Empire )

    if( self.TerritoryInfo ) then
        self.TerritoryInfo[2] = Empire:GetID()
        GAMEMODE:UpdateTerritories()
    end

end

function ENT:RemoveControl( bFromUpdate )

    if( self:GetEmpire() ) then
        self:OnRemoveControl( self:GetEmpire() )
    end

    self:SetColor(color_white)
    self:SetEmpire( nil )

    if( self.TerritoryInfo ) then
        self.TerritoryInfo[2] = -1
        GAMEMODE:UpdateTerritories()
    end

end

function ENT:WallUpdateControl()
    if(not self.Destroyed) then
        return
    end
    for k,v in ipairs(ents.FindInSphere(self:GetPos(), 40)) do
        if(v:IsBuilding() and v:IsBuilt() and not v.Destroyed and v:GetEmpire()) then
            if(v:GetEmpire() ~= self:GetEmpire()) then
                self:SetControl(v:GetEmpire())
            end
            return
        end
    end
    self:RemoveControl( true )
end

function ENT:Destroy( Info, AttackingEmpire )
    if(self.Destroyed) then
        return
    end
    if self:GetClass() == "building_gate" then
        if timer.Exists(tostring(self)) then
            timer.Destroy(tostring(self))
        end
        for k,v in pairs(self.HiddenWalls) do
            v.gate = nil
        end
        if(Info == building.BUILDING_DESTROY) then
            local vecPos = self:GetPos()
            local closest = nil
            for _, w in pairs(ents.FindByClass("building_wall")) do
                if w:GetEmpire() == self:GetEmpire() then
                    if closest == nil then
                        closest = w
                    end
                    if closest:GetPos():Distance(vecPos) > w:GetPos():Distance(vecPos) then
                        closest = w
                    end
                end
            end
            if closest != nil then
                closest:UnHideWalls(self.HiddenWalls)
                for i,d in pairs(self.HiddenWalls) do
                    closest:DestroyWallSegment( d )
                end
            end
        end
    elseif self:GetClass() == "building_city" then
        self:GetEmpire():DecrCity()
        self:GetEmpire():CalculateSupply()
    end
	self.dt.bDestroyed = true
    self.Destroyed = true
    
    local Empire = self:GetEmpire()
    
    if(self.DestroyGold and self:IsBuilt() and Info ~= building.BUILDING_SELL) then
        if( Empire ) then
            Empire:AddGold(-self.DestroyGold)
        end
        if( ValidEmpire(AttackingEmpire) ) then
            AttackingEmpire:AddGold(self.DestroyGold)
            --TODO: Fix bonus to empire not player
            --ply.Bonus = ply.Bonus + (self.DestroyBonus or 8)
        end
    end
    
    if(Info == building.BUILDING_DESTROY) then
        if !self.Plummeted then
            local effect = EffectData()
    			effect:SetEntity(self)
    			effect:SetOrigin(self:GetPos())
    			effect:SetRadius(self:OBBMaxs().z * 0.5)
    			effect:SetScale(10)
    			effect:SetMagnitude(self.Gib or GIB_ALL)
            util.Effect("gib_structure", effect, true, true)
        end

        if self.DestroyGold then
            if( Empire ) then
                Empire:AddGold(-self.DestroyGold)
            end
            if( ValidEmpire(AttackingEmpire) ) then
                AttackingEmpire:AddGold(self.DestroyGold)
                AttackingEmpire:AddGold(self.DestroyBonus or 8)
            end
        end
    elseif(Info == building.BUILDING_SELL or Info == building.BUILDING_DISCONNECTED) then
        local Effect = EffectData()
        Effect:SetEntity(self)
        util.Effect("dissolve", Effect, true, true)    
    end
    
    self:Extinguish()
    self:SetNoDraw(true)
	self:SetSolid( SOLID_NONE )
    
    if(self.Materialized and Info ~= building.BUILDING_UPGRADE) then
        self:EmitSound("sassilization/units/buildingbreak0"..math.random(1, 2)..".wav", 70)
    end
    
    self:UpdateControl()
    
    if(Info == building.BUILDING_DISCONNECTED) then
        if(self.Expansions) then
            for k,v in pairs(self.Expansions) do
                if(IsValid(v)) then
                    v:Destroy(Info, Attacker)
                end
            end
        end
    end
    
    self:OnDestroy(Info, Empire, Attacker)
    self:RemoveControl()

    if self:GetClass() == "building_gate" then
        if(Info == building.BUILDING_DESTROY) then
            for k,v in pairs(self.Connected) do
                if v:IsValid() then
                    v:Destroy(building.BUILDING_DESTROY)
                end
            end
        end
    end
    
    timer.Simple(0.5, function() SafeRemoveEntity(self) end)
end

------------------------------------------------------------

function ENT:OnBuilt(Controller)
end

function ENT:OnLevel(Level)
end

function ENT:OnThink()
end

function ENT:OnControl(Empire)
end

function ENT:OnRemoveControl(Empire)
end

function ENT:OnDamaged(Amount, Health, Attacker)
end

function ENT:OnDestroy(Info, Empire, Attacker)
end

function ENT:Expand(Dir)
    if(not IsValid(self) or self.Destroyed) then
        return
    end
    
    local Empire = self:GetEmpire()
    if(not Empire) then
        return
    end
    
    if(self.CParent and not IsValid(self.CParent)) then
        return
    end
    
    local Trace = {}
    local Forward = Dir:Forward() * math.random(24, 48)
    local VECTOR_EXPAND_UP = Vector(0, 0, 50)
    Trace.start = self:GetPos() + VECTOR_EXPAND_UP --self:OBBCenter()
    Trace.endpos = Trace.start + (self:GetRight() * Forward.x) + (self:GetForward() * Forward.y) + (self:GetUp() * 30)
    Trace.filter = self
    Trace.mask = CHECK_MASK
    
    local tr = util.TraceLine(Trace)
    if(tr.Hit) then
        return
    end
    
    Trace.start = tr.HitPos
    Trace.endpos = tr.HitPos - (Dir:Up() * 164)
    
    local tr = util.TraceLine(Trace)
    
    if(GAMEMODE:PosInWater(tr.HitPos)) then
        return
    end
    
    if(tr.HitNormal:Angle().p > 300 or tr.HitNormal:Angle().p < 240) then
        return
    end
    
    -- for k,v in pairs(ents.FindInSphere(tr.HitPos, 15)) do
        -- if(v:IsBuilding() or v:IsUnit()) then
            -- return
        -- end
    -- end
    
    local Ang = Angle( 0, math.random()*360, 0 )
    
    local houseID = math.random(1, 3)
    
    local CanFit, Pos, Ang = GAMEMODE:CanFit(tr, building.HouseData[houseID].OBBMins, building.HouseData[houseID].OBBMaxs, Ang, true, true)
    
    if(not CanFit) then
        return
    end
    
    local HouseParent = self.CParent

    if (IsValid(HouseParent)) then
        if (HouseParent:GetPos():Distance(Pos) > SA.CITY_DISTANCE) then
            return
        end
    else
        HouseParent = self
    end

    Trace.start = self:GetPos()
    Trace.endpos = Pos
    Trace.filter = self
    Trace.mask = CHECK_MASK
    
    local tr = util.TraceLine(Trace)
    if tr.HitWorld and tr.HitNormal.z == 0 then return end
    
    for _, ent in ipairs( ents.FindInSphere( Pos, SA.MIN_HOUSE_DISTANCE ) ) do
        if( ent:IsBuilding() ) then
            return
        end
    end

    for _, ent in ipairs( ents.FindInSphere( Pos, 12 ) ) do
        if( ent:GetClass() == "iron_mine" or ent:GetClass() == "farm" ) then
            return
        end
    end

    if self:GetPos().z - Pos.z > 30 then return end -- This keeps buildings from spawning on top of ledges/down a cliff away from the rest of the city
    if Pos.z - self:GetPos().z > 30 then return end
  
    local House = ents.Create("building_house")
    House.HouseID = houseID
    House:SetControl(Empire)
    House:SetPos(Pos)
    House:SetAngles(Ang)
    House:Spawn()
    House:Activate()
    House.CachedType = Name
    House:InitHouse(HouseParent)
    
    table.insert(self.Expansions, House)

    HouseParent.Influence = math.max( 0, HouseParent.Influence - 16.875 )
    GAMEMODE:UpdateTerritories()
end